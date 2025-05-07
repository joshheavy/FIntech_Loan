import 'dart:convert';

import 'package:fintech_loan/models/customer.dart';
import 'package:fintech_loan/models/loan.dart';
import 'package:fintech_loan/models/loan_scedule.dart';
import 'package:fintech_loan/models/payment.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LocalStorageService {
  static const String _customerKey = 'customers';
  static const String _loanKey = 'loans';
  static const String _paymentKey = 'payments';
  static const String _loanScheduleKey = 'loanSchedule';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<List<Customer>> getCustomers() async {
    final String? jsonString = _prefs.getString(_customerKey);
    if(jsonString == null) return [];
    final json = jsonDecode(jsonString) as List<dynamic>;
    return json.map((e) => Customer.fromJson(e as Map<String, dynamic>)).toList(); 
  }

  static Future<void> saveCustomers(List<Customer> customers) async {
    final json = customers.map((e) => e.toJson()).toList();
    _prefs.setString(_customerKey, jsonEncode(json));
  }

  static Future<List<Loan>> getLoans() async {
    final String? jsonString = _prefs.getString(_loanKey);
    if(jsonString == null) return [];
    final json = jsonDecode(jsonString) as List<dynamic>;
    return json.map((e) => Loan.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> saveLoans(List<Loan> loans) async {
    final json = loans.map((e) => e.toJson()).toList();
    _prefs.setString(_loanKey, jsonEncode(json));
  }

  static Future<List<Payment>> getPayments() async {
    final String? jsonString = _prefs.getString(_paymentKey);
    if(jsonString == null) return [];
    final json = jsonDecode(jsonString) as List<dynamic>;
    return json.map((e) => Payment.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> savePayments(List<Payment> payments)async {
    final json = payments.map((e) => e.toJson()).toList();
    _prefs.setString(_paymentKey, jsonEncode(json));
  }

  static Future<List<LoanSchedule>> getLoanSchedule() async {
    final String? jsonString = _prefs.getString(_loanScheduleKey);
    if(jsonString == null) return [];
    final json = jsonDecode(jsonString) as List<dynamic>;
    return json.map((e) => LoanSchedule.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> saveLoanSchedule(List<LoanSchedule> loanSchedule) async {
    final json = loanSchedule.map((e) => e.toJson()).toList();
    _prefs.setString(_loanScheduleKey, jsonEncode(json));
  }
}
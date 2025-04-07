import 'package:fintech_loan/screens/customers/add_customer_screen.dart';
import 'package:fintech_loan/screens/customers/customer_list_screen.dart';
import 'package:fintech_loan/screens/loans/add_loan_screen.dart';
import 'package:fintech_loan/screens/loans/loan_list_screen.dart';
import 'package:fintech_loan/screens/payments/add_payment_screen.dart';
import 'package:fintech_loan/screens/payments/payment_list_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fintech Loan System',
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        primarySwatch: Colors.blue,
      ),
      home: CustomerListScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/customers': (context) => CustomerListScreen(),
        '/addCustomer': (context) => AddCustomerScreen(),
        '/loans': (context) => LoanListScreen(),
        '/addLoan': (context) => AddLoanScreen(),
        '/payments': (context) => PaymentListScreen(),
        '/addPayment': (context) => AddPaymentScreen(),
      }
    );
  }
}
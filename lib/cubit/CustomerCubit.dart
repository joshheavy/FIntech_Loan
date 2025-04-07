import 'package:fintech_loan/models/customer.dart';
import 'package:fintech_loan/services/localStorage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';

class CustomerCubit extends Cubit<List<Customer>> {
  CustomerCubit():super([]);

  void loadCustomer() async {
    final data = await LocalStorageService().getData("customers");
    if(data != null) {
      final customers = (json.decode(data) as List)
          .map((e) => Customer.fromJson(e))
          .toList();
      emit(customers);
    }
  }

  void addCustomer(Customer customer) async {
    final updatedCustomer = [...state, customer];
    await LocalStorageService().saveData("customers", json.encode(updatedCustomer));
    emit(updatedCustomer);
  }
}
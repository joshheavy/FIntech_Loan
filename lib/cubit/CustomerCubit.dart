// import 'package:fintech_loan/cubit/CustomerState.dart';
// import 'package:fintech_loan/models/customer.dart';
// import 'package:fintech_loan/services/localStorage_service.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// class CustomerCubit extends Cubit<CustomerState> {
//   CustomerCubit() : super(CustomerInitial());
  
//   Future<void> loadCustomers() async {
//     try {
//       // Simulate loading from storage
//       emit(CustomerLoading());
//       final customers = await LocalStorageService.getCustomers();
//       emit(CustomerLoaded(allCustomers: customers, filteredCustomers: customers));
//     } catch (e) {
//       emit(CustomerError(message: 'Failed to load customers: $e'));
//     }
//   }
  
//   Future<void> addCustomer(Customer customer) async{
//     try {
//       emit(CustomerLoading());
//       final customers = await LocalStorageService.getCustomers();
//       // Add the new customer to the list
//       final updatedCustomers = [...customers, customer];
//       print('Customer JSON: ${customer.toJson()}');
//       await LocalStorageService.saveCustomers(updatedCustomers);
//       emit(CustomerLoaded(allCustomers: updatedCustomers, filteredCustomers: updatedCustomers));
//     } catch (e){
//       emit(CustomerError(message: 'Failed to add customer: $e'));
//     }
//   }
  
//   void updateCustomer(Customer customer) async {
//     try {
//       emit(CustomerLoading());
//       final customers = await LocalStorageService.getCustomers();
//       // Replace the existing customer with the updated one based on ID
//       final updatedCustomers = customers.map((c) {
//         return c.id == customer.id ? customer : c;
//       }).toList();
//       await LocalStorageService.saveCustomers(updatedCustomers);
//       emit(CustomerLoaded(allCustomers: updatedCustomers, filteredCustomers: updatedCustomers));
//     } catch (e) {
//       emit(CustomerError(message: 'Failed to update customer: $e'));
//     }
//   }

//   Future<void> deleteCustomer(String customerId) async{
//     try {
//       emit(CustomerLoading());
//       final customers = await LocalStorageService.getCustomers();
//       final updatedCustomers = customers.where((customer) => customer.id != customerId).toList();
//       await LocalStorageService.saveCustomers(customers);
//       emit(CustomerLoaded(allCustomers: updatedCustomers, filteredCustomers: updatedCustomers));
//     } catch(e) {
//       emit(CustomerError(message: 'Failed to delete customer: $e'));
//     }
//   }
  
//   Future<void> searchCustomers(String query) async{
//     try {
//       emit(CustomerLoading());
//       final customers = await LocalStorageService.getCustomers();
//       final filteredCustomers = customers.where((customer) => 
//         customer.fullName.toLowerCase().contains(query.toLowerCase()) ||
//         customer.email.toLowerCase().contains(query.toLowerCase())
//       ).toList();
//       emit(CustomerLoaded(allCustomers: customers, filteredCustomers: filteredCustomers));
//     } catch (e) {
//       emit(CustomerError(message: 'Failed to search customers: $e'));
//     }
//   }

//   Future<void> showAllCustomers() async {
//     try {
//       emit(CustomerLoading());
//       final customers = await LocalStorageService.getCustomers();
//       emit(CustomerLoaded(allCustomers: customers, filteredCustomers: customers));
//     } catch (e) {
//       emit(CustomerError(message: 'Failed to show all customers: $e'));
//     }
//   }
// }
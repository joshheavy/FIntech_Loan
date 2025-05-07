// import 'dart:async';
// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:meta/meta.dart';
// import '../models/customer.dart';
//
// part 'customer_event.dart';
// part 'customer_state.dart';
//
// class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
//   CustomerBloc() : super(CustomerInitial()) {
//     on<LoadCustomers>(_onLoadCustomers);
//     on<AddCustomer>(_onAddCustomer);
//     on<UpdateCustomer>(_onUpdateCustomer);
//     on<DeleteCustomer>(_onDeleteCustomer);
//     on<SearchCustomers>(_onSearchCustomers);
//   }
//
//   final List<Customer> _customers = [];
//
//   Future<void> _onLoadCustomers(
//       LoadCustomers event,
//       Emitter<CustomerState> emit,
//       ) async {
//     emit(CustomerLoading());
//     try {
//       // Simulate loading from storage
//       await Future.delayed(Duration(milliseconds: 500));
//       _customers.addAll([
//         Customer(
//           id: '1',
//           fullName: 'John Doe',
//           email: 'john@example.com',
//           phone: '1234567890',
//           dateOfRegistration: DateTime.now(),
//           customerType: 'Individual',
//           avatarColor: Colors.blue.value,
//         ),
//         Customer(
//           id: '2',
//           fullName: 'Jane Smith',
//           email: 'jane@example.com',
//           phone: '0987654321',
//           dateOfRegistration: DateTime.now(),
//           customerType: 'Corporate',
//           avatarColor: Colors.pink.value,
//         ),
//       ]);
//       emit(CustomerLoaded(_customers));
//     } catch (e) {
//       emit(CustomerError(e.toString()));
//     }
//   }
//
//   void _onAddCustomer(AddCustomer event, Emitter<CustomerState> emit) {
//     _customers.add(event.customer);
//     emit(CustomerLoaded(List.from(_customers)));
//   }
//
//   void _onUpdateCustomer(UpdateCustomer event, Emitter<CustomerState> emit) {
//     final index = _customers.indexWhere((c) => c.id == event.customer.id);
//     if (index >= 0) {
//       _customers[index] = event.customer;
//       emit(CustomerLoaded(List.from(_customers)));
//     }
//   }
//
//   void _onDeleteCustomer(DeleteCustomer event, Emitter<CustomerState> emit) {
//     _customers.removeWhere((c) => c.id == event.customerId);
//     emit(CustomerLoaded(List.from(_customers)));
//   }
//
//   void _onSearchCustomers(SearchCustomers event, Emitter<CustomerState> emit) {
//     if (event.query.isEmpty) {
//       emit(CustomerLoaded(_customers));
//     } else {
//       final filtered = _customers
//           .where((c) => c.fullName.toLowerCase().contains(event.query.toLowerCase()))
//           .toList();
//       emit(CustomerLoaded(filtered));
//     }
//   }
// }
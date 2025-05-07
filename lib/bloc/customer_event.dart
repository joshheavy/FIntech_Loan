// import 'package:equatable/equatable.dart';
// import 'package:fintech_loan/models/customer.dart';
//
// part 'customer_bloc.dart';
//
// @immutable
// abstract class CustomerEvent extends Equatable {
//   @override
//   List<Object?> get props => [];
// }
//
// class LoadCustomer extends CustomerEvent {}
//
// class AddCustomer extends CustomerEvent {
//   final Customer customer;
//   AddCustomer(this.customer);
//
//   @override
//   List<Object?> get props => [customer];
// }
//
// class UpdateCustomer extends CustomerEvent {
//   final Customer customer;
//   UpdateCustomer(this.customer);
//
//   @override
//   List<Object?> get props => [customer];
// }
//
// class DeleteCustomer extends CustomerEvent {
//   final String customerId;
//   DeleteCustomer(this.customerId);
//
//   @override
//   List<Object?> get props => [customerId];
// }
//
// class SearchCustomers extends CustomerEvent {
//   final String query;
//   SearchCustomers(this.query);
//
//   @override
//   List<Object?> get props => [query];
// }
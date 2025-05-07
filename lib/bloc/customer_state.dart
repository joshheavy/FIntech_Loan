// part of 'customer_bloc.dart';
//
// @immutable
// abstract class CustomerState extends Equatable {
//   @override
//   List<Object?> get props => [];
// }
//
// class CustomerInitial extends CustomerState {}
//
// class CustomerLoading extends CustomerState {}
//
// class CustomerLoaded extends CustomerState {
//   final List<Customer> customers;
//   CustomerLoaded(this.customers);
//
//   @override
//   List<Object?> get props => [customers];
// }
//
// class CustomerError extends CustomerState {
//   final String message;
//   CustomerError(this.message);
//
//   @override
//   List<Object?> get props => [message];
// }
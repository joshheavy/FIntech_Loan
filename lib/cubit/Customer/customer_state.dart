import 'package:equatable/equatable.dart';
import 'package:fintech_loan/models/customer.dart';

abstract class CustomerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<Customer> allCustomers;
  late final List<Customer> filteredCustomers;
  final bool hasMore;

  CustomerLoaded({
    required this.allCustomers,
    required this.filteredCustomers,
    this.hasMore = false,
  });
  // Optional: Add a copyWith method for convenience
  CustomerLoaded copyWith({
    List<Customer>? allCustomers,
    List<Customer>? filteredCustomers,
    bool? hasMore,
  }) {
    return CustomerLoaded(
      allCustomers: allCustomers ?? this.allCustomers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      hasMore: hasMore = false,
    );
  }
  @override
  List<Object?> get props => [allCustomers, filteredCustomers, hasMore];
}

class CustomerError extends CustomerState {
  final String message;
  CustomerError({required this.message});

  @override
  List<Object?> get props => [message];
}
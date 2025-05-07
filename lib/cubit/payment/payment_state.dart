import 'package:equatable/equatable.dart';
import 'package:fintech_loan/models/payment.dart';

abstract class PaymentState extends Equatable{
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}
class PaymentLoading extends PaymentState{
  PaymentLoading();
}

class PaymentLoaded extends PaymentState {
  final List<Payment> payments;
  late final List<Payment> filteredPayments;

  PaymentLoaded({
    required this.payments,
    required this.filteredPayments,
  });

  PaymentLoaded copyWith({
    List<Payment>? payment,
    List<Payment>? filteredPayment,
  }) {
    return PaymentLoaded(
      payments: payment ?? this.payments,
      filteredPayments: filteredPayment ?? this.filteredPayments,
    );
  }
  @override  
  List<Object?> get props => [payments, filteredPayments];
}

class PaymentError extends PaymentState {
  final String message;
  PaymentError({required this.message});

  @override 
  List<Object?> get props => [message];
}


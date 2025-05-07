import 'package:fintech_loan/cubit/payment/payment_state.dart';
import 'package:fintech_loan/models/payment.dart';
import 'package:fintech_loan/services/localStorage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(PaymentInitial());

  Future<void> loadPayment() async {
    try {
      emit(PaymentLoading());
      final payments = await LocalStorageService.getPayments();
      emit(PaymentLoaded(payments: payments, filteredPayments: payments));
    } catch (e) {
      emit(PaymentError(message: 'Failed to load payments: $e'));
    }
  }

  Future<void> addPayment(Payment payment) async {
    try {
      emit(PaymentLoading());
      final payments = await LocalStorageService.getPayments();
      final updatedPayments = [...payments, payment];
      await LocalStorageService.savePayments(updatedPayments);
      emit(PaymentLoaded(payments: updatedPayments, filteredPayments: updatedPayments));
    } catch (e) {
      emit(PaymentError(message: 'Failed to add payment: $e'));
    }
  }

  Future<List<Payment>> loadPaymentsForLoan(String loanId) async {
    final payments = await LocalStorageService.getPayments();
    return payments.where((payment) => payment.loanId == loanId).toList();
  }
}
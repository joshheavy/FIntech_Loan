import 'package:fintech_loan/cubit/Customer/customer_cubit.dart';
import 'package:fintech_loan/cubit/Customer/customer_state.dart';
import 'package:fintech_loan/cubit/loan/loan_cubit.dart';
import 'package:fintech_loan/cubit/loan/loan_state.dart';
import 'package:fintech_loan/cubit/payment/payment_cubit.dart';
import 'package:fintech_loan/cubit/payment/payment_state.dart';
import 'package:fintech_loan/models/customer.dart';
import 'package:fintech_loan/models/loan.dart';
import 'package:fintech_loan/models/payment.dart';
import 'package:fintech_loan/widgets/wave_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class PaymentListScreen extends StatelessWidget {
  const PaymentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Gradient Header with Wave Design
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[900]!, Colors.blue[400]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: CustomPaint(
                  painter: WavePainter(),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Payments',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Track your payment history',
                          style: TextStyle(color: Colors.white70, fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Payment List
          SliverToBoxAdapter(
            child: RefreshIndicator(
              onRefresh: () => context.read<PaymentCubit>().loadPayment(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: BlocBuilder<PaymentCubit, PaymentState>(
                  builder: (context, paymentState) {
                    if (paymentState is PaymentLoading) {
                      return const SizedBox(
                        height: 400,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (paymentState is PaymentError) {
                      return SizedBox(
                        height: 400,
                        child: Center(child: Text(paymentState.message)),
                      );
                    } else if (paymentState is PaymentLoaded) {
                      if (paymentState.payments.isEmpty) {
                        return _buildEmptyState(context);
                      }
                      return BlocBuilder<CustomerCubit, CustomerState>(
                        builder: (context, customerState) {
                          return BlocBuilder<LoanCubit, LoanState>(
                            builder: (context, loanState) {
                              return _buildPaymentList(
                                context,
                                paymentState.payments,
                                customerState is CustomerLoaded ? customerState.allCustomers : [],
                                loanState is LoanLoaded ? loanState.loan : [],
                              );
                            },
                          );
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_outlined, size: 80, color: Colors.blue[200]),
            const SizedBox(height: 16),
            Text(
              'No Payments Yet',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.blue[800], fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Payments will appear here once made.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentList(
    BuildContext context,
    List<Payment> payments,
    List<Customer> customers,
    List<Loan> loans,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        // Find the customer and loan associated with the payment
        final customer = customers.firstWhere(
          (c) => c.id == payment.customerId,
          orElse: () => Customer(
            id: '',
            fullName: 'Unknown',
            email: '',
            phone: '',
            dateOfRegistration: DateTime.now(),
            customerType: '',
            avatarColor: Colors.grey,
          ),
        );
        final loan = loans.firstWhere(
          (l) => l.id == payment.loanId,
          orElse: () => Loan(
            id: '',
            customerId: '',
            loanType: 'Unknown',
            loanAmount: 0,
            interestRate: 0,
            durationMonths: 0,
          ),
        );
        return _buildPaymentCard(context, payment, customer, loan);
      },
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    Payment payment,
    Customer customer,
    Loan loan,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icon based on payment method
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                payment.paymentMethod == 'Card'
                    ? Icons.credit_card
                    : Icons.phone_android,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(width: 16),
            // Payment Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Amount: \$${payment.amountPaid.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue[900],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: payment.paymentMethod == 'Card'
                              ? Colors.green[100]
                              : Colors.orange[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          payment.paymentMethod,
                          style: TextStyle(
                            color: payment.paymentMethod == 'Card'
                                ? Colors.green[800]
                                : Colors.orange[800],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${DateFormat('MMM dd, yyyy').format(payment.paymentDate)}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Loan: ${loan.loanType} (#${payment.loanId.substring(0, 8)}...)',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Customer: ${customer.fullName}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Installment: #${payment.installmentNumber}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:fintech_loan/cubit/Customer/customer_cubit.dart';
import 'package:fintech_loan/cubit/Customer/customer_state.dart';
import 'package:fintech_loan/cubit/loan/loan_cubit.dart';
import 'package:fintech_loan/cubit/loan/loan_state.dart';
import 'package:fintech_loan/models/customer.dart';
import 'package:fintech_loan/models/loan.dart';
import 'package:fintech_loan/screens/loans/loan_schedule_screen.dart';
import 'package:fintech_loan/screens/loans/add_loan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoanListScreen extends StatelessWidget {
  final String? customerId; // Optional customerId to filter loans

  const LoanListScreen({super.key, this.customerId});

  @override
  Widget build(BuildContext context) {
    // Load loans when the screen is built
    context.read<LoanCubit>().loadLoans();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.blue[800],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[800]!, Colors.lightBlue[400]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Your Loan${customerId != null ? 's for Customer' : ''}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 35),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Manage your finances with ease',
                        style: TextStyle(color: Colors.white70, fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            shape: const ContinuousRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
          ),
          SliverToBoxAdapter(
            child: RefreshIndicator(
              onRefresh: () async {
                final cubit = context.read<LoanCubit>();
                await cubit.loadLoans();
              },
              child: BlocBuilder<LoanCubit, LoanState>(
                builder: (context, state) {
                  if (state is LoanLoading) {
                    return SizedBox(
                      height: 400,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is LoanError) {
                    return SizedBox(
                      height: 400,
                      child: Text(state.message),
                    );
                  } else if (state is LoanLoaded) {
                    // Filter loans based on customerId if provided
                    final loans = customerId != null
                        ? state.loan.where((loan) => loan.customerId == customerId).toList()
                        : state.loan;
                    if (loans.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: loans.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final loan = loans[index];
                          return _buildLoanCard(context, loan);
                        },
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange[800],
        shape: const CircleBorder(),
        onPressed: () {
          // Use Future.microtask to defer the dialog display
          Future.microtask(() {
            _showCustomerSelectionDialog(context);
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCustomerSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Customer'),
        content: BlocBuilder<CustomerCubit, CustomerState>(
          builder: (context, state) {
            if (state is CustomerLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CustomerError) {
              return Text(state.message);
            } else if (state is CustomerLoaded) {
              if (state.allCustomers.isEmpty) {
                return const Text('No customers available. Please add a customer first.');
              }
              return SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: state.allCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = state.allCustomers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: customer.avatarColor,
                        child: Text(
                          customer.fullName.isNotEmpty ? customer.fullName[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(customer.fullName),
                      subtitle: Text(customer.email),
                      onTap: () {
                        Navigator.pop(dialogContext); // Close the dialog
                        // Use Future.microtask to defer navigation to AddLoanScreen
                        Future.microtask(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddLoanScreen(customer: customer),
                            ),
                          ).then((_) {
                            // Reload loans after adding a new loan
                            context.read<LoanCubit>().loadLoans();
                          });
                        });
                      },
                    );
                  },
                ),
              );
            }
            return const SizedBox();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
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
            Icon(Icons.account_balance_wallet_outlined,
                size: 80, color: Colors.orange[300]),
            const SizedBox(height: 16),
            Text(
              'No Loans Yet',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.orange[800], fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a loan to get started!',
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

  Widget _buildLoanCard(BuildContext context, Loan loan) {
    return GestureDetector(
      onTap: () {
        // Use Future.microtask to defer navigation to LoanScheduleScreen
        Future.microtask(() {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LoanScheduleScreen(loanId: loan.id)),
          );
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance, color: Colors.orange),
              ),
              const SizedBox(height: 12),
              Text(
                'Loan #${loan.id.substring(0, 8)}...',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Customer: ${loan.customerId}',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Type: ${loan.loanType}',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${loan.loanAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.orange[800],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${loan.durationMonths} mo',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => context.read<LoanCubit>().deleteLoan(loan.id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
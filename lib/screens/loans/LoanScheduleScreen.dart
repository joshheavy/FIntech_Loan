import 'package:fintech_loan/screens/payments/add_payment_screen.dart';
import 'package:flutter/material.dart';

class LoanScheduleScreen extends StatelessWidget {
  const LoanScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Repayment Schedule'),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Installment ${index + 1}'),
            subtitle: Text('Due Date: 2023-12-01, Amount: \$${(index + 1) * 100}, Status: Pending'),
            trailing: IconButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPaymentScreen())
                );
              }, 
              icon: const Icon(Icons.payment),
            ),
          );
        }
      ) 
    );
  }
}
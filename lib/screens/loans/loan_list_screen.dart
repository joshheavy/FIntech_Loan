import 'package:fintech_loan/screens/loans/add_loan_screen.dart';
import 'package:flutter/material.dart';

class LoanListScreen extends StatelessWidget {
  const LoanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans'),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Loan $index'),
            subtitle: Text('Amount: \$${index * 100}'),
            trailing: IconButton(
              onPressed: () {}, 
              icon: Icon(Icons.delete)
            ),
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => AddLoanScreen())
          );
        }
      ),
    );
  }
}
import 'package:fintech_loan/screens/payments/add_payment_screen.dart';
import 'package:flutter/material.dart';

class PaymentListScreen extends StatelessWidget {
  const PaymentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payments'),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index){
          return ListTile(
            title: Text('Payment $index'), 
            subtitle: Text('Amount: \$100'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {}
            ),
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => AddPaymentScreen())
          );
        }, 
        child: Icon(Icons.add),
      ),
    );
  }
}
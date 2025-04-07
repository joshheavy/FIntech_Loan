import 'package:fintech_loan/screens/customers/add_customer_screen.dart';
import 'package:flutter/material.dart';

class CustomerListScreen extends StatelessWidget{
  const CustomerListScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customers'),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Customer $index'),
            subtitle: Text('Email: customer $index@gmail.com'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.edit), onPressed: () {}),
                IconButton(icon: Icon(Icons.delete), onPressed: () {})
              ],
            ),
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => AddCustomerScreen())
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
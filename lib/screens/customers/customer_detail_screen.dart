import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fintech_loan/models/customer.dart';
import 'package:fintech_loan/screens/customers/add_edit_customer_screen.dart';
import 'package:fintech_loan/screens/loans/add_loan_screen.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final Customer customer;
  const CustomerDetailsScreen({required this.customer, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(customer.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditCustomerScreen(customer: customer),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: 'avatar-${customer.id}',
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: customer.profileImage != null
                      ? MemoryImage(base64Decode(customer.profileImage!))
                      : null,
                  backgroundColor: customer.avatarColor,
                  child: customer.profileImage == null
                      ? Text(
                          customer.fullName.isNotEmpty ? customer.fullName[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white, fontSize: 40),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Full Name: ${customer.fullName}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Email: ${customer.email}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Phone: ${customer.phone}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Type: ${customer.customerType}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Status: ${customer.status}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Registered: ${customer.dateOfRegistration.toString().split(' ')[0]}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            if (customer.address != null) ...[
              Text('Address: ${customer.address}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
            ],
            if (customer.notes != null) ...[
              Text('Notes: ${customer.notes}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddLoanScreen(customer: customer),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Create Loan'),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class AddLoanScreen extends StatelessWidget {
  AddLoanScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _loanTypeController = TextEditingController();
  final _loanAmountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _durationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply for Loan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), 
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField(
                items: ['Customer 1', 'Customer 2'].map((String value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(), 
                onChanged: (value) {},
                decoration: InputDecoration(labelText: 'Customer'),
              ), 
              TextFormField(
                controller: _loanTypeController,
                decoration: InputDecoration(labelText: "Loan Type"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter loan type';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _loanAmountController,
                decoration: InputDecoration(labelText: "Loan Amount"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter loan amount';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _interestRateController,
                decoration: InputDecoration(labelText: "Interest Rate"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter interest rate';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(labelText: 'Duration (Months)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter duration';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: (){
                  if (_formKey.currentState!.validate()) {
                    // Save loan to LocalStorage
                    Navigator.pop(context);
                  }
                }, 
                child: const Text('Apply')
              ),
            ]
          ),
        ),
      ),
    );
  }
}
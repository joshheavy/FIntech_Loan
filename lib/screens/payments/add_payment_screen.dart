import 'package:flutter/material.dart';

class AddPaymentScreen extends StatelessWidget {
  AddPaymentScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _amountPaidController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField(
                items: ['Loan 1', 'Loan 2'].map((String value){
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(), 
                onChanged: (value) {}, 
                decoration: InputDecoration(labelText: "Select Loan"),
              ),
              DropdownButtonFormField(
                items: ['Installment 1', 'Installment 2'].map((String value){
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(), 
                onChanged: (value) {}, 
                decoration: InputDecoration(labelText: "Select Installment"),
              ),
              TextFormField(
                controller: _amountPaidController,
                decoration: InputDecoration(labelText: "Amount Paid"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the amount paid';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20), 
              ElevatedButton(
                onPressed: (){
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context);
                  }
                }, 
                child: Text('Save Payment'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
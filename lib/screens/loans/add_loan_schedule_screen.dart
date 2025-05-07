import 'package:fintech_loan/cubit/LoanSchedule/loan_schedule_cubit.dart';
import 'package:fintech_loan/models/loan_scedule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddLoanScheduleScreen extends StatefulWidget {

  final String loanId;
  const AddLoanScheduleScreen({super.key, required this.loanId});

  @override
  State<AddLoanScheduleScreen> createState() => _AddLoanScheduleScreenState();
}

class _AddLoanScheduleScreenState extends State<AddLoanScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _installmentNumberController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _dueDate;

  @override 
  void dispose() {
    _installmentNumberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2110),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _dueDate != null) {
      final newSchedule = LoanSchedule(
        loanId: widget.loanId, 
        installmentNumber: int.parse(_installmentNumberController.text), 
        dueDate: _dueDate!, 
        amount: double.parse(_amountController.text), 
        status: 'Pending',
      );
      context.read<LoanScheduleCubit>().addSchedule(newSchedule);
      Navigator.pop(context);
    } else if(_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a due date')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Loan Schedule'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _installmentNumberController,
                decoration: const InputDecoration(
                  labelText: 'Installment Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number, 
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an installment number';
                  }
                  if(int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16), 
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$'
                ),
                keyboardType: TextInputType.number, 
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if(int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid positive amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _dueDate == null ? 'Select a date' : _dueDate!.toString().substring(0, 10),
                    style: TextStyle(fontSize: 16, color: _dueDate == null ? Colors.grey : Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 24), 
              Center(
                child: ElevatedButton(
                  onPressed: _submit, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700], 
                    foregroundColor: Colors.white, 
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    )
                  ),
                  child: const Text('Save Schedule'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
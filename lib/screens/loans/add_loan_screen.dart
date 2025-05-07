import 'package:fintech_loan/cubit/Customer/customer_cubit.dart';
import 'package:fintech_loan/models/customer.dart';
import 'package:fintech_loan/models/loan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class AddLoanScreen extends StatefulWidget {
  final Customer customer;

  const AddLoanScreen({super.key, required this.customer});

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loanAmountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _durationController = TextEditingController();
  String _loanType = 'Personal';

  @override
  void dispose() {
    _loanAmountController.dispose();
    _interestRateController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final loan = Loan(
        id: const Uuid().v4(),
        customerId: widget.customer.id,
        loanType: _loanType,
        loanAmount: double.parse(_loanAmountController.text),
        interestRate: double.parse(_interestRateController.text),
        durationMonths: int.parse(_durationController.text),
      );
      context.read<CustomerCubit>().createLoanForCustomer(widget.customer, loan);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Loan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Create Loan for ${widget.customer.fullName}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _loanType,
                decoration: const InputDecoration(labelText: 'Loan Type'),
                items: ['Personal', 'Business', 'Education'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => _loanType = value!),
              ),
              TextFormField(
                controller: _loanAmountController,
                decoration: const InputDecoration(labelText: 'Loan Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter loan amount';
                  if (double.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              TextFormField(
                controller: _interestRateController,
                decoration: const InputDecoration(labelText: 'Interest Rate (%)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter interest rate';
                  if (double.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Duration (Months)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter duration';
                  if (int.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Loan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// import 'package:fintech_loan/cubit/loan/loan_cubit.dart';
// import 'package:fintech_loan/models/loan.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:uuid/uuid.dart'; // Add uuid package for unique IDs

// class AddLoanScreen extends StatefulWidget {
//   const AddLoanScreen({super.key});

//   @override
//   _AddLoanScreenState createState() => _AddLoanScreenState();
// }

// class _AddLoanScreenState extends State<AddLoanScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _customerIdController = TextEditingController();
//   final _loanTypeController = TextEditingController();
//   final _loanAmountController = TextEditingController();
//   final _interestRateController = TextEditingController();
//   final _durationController = TextEditingController();

//   @override
//   void dispose() {
//     _customerIdController.dispose();
//     _loanTypeController.dispose();
//     _loanAmountController.dispose();
//     _interestRateController.dispose();
//     _durationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.blue[700]!, Colors.lightBlue[200]!],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: ListView(
//                 children: [
//                   const Text(
//                     'Apply for a Loan',
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 20),
//                   _buildTextField(_customerIdController, 'Customer ID', Icons.person),
//                   _buildTextField(_loanTypeController, 'Loan Type', Icons.category),
//                   _buildTextField(_loanAmountController, 'Loan Amount', Icons.attach_money,
//                       keyboardType: TextInputType.number),
//                   _buildTextField(_interestRateController, 'Interest Rate (%)', Icons.percent,
//                       keyboardType: TextInputType.number),
//                   _buildTextField(_durationController, 'Duration (Months)', Icons.calendar_today,
//                       keyboardType: TextInputType.number),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: Colors.blue[700],
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       elevation: 4,
//                     ),
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         final loan = Loan(
//                           id: const Uuid().v4(), // Generate unique ID
//                           customerId: _customerIdController.text,
//                           loanType: _loanTypeController.text,
//                           loanAmount: double.parse(_loanAmountController.text),
//                           interestRate: double.parse(_interestRateController.text),
//                           durationMonths: int.parse(_durationController.text),
//                         );
//                         context.read<LoanCubit>().addLoan(loan);
//                         Navigator.pop(context);
//                       }
//                     },
//                     child: const Text(
//                       'Apply Now',
//                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(TextEditingController controller, String label, IconData icon,
//       {TextInputType? keyboardType}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: Colors.white70),
//           prefixIcon: Icon(icon, color: Colors.white70),
//           filled: true,
//           fillColor: Colors.white.withOpacity(0.2),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//         ),
//         style: const TextStyle(color: Colors.white),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'Please enter $label';
//           }
//           return null;
//         },
//       ),
//     );
//   }
// }
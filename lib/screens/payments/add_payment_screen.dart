import 'package:fintech_loan/cubit/Customer/customer_cubit.dart';
import 'package:fintech_loan/cubit/Customer/customer_state.dart';
import 'package:fintech_loan/cubit/LoanSchedule/loan_schedule_cubit.dart';
import 'package:fintech_loan/cubit/loan/loan_cubit.dart';
import 'package:fintech_loan/cubit/loan/loan_state.dart';
import 'package:fintech_loan/cubit/payment/payment_cubit.dart';
import 'package:fintech_loan/models/payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddPaymentScreen extends StatefulWidget {
  final String loanId;
  final int installmentNumber;
  final double amount;

  const AddPaymentScreen({
    super.key,
    required this.loanId,
    required this.installmentNumber, 
    required this.amount
  });

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  String _selectedPaymentMethod = "Card";

  @override 
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _submitPayment(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final state = context.read<CustomerCubit>().state;
      String customerId = '';
      if(state is CustomerLoaded) {
        final loans = context.read<LoanCubit>().state;
        if( loans is LoanLoaded) {
          final loan = loans.loan.firstWhere((l) => l.id == widget.loanId);
          customerId = loan.customerId;
        }
      }

      final payment = Payment(
        loanId: widget.loanId, 
        customerId: customerId, 
        installmentNumber: widget.installmentNumber, 
        amountPaid: widget.amount, 
        paymentDate: DateTime.now(), 
        paymentMethod: _selectedPaymentMethod
      );

      context.read<PaymentCubit>().addPayment(payment);
      // Update the loan Schedule Status
      context.read<LoanScheduleCubit>().updateScheduleStatus(widget.loanId, widget.installmentNumber, "Paid");
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment of \$${widget.amount.toStringAsFixed(2)} successful!'), 
          backgroundColor: Colors.green,
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[900]!, Colors.blue[400]!], 
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context), 
                        icon: const Icon(Icons.arrow_back, color: Colors.white,)
                      ),
                      const Text(
                        'Make Payment', 
                        style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                // Payment Summary Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16), 
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10, 
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Payment Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Installment:', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          Text('#${widget.installmentNumber}', style: const TextStyle(fontWeight: FontWeight.bold),)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Amount Due:', style: TextStyle(color: Colors.grey)),
                          Text('#${widget.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),)
                        ],
                      ),
                    ],
                  ),
                ), 
                const SizedBox(height: 16), 
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPaymentMethodTab('Card', Icons.credit_card), 
                      const SizedBox(width: 16), 
                      _buildPaymentMethodTab('M-pesa', Icons.phone_android)
                    ],
                  ),
                ), 
                const SizedBox(height: 16), 
                // Payment Form 
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10, 
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: _selectedPaymentMethod == "Card"
                       ? _buildCardPaymentForm()
                       : _buildMpesaPaymentForm(),
                  ),
                ), 
                const SizedBox(height: 16), 
                // Pay Button
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () => _submitPayment(context), 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, 
                      foregroundColor: Colors.white, 
                      padding: const EdgeInsets.symmetric(vertical: 16), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payment), 
                        SizedBox(width: 8),
                        Text('Pay Now', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            )
          ),
        ),
      )
    );
  }
  
  _buildPaymentMethodTab(String method, IconData icon) {
    final isSelected = _selectedPaymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16), 
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.white),
            const SizedBox(width: 8), 
            Text(
              method, 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16, 
                color: isSelected ? Colors.blue : Colors.white
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  _buildCardPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card Preview
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16), 
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[700]!, Colors.blue[400]!],
              begin: Alignment.topLeft, 
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12), 
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 3)
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _cardNumberController.text.isEmpty
                  ? '**** **** **** ****'
                  : _cardNumberController.text,
                style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2),
              ),
              const SizedBox(height: 16), 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _cardHolderController.text.isEmpty 
                      ? 'CARD HOLDER'
                      : _cardHolderController.text.toUpperCase(),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    _expiryDateController.text.isEmpty 
                      ? 'MM/YY'
                      : _expiryDateController.text.toUpperCase(),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Card Details Form
        TextFormField(
          controller: _cardNumberController,
          decoration: const InputDecoration(
            labelText: 'Card Number',
            prefixIcon: Icon(Icons.credit_card), 
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          maxLength: 16,
          validator: (value) {
            if (value == null || value.isEmpty) return "Please enter card number"; 
            if(value.length != 16) return 'Card number must be 16 digits';
            return null;
          },
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 16), 
        TextFormField(
          controller: _cardHolderController,
          decoration: const InputDecoration(
            labelText: 'Card Holder Name',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return "Please enter card holder name";
            return null;
          }, 
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 16), 
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryDateController,
                decoration: const InputDecoration(
                  labelText: 'Expiry Date (MM/YY)',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
                maxLength: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter expiry date";
                  if(!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) return "Format: MM/YY";
                  final parts = value.split("/");
                  final month = int.parse(parts[0]);
                  final year = int.parse(parts[1]);
                  final now = DateTime.now();
                  final currentYear = now.year % 100;
                  if (month < 1 || month > 12) return "Invalid month";
                  if(year < currentYear || (year == currentYear && month < now.month)) {
                    return "Card expired. Expiry date must be in the future";
                  }
                  return null;
                },
                onChanged: (value) => setState(() {
                  if(value.length == 2 && !value.contains('/')) {
                    _expiryDateController.text = '$value/';
                    _expiryDateController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _expiryDateController.text.length),
                    );
                  }
                  setState(() {});
                }),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _cvvController, 
                decoration: const InputDecoration(
                  labelText: 'CVV', 
                  prefixIcon: Icon(Icons.lock), 
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number, 
                maxLength: 3, 
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter CVV";
                  if(value.length != 3) return 'CVV must be 3 digits';
                  return null;
                }
              ),
            ),
          ],
        ), 
      ],
    );
  }
  
  _buildMpesaPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MPESA Payment Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(height: 16), 
        const Text(
          "M-pesa integration coming soon!", 
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16), 
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Phone Number', 
            prefixIcon: Icon(Icons.phone), 
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          enabled: false,
        ),
      ],
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fintech_loan/services/image_service.dart';
import 'package:fintech_loan/cubit/Customer/customer_cubit.dart';
import 'package:fintech_loan/models/customer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _profileImageBase64;
  late String _customerId;
  String _customerType = 'Individual'; // Default customer type

  @override
  void initState() {
    super.initState();
    _customerId = const Uuid().v4();
  }

  // Method to pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final base64Image = await Imagehandler.pickAndSaveImage(
      context,
      customerId: _customerId,
      source: source,
    );
    if (base64Image != null) {
      setState(() {
        _profileImageBase64 = base64Image;
      });
    }
  }

  // Method to save the customer
  void _saveCustomer() {
    final customer = Customer(
      id: _customerId,
      fullName: _fullNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      dateOfRegistration: DateTime.now(),
      customerType: _customerType,
      avatarColor: Colors.blue,
      profileImage: _profileImageBase64,
    );
    context.read<CustomerCubit>().addCustomer(customer);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Customer")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Choose from Gallery'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Take a Photo'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.camera);
                              },
                            ),
                            if (_profileImageBase64 != null)
                              ListTile(
                                leading: const Icon(Icons.delete),
                                title: const Text('Remove Photo'),
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _profileImageBase64 = null;
                                    Imagehandler.clearSavedImage(_customerId);
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImageBase64 != null
                            ? MemoryImage(base64Decode(_profileImageBase64!))
                            : null,
                        backgroundColor: Colors.blue,
                        child: _profileImageBase64 == null
                            ? const Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _profileImageBase64 == null
                            ? 'Tap to set profile picture'
                            : 'Tap to change profile picture',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your full name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: "Phone",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your phone";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _customerType,
                  decoration: const InputDecoration(
                    labelText: "Customer Type",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Individual',
                      child: Text('Individual'),
                    ),
                    DropdownMenuItem(
                      value: 'Business',
                      child: Text('Business'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _customerType = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please select a customer type";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveCustomer();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Save", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
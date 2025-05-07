import 'dart:convert';
import 'package:fintech_loan/cubit/Customer/customer_cubit.dart';
import 'package:fintech_loan/models/customer.dart';
import 'package:fintech_loan/services/image_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class AddEditCustomerScreen extends StatefulWidget {
  final Customer? customer;
  const AddEditCustomerScreen({this.customer, super.key});

  @override
  State<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends State<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController; // New controller
  late final TextEditingController _notesController;
  late String _customerType;
  late Color _avatarColor;
  late String _status;
  String? _profileImageBase64;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.fullName ?? "");
    _emailController = TextEditingController(text: widget.customer?.email ?? "");
    _phoneController = TextEditingController(text: widget.customer?.phone ?? "");
    _addressController = TextEditingController(text: widget.customer?.address ?? ""); // Initialize
    _notesController = TextEditingController(text: widget.customer?.notes ?? "");
    _customerType = widget.customer?.customerType ?? "Individual";
    _status = widget.customer?.status ?? 'Active';
    _avatarColor = widget.customer?.avatarColor ?? Colors.blue.shade400;
    _profileImageBase64 = widget.customer?.profileImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose(); // Dispose new controller
    _notesController.dispose();
    super.dispose();
  }

  // Method to pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final customerId = widget.customer?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final base64Image = await Imagehandler.pickAndSaveImage(
      context,
      customerId: customerId,
      source: source,
    );
    if (base64Image != null) {
      setState(() {
        _profileImageBase64 = base64Image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer == null ? "Add Customer" : "Edit Customer"),
        actions: [
          if (widget.customer != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAvatarSelector(),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _nameController,
                label: "Full Name",
                icon: Icons.person,
                validator: _validateName,
              ),
              _buildTextFormField(
                controller: _emailController,
                label: "Email",
                icon: Icons.email,
                validator: _validateEmail,
              ),
              _buildTextFormField(
                controller: _phoneController,
                label: "Phone",
                icon: Icons.phone,
                validator: _validatePhone,
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  // Simple phone formatting (e.g., 123-456-7890)
                  if (value.length == 3 || value.length == 7) {
                    _phoneController.text = '$value-';
                    _phoneController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _phoneController.text.length),
                    );
                  }
                },
              ),
              _buildTextFormField(
                controller: _addressController,
                label: "Address",
                icon: Icons.location_on,
                validator: _validateAddress,
              ),
              _buildTextFormField(
                controller: _notesController,
                label: "Notes",
                icon: Icons.notes,
                validator: (value) => null,
                maxLines: 3,
              ),
              _buildCustomerTypeDropdown(),
              const SizedBox(height: 16),
              _buildStatusDropdown(),
              const SizedBox(height: 30),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSelector() {
    final firstLetter = _nameController.text.isNotEmpty
        ? _nameController.text[0].toUpperCase()
        : '?';

    return Center(
      child: GestureDetector(
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
                        final customerId = widget.customer?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
                        setState(() {
                          _profileImageBase64 = null;
                          Imagehandler.clearSavedImage(customerId);
                        });
                      },
                    ),
                  ListTile(
                    leading: const Icon(Icons.color_lens),
                    title: const Text('Change Avatar Color'),
                    onTap: () {
                      Navigator.pop(context);
                      _changeAvatarColor();
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: Hero(
          tag: widget.customer != null
              ? 'avatar-${widget.customer!.id}'
              : 'new-avatar',
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: _profileImageBase64 != null
                      ? DecorationImage(
                          image: MemoryImage(base64Decode(_profileImageBase64!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: _profileImageBase64 == null ? _avatarColor : null,
                ),
                child: _profileImageBase64 == null
                    ? Center(
                        child: Text(
                          firstLetter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                _profileImageBase64 == null
                    ? 'Tap to set profile picture or change color'
                    : 'Tap to change profile picture or color',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int? maxLines,
    required String? Function(String?) validator, TextInputType? keyboardType, ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueGrey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        maxLines: maxLines,
        validator: validator,
        keyboardType: keyboardType,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCustomerTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _customerType,
      decoration: InputDecoration(
        labelText: "Customer Type",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: const [
        DropdownMenuItem(value: "Individual", child: Text("Individual")),
        DropdownMenuItem(value: "Corporate", child: Text("Corporate")),
        DropdownMenuItem(value: "VIP", child: Text("VIP")),
      ],
      onChanged: (value) => setState(() => _customerType = value ?? "Individual"),
      validator: (value) => value == null ? 'Please select customer type' : null,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        child: const Text(
          "Save Customer",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter name';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty || !value.contains('@')) {
      return 'Enter valid email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty || value.length < 10) {
      return 'Enter valid phone number';
    }
    if (value.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if(value != null && value.isNotEmpty && value.length < 5){
      return 'Address must be at least 5 characters if provided';
    }
    return null;
  }

  void _changeAvatarColor() {
    setState(() {
      _avatarColor = Colors.primaries[
        DateTime.now().millisecond % Colors.primaries.length
      ].shade400;
    });
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Customer"),
        content: Text("Are you sure you want to delete ${widget.customer?.fullName}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<CustomerCubit>().deleteCustomer(widget.customer!.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final customer = Customer(
        id: widget.customer?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        dateOfRegistration: widget.customer?.dateOfRegistration ?? DateTime.now(),
        customerType: _customerType,
        avatarColor: _avatarColor,
        profileImage: _profileImageBase64,
        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        status: _status,
      );

      if (widget.customer == null) {
        context.read<CustomerCubit>().addCustomer(customer);
      } else {
        context.read<CustomerCubit>().updateCustomer(customer);
      }

      Navigator.pop(context);
    }
  }
  
  _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _status,
      decoration: InputDecoration(
        labelText: 'Status', 
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10)
        ), 
        filled: true, 
        fillColor: Colors.grey.shade50,
      ),
      items: const [
        DropdownMenuItem(value: "Active", child: Text("Active")),
        DropdownMenuItem(value: "Inactive", child: Text("Inactive")),
        DropdownMenuItem(value: "Suspended", child: Text("Suspended")),
      ], 
      onChanged: (value) => setState(() => _status = value ?? 'Active'),
      validator: (value) => value == null ? 'Please select a status' : null,
    );
  }
}
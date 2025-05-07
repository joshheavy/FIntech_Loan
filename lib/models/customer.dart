import 'package:flutter/material.dart';

class Customer {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final DateTime dateOfRegistration;
  final String customerType;
  final Color avatarColor;
  final String? profileImage;
  final String? address;
  final String? notes;
  final String? status;

  Customer({
    required this.id,
    required this.fullName,
    required this.email, 
    required this.phone,
    required this.dateOfRegistration,
    required this.customerType,
    required this.avatarColor,
    this.profileImage,
    this.address, 
    this.notes,
    this.status = 'Active',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'dateOfRegistration': dateOfRegistration.toIso8601String(),
    'customerType': customerType,
    'avatarColor': avatarColor.value,
    'profileImage': profileImage, 
    'address': address, 
    'notes': notes,
    'status': status,
  };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json['id'],
    fullName: json['fullName'],
    email: json['email'],
    phone: json['phone'],
    dateOfRegistration: DateTime.parse(json['dateOfRegistration'] as String),
    customerType: json['customerType'],
    avatarColor: Color(json['avatarColor'] as int),
    profileImage: json['profileImage'] as String?,
    address: json['address'] as String?,
    notes: json['notes'] as String?,
    status: json['status'] as String? ?? 'Active',
  );
}
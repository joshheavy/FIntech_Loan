class Customer {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String dateOfRegistration;
  final String customerType;

  Customer({
    required this.id,
    required this.fullName,
    required this.email, 
    required this.phone,
    required this.dateOfRegistration,
    required this.customerType,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'dateOfRegistration': dateOfRegistration,
    'customerType': customerType,
  };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json['id'],
    fullName: json['fullName'],
    email: json['email'],
    phone: json['phone'],
    dateOfRegistration: json['dateOfRegistration'],
    customerType: json['customerType'],
  );
}
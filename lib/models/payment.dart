class Payment {
  final String loanId;
  final String customerId;
  final int installmentNumber;
  final double amountPaid;
  final DateTime paymentDate;
  final String paymentMethod;

  Payment({
    required this.loanId,
    required this.customerId,
    required this.installmentNumber,
    required this.amountPaid,
    required this.paymentDate,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
        'loanId': loanId,
        'customerId': customerId,
        'installmentNumber': installmentNumber,
        'amountPaid': amountPaid,
        'paymentDate': paymentDate.toIso8601String(),
        'paymentMethod': paymentMethod,
      };

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        loanId: json['loanId'],
        customerId: json['customerId'],
        installmentNumber: json['installmentNumber'],
        amountPaid: json['amountPaid'],
        paymentDate: DateTime.parse(json['paymentDate']),
        paymentMethod: json['paymentMethod'],
      );
}
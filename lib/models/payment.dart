class Payment {
  final String loanId;
  final int installmentNumber;
  final double amountPaid;
  final DateTime paymentDate;

  Payment({
    required this.loanId,
    required this.installmentNumber,
    required this.amountPaid,
    required this.paymentDate,
  });

  Map<String, dynamic> toJson() => {
        'loanId': loanId,
        'installmentNumber': installmentNumber,
        'amountPaid': amountPaid,
        'paymentDate': paymentDate.toIso8601String(),
      };

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        loanId: json['loanId'],
        installmentNumber: json['installmentNumber'],
        amountPaid: json['amountPaid'],
        paymentDate: DateTime.parse(json['paymentDate']),
      );
}
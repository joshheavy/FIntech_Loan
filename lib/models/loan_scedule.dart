class LoanSchedule {
  final String loanId;
  final int installmentNumber;
  final DateTime dueDate;
  final double amount;
  final String status;

  LoanSchedule({
    required this.loanId,
    required this.installmentNumber,
    required this.dueDate,
    required this.amount, 
    required this.status
  });

  Map<String, dynamic> toJson() => {
    'loanId': loanId,
    'installmentNumber': installmentNumber,
    'dueDate': dueDate.toIso8601String(),
    'amount': amount,
    'status': status
  };

  factory LoanSchedule.fromJson(Map<String, dynamic> json) => LoanSchedule(
    loanId: json['loanId'], 
    installmentNumber: json['installmentNumber'], 
    dueDate: json['dueDate'], 
    amount: json['amount'], 
    status: json['status']
  );
}
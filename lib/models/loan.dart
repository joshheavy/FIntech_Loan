class Loan {
  final String id;
  final String customerId;
  final String loanType; 
  final double loanAmount;
  final double interestRate;
  final int durationMonths;

  Loan({
    required this.id,
    required this.customerId, 
    required this.loanType,
    required this.loanAmount,
    required this.interestRate,
    required this.durationMonths,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'loanType': loanType,
    'loanAmount': loanAmount,
    'interestRate': interestRate,
    'durationMonths': durationMonths,
  };

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
    id: json['id'],
    customerId: json['customerId'],
    loanType: json['loanType'],
    loanAmount: json['loanAmount'],
    interestRate: json['interestRate'],
    durationMonths: json['durationMonths'],
  );
}


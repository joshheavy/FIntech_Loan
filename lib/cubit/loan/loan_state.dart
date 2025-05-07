import 'package:equatable/equatable.dart';
import 'package:fintech_loan/models/loan.dart';

abstract class LoanState extends Equatable{
  @override
  List<Object?> get props => [];
}

class LoanLoading extends LoanState{
  LoanLoading();
}

class LoanLoaded extends LoanState {
  final List<Loan> loan;
  late final List<Loan> filteredLoan;

  LoanLoaded({
    required this.loan,
    required this.filteredLoan,
  });

  LoanLoaded copyWith({
    List<Loan>? loan,
    List<Loan>? filteredLoan,
  }) {
    return LoanLoaded(
      loan: loan ?? this.loan,
      filteredLoan: filteredLoan ?? this.filteredLoan,
    );
  }
  @override  
  List<Object?> get props => [loan, filteredLoan];
}

class LoanError extends LoanState {
  final String message;
  LoanError({required this.message});

  @override 
  List<Object?> get props => [message];
}


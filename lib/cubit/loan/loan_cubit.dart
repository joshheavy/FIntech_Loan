import 'package:fintech_loan/cubit/loan/loan_state.dart';
import 'package:fintech_loan/models/loan.dart';
import 'package:fintech_loan/services/localStorage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// class LoanCubit extends Cubit<LoanState> {
//   LoanCubit() : super(LoanLoading());

//   Future<void> loadLoans() async {
//     try {
//       emit(LoanLoading());
//       final loans = await LocalStorageService.getLoans();
//       emit(LoanLoaded(loan: loans, filteredLoan: loans));
//     } catch (e) {
//       emit(LoanError(message: 'Failed to load loans: $e'));
//     }
//   }

//   Future<void> addLoan(Loan loan) async {
//     try {
//       emit(LoanLoading());
//       final loans = await LocalStorageService.getLoans();
//       final updatedLoans = [...loans, loan];
//       await LocalStorageService.savedLoans(updatedLoans);

//       // Generate and save schedule
//       final schedules = await LocalStorageService.getLoanSchedules();
//       final newSchedules = _generateSchedule(loan);
//       final updatedSchedules = [...schedules, ...newSchedules];
//       await LocalStorageService.saveLoanSchedules(updatedSchedules);

//       emit(LoanLoaded(loan: loans, filteredLoan: loans));
//     } catch (e) {
//       emit(LoanError(message: 'Failed to add loan: $e'));
//     }
//   }

//   Future<void> deleteLoan(String loanId) async {
//     try {
//       emit(LoanLoading());
//       final loans = await LocalStorageService.getLoans();
//       final updatedLoans = loans.where((loan) => loan.id != loanId).toList();
//       await LocalStorageService.savedLoans(updatedLoans);
//       emit(LoanLoaded(loan: loans, filteredLoan: loans));
//     } catch (e) {
//       emit(LoanError(message: 'Failed to delete loan: $e'));
//     }
//   }

//   List<LoanSchedule> _generateSchedule(Loan loan) {
//     final monthlyPayment = _calculateMonthlyPayment(loan);
//     final schedules = <LoanSchedule>[];
//     for (int i = 0; i < loan.durationMonths; i++) {
//       schedules.add(
//         LoanSchedule(
//           loanId: loan.id,
//           installmentNumber: i + 1,
//           dueDate: DateTime.now().add(Duration(days: (i + 1) * 30)),
//           amount: monthlyPayment,
//           status: 'Pending',
//         ),
//       );
//     }
//     return schedules;
//   }

//   double _calculateMonthlyPayment(Loan loan) {
//     final monthlyRate = loan.interestRate / 100 / 12;
//     final denominator = 1 - (1 + monthlyRate).pow(-loan.durationMonths);
//     return (loan.loanAmount * monthlyRate) / denominator;
//   }
// }

class LoanCubit extends Cubit<LoanState> {
  LoanCubit() : super(LoanLoading());

  Future<void> loadLoans() async {
    try {
      emit(LoanLoading());
      final loans = await LocalStorageService.getLoans();
      emit(LoanLoaded(loan: loans, filteredLoan: loans));
    } catch (e) {
      emit(LoanError(message: 'Failed to load loans: $e'));
    }
  }
  
  Future<List<Loan>> loadLoansForCustomer(String customerId) async {
    final loans = await LocalStorageService.getLoans();
    return loans.where((loan) => loan.customerId == customerId).toList();
  }

  Future<void> addLoan(Loan loan) async {
    try {
      emit(LoanLoading());
      final loans = await LocalStorageService.getLoans();
      final updatedLoans = [...loans, loan];
      await LocalStorageService.saveLoans(updatedLoans);
      emit(LoanLoaded(loan: updatedLoans, filteredLoan: updatedLoans));
    } catch (e) {
      emit(LoanError(message: 'Failed to add loan: $e'));
    }
  }

  Future<void> deleteLoan(String loanId) async {
    try {
      emit(LoanLoading());
      final loans = await LocalStorageService.getLoans();
      final updatedLoans = loans.where((loan) => loan.id != loanId).toList();
      await LocalStorageService.saveLoans(updatedLoans);
      emit(LoanLoaded(loan: updatedLoans, filteredLoan: updatedLoans));
    } catch (e) {
      emit(LoanError(message: 'Failed to delete loan: $e'));
    }
  }
}
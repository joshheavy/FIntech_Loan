import 'package:equatable/equatable.dart';
import 'package:fintech_loan/models/loan_scedule.dart';

abstract class LoanScheduleState extends Equatable {
  const LoanScheduleState();

  @override
  List<Object?> get props => [];
}

class LoanScheduleLoading extends LoanScheduleState {
  const LoanScheduleLoading();
}

class LoanScheduleLoaded extends LoanScheduleState {
  final List<LoanSchedule> schedules;

  const LoanScheduleLoaded({ required this.schedules});

  @override
  List<Object?> get props => [schedules];
}

class LoanScheduleError extends LoanScheduleState {
  final String message;

  const LoanScheduleError({ required this.message });

  @override
  List<Object?> get props => [message];
}
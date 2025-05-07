import 'package:fintech_loan/services/localStorage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintech_loan/cubit/LoanSchedule/loan_schedule_state.dart';

import 'package:fintech_loan/models/loan_scedule.dart';

class LoanScheduleCubit extends Cubit<LoanScheduleState> {
  LoanScheduleCubit() : super(LoanScheduleLoading());

  Future<void> loanSchedules() async {
    try {
      emit(LoanScheduleLoading());
      final schedules = await LocalStorageService.getLoanSchedule();
      emit(LoanScheduleLoaded(schedules: schedules));
    } catch(e) {
      emit(LoanScheduleError(message: "Failed to load schedules: $e"));
    }
  }

  Future<void> addSchedule(LoanSchedule schedule) async{
    try {
      emit(LoanScheduleLoading());
      final schedules = await LocalStorageService.getLoanSchedule();
      final updatedSchedules = [...schedules, schedule];
      await LocalStorageService.saveLoanSchedule(updatedSchedules);
      emit(LoanScheduleLoaded(schedules: updatedSchedules));
    } catch (e) {
      emit(LoanScheduleError(message: "Failed to add schedule: $e"));
    }
  }

  Future<void> updateScheduleStatus(String loanId, int installmentNumber, String status) async {
    try {
      emit(LoanScheduleLoading());
      final schedules = await LocalStorageService.getLoanSchedule();
      final updatedSchedules = schedules.map((schedule) {
        if (schedule.loanId == loanId && schedule.installmentNumber == installmentNumber) {
          return LoanSchedule(
            loanId: schedule.loanId, 
            installmentNumber: schedule.installmentNumber, 
            dueDate: schedule.dueDate, 
            amount: schedule.amount, 
            status: status
          );
        }
        return schedule;
      }).toList();
      await LocalStorageService.saveLoanSchedule(updatedSchedules);
      emit(LoanScheduleLoaded(schedules: updatedSchedules));
    } catch (e) {
      emit(LoanScheduleError(message: "Failed to update schedule: $e"));
    }
  }
}
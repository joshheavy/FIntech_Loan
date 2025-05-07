import 'package:fintech_loan/cubit/LoanSchedule/loan_schedule_cubit.dart';
import 'package:fintech_loan/cubit/LoanSchedule/loan_schedule_state.dart';
import 'package:fintech_loan/models/loan_scedule.dart';
import 'package:fintech_loan/screens/loans/add_loan_schedule_screen.dart';
import 'package:fintech_loan/screens/payments/add_payment_screen.dart';
import 'package:fintech_loan/widgets/wave_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoanScheduleScreen extends StatelessWidget {
  final String loanId;
  const LoanScheduleScreen({super.key, required this.loanId});

  @override
  Widget build(BuildContext context) {
    final headerHeight = 200.0;
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Column(
        children: [
          // Header
          Container(
            height: headerHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[900]!, Colors.blue[400]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: CustomPaint(
              painter: WavePainter(),
              child: SafeArea(
                left: false,
                right: false,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Repayment Schedule',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Loan #$loanId', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Content Area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: BlocBuilder<LoanScheduleCubit, LoanScheduleState>(
                builder: (context, state) {
                  if (state is LoanScheduleLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is LoanScheduleError) {
                    return Center(child: Text(state.message));
                  } else if (state is LoanScheduleLoaded) {
                    final schedules = state.schedules.where((s) => s.loanId == loanId).toList();
                    if (schedules.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        return _buildScheduleItem(context, schedules[index], schedules.length);
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_rounded, size: 60, color: Colors.blue[200]),
          const SizedBox(height: 12),
          Text(
            'No Schedule Yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.blue[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'This loan has no repayment schedule',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blue[600]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16), 
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => AddLoanScheduleScreen(loanId: loanId)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700], 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              )
            ),
            child: const Text('Add Schedule'),
          )
        ],
      ),
    );
  }

  Widget _buildScheduleItem(BuildContext context, LoanSchedule schedule, int totalInstallments) {
    final progress = schedule.installmentNumber / totalInstallments;
    final isPaid = schedule.status == "Paid";
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular Progress Indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.blue[100],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isPaid ? Colors.green : Colors.blue[800]!,
                  ),
                ),
              ),
              Text(
                '${schedule.installmentNumber}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isPaid ? Colors.green : Colors.blue[900],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Due: ${schedule.dueDate.toString().substring(0, 10)}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900]),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Amount: \$${schedule.amount.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.blue[700]),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status: ${schedule.status}',
                            style: TextStyle(
                              color: isPaid ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!isPaid)
                            IconButton(
                              icon: Icon(Icons.payment, color: Colors.blue[700]),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AddPaymentScreen(
                                  loanId: schedule.loanId,
                                  installmentNumber: schedule.installmentNumber,
                                  amount: schedule.amount,
                                )),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:fintech_loan/cubit/LoanSchedule/loan_schedule_cubit.dart';
// import 'package:fintech_loan/cubit/LoanSchedule/loan_schedule_state.dart';
// import 'package:fintech_loan/models/loan_scedule.dart';
// import 'package:fintech_loan/screens/payments/add_payment_screen.dart';
// import 'package:fintech_loan/widgets/wave_painter.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// class LoanScheduleScreen extends StatelessWidget {
//   final String loanId;
//   const LoanScheduleScreen({super.key, required this.loanId});
//
//   @override
//   Widget build(BuildContext context) {
//     final headerHeight = 180.0;
//     return Scaffold(
//       backgroundColor: Colors.blue[50],
//       body: Stack(
//         children: [
//           Container(
//             height: headerHeight,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.blue[900]!, Colors.blue[400]!],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//             child: CustomPaint(
//               painter: WavePainter(),
//               child: SafeArea(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Repayment Schedule',
//                         style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text('Loan #$loanId', style: TextStyle(color: Colors.white70, fontSize: 16)),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             top: headerHeight -20,
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.blue.withOpacity(0.1),
//                     blurRadius: 10,
//                     offset: const Offset(0, -5),
//                   ),
//                 ]
//               ),
//               child: BlocBuilder<LoanScheduleCubit, LoanScheduleState>(
//                 builder: (context, state) {
//                   if(state is LoanScheduleLoading) {
//                     return const Center(child: CircularProgressIndicator());
//                   } else if (state is LoanScheduleError) {
//                     return Center(child: Text(state.message));
//                   } else if(state is LoanScheduleLoaded) {
//                     final schedules = state.schedules.where((s) => s.loanId == loanId).toList();
//                     if(schedules.isEmpty){
//                       return _buildEmptyState(context);
//                     }
//                     return ListView.builder(
//                       padding: const EdgeInsets.all(20),
//                       itemCount: schedules.length,
//                       itemBuilder: (context, index) {
//                         _buildScheduleItem(context, schedules[index], schedules.length);
//                       }
//                     );
//                   }
//                   return const SizedBox();
//                 }
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.calendar_today_rounded, size: 80, color: Colors.blue[200]),
//           const SizedBox(height: 12),
//           Text(
//             'No Schedule yet',
//             style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.blue[800], fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Text(
//               'This loan has no repayment schedule',
//               style:Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blue[600]),
//               textAlign: TextAlign.center,
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget _buildScheduleItem(BuildContext context, LoanSchedule schedule, int totalInstallments) {
//     final progress = schedule.installmentNumber / totalInstallments;
//     final isPaid = schedule.status == "Paid";
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Circular Progress Indicator
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               SizedBox(
//                 width: 60,
//                 height: 60,
//                 child: CircularProgressIndicator(
//                   value: progress,
//                   strokeWidth: 6,
//                   backgroundColor: Colors.blue[100],
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                     isPaid ? Colors.green : Colors.blue[800]!,
//                   ),
//                 ),
//               ),
//               Text(
//                 '${schedule.installmentNumber}',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: isPaid ? Colors.green : Colors.blue[900],
//                 ),
//               ),
//             ]
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.blue.withOpacity(0.1),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   )
//                 ],
//               ),
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(maxHeight: 80),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       'Due: ${schedule.dueDate.toString().substring(0, 10)}',
//                       style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900]),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Amount: \$${schedule.amount.toStringAsFixed(2)}',
//                       style: TextStyle(color: Colors.blue[700]),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Flexible(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Status: ${schedule.status}',
//                             style: TextStyle(
//                               color: isPaid ? Colors.green : Colors.orange,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           if(!isPaid)
//                             IconButton(
//                               icon: Icon(Icons.payment, color: Colors.blue[700]),
//                               onPressed: () => Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (_) => AddPaymentScreen())
//                               ),
//                             )
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
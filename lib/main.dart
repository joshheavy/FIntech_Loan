import 'package:fintech_loan/cubit/Customer/customer_cubit.dart';
import 'package:fintech_loan/cubit/LoanSchedule/loan_schedule_cubit.dart';
import 'package:fintech_loan/cubit/loan/loan_cubit.dart';
import 'package:fintech_loan/cubit/payment/payment_cubit.dart';
import 'package:fintech_loan/screens/dashboard_screen.dart';
import 'package:fintech_loan/services/localStorage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CustomerCubit>(create: (_) => CustomerCubit()..loadCustomers()),
        BlocProvider<LoanCubit>(create: (_) => LoanCubit()..loadLoans()),
        BlocProvider<LoanScheduleCubit>(create: (_) => LoanScheduleCubit()..loanSchedules()),
        BlocProvider<PaymentCubit>(create: (_) => PaymentCubit()..loadPayment()),
      ],
      child: MaterialApp(
        title: 'Fintech Loan App',
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primarySwatch: Colors.blue,
        ),
        home: const DashboardScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
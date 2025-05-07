import 'dart:async';

import 'package:fintech_loan/cubit/Customer/customer_cubit.dart';
import 'package:fintech_loan/cubit/Customer/customer_state.dart';
import 'package:fintech_loan/cubit/loan/loan_cubit.dart';
import 'package:fintech_loan/cubit/loan/loan_state.dart';
import 'package:fintech_loan/cubit/payment/payment_cubit.dart';
import 'package:fintech_loan/cubit/payment/payment_state.dart';
import 'package:fintech_loan/screens/customers/customer_list_screen.dart';
import 'package:fintech_loan/screens/loans/loan_list_screen.dart';
import 'package:fintech_loan/screens/payments/payment_list_screen.dart';
import 'package:fintech_loan/widgets/wave_painter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<FlSpot> _paymentSpots = [];
  Timer? _timer;

  @override 
  void initState() {
    super.initState();
    // Load initial data
    context.read<CustomerCubit>().loadCustomers();
    context.read<LoanCubit>().loadLoans();
    context.read<PaymentCubit>().loadPayment();

    // Simulate real-time payment data (replace with actual data in production)
    _paymentSpots = _generateInitialPaymentSpots();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _paymentSpots = _updatePaymentSpots(_paymentSpots);
      });
    });
  }

  @override 
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Generate initial mock payment data for the chart (last 7days)
  List<FlSpot> _generateInitialPaymentSpots() {
    return List.generate(7, (index) {
      return FlSpot(index.toDouble(), (index * 100 + 200).toDouble());
    });
  }
  // Simulate real-time updates by shifting the data and adding a new random point
  List<FlSpot> _updatePaymentSpots(List<FlSpot> spots) {
    final newSpots = spots.sublist(1); // Remove the oldest point
    final lastX = newSpots.last.x + 1;
    final newY = (newSpots.last.y + (DateTime.now().second % 10) * 50) % 1000;
    // Simulate new Payment amount
    newSpots.add(FlSpot(lastX, newY));
    return newSpots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240, 
            floating: false, 
            pinned: true, 
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[900]!, Colors.blue[400]!], 
                    begin: Alignment.topCenter, 
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: CustomPaint(
                  painter: WavePainter(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), 
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'FinTech Dashboard', 
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15), 
                        Text(
                          "Welcome to your financial Overview", 
                          style: TextStyle(color: Colors.white70, fontSize: 16.0),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ), 
          SliverToBoxAdapter(
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
              child: Padding(
                padding:const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    _buildSummarySection(context), 
                    const SizedBox(height: 20), 
                    //Real-Time Chart
                    _buildChartSection(context),
                    const SizedBox(height: 20),
                    // Navigation Buttons
                    _buildNavigationSection(context),
                  ],
                ),
              ),
            ),
          ), 
        ],
      ),
    );
  }
  
  _buildSummarySection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSummaryCard(
          context, 
          title: "Customers", 
          icon: Icons.person, 
          color: Colors.blue[800]!, 
          dataBuilder: (context) => BlocBuilder<CustomerCubit, CustomerState>(
            builder: (context, state) {
              if(state is CustomerLoaded) {
                return Text(
                  '${state.allCustomers.length}', 
                  style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[800],
                  ),
                );
              }
              return const CircularProgressIndicator();
            },
          ),
          onTap: () {
            Future.microtask(() {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const CustomerListScreen()),
              );
            });
          }
        ),
        _buildSummaryCard(
          context, 
          title: "Loans", 
          icon: Icons.account_balance, 
          color: Colors.orange[800]!, 
          dataBuilder: (context) => BlocBuilder<LoanCubit, LoanState>(
            builder: (context, state) {
              if(state is LoanLoaded) {
                return Text(
                  '${state.loan.length}', 
                  style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange[800],
                  ),
                );
              }
              return const CircularProgressIndicator();
            },
          ),
          onTap: () {
            Future.microtask(() {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const LoanListScreen()),
              );
            });
          }
        ),
        _buildSummaryCard(
          context, 
          title: "Payments", 
          icon: Icons.payment, 
          color: Colors.green[800]!, 
          dataBuilder: (context) => BlocBuilder<PaymentCubit, PaymentState>(
            builder: (context, state) {
              if(state is PaymentLoaded) {
                final totalPayments = state.payments.fold<double>(
                  0, (sum, payment) => sum + payment.amountPaid,
                );
                return Text(
                  '\$${totalPayments.toStringAsFixed(2)}', 
                  style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[800],
                  ),
                );
              }
              return const CircularProgressIndicator();
            },
          ),
          onTap: () {
            Future.microtask(() {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const PaymentListScreen()),
              );
            });
          }
        ),
      ],
    );
  }
  
  _buildChartSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Payment Activity', 
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue[900]),
        ),
        const SizedBox(height: 10), 
        Container(
          height: 200, 
          padding: const EdgeInsets.all(16),
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
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false), 
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) { return Text('\$${value.toInt()}', style: TextStyle(color: Colors.grey[700], fontSize: 12),); }
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) { return Text('Day ${value.toInt() + 1}', style: TextStyle(color: Colors.grey[700], fontSize: 12),); }
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false), 
              lineBarsData: [
                LineChartBarData(
                  spots: _paymentSpots, 
                  isCurved: true, 
                  color: Colors.blue[800], 
                  barWidth: 3, 
                  belowBarData: BarAreaData(
                    show: true, 
                    color: Colors.blue[200]!.withOpacity(0.3),
                  ), 
                  dotData: FlDotData(show: false),
                )
              ],
              minX: 0, 
              maxX: 6, 
              minY: 0, 
              maxY: 1000,
            ),
          ),
        ),
      ],
    );
  }
  
  _buildNavigationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quick Actions", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue[900]),),
        const SizedBox(height: 10), 
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(
              context, 
              label: 'View Customers', 
              icon: Icons.person, 
              color: Colors.blue[800]!, 
              onTap: () {
                Future.microtask(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CustomerListScreen()),
                  );
                });
              }
            ),
            _buildActionButton(
              context, 
              label: 'View Loans', 
              icon: Icons.account_balance, 
              color: Colors.orange[800]!, 
              onTap: () {
                Future.microtask(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoanListScreen()),
                  );
                });
              }
            ),
            _buildActionButton(
              context, 
              label: 'View Payments', 
              icon: Icons.payment, 
              color: Colors.green[800]!, 
              onTap: () {
                Future.microtask(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaymentListScreen()),
                  );
                });
              }
            ),
          ],
        ), 
      ],
    );
  } 
  _buildSummaryCard(BuildContext context, {required String title, required IconData icon, required Color color, required Widget Function(BuildContext context) dataBuilder, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        width: 100, 
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1), 
              blurRadius: 8, 
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30), 
            const SizedBox(height: 8), 
            Text(
              title, 
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 8), 
            dataBuilder(context),
          ],
        ),
      ),
    );
  }
  
  _buildActionButton(BuildContext context, {required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap, 
      label: Text(label), 
      style: ElevatedButton.styleFrom(
        backgroundColor: color, 
        foregroundColor: Colors.white, 
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
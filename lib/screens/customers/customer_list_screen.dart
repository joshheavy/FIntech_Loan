import 'dart:async';
import 'package:animations/animations.dart';
import 'package:fintech_loan/cubit/Customer/customer_cubit.dart';
import 'package:fintech_loan/cubit/Customer/customer_state.dart';
import 'package:fintech_loan/models/customer.dart';
// import 'package:fintech_loan/models/loan.dart';
import 'package:fintech_loan/screens/customers/add_edit_customer_screen.dart';
import 'package:fintech_loan/screens/customers/customer_detail_screen.dart';
import 'package:fintech_loan/screens/loans/add_loan_screen.dart';
import 'package:fintech_loan/services/image_service.dart';
import 'package:fintech_loan/widgets/wave_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:uuid/uuid.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> with SingleTickerProviderStateMixin{
  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey<SliverAnimatedListState>();
  List<Customer> _displayedCustomers = [];
  String _sortOption = 'name_asc';
  String _filterOption = 'All';
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    context.read<CustomerCubit>().loadCustomers();
    _fabController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 500),
    );
    _fabAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut)
    );
    _fabController.forward();
  }

  @override 
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          final cubit = context.read<CustomerCubit>();
          await cubit.loadCustomers();
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[800]!, Colors.lightBlue[400]!],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: CustomPaint(
                    painter: WavePainter(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Customers',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Manage your customer list',
                            style: const TextStyle(color: Colors.white70, fontSize: 16.0),
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
              child: FutureBuilder<Map<String, dynamic>>(
                future: context.read<CustomerCubit>().getCustomerStatistic(),
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0), 
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if(snapshot.hasData) {
                    final stats = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.all(16.0), 
                      child: Card(
                        elevation: 2, 
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Customer Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('Total Customers: ${stats['totalCustomers']}'),
                              Text('Active Loans: ${stats['activeLoans']}'),
                              const SizedBox(height: 8),
                              Text('Breakdown by Type:'),
                              Text('Individual: ${stats['customerTypeBreakdown']['Individual']}'),
                              Text('Corporate: ${stats['customerTypeBreakdown']['Corporate']}'),
                              Text('VIP: ${stats['customerTypeBreakdown']['VIP']}'),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      value: _sortOption,
                      hint: const Text('Sort By'),
                      items: const [
                        DropdownMenuItem(value: 'name_asc', child: Text('Name (A-Z)')),
                        DropdownMenuItem(value: 'name_desc', child: Text('Name (Z-A)')),
                        DropdownMenuItem(value: 'date_newest', child: Text('Newest First')),
                        DropdownMenuItem(value: 'date_oldest', child: Text('Oldest First')),
                      ], 
                      onChanged: (value) {
                        setState(() => _sortOption = value!);
                        context.read<CustomerCubit>().sortCustomers(value!);
                      }
                    ),
                    DropdownButton<String>(
                      value: _filterOption,
                      hint: const Text('Filter By Type'),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All Types')),
                        DropdownMenuItem(value: 'Individual', child: Text('Individual')),
                        DropdownMenuItem(value: 'Corporate', child: Text('Corporate')),
                        DropdownMenuItem(value: 'VIP', child: Text('VIP')),
                      ], 
                      onChanged: (value) {
                        setState(() => _filterOption = value!);
                        context.read<CustomerCubit>().filterCustomersByType(value!);
                      }
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0), 
                child: _buildSearchField(context),
              ),
            ),
            BlocConsumer<CustomerCubit, CustomerState>(
              listener: (context, state) {
                if (state is CustomerLoaded) {
                  final newCustomers = state.filteredCustomers;
                  _updateAnimatedList(newCustomers);
                }
              },
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 400,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                } else if (state is CustomerError) {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: 400,
                      child: Center(child: Text(state.message)),
                    ),
                  );
                } else if (state is CustomerLoaded) {
                  if (state.filteredCustomers.isEmpty) {
                    return SliverToBoxAdapter(
                      child: _buildEmptyState(context),
                    );
                  }
                  return SliverAnimatedList(
                    key: _listKey,
                    initialItemCount: _displayedCustomers.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (context, index, animation) {
                      if (state.hasMore && index == _displayedCustomers.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0), 
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, 
                              foregroundColor: Colors.white, 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                            ),
                            onPressed: (){
                              context.read<CustomerCubit>().loadCustomers(loadMore: true);
                            }, 
                            child: const Text('Load More'),
                          ),
                        );
                      }
                      if(index >= _displayedCustomers.length) {
                        return const SizedBox.shrink();
                      }
                      final customer = _displayedCustomers[index];
                      return _buildCustomerCard(customer, context, animation);
                    },
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox());
              },
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: OpenContainer(
          closedElevation: 6,
          closedShape: const CircleBorder(),
          closedBuilder: (_, openContainer) => FloatingActionButton(
            onPressed: () => Future.delayed(Duration.zero, openContainer),
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          openBuilder: (_, __) => const AddEditCustomerScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionType: ContainerTransitionType.fadeThrough,
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final searchController = TextEditingController();
    Timer? _debounce;

    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Search customers...',
        prefixIcon: const Icon(Icons.search, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            searchController.clear();
            context.read<CustomerCubit>().showAllCustomers();
          },
        ),
      ),
      onChanged: (query) {
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () {
          final cubit = context.read<CustomerCubit>();
          if (query.isEmpty) {
            cubit.showAllCustomers();
          } else {
            cubit.searchCustomers(query);
          }
        });
      },
    );
  }

  void _updateAnimatedList(List<Customer> newCustomers) {
    for (int i = _displayedCustomers.length - 1; i >= 0; i--) {
      if (!newCustomers.contains(_displayedCustomers[i])) {
        final removedCustomer = _displayedCustomers[i];
        _displayedCustomers.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildCustomerCard(removedCustomer, context, animation),
          duration: const Duration(milliseconds: 300),
        );
      }
    }

    for (int i = 0; i < newCustomers.length; i++) {
      if (!_displayedCustomers.contains(newCustomers[i])) {
        _displayedCustomers.insert(i, newCustomers[i]);
        _listKey.currentState?.insertItem(
          i,
          duration: const Duration(milliseconds: 300),
        );
      }
    }
    _displayedCustomers = List.from(newCustomers);
  }

  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No customers found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first customer by tapping the + button',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer, BuildContext context, Animation<double> animation) {
    final firstLetter = customer.fullName.isNotEmpty
        ? customer.fullName[0].toUpperCase()
        : '?';

    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.blue[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _navigateToEdit(customer, context),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'avatar-${customer.id}',
                        child: FutureBuilder<Image?>(
                          future: Imagehandler.getSavedImage(customer.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (snapshot.hasData && snapshot.data != null) {
                              return CircleAvatar(
                                radius: 24,
                                backgroundImage: snapshot.data!.image,
                              );
                            }
                            return CircleAvatar(
                              radius: 24,
                              backgroundColor: customer.avatarColor,
                              child: Text(
                                firstLetter,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<int>(
                              future: context.read<CustomerCubit>().getActiveLoansCount(customer.id),
                              builder: (context, snapshot) {
                                if(snapshot.hasData && snapshot.data! > 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Chip(
                                      label: Text(
                                        '${snapshot.data} Active Loan${snapshot.data! > 1 ? 's' : ''}',
                                        style: const TextStyle(fontSize: 12, color: Colors.white),
                                      ),
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            Text(
                              customer.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              customer.email,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            Text(
                              customer.phone,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            Text(
                              'Type: ${customer.customerType}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            Text(
                              'Registered: ${customer.dateOfRegistration.toString().split(' ')[0]}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            Text(
                              'Status: ${customer.status}',
                              style: TextStyle(
                                color: customer.status == 'Active' ? Colors.green : customer.status == 'Inactive' ? Colors.grey : Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                        onSelected: (value) {
                          switch (value) {
                            case 'create_loan':
                              _createLoan(customer, context);
                              break;
                            case 'edit':
                              _navigateToEdit(customer, context);
                              break;
                            case 'delete':
                              _deleteCustomer(context, customer);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'create_loan',
                            child: Row(
                              children: [
                                Icon(Icons.add_circle, color: Colors.green),
                                SizedBox(width: 8),
                                Text('Create Loan'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('View Customer'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete Customer'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _createLoan(Customer customer, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddLoanScreen(customer: customer),
      ),
    );
  }

  void _navigateToEdit(Customer customer, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailsScreen(customer: customer),
      ),
    );
  }

  void _deleteCustomer(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${customer.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CustomerCubit>().deleteCustomer(customer.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${customer.fullName} deleted'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// import 'dart:async';
// import 'package:animations/animations.dart';
// import 'package:fintech_loan/cubit/Customer/customer_cubit.dart';
// import 'package:fintech_loan/cubit/Customer/customer_state.dart';
// import 'package:fintech_loan/models/customer.dart';
// // import 'package:fintech_loan/models/loan.dart';
// import 'package:fintech_loan/screens/customers/add_edit_customer_screen.dart';
// import 'package:fintech_loan/screens/loans/add_loan_screen.dart';
// import 'package:fintech_loan/services/image_service.dart';
// import 'package:fintech_loan/widgets/wave_painter.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:uuid/uuid.dart';

// class CustomerListScreen extends StatefulWidget {
//   const CustomerListScreen({super.key});

//   @override
//   State<CustomerListScreen> createState() => _CustomerListScreenState();
// }

// class _CustomerListScreenState extends State<CustomerListScreen> {
//   final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
//   List<Customer> _displayedCustomers = [];

//   @override
//   void initState() {
//     super.initState();
//     context.read<CustomerCubit>().loadCustomers();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, 
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 200,
//             floating: false,
//             pinned: true,
//             backgroundColor: Colors.transparent,
//             flexibleSpace: FlexibleSpaceBar(
//               background: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.blue[800]!, Colors.lightBlue[400]!], // Match LoanListScreen gradient
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//                 child: CustomPaint(
//                   painter: WavePainter(),
//                   child: Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         Text(
//                           'Customers',
//                           style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         // SizedBox(height: 20),
//                         Text(
//                           'Manage your customer list',
//                           style: TextStyle(color: Colors.white70, fontSize: 16.0),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
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
//                 ],
//               ),
//               child: RefreshIndicator(
//                 onRefresh: () async {
//                   final cubit = context.read<CustomerCubit>();
//                   await cubit.loadCustomers();
//                 },
//                 child: SingleChildScrollView(
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       children: [
//                         _buildSearchField(context),
//                         const SizedBox(height: 16),
//                         _buildCustomerList(),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: OpenContainer(
//         closedElevation: 6,
//         closedShape: const CircleBorder(),
//         closedBuilder: (_, openContainer) => FloatingActionButton(
//           onPressed: () => Future.delayed(Duration.zero, openContainer),
//           backgroundColor: Colors.blue,
//           child: const Icon(Icons.add, color: Colors.white),
//         ),
//         openBuilder: (_, __) => AddEditCustomerScreen(),
//         transitionDuration: const Duration(milliseconds: 500),
//         transitionType: ContainerTransitionType.fadeThrough,
//       ),
//     );
//   }

//   Widget _buildSearchField(BuildContext context) {
//     final searchController = TextEditingController();
//     Timer? _debounce;

//     return TextField(
//       controller: searchController,
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: Colors.white,
//         hintText: 'Search customers...',
//         prefixIcon: const Icon(Icons.search, color: Colors.blue),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(30),
//           borderSide: BorderSide.none,
//         ),
//         contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
//         suffixIcon: IconButton(
//           icon: const Icon(Icons.clear),
//           onPressed: () {
//             searchController.clear();
//             context.read<CustomerCubit>().showAllCustomers();
//           },
//         ),
//       ),
//       onChanged: (query) {
//         if (_debounce?.isActive ?? false) _debounce?.cancel();
//         _debounce = Timer(const Duration(milliseconds: 500), () {
//           final cubit = context.read<CustomerCubit>();
//           if (query.isEmpty) {
//             cubit.showAllCustomers();
//           } else {
//             cubit.searchCustomers(query);
//           }
//         });
//       },
//     );
//   }

//   Widget _buildCustomerList() {
//     return BlocConsumer<CustomerCubit, CustomerState>(
//       listener: (context, state) {
//         if (state is CustomerLoaded) {
//           final newCustomers = state.filteredCustomers;
//           _updateAnimatedList(newCustomers);
//         }
//       },
//       builder: (context, state) {
//         if (state is CustomerLoading) {
//           return const SizedBox(
//             height: 400,
//             child: Center(child: CircularProgressIndicator()),
//           );
//         } else if (state is CustomerError) {
//           return SizedBox(
//             height: 400,
//             child: Center(child: Text(state.message)),
//           );
//         } else if (state is CustomerLoaded) {
//           if (state.filteredCustomers.isEmpty) {
//             return _buildEmptyState(context);
//           }
//           return _buildCustomerListView();
//         }
//         return const SizedBox();
//       },
//     );
//   }

//   void _updateAnimatedList(List<Customer> newCustomers) {
//     for (int i = _displayedCustomers.length - 1; i >= 0; i--) {
//       if (!newCustomers.contains(_displayedCustomers[i])) {
//         final removedCustomer = _displayedCustomers[i];
//         _displayedCustomers.removeAt(i);
//         _listKey.currentState?.removeItem(
//           i,
//           (context, animation) => _buildCustomerCard(removedCustomer, context, animation),
//           duration: const Duration(milliseconds: 300),
//         );
//       }
//     }

//     for (int i = 0; i < newCustomers.length; i++) {
//       if (!_displayedCustomers.contains(newCustomers[i])) {
//         _displayedCustomers.insert(i, newCustomers[i]);
//         _listKey.currentState?.insertItem(
//           i,
//           duration: const Duration(milliseconds: 300),
//         );
//       }
//     }

//     _displayedCustomers = List.from(newCustomers);
//   }

//   Widget _buildEmptyState(BuildContext context) {
//     return SizedBox(
//       height: 400,
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
//             const SizedBox(height: 16),
//             Text(
//               'No customers found',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Add your first customer by tapping the + button',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCustomerListView() {
//     return AnimatedList(
//       key: _listKey,
//       padding: const EdgeInsets.symmetric(horizontal: 0),
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       initialItemCount: _displayedCustomers.length,
//       itemBuilder: (context, index, animation) {
//         if (index >= _displayedCustomers.length) {
//           return const SizedBox.shrink();
//         }
//         final customer = _displayedCustomers[index];
//         return _buildCustomerCard(customer, context, animation);
//       },
//     );
//   }

//   Widget _buildCustomerCard(Customer customer, BuildContext context, Animation<double> animation) {
//     final firstLetter = customer.fullName.isNotEmpty
//         ? customer.fullName[0].toUpperCase()
//         : '?';

//     return SizeTransition(
//       sizeFactor: animation,
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 16.0),
//         child: Material(
//           elevation: 4,
//           borderRadius: BorderRadius.circular(20),
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               gradient: LinearGradient(
//                 colors: [Colors.white, Colors.blue[50]!],
//                 begin: Alignment.topLeft, 
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: InkWell(
//               borderRadius: BorderRadius.circular(20),
//               onTap: () => _navigateToEdit(customer, context),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   children: [
//                     Hero(
//                       tag: 'avatar-${customer.id}',
//                       child: FutureBuilder<Image?>(
//                         future: Imagehandler.getSavedImage(customer.id),
//                         builder: (context, snapshot) {
//                           if(snapshot.connectionState == ConnectionState.waiting){
//                             return const CircularProgressIndicator();
//                           }
//                           if(snapshot.hasData && snapshot.data != null) {
//                             return CircleAvatar(
//                               radius: 24,
//                               backgroundImage: snapshot.data!.image,
//                             );
//                           }
//                           return CircleAvatar(
//                             radius: 24,
//                             backgroundColor: customer.avatarColor,
//                             child: Text(firstLetter, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
//                           );
//                         }
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             customer.fullName,
//                             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             customer.email,
//                             style: TextStyle(color: Colors.grey[700]), // Match secondary text color
//                           ),
//                         ],
//                       ),
//                     ),
//                     PopupMenuButton<String>(
//                       icon: const Icon(Icons.more_vert, color: Colors.grey),
//                       onSelected: (value) {
//                         switch (value) {
//                           case 'create_loan':
//                             _createLoan(customer, context);
//                             break;
//                           case 'edit':
//                             _navigateToEdit(customer, context);
//                             break;
//                           case 'delete':
//                             _deleteCustomer(context, customer);
//                             break;
//                         }
//                       },
//                       itemBuilder: (context) => [
//                         const PopupMenuItem(
//                           value: 'create_loan',
//                           child: Row(
//                             children: [
//                               Icon(Icons.add_circle, color: Colors.green),
//                               SizedBox(width: 8),
//                               Text('Create Loan'),
//                             ],
//                           ),
//                         ),
//                         const PopupMenuItem(
//                           value: 'edit',
//                           child: Row(
//                             children: [
//                               Icon(Icons.edit, color: Colors.blue),
//                               SizedBox(width: 8),
//                               Text('Edit Customer'),
//                             ],
//                           ),
//                         ),
//                         const PopupMenuItem(
//                           value: 'delete',
//                           child: Row(
//                             children: [
//                               Icon(Icons.delete, color: Colors.red),
//                               SizedBox(width: 8),
//                               Text('Delete Customer'),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _createLoan(Customer customer, BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddLoanScreen(customer: customer),
//       ),
//     );
//   }

//   void _navigateToEdit(Customer customer, BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddEditCustomerScreen(customer: customer),
//       ),
//     );
//   }

//   void _deleteCustomer(BuildContext context, Customer customer) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Customer'),
//         content: Text('Are you sure you want to delete ${customer.fullName}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               context.read<CustomerCubit>().deleteCustomer(customer.id);
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('${customer.fullName} deleted'),
//                   behavior: SnackBarBehavior.floating,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               );
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
// }



// import 'dart:async';
// import 'package:animations/animations.dart';
// import 'package:fintech_loan/cubit/Customer/customer_cubit.dart';
// import 'package:fintech_loan/cubit/Customer/customer_state.dart';
// import 'package:fintech_loan/models/customer.dart';
// import 'package:fintech_loan/screens/customers/add_edit_customer_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class CustomerListScreen extends StatefulWidget {
//   const CustomerListScreen({super.key});

//   @override
//   State<CustomerListScreen> createState() => _CustomerListScreenState();
// }

// class _CustomerListScreenState extends State<CustomerListScreen> {
//   final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Text('Customers', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
//         centerTitle: true,
//         elevation: 0,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.blue[700]!, Colors.lightBlue[400]!],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight
//             )
//           ),
//         ),
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           final cubit = context.read<CustomerCubit>();
//           await cubit.loadCustomers();
//         },
//         child: Column(
//           children: [
//             _buildSearchField(context),
//             Expanded(child: _buildCustomerList()),
//           ],
//         ),
//       ),
//       floatingActionButton: OpenContainer(
//         closedElevation: 6,
//         closedShape: const CircleBorder(),
//         closedBuilder: (_, openContainer) => FloatingActionButton(
//           onPressed: () => Future.delayed(Duration.zero, openContainer),
//           backgroundColor: Colors.blue,
//           child: const Icon(Icons.add, color: Colors.white),
//         ),
//         openBuilder: (_, __) => AddEditCustomerScreen(),
//         transitionDuration: const Duration(milliseconds: 500),
//         transitionType: ContainerTransitionType.fadeThrough
//       ),
//     );
//   }

//   Widget _buildSearchField(BuildContext context) {
//     final searchController = TextEditingController();
//     Timer? _debounce;

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: TextField(
//         controller: searchController,
//         decoration: InputDecoration(
//           filled: true,
//           fillColor: Colors.white,
//           hintText: 'Search customers...',
//           prefixIcon: const Icon(Icons.search, color: Colors.blue),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30),
//             borderSide: BorderSide.none,
//           ),
//           contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
//           suffixIcon: IconButton(
//             icon: const Icon(Icons.clear),
//             onPressed: () {
//               searchController.clear();
//               context.read<CustomerCubit>().showAllCustomers();
//             }, 
//           )
//         ),
//         onChanged: (query) {
//           if (_debounce?.isActive ?? false) _debounce?.cancel();
//           _debounce = Timer(const Duration(milliseconds: 500), () {
//             final cubit = context.read<CustomerCubit>();
//             if (query.isEmpty) {
//               cubit.showAllCustomers();
//             } else {
//               cubit.searchCustomers(query);
//             }
//           });
//         },
//       ),
//     );
//   }

//   Widget _buildCustomerList() {
//     return BlocConsumer<CustomerCubit, CustomerState>(
//       listener: (context, state) {
//         if(state is CustomerLoaded) {
//           final previousState = context.read<CustomerCubit>().state;
//           if(previousState is CustomerLoaded) {
//             final previousCount = previousState.filteredCustomers.length;
//             final currentCount = state.filteredCustomers.length;
//             if(currentCount < previousCount) {
//               final removeIndex = previousState.filteredCustomers.indexWhere(
//                 (c) => !state.filteredCustomers.contains(c),
//               );
//               if(removeIndex != -1) {
//                 _listKey.currentState?.removeItem(
//                   removeIndex,
//                   (context, animation) => _buildCustomerCard(
//                     previousState.filteredCustomers[removeIndex], 
//                     context, 
//                     animation
//                   ),
//                   duration: const Duration(microseconds: 300)
//                 );
//               }
//             }
//           }
//         }
//       },
//       builder: (context, state) {
//         if (state is CustomerLoading) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (state is CustomerError) {
//           return Center(child: Text(state.message));
//         } else if (state is CustomerLoaded) {
//           if (state.filteredCustomers.isEmpty) {
//             return _buildEmptyState(context);
//           }
//           return _buildCustomerListView(state.filteredCustomers);
//         }
//         return const SizedBox();
//       },
//     );
//   }

//   Widget _buildEmptyState(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(
//             'No customers found',
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Add your first customer by tapping the + button',
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCustomerListView(List<Customer> customers) {
//     return AnimatedList(
//       key: _listKey,
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       initialItemCount: customers.length,
//       itemBuilder: (context, index, animation) {
//         final customer = customers[index];
//         return _buildCustomerCard(customer, context, animation);
//       },
//     );
//   }

//   Widget _buildCustomerCard(Customer customer, BuildContext context, Animation<double> animation) {
//     final firstLetter = customer.fullName.isNotEmpty
//         ? customer.fullName[0].toUpperCase()
//         : '?';

//     return SizeTransition(
//       sizeFactor: animation,
//       child: Card(
//         elevation: 4,
//         margin: const EdgeInsets.only(bottom: 16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(12),
//           onTap: () => _navigateToEdit(customer, context),
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               children: [
//                 Hero(
//                   tag: 'avatar-${customer.id}',
//                   child: CircleAvatar(
//                     backgroundColor: customer.avatarColor,
//                     child: Text(firstLetter, style: const TextStyle(color: Colors.white)),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         customer.fullName,
//                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         customer.email,
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.edit, color: Colors.blue),
//                       onPressed: () => _navigateToEdit(customer, context),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () => _deleteCustomer(context, customer),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _navigateToEdit(Customer customer, BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddEditCustomerScreen(customer: customer),
//       ),
//     );
//   }

//   void _deleteCustomer(BuildContext context, Customer customer) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Customer'),
//         content: Text('Are you sure you want to delete ${customer.fullName}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               context.read<CustomerCubit>().deleteCustomer(customer.id);
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('${customer.fullName} deleted'),
//                   behavior: SnackBarBehavior.floating,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               );
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
// }




// import 'dart:async';

// import 'package:animations/animations.dart';
// import 'package:fintech_loan/cubit/CustomerCubit.dart';
// import 'package:fintech_loan/models/customer.dart';
// import 'package:fintech_loan/screens/customers/add_edit_customer_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../cubit/CustomerState.dart';

// class CustomerListScreen extends StatelessWidget{
//   const CustomerListScreen({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => CustomerCubit()..loadCustomers(),
//       child: Scaffold(
//         backgroundColor: Colors.grey[50],
//         appBar: AppBar(
//           title: const Text('Customers', style: TextStyle(fontWeight: FontWeight.bold)),
//           centerTitle: true,
//           elevation: 0,
//           flexibleSpace: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.blue[700]!, Colors.lightBlue[400]!],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight
//               )
//             ),
//           ),
//         ),
//         body: Column(
//           children: [
//             _buildSearchField(),
//             Expanded(child: _buildCustomerList(),)
//           ],
//         ),
//         floatingActionButton: OpenContainer(
//           closedBuilder: (_, openContainer) => FloatingActionButton(
//             onPressed: () {
//               // Delay the opening to avoid build conflict
//               Future.delayed(Duration.zero, openContainer);
//             },
//             backgroundColor: Colors.blue,
//             child: Icon(Icons.add),
//           ),
//           openBuilder: (_, __) => AddEditCustomerScreen(),
//           transitionDuration: Duration(milliseconds: 500),
//         )
//       ),
//     );
//   }

//   Widget _buildSearchField() {
//     final SearchController = TextEditingController()
//     Timer? _debounce;
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: BlocBuilder<CustomerCubit,CustomerState>(
//           builder: (context, state) {
//             return TextField(
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.white,
//                 hintText: 'Search customers...',
//                 prefixIcon: Icon(Icons.search, color: Colors.blue),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20)
//               ),
//               onChanged: (query){
//                 if (_debounce?.isActive ?? false) _debounce?.cancel();
//                 _debounce = Timer(Duration(milliseconds: 500), () {
//                   final cubit = context.read<CustomerCubit>();
//                   if(query.isEmpty){
//                     cubit.showAllCustomers();
//                   } else {
//                     cubit.searchCustomers(query);
//                   }
//                 });
//               },
//             );
//           }
//       ),
//     );
//   }

//   Widget _buildCustomerList() {
//     return BlocBuilder<CustomerCubit, CustomerState>(
//       builder: (context, state) {
//         if(state is CustomerLoading){
//           return Center(child: CircularProgressIndicator());
//         } else if(state is CustomerError) {
//           return Center(child: Text(state.message));
//         } else if(state is CustomerLoaded){
//           return AnimatedList(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             initialItemCount: state.customers.length,
//             itemBuilder: (context, index, animation){
//               final customer = state.customers[index];
//               return _buildCustomerCard(customer, context, animation);
//             }
//           );
//         }
//         return SizedBox();
//       },
//     );
//   }
//   Widget _buildCustomerCard(Customer customer, BuildContext context, Animation<double> animation) {
//     final firstLetter = customer.fullName.isNotEmpty
//         ? customer.fullName[0].toUpperCase()
//         : '?';
//   return SizeTransition(
//     sizeFactor: animation,
//     child: Card(
//       elevation: 4,
//       margin: EdgeInsets.only(bottom: 16),
//       child: ListTile(
//         leading: Hero(
//           tag: 'avatar-${customer.id}',
//           child: CircleAvatar(
//             backgroundColor: Color(0xFF0000FF),
//             child: Text(firstLetter),
//           ),
//         ),
//         title: Text(customer.fullName),
//         subtitle: Text(customer.email),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               icon: Icon(Icons.edit),
//               onPressed: () => _navigateToEdit(customer, context),
//             ),
//             IconButton(
//               icon: Icon(Icons.delete),
//               onPressed: () => _deleteCustomer(context, customer),
//             ),
//           ],
//         ),
//         onTap: () => _navigateToEdit(customer, context),
//       ),
//     ),
//   );
// }

// void _navigateToEdit(Customer customer, BuildContext context) {
//   // Use postFrame callback to avoid build conflicts
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddEditCustomerScreen(customer: customer),
//       ),
//     );
//   });
// }
//   _deleteCustomer(BuildContext context, Customer customer) {
//     showDialog(
//       context: context, 
//       builder: (context) => AlertDialog(
//         title: Text('Delete Customer'),
//         content: Text('Are you sure you want to delete ${customer.fullName}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//               onPressed: (){
//                 context.read<CustomerCubit>().deleteCustomer(customer.id);
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('${customer.fullName} deleted'),
//                     behavior: SnackBarBehavior.floating,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10)),
//                   ),
//                 );
//               }, 
//               child: const Text("Delete", style: TextStyle(color: Colors.red)),
//           )
//         ],
//       )
//     );
//   }
// }
import 'package:fintech_loan/cubit/Customer/customer_state.dart';
import 'package:fintech_loan/models/customer.dart';
import 'package:fintech_loan/models/loan.dart';
import 'package:fintech_loan/services/localStorage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class CustomerCubit extends Cubit<CustomerState> {
  CustomerCubit() : super(CustomerInitial());
  
  int _pageSize = 20;
  int _currentPage = 0;
  List<Customer> _allLoadedCustomers = [];
  bool _hasMore = true;

  Future<void> loadCustomers({bool loadMore = false}) async {
    try {
      if(loadMore) {
        _currentPage++;
      } else {
        _currentPage = 0;
        _allLoadedCustomers.clear();
        emit(CustomerLoading());
      }
      final allCustomers = await LocalStorageService.getCustomers();
      final startIndex = _currentPage * _pageSize;
      final endIndex = startIndex + _pageSize;
      final newCustomers = allCustomers.sublist(
        startIndex, 
        endIndex > allCustomers.length ? allCustomers.length : endIndex,
      );
      _allLoadedCustomers.addAll(newCustomers);
      _hasMore = endIndex < allCustomers.length;
      emit(CustomerLoaded(allCustomers: allCustomers, filteredCustomers: _allLoadedCustomers, hasMore: _hasMore));
    } catch (e) {
      emit(CustomerError(message: 'Failed to load customers: $e'));
    }
  }
  
  Future<void> addCustomer(Customer customer) async{
    try {
      emit(CustomerLoading());
      final customers = await LocalStorageService.getCustomers();
      // Add the new customer to the list
      final updatedCustomers = [...customers, customer];
      print('Customer JSON: ${customer.toJson()}');
      await LocalStorageService.saveCustomers(updatedCustomers);
      emit(CustomerLoaded(allCustomers: updatedCustomers, filteredCustomers: updatedCustomers));
    } catch (e){
      emit(CustomerError(message: 'Failed to add customer: $e'));
    }
  }
  
  void updateCustomer(Customer customer) async {
    try {
      emit(CustomerLoading());
      final customers = await LocalStorageService.getCustomers();
      // Replace the existing customer with the updated one based on ID
      final updatedCustomers = customers.map((c) {
        return c.id == customer.id ? customer : c;
      }).toList();
      await LocalStorageService.saveCustomers(updatedCustomers);
      emit(CustomerLoaded(allCustomers: updatedCustomers, filteredCustomers: updatedCustomers));
    } catch (e) {
      emit(CustomerError(message: 'Failed to update customer: $e'));
    }
  }

  Future<void> deleteCustomer(String customerId) async{
    try {
      emit(CustomerLoading());
      final customers = await LocalStorageService.getCustomers();
      final updatedCustomers = customers.where((customer) => customer.id != customerId).toList();
      await LocalStorageService.saveCustomers(updatedCustomers);
      // Update filteredCustomers based on the current search query
      final currentState = state;
      List<Customer> updatedFilteredCustomers = updatedCustomers;
      if(currentState is CustomerLoaded && currentState.filteredCustomers != currentState.allCustomers){
        updatedFilteredCustomers = currentState.filteredCustomers.where((customer) => customer.id != customerId).toList();
      }
      emit(CustomerLoaded(allCustomers: updatedCustomers, filteredCustomers: updatedFilteredCustomers));
    } catch(e) {
      emit(CustomerError(message: 'Failed to delete customer: $e'));
    }
  }
  
  Future<void> searchCustomers(String query) async{
    try {
      emit(CustomerLoading());
      final customers = await LocalStorageService.getCustomers();
      final filteredCustomers = customers.where((customer) => 
        customer.fullName.toLowerCase().contains(query.toLowerCase()) ||
        customer.email.toLowerCase().contains(query.toLowerCase())
      ).toList();
      emit(CustomerLoaded(allCustomers: customers, filteredCustomers: filteredCustomers));
    } catch (e) {
      emit(CustomerError(message: 'Failed to search customers: $e'));
    }
  }

  Future<void> showAllCustomers() async {
    try {
      emit(CustomerLoading());
      final customers = await LocalStorageService.getCustomers();
      emit(CustomerLoaded(allCustomers: customers, filteredCustomers: customers));
    } catch (e) {
      emit(CustomerError(message: 'Failed to show all customers: $e'));
    }
  }

  Future<void> createLoanForCustomer(Customer customer, Loan loan) async {
    try{
      emit(CustomerLoading());
      final loans = await LocalStorageService.getLoans();
      final newLoan = Loan(
        id: loan.id, 
        customerId: loan.customerId, 
        loanType: loan.loanType, 
        loanAmount: loan.loanAmount, 
        interestRate: loan.interestRate, 
        durationMonths: loan.durationMonths
      );
      final updatedLoans = [...loans, newLoan];
      await LocalStorageService.saveLoans(updatedLoans);
      final customers = await LocalStorageService.getCustomers();
      emit(CustomerLoaded(allCustomers: customers, filteredCustomers: customers));
    } catch (e) {
      emit(CustomerError(message: 'Failed to create loan for customer: $e'));
    }
  }

  Future<void> sortCustomers(String sortOption) async {
    try {
      emit(CustomerLoading());
      final customers = await LocalStorageService.getCustomers();
      List<Customer> sortedCustomers = List.from(customers);
      switch (sortOption) {
        case 'name_asc':
          sortedCustomers.sort((a, b) => a.fullName.compareTo(b.fullName));
          break;
        case 'name_desc':
          sortedCustomers.sort((a, b) => b.fullName.compareTo(a.fullName));
          break; 
        case 'date_newest':
          sortedCustomers.sort((a, b) => b.dateOfRegistration.compareTo(a.dateOfRegistration));
          break;
        case 'date_oldest':
          sortedCustomers.sort((a, b) => a.dateOfRegistration.compareTo(b.dateOfRegistration));
          break;
      }
      emit(CustomerLoaded(allCustomers: customers, filteredCustomers: sortedCustomers));
    } catch (e) {
      emit(CustomerError(message: 'Failed to sort customers: $e'));
    }
  }

  Future<void> filterCustomersByType(String type) async{
    try {
      emit(CustomerLoading());
      final customers = await LocalStorageService.getCustomers();
      List<Customer> filteredCustomers = type == 'All' ? customers : customers.where((customer) => customer.customerType == type).toList();
      emit(CustomerLoaded(allCustomers: customers, filteredCustomers: filteredCustomers));
    } catch (e) {
      emit(CustomerError(message: 'Failed to filter custoemrs: $e'));
    }
  }

  Future<int> getActiveLoansCount(String customerId) async {
    final loans = await LocalStorageService.getLoans();
    return loans.where((loan) => loan.customerId == customerId).length;
  }

  Future<Map<String, dynamic>> getCustomerStatistic() async {
    final customers = await LocalStorageService.getCustomers();
    final loans = await LocalStorageService.getLoans();

    final totalCustomers = customers.length;
    final activeLoans = loans.length;
    final customerTypeBreakdown = {
      'Individual' : customers.where((c) => c.customerType == 'Individual').length,
      'Corporate' : customers.where((c) => c.customerType == 'Corporate').length,
      'VIP' : customers.where((c) => c.customerType == 'VIP').length,
    };
    return {
      'totalCustomers' : totalCustomers, 
      'activeLoans' : activeLoans, 
      'customerTypeBreakdown' : customerTypeBreakdown
    };
  }
}
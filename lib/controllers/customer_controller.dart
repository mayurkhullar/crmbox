import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../services/customer_service.dart';
import '../services/auth_service.dart';

class CustomerController extends GetxController {
  static CustomerController get to => Get.find();
  
  final _customerService = CustomerService.to;
  final searchController = TextEditingController();
  
  // Observable state
  final customers = <CustomerModel>[].obs;
  final isLoading = false.obs;
  final statistics = <String, int>{}.obs;
  
  // Filters
  final selectedStatus = Rx<CustomerStatus?>(null);
  final selectedAssignee = Rx<String?>(null);
  final selectedTeam = Rx<String?>(null);
  final selectedSource = Rx<String?>(null);

  // Pagination (if needed later)
  final hasMore = true.obs;
  final isFetchingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Start listening to customers stream when controller is initialized
    _initCustomersStream();
    // Load initial statistics
    loadStatistics();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _initCustomersStream() {
    isLoading.value = true;
    
    _customerService.streamCustomers(
      searchQuery: searchController.text,
      status: selectedStatus.value,
      assignedTo: selectedAssignee.value,
      teamId: selectedTeam.value,
      source: selectedSource.value,
    ).listen(
      (data) {
        customers.value = data;
        isLoading.value = false;
      },
      onError: (error) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Failed to load customers: $error',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      },
    );
  }

  // Apply filters
  void applyFilters({
    CustomerStatus? status,
    String? assignedTo,
    String? teamId,
    String? source,
  }) {
    selectedStatus.value = status;
    selectedAssignee.value = assignedTo;
    selectedTeam.value = teamId;
    selectedSource.value = source;
    _initCustomersStream();
  }

  // Clear all filters
  void clearFilters() {
    selectedStatus.value = null;
    selectedAssignee.value = null;
    selectedTeam.value = null;
    selectedSource.value = null;
    searchController.clear();
    _initCustomersStream();
  }

  // Search customers
  void searchCustomers(String query) {
    searchController.text = query;
    _initCustomersStream();
  }

  // Add new customer
  Future<void> addCustomer({
    required String name,
    required String email,
    required String phone,
    String? address,
    String? source,
    String? assignedTo,
    String? teamId,
  }) async {
    try {
      final user = AuthService.to.userModel;
      if (user == null) throw 'User not authenticated';

      final customer = CustomerModel(
        id: '', // Will be set by Firestore
        name: name,
        email: email,
        phone: phone,
        address: address,
        source: source,
        assignedTo: assignedTo ?? user.uid,
        teamId: teamId ?? user.teamId,
        status: CustomerStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: user.uid,
      );

      await _customerService.addCustomer(customer);
      Get.back(); // Close dialog/form
      Get.snackbar(
        'Success',
        'Customer added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add customer: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // Update customer
  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await _customerService.updateCustomer(customer);
      Get.back(); // Close dialog/form
      Get.snackbar(
        'Success',
        'Customer updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update customer: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // Delete customer
  Future<void> deleteCustomer(String customerId) async {
    try {
      await _customerService.deleteCustomer(customerId);
      Get.back(); // Close confirmation dialog
      Get.snackbar(
        'Success',
        'Customer deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete customer: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // Add note to customer
  Future<void> addNote(String customerId, String content, {bool isPrivate = false}) async {
    try {
      await _customerService.addNote(
        customerId,
        content,
        isPrivate: isPrivate,
      );
      Get.back(); // Close note dialog
      Get.snackbar(
        'Success',
        'Note added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add note: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // Reassign customer
  Future<void> reassignCustomer(String customerId, String? assignedTo, String? teamId) async {
    try {
      await _customerService.reassignCustomer(customerId, assignedTo, teamId);
      Get.back(); // Close reassign dialog
      Get.snackbar(
        'Success',
        'Customer reassigned successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reassign customer: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // Load customer statistics
  Future<void> loadStatistics() async {
    try {
      final stats = await _customerService.getStatistics();
      statistics.value = stats;
    } catch (e) {
      print('Failed to load statistics: $e');
    }
  }
}

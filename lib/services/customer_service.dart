import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/base_model.dart';
import '../models/customer_model.dart';
import '../services/auth_service.dart';

class CustomerService extends BaseService<CustomerModel> {
  static CustomerService get to => Get.find();
  
  CustomerService() : super('customers');

  @override
  CustomerModel fromMap(Map<String, dynamic> map) {
    return CustomerModel.fromMap(map);
  }

  // Get customer by ID
  @override
  Future<CustomerModel?> get(String id) async {
    final doc = await collectionRef.doc(id).get();
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    data['id'] = doc.id;
    return fromMap(BaseModel.processTimestamps(data));
  }

  // Stream customers based on user's role and team
  Stream<List<CustomerModel>> streamCustomers({
    String? searchQuery,
    CustomerStatus? status,
    String? assignedTo,
    String? teamId,
    String? source,
  }) {
    final user = AuthService.to.userModel;
    if (user == null) return const Stream.empty();

    Query<Map<String, dynamic>> query = collectionRef
        .where('isDeleted', isEqualTo: false)
        .where('isActive', isEqualTo: true);

    // Apply role-based filters
    if (user.role != UserRole.admin && user.role != UserRole.manager) {
      if (user.teamId != null) {
        query = query.where('teamId', isEqualTo: user.teamId);
      } else {
        query = query.where('assignedTo', isEqualTo: user.uid);
      }
    }

    // Apply additional filters
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    
    if (assignedTo != null) {
      query = query.where('assignedTo', isEqualTo: assignedTo);
    }
    
    if (teamId != null) {
      query = query.where('teamId', isEqualTo: teamId);
    }
    
    if (source != null) {
      query = query.where('source', isEqualTo: source);
    }

    // Order by most recently updated
    query = query.orderBy('updatedAt', descending: true);

    return query.snapshots().map((snapshot) {
      final customers = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return fromMap(BaseModel.processTimestamps(data));
      }).toList();

      // Apply search filter in memory if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        return customers.where((customer) {
          return customer.name.toLowerCase().contains(searchLower) ||
              customer.email.toLowerCase().contains(searchLower) ||
              customer.phone.contains(searchQuery);
        }).toList();
      }

      return customers;
    });
  }

  // Add a new customer
  Future<String> addCustomer(CustomerModel customer) async {
    // Check for duplicate email or phone
    final duplicates = await collectionRef
        .where('email', isEqualTo: customer.email)
        .where('isDeleted', isEqualTo: false)
        .get();

    if (duplicates.docs.isNotEmpty) {
      throw 'A customer with this email already exists';
    }

    return add(customer);
  }

  // Update customer
  Future<void> updateCustomer(CustomerModel customer) async {
    // Check for duplicate email if email is being changed
    final existing = await get(customer.id);
    if (existing != null && existing.email != customer.email) {
      final duplicates = await collectionRef
          .where('email', isEqualTo: customer.email)
          .where('isDeleted', isEqualTo: false)
          .get();

      if (duplicates.docs.isNotEmpty) {
        throw 'A customer with this email already exists';
      }
    }

    await update(customer.id, customer);
  }

  // Soft delete customer
  Future<void> deleteCustomer(String id) async {
    final user = AuthService.to.userModel;
    if (user == null) throw 'User not authenticated';

    final customer = await get(id);
    if (customer == null) throw 'Customer not found';

    final updatedCustomer = customer.copyWith(
      isDeleted: true,
      deletedAt: DateTime.now(),
      deletedBy: user.uid,
      status: CustomerStatus.archived,
    );

    await update(id, updatedCustomer);
  }

  // Add a note to customer
  Future<void> addNote(String customerId, String content, {bool isPrivate = false}) async {
    final user = AuthService.to.userModel;
    if (user == null) throw 'User not authenticated';

    final customer = await get(customerId);
    if (customer == null) throw 'Customer not found';

    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      createdBy: user.uid,
      createdAt: DateTime.now(),
      isPrivate: isPrivate,
    );

    final updatedCustomer = customer.copyWith(
      notes: [...customer.notes, note],
      updatedAt: DateTime.now(),
    );

    await update(customerId, updatedCustomer);
  }

  // Reassign customer
  Future<void> reassignCustomer(String customerId, String? assignedTo, String? teamId) async {
    final customer = await get(customerId);
    if (customer == null) throw 'Customer not found';

    final updatedCustomer = customer.copyWith(
      assignedTo: assignedTo,
      teamId: teamId,
      updatedAt: DateTime.now(),
    );

    await update(customerId, updatedCustomer);
  }

  // Get customer statistics
  Future<Map<String, int>> getStatistics() async {
    final user = AuthService.to.userModel;
    if (user == null) throw 'User not authenticated';

    Query<Map<String, dynamic>> query = collectionRef
        .where('isDeleted', isEqualTo: false)
        .where('isActive', isEqualTo: true);

    // Apply role-based filters
    if (user.role != UserRole.admin && user.role != UserRole.manager) {
      if (user.teamId != null) {
        query = query.where('teamId', isEqualTo: user.teamId);
      } else {
        query = query.where('assignedTo', isEqualTo: user.uid);
      }
    }

    final snapshot = await query.get();
    final customers = snapshot.docs.map((doc) => CustomerModel.fromMap({
      ...doc.data(),
      'id': doc.id,
    })).toList();

    return {
      'total': customers.length,
      'active': customers.where((c) => c.status == CustomerStatus.active).length,
      'inactive': customers.where((c) => c.status == CustomerStatus.inactive).length,
      'archived': customers.where((c) => c.status == CustomerStatus.archived).length,
    };
  }
}

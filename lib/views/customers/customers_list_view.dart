import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_config.dart';
import '../../controllers/customer_controller.dart';
import '../../models/customer_model.dart';
import '../../services/auth_service.dart';
import '../shared/shell_view.dart';
import '../shared/widgets/common_widgets.dart';

class CustomersListView extends StatelessWidget {
  const CustomersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ShellView(
      child: GetX<CustomerController>(
        init: CustomerController(),
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with stats
                _buildHeader(controller),
                const SizedBox(height: 24),

                // Search and filters
                _buildSearchAndFilters(controller),
                const SizedBox(height: 24),

                // Customers list
                Expanded(
                  child: _buildCustomersList(controller),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(CustomerController controller) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              // Total customers stat
              CustomCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Customers',
                      style: TextStyle(
                        color: AppConfig.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${controller.statistics['total'] ?? 0}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Active customers stat
              CustomCard(
                padding: const EdgeInsets.all(16),
                color: AppConfig.success.withOpacity(0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active',
                      style: TextStyle(
                        color: AppConfig.success,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${controller.statistics['active'] ?? 0}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppConfig.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddCustomerDialog(Get.context!),
          icon: const Icon(Icons.add),
          label: const Text('Add Customer'),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(CustomerController controller) {
    return Row(
      children: [
        // Search field
        Expanded(
          child: SearchField(
            controller: controller.searchController,
            hint: 'Search customers...',
            onChanged: controller.searchCustomers,
          ),
        ),
        const SizedBox(width: 16),

        // Status filter
        DropdownButton<CustomerStatus>(
          value: controller.selectedStatus.value,
          hint: const Text('Status'),
          items: CustomerStatus.values.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status.displayName),
            );
          }).toList(),
          onChanged: (value) {
            controller.applyFilters(status: value);
          },
        ),
        const SizedBox(width: 16),

        // Clear filters button
        TextButton.icon(
          onPressed: controller.clearFilters,
          icon: const Icon(Icons.clear),
          label: const Text('Clear Filters'),
        ),
      ],
    );
  }

  Widget _buildCustomersList(CustomerController controller) {
    if (controller.isLoading.value) {
      return const Center(child: LoadingSpinner());
    }

    if (controller.customers.isEmpty) {
      return EmptyState(
        message: 'No customers found',
        icon: Icons.people_outline,
        onAction: () => _showAddCustomerDialog(Get.context!),
        actionLabel: 'Add Customer',
      );
    }

    return ListView.separated(
      itemCount: controller.customers.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final customer = controller.customers[index];
        return _CustomerListItem(
          customer: customer,
          onTap: () => _showCustomerDetails(customer),
        );
      },
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    Get.dialog(
      Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Customer',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter customer name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter customer name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter customer email',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter customer email';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    hintText: 'Enter customer phone',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter customer phone';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address (Optional)',
                    hintText: 'Enter customer address',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          CustomerController.to.addCustomer(
                            name: nameController.text,
                            email: emailController.text,
                            phone: phoneController.text,
                            address: addressController.text,
                          );
                        }
                      },
                      child: const Text('Add Customer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCustomerDetails(CustomerModel customer) {
    // TODO: Navigate to customer details page
    Get.toNamed('/customers/${customer.id}');
  }
}

class _CustomerListItem extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onTap;

  const _CustomerListItem({
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppConfig.primaryColor,
        child: Text(
          customer.name.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(customer.name),
      subtitle: Text(customer.email),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusBadge(
            text: customer.status.displayName,
            color: _getStatusColor(customer.status),
          ),
          if (AuthService.to.userModel?.role == UserRole.admin ||
              AuthService.to.userModel?.role == UserRole.manager) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showCustomerActions(context),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(CustomerStatus status) {
    switch (status) {
      case CustomerStatus.active:
        return AppConfig.success;
      case CustomerStatus.inactive:
        return AppConfig.warning;
      case CustomerStatus.archived:
        return AppConfig.textMuted;
    }
  }

  void _showCustomerActions(BuildContext context) {
    final controller = CustomerController.to;

    Get.dialog(
      Dialog(
        child: Container(
          width: 300,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Customer'),
                onTap: () {
                  Get.back();
                  // TODO: Show edit dialog
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Reassign'),
                onTap: () {
                  Get.back();
                  // TODO: Show reassign dialog
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: AppConfig.danger,
                ),
                title: Text(
                  'Delete Customer',
                  style: TextStyle(color: AppConfig.danger),
                ),
                onTap: () {
                  Get.back();
                  Get.dialog(
                    ConfirmationDialog(
                      title: 'Delete Customer',
                      message: 'Are you sure you want to delete this customer? This action cannot be undone.',
                      confirmLabel: 'Delete',
                      confirmColor: AppConfig.danger,
                      onConfirm: () => controller.deleteCustomer(customer.id),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

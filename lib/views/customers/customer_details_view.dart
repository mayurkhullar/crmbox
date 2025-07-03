import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_config.dart';
import '../../controllers/customer_controller.dart';
import '../../models/customer_model.dart';
import '../../services/auth_service.dart';
import '../shared/shell_view.dart';
import '../shared/widgets/common_widgets.dart';

class CustomerDetailsView extends StatelessWidget {
  final String customerId;

  const CustomerDetailsView({
    super.key,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    return ShellView(
      child: GetX<CustomerController>(
        init: CustomerController(),
        builder: (controller) {
          final customer = controller.customers
              .firstWhereOrNull((c) => c.id == customerId);

          if (customer == null) {
            return const Center(
              child: Text('Customer not found'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button and actions
                _buildHeader(context, customer),
                const SizedBox(height: 24),

                // Customer information and tabs
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer info sidebar
                      SizedBox(
                        width: 300,
                        child: _CustomerInfoCard(customer: customer),
                      ),
                      const SizedBox(width: 24),

                      // Tabs section
                      Expanded(
                        child: _CustomerTabs(customer: customer),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CustomerModel customer) {
    return Row(
      children: [
        // Back button
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        const SizedBox(width: 16),

        // Customer name and status
        Expanded(
          child: Row(
            children: [
              Text(
                customer.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(width: 16),
              StatusBadge(
                text: customer.status.displayName,
                color: _getStatusColor(customer.status),
              ),
            ],
          ),
        ),

        // Action buttons
        if (AuthService.to.userModel?.role == UserRole.admin ||
            AuthService.to.userModel?.role == UserRole.manager) ...[
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Show edit dialog
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Customer'),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Show reassign dialog
            },
            icon: const Icon(Icons.person_outline),
            label: const Text('Reassign'),
          ),
        ],
      ],
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
}

class _CustomerInfoCard extends StatelessWidget {
  final CustomerModel customer;

  const _CustomerInfoCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer avatar and basic info
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppConfig.primaryColor,
                child: Text(
                  customer.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'Added on ${_formatDate(customer.createdAt)}',
                      style: TextStyle(
                        color: AppConfig.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),

          // Contact information
          _InfoSection(
            title: 'Contact Information',
            items: [
              _InfoItem(
                icon: Icons.email_outlined,
                label: 'Email',
                value: customer.email,
              ),
              _InfoItem(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: customer.phone,
              ),
              if (customer.address != null)
                _InfoItem(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: customer.address!,
                ),
            ],
          ),
          const Divider(height: 32),

          // Assignment information
          _InfoSection(
            title: 'Assignment',
            items: [
              _InfoItem(
                icon: Icons.person_outline,
                label: 'Assigned To',
                value: customer.assignedTo ?? 'Unassigned',
              ),
              if (customer.teamId != null)
                _InfoItem(
                  icon: Icons.groups_outlined,
                  label: 'Team',
                  value: customer.teamId!,
                ),
            ],
          ),
          const Divider(height: 32),

          // Source information
          if (customer.source != null) ...[
            _InfoSection(
              title: 'Source',
              items: [
                _InfoItem(
                  icon: Icons.source_outlined,
                  label: 'Lead Source',
                  value: customer.source!,
                ),
              ],
            ),
            const Divider(height: 32),
          ],

          // Metadata
          if (customer.metadata != null && customer.metadata!.isNotEmpty)
            _InfoSection(
              title: 'Additional Information',
              items: customer.metadata!.entries.map((entry) {
                return _InfoItem(
                  icon: Icons.info_outline,
                  label: entry.key,
                  value: entry.value.toString(),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _CustomerTabs extends StatelessWidget {
  final CustomerModel customer;

  const _CustomerTabs({required this.customer});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Destinations'),
              Tab(text: 'Bookings'),
              Tab(text: 'Payments'),
              Tab(text: 'Notes'),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: TabBarView(
              children: [
                _DestinationsTab(customer: customer),
                _BookingsTab(customer: customer),
                _PaymentsTab(customer: customer),
                _NotesTab(customer: customer),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<_InfoItem> items;

  const _InfoSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppConfig.textMuted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppConfig.textMuted,
                    fontSize: 12,
                  ),
                ),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder tab contents
class _DestinationsTab extends StatelessWidget {
  final CustomerModel customer;

  const _DestinationsTab({required this.customer});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Destinations tab content'),
    );
  }
}

class _BookingsTab extends StatelessWidget {
  final CustomerModel customer;

  const _BookingsTab({required this.customer});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Bookings tab content'),
    );
  }
}

class _PaymentsTab extends StatelessWidget {
  final CustomerModel customer;

  const _PaymentsTab({required this.customer});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Payments tab content'),
    );
  }
}

class _NotesTab extends StatelessWidget {
  final CustomerModel customer;

  const _NotesTab({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showAddNoteDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Note'),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: customer.notes.isEmpty
              ? const EmptyState(
                  message: 'No notes added yet',
                  icon: Icons.note_outlined,
                )
              : ListView.separated(
                  itemCount: customer.notes.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final note = customer.notes[index];
                    return ListTile(
                      title: Text(note.content),
                      subtitle: Text(
                        'Added by ${note.createdBy} on ${_formatDate(note.createdAt)}',
                        style: TextStyle(
                          color: AppConfig.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      trailing: note.isPrivate
                          ? Icon(
                              Icons.lock_outline,
                              color: AppConfig.textMuted,
                              size: 16,
                            )
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddNoteDialog(BuildContext context) {
    final contentController = TextEditingController();
    final isPrivate = false.obs;

    Get.dialog(
      Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Note',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Note Content',
                  hintText: 'Enter note content',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Obx(() => CheckboxListTile(
                    value: isPrivate.value,
                    onChanged: (value) => isPrivate.value = value!,
                    title: const Text('Private Note'),
                    subtitle: const Text(
                      'Private notes are only visible to team members',
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  )),
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
                      if (contentController.text.isNotEmpty) {
                        CustomerController.to.addNote(
                          customer.id,
                          contentController.text,
                          isPrivate: isPrivate.value,
                        );
                      }
                    },
                    child: const Text('Add Note'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

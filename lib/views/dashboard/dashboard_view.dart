import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_config.dart';
import '../../services/auth_service.dart';
import '../shared/shell_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ShellView(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _WelcomeSection(),
            const SizedBox(height: 32),

            // Quick Stats
            _QuickStats(),
            const SizedBox(height: 32),

            // Recent Activity and Tasks
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 1200) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _RecentActivity()),
                      const SizedBox(width: 24),
                      Expanded(child: _TasksList()),
                    ],
                  );
                }
                return Column(
                  children: [
                    _RecentActivity(),
                    const SizedBox(height: 24),
                    _TasksList(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = AuthService.to.userModel;
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, ${user?.name ?? "User"}!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Here\'s what\'s happening today',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppConfig.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: MediaQuery.of(context).size.width > 1200 ? 1.5 : 1.2,
      children: [
        _StatCard(
          icon: Icons.people_outline,
          label: 'Active Customers',
          value: '124',
          trend: '+12%',
          trendUp: true,
          color: AppConfig.primaryColor,
        ),
        _StatCard(
          icon: Icons.book_outlined,
          label: 'New Bookings',
          value: '28',
          trend: '+5%',
          trendUp: true,
          color: AppConfig.accentColor,
        ),
        _StatCard(
          icon: Icons.pending_actions_outlined,
          label: 'Pending Tasks',
          value: '15',
          trend: '-3%',
          trendUp: false,
          color: AppConfig.warning,
        ),
        _StatCard(
          icon: Icons.payments_outlined,
          label: 'Revenue (MTD)',
          value: '₹4.2L',
          trend: '+18%',
          trendUp: true,
          color: AppConfig.success,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String trend;
  final bool trendUp;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.trend,
    required this.trendUp,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (trendUp ? AppConfig.success : AppConfig.danger)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendUp
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 16,
                        color: trendUp ? AppConfig.success : AppConfig.danger,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend,
                        style: TextStyle(
                          color: trendUp ? AppConfig.success : AppConfig.danger,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppConfig.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return _ActivityItem(
                  title: 'New booking confirmed',
                  subtitle: 'Booking #1234 - Goa Package',
                  time: '2 hours ago',
                  icon: Icons.book_outlined,
                  color: AppConfig.primaryColor,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppConfig.textMuted),
      ),
      trailing: Text(
        time,
        style: TextStyle(color: AppConfig.textMuted),
      ),
    );
  }
}

class _TasksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Tasks',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: () {
                    Get.toNamed('/tasks');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Task'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return _TaskItem(
                  title: 'Follow up with client',
                  dueTime: '2:30 PM',
                  isCompleted: index == 1,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final String title;
  final String dueTime;
  final bool isCompleted;

  const _TaskItem({
    required this.title,
    required this.dueTime,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: isCompleted,
      onChanged: (value) {
        // TODO: Implement task completion
      },
      title: Text(
        title,
        style: TextStyle(
          decoration: isCompleted ? TextDecoration.lineThrough : null,
          color: isCompleted ? AppConfig.textMuted : AppConfig.textMain,
        ),
      ),
      subtitle: Text(
        'Due at $dueTime',
        style: TextStyle(
          color: AppConfig.textMuted,
        ),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}

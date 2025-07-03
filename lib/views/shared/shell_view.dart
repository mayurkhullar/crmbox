import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_config.dart';
import '../../controllers/theme_controller.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';

class ShellView extends StatelessWidget {
  final Widget child;

  const ShellView({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 1200) {
            return _DesktopShell(child: child);
          }
          return _MobileShell(child: child);
        },
      ),
    );
  }
}

class _DesktopShell extends StatelessWidget {
  final Widget child;

  const _DesktopShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _Sidebar(),
        Expanded(
          child: Column(
            children: [
              const _TopBar(),
              Expanded(child: child),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobileShell extends StatelessWidget {
  final Widget child;

  const _MobileShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: _TopBar(),
      ),
      drawer: const Drawer(
        child: _Sidebar(),
      ),
      body: child,
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    final user = AuthService.to.userModel;
    final currentRoute = Get.currentRoute;

    return Container(
      width: 280,
      color: AppConfig.surfaceColor,
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: const EdgeInsets.all(24),
            child: Text(
              AppConfig.companyName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppConfig.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _NavItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  route: AppRoutes.dashboard,
                  isSelected: currentRoute == AppRoutes.dashboard,
                ),
                _NavItem(
                  icon: Icons.people_outline,
                  label: 'Customers',
                  route: AppRoutes.customers,
                  isSelected: currentRoute == AppRoutes.customers,
                ),
                _NavItem(
                  icon: Icons.place_outlined,
                  label: 'Destinations',
                  route: AppRoutes.destinations,
                  isSelected: currentRoute == AppRoutes.destinations,
                ),
                _NavItem(
                  icon: Icons.card_travel_outlined,
                  label: 'Packages',
                  route: AppRoutes.packages,
                  isSelected: currentRoute == AppRoutes.packages,
                ),
                _NavItem(
                  icon: Icons.book_outlined,
                  label: 'Bookings',
                  route: AppRoutes.bookings,
                  isSelected: currentRoute == AppRoutes.bookings,
                ),
                _NavItem(
                  icon: Icons.payment_outlined,
                  label: 'Payments',
                  route: AppRoutes.payments,
                  isSelected: currentRoute == AppRoutes.payments,
                ),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Expenses',
                  route: AppRoutes.expenses,
                  isSelected: currentRoute == AppRoutes.expenses,
                ),
                _NavItem(
                  icon: Icons.task_outlined,
                  label: 'Tasks',
                  route: AppRoutes.tasks,
                  isSelected: currentRoute == AppRoutes.tasks,
                ),
                if (user?.hasPermission(UserRole.manager) ?? false) ...[
                  _NavItem(
                    icon: Icons.bar_chart_outlined,
                    label: 'Reports',
                    route: AppRoutes.reports,
                    isSelected: currentRoute == AppRoutes.reports,
                  ),
                ],
                if (user?.hasPermission(UserRole.admin) ?? false) ...[
                  _NavItem(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Users',
                    route: AppRoutes.users,
                    isSelected: currentRoute == AppRoutes.users,
                  ),
                ],
              ],
            ),
          ),

          // Bottom Section
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              _NavItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                route: AppRoutes.settings,
                isSelected: currentRoute == AppRoutes.settings,
              ),
              const SizedBox(height: 8),
              _LogoutButton(),
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isSelected;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppConfig.primaryColor : AppConfig.textMuted,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppConfig.primaryColor : AppConfig.textMain,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppConfig.primaryColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () => Get.offAllNamed(route),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final user = AuthService.to.userModel;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppConfig.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: AppConfig.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (MediaQuery.of(context).size.width < 1200) ...[
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            const SizedBox(width: 8),
          ],
          Text(
            _getPageTitle(Get.currentRoute),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined),
            onPressed: () => ThemeController.to.toggleTheme(),
          ),
          const SizedBox(width: 8),
          _UserMenu(user: user),
        ],
      ),
    );
  }

  String _getPageTitle(String route) {
    switch (route) {
      case AppRoutes.dashboard:
        return 'Dashboard';
      case AppRoutes.customers:
        return 'Customers';
      case AppRoutes.destinations:
        return 'Destinations';
      case AppRoutes.packages:
        return 'Packages';
      case AppRoutes.bookings:
        return 'Bookings';
      case AppRoutes.payments:
        return 'Payments';
      case AppRoutes.expenses:
        return 'Expenses';
      case AppRoutes.tasks:
        return 'Tasks';
      case AppRoutes.reports:
        return 'Reports';
      case AppRoutes.settings:
        return 'Settings';
      case AppRoutes.users:
        return 'Users';
      default:
        return AppConfig.companyName;
    }
  }
}

class _UserMenu extends StatelessWidget {
  final UserModel? user;

  const _UserMenu({this.user});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppConfig.primaryColor,
              radius: 16,
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'User',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  user?.role.displayName ?? 'Role',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppConfig.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person_outline),
              const SizedBox(width: 8),
              const Text('Profile'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout),
              const SizedBox(width: 8),
              const Text('Logout'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'logout') {
          AuthService.to.signOut();
        }
      },
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.logout,
        color: AppConfig.danger,
      ),
      title: Text(
        'Logout',
        style: TextStyle(
          color: AppConfig.danger,
        ),
      ),
      onTap: () => AuthService.to.signOut(),
    );
  }
}

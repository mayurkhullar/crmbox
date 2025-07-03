import 'package:get/get.dart';
import '../middleware/auth_middleware.dart';
import '../models/user_model.dart';
import '../views/auth/login_view.dart';
import '../views/auth/unauthorized_view.dart';
import '../views/dashboard/dashboard_view.dart';
import '../views/customers/customers_list_view.dart';
import '../views/customers/customer_details_view.dart';
import '../views/destinations/destinations_list_view.dart';
import '../views/packages/packages_list_view.dart';
import '../views/bookings/bookings_list_view.dart';
import '../views/payments/payments_list_view.dart';
import '../views/expenses/expenses_list_view.dart';
import '../views/tasks/tasks_list_view.dart';
import '../views/reports/reports_dashboard_view.dart';
import '../views/settings/settings_view.dart';
import '../views/users/users_list_view.dart';

class AppRoutes {
  static final routes = [
    GetPage(
      name: '/login',
      page: () => const LoginView(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: '/unauthorized',
      page: () => const UnauthorizedView(),
    ),
    GetPage(
      name: '/dashboard',
      page: () => const DashboardView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/customers',
      page: () => const CustomersListView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/customers/:id',
      page: () {
        final id = Get.parameters['id']!;
        return CustomerDetailsView(customerId: id);
      },
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/destinations',
      page: () => const DestinationsListView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/packages',
      page: () => const PackagesListView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/bookings',
      page: () => const BookingsListView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/payments',
      page: () => const PaymentsListView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/expenses',
      page: () => const ExpensesListView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/tasks',
      page: () => const TasksListView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/reports',
      page: () => const ReportsDashboardView(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(UserRole.manager),
      ],
    ),
    GetPage(
      name: '/settings',
      page: () => const SettingsView(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(UserRole.manager),
      ],
    ),
    GetPage(
      name: '/users',
      page: () => const UsersListView(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(UserRole.admin),
      ],
    ),
  ];

  static const initial = '/login';

  // Named routes for easy reference
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const customers = '/customers';
  static const destinations = '/destinations';
  static const packages = '/packages';
  static const bookings = '/bookings';
  static const payments = '/payments';
  static const expenses = '/expenses';
  static const tasks = '/tasks';
  static const reports = '/reports';
  static const settings = '/settings';
  static const users = '/users';
  static const unauthorized = '/unauthorized';
}

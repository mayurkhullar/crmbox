import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!AuthService.to.isAuthenticated) {
      return const RouteSettings(name: '/login');
    }
    return null;
  }
}

class RoleMiddleware extends GetMiddleware {
  final UserRole requiredRole;

  RoleMiddleware(this.requiredRole);

  @override
  RouteSettings? redirect(String? route) {
    if (!AuthService.to.isAuthenticated) {
      return const RouteSettings(name: '/login');
    }

    if (!AuthService.to.hasPermission(requiredRole)) {
      return const RouteSettings(name: '/unauthorized');
    }

    return null;
  }
}

class GuestMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (AuthService.to.isAuthenticated) {
      return const RouteSettings(name: '/dashboard');
    }
    return null;
  }
}

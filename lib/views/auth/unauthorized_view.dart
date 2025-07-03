import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_config.dart';
import '../../routes/app_routes.dart';

class UnauthorizedView extends StatelessWidget {
  const UnauthorizedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Icon(
                Icons.lock_outline,
                size: 64,
                color: AppConfig.primaryColor,
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                'Access Denied',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppConfig.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                'You don\'t have permission to access this page.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppConfig.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Back to Dashboard Button
              ElevatedButton(
                onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Back to Dashboard'),
              ),
              const SizedBox(height: 16),
              
              // Contact Admin Link
              TextButton.icon(
                onPressed: () {
                  // TODO: Implement contact admin functionality
                  Get.snackbar(
                    'Contact Admin',
                    'Please contact your administrator for access.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppConfig.primaryColor.withOpacity(0.1),
                    colorText: AppConfig.primaryColor,
                    margin: const EdgeInsets.all(16),
                  );
                },
                icon: const Icon(Icons.support_agent_outlined),
                label: const Text('Contact Administrator'),
                style: TextButton.styleFrom(
                  foregroundColor: AppConfig.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

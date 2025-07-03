import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'config/app_theme.dart';
import 'controllers/theme_controller.dart';
import 'services/auth_service.dart';
import 'services/customer_service.dart';
import 'routes/app_routes.dart';
import 'views/auth/unauthorized_view.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GetStorage for theme persistence
  await GetStorage.init();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'YOUR_API_KEY',
      appId: 'YOUR_APP_ID',
      messagingSenderId: 'YOUR_SENDER_ID',
      projectId: 'YOUR_PROJECT_ID',
      authDomain: 'YOUR_AUTH_DOMAIN',
      storageBucket: 'YOUR_STORAGE_BUCKET',
    ),
  );

  // Initialize services and controllers
  Get.put(ThemeController());
  Get.put(AuthService());
  Get.put(CustomerService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'K. Holiday Maps CRM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeController.to.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppRoutes.initial,
      getPages: AppRoutes.routes,
      defaultTransition: Transition.fade,
      // Handle 404 routes
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => const UnauthorizedView(),
      ),
    );
  }
}

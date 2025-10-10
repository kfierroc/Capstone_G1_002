import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'screens/auth/login.dart';
import 'screens/home/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Emergencias - Bomberos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: ThemeData.light().textTheme.copyWith(
              headlineLarge: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              headlineMedium: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              headlineSmall: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              titleLarge: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              titleMedium: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              titleSmall: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              bodyLarge: const TextStyle(fontSize: 16),
              bodyMedium: const TextStyle(fontSize: 14),
              bodySmall: const TextStyle(fontSize: 12),
            ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
        ).copyWith(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.error,
        ),
      ),
      home: const AuthChecker(),
    );
  }
}

/// Verifica si el usuario ya está autenticado
class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool _isAuthenticated = false;
  String? _userEmail;

  void _setAuthenticated(String email) {
    setState(() {
      _isAuthenticated = true;
      _userEmail = email;
    });
  }

  void _logout() {
    setState(() {
      _isAuthenticated = false;
      _userEmail = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return HomeScreen(
        onLogout: _logout,
        userEmail: _userEmail,
      );
    }
    return LoginScreen(onLogin: _setAuthenticated);
  }
}

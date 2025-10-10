import 'package:flutter/material.dart';

class MockAuthService {
  static final MockAuthService _instance = MockAuthService._internal();
  factory MockAuthService() => _instance;
  MockAuthService._internal();

  // Credenciales de prueba
  static const String _testEmail = 'bombero@prueba.com';
  static const String _testPassword = 'bombero123';
  
  // Usuario actual (simulado)
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Simular login
  Future<AuthResult> signInWithPassword({
    required String email,
    required String password,
  }) async {
    // Simular delay de red
    await Future.delayed(const Duration(seconds: 1));
    
    if (email == _testEmail && password == _testPassword) {
      _currentUser = User(
        id: '1',
        email: email,
        name: 'Bombero de Prueba',
        role: 'bombero',
      );
      return AuthResult.success(_currentUser!);
    } else {
      return AuthResult.error('Credenciales incorrectas');
    }
  }

  // Simular logout
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  // Simular registro
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Simular que el registro siempre funciona
    _currentUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      role: 'bombero',
    );
    return AuthResult.success(_currentUser!);
  }

  // Obtener credenciales de prueba
  static String get testEmail => _testEmail;
  static String get testPassword => _testPassword;
}

class User {
  final String id;
  final String email;
  final String name;
  final String role;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });
}

class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? error;

  AuthResult._(this.isSuccess, this.user, this.error);

  factory AuthResult.success(User user) => AuthResult._(true, user, null);
  factory AuthResult.error(String error) => AuthResult._(false, null, error);
}

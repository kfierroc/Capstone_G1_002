import 'package:flutter/material.dart';
import '../../utils/app_styles.dart';
import '../../services/unified_auth_service.dart';

/// Pantalla para verificar el correo electrónico antes de continuar con el registro
class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String password;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final UnifiedAuthService _authService = UnifiedAuthService();
  
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  int _resendCountdown = 0;
  bool _canResend = true;

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// Enviar correo de verificación
  Future<void> _sendVerificationEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Crear cuenta temporal para enviar verificación
      final result = await _authService.registerWithEmail(
        widget.email,
        widget.password,
        sendEmailVerification: true,
      );

      if (result.isSuccess) {
        _startResendCountdown();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Correo de verificación enviado a ${widget.email}'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = result.message ?? 'Error al enviar correo de verificación';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Reenviar correo de verificación
  Future<void> _resendVerificationEmail() async {
    if (!_canResend) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      await _authService.resendEmailVerification(email: widget.email);
      _startResendCountdown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correo de verificación reenviado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        if (e.toString().contains('validation_failed')) {
          _errorMessage = 'Error: No se pudo reenviar el correo. Verifica que el email sea válido.';
        } else if (e.toString().contains('email no disponible')) {
          _errorMessage = 'Error: No se puede reenviar el correo. Email no disponible.';
        } else {
          _errorMessage = 'Error al reenviar correo: $e';
        }
      });
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  /// Iniciar cuenta regresiva para reenvío
  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 60;
      _canResend = false;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _resendCountdown--;
        });
        return _resendCountdown > 0;
      }
      return false;
    }).then((_) {
      if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  /// Saltar verificación y continuar al registro
  void _skipVerification() {
    Navigator.pushReplacementNamed(
      context, 
      '/registration-steps',
      arguments: {
        'email': widget.email,
        'password': widget.password,
      },
    );
  }

  /// Verificar código de verificación
  Future<void> _verifyEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Usar el servicio de autenticación real
      final authService = UnifiedAuthService();
      final result = await authService.verifyEmailCode(_codeController.text.trim());
      
      if (result.isSuccess) {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context, 
            '/registration-steps',
            arguments: {
              'email': widget.email,
              'password': widget.password,
            },
          );
        }
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Código de verificación inválido';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al verificar código: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade400, Colors.green.shade700],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.email_outlined,
                      size: 60,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Verificar correo electrónico',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Revisa tu correo electrónico',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.email, color: Colors.green.shade700),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.email,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _codeController,
                            decoration: InputDecoration(
                              labelText: 'Código de verificación',
                              hintText: 'Ingresa el código de 6 dígitos',
                              prefixIcon: const Icon(Icons.security),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.green, width: 2),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa el código de verificación';
                              }
                              if (value.length != 6) {
                                return 'El código debe tener 6 dígitos';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red.shade700),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(color: Colors.red.shade700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_errorMessage != null) const SizedBox(height: 8),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _verifyEmail,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Verificar correo',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: _canResend && !_isResending ? _resendVerificationEmail : null,
                                  child: _isResending
                                      ? const SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : Text(
                                          _canResend
                                              ? 'Reenviar código'
                                              : 'Reenviar en ${_resendCountdown}s',
                                          style: TextStyle(
                                            color: _canResend ? Colors.green : Colors.grey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              Expanded(
                                child: TextButton(
                                  onPressed: _isLoading ? null : _skipVerification,
                                  child: Text(
                                    'Saltar',
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.green.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Si no recibes el correo, revisa tu carpeta de spam.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

  }
}

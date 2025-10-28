import 'package:flutter/material.dart';
import '../../services/supabase_auth_service.dart';
import '../home/home_main.dart';

/// Pantalla final de registro - Completar datos del bombero
class RegisterStep3CompletionScreen extends StatefulWidget {
  final String email;
  final String password;

  const RegisterStep3CompletionScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<RegisterStep3CompletionScreen> createState() => _RegisterStep3CompletionScreenState();
}

class _RegisterStep3CompletionScreenState extends State<RegisterStep3CompletionScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoPaternoController = TextEditingController();
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoPaternoController.dispose();
    _rutController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  String? _validateNombre(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu nombre';
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

  String? _validateApellidoPaterno(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu apellido paterno';
    }
    if (value.trim().length < 2) {
      return 'El apellido paterno debe tener al menos 2 caracteres';
    }
    return null;
  }

  String? _validateRut(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu RUT';
    }

    String cleanRut = value
        .replaceAll('.', '')
        .replaceAll('-', '')
        .toUpperCase();

    if (cleanRut.length < 8) {
      return 'RUT inválido';
    }

    String rutNumber = cleanRut.substring(0, cleanRut.length - 1);
    String verifier = cleanRut.substring(cleanRut.length - 1);

    if (int.tryParse(rutNumber) == null) {
      return 'RUT inválido';
    }

    int sum = 0;
    int multiplier = 2;

    for (int i = rutNumber.length - 1; i >= 0; i--) {
      sum += int.parse(rutNumber[i]) * multiplier;
      multiplier = multiplier == 7 ? 2 : multiplier + 1;
    }

    int mod = 11 - (sum % 11);
    String calculatedVerifier = mod == 11
        ? '0'
        : mod == 10
        ? 'K'
        : mod.toString();

    if (verifier != calculatedVerifier) {
      return 'RUT inválido';
    }

    return null;
  }

  void _formatRut(String value) {
    String cleanRut = value.replaceAll('.', '').replaceAll('-', '');

    if (cleanRut.isNotEmpty && cleanRut.length > 1) {
      String rutNumber = cleanRut.substring(0, cleanRut.length - 1);
      String verifier = cleanRut.substring(cleanRut.length - 1);

      String formattedNumber = '';
      int counter = 0;
      for (int i = rutNumber.length - 1; i >= 0; i--) {
        if (counter == 3) {
          formattedNumber = '.$formattedNumber';
          counter = 0;
        }
        formattedNumber = rutNumber[i] + formattedNumber;
        counter++;
      }

      String formattedRut = '$formattedNumber-$verifier';

      if (formattedRut != value) {
        _rutController.value = TextEditingValue(
          text: formattedRut,
          selection: TextSelection.collapsed(offset: formattedRut.length),
        );
      }
    }
  }

  String? _validateCompany(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu compañía de bomberos';
    }
    if (value.length < 3) {
      return 'Nombre completo de la compañía';
    }
    return null;
  }

  Future<void> _register() async {
    if (_isLoading) return;
    
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = SupabaseAuthService();
        final result = await authService.signUpBombero(
          email: widget.email,
          password: widget.password,
          rutCompleto: _rutController.text.trim(),
          nombre: _nombreController.text.trim(),
          apellidoPaterno: _apellidoPaternoController.text.trim(),
          compania: _companyController.text.trim(),
        );

        if (mounted) {
          if (result.isSuccess) {
            final bombero = result.user?.bombero;
            final nombreCompleto = bombero != null 
                ? '${bombero.nombBombero} ${bombero.apePBombero}'
                : widget.email;
            final cargo = 'Voluntario';
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '¡Registro exitoso! Bienvenido, $cargo $nombreCompleto',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else {
            String errorMessage = result.error ?? 'Error al registrar';
            
            if (errorMessage.contains('Ya existe un bombero registrado')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(errorMessage),
                      const SizedBox(height: 8),
                      const Text(
                        '💡 Sugerencias:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text('• Verifica que el RUT sea correcto'),
                      const Text('• Si ya tienes cuenta, ve a "Iniciar Sesión"'),
                      const Text('• Si olvidaste tu contraseña, usa "Recuperar contraseña"'),
                    ],
                  ),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 8),
                  action: SnackBarAction(
                    label: 'Iniciar Sesión',
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error inesperado: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
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
                      Icons.person_add_outlined,
                      size: 60,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Completa tu registro',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Ingresa tus datos de bombero',
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
                          TextFormField(
                            controller: _nombreController,
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            validator: _validateNombre,
                            decoration: InputDecoration(
                              labelText: 'Nombre *',
                              hintText: 'Carlos',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _apellidoPaternoController,
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            validator: _validateApellidoPaterno,
                            decoration: InputDecoration(
                              labelText: 'Apellido Paterno *',
                              hintText: 'Neira',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _rutController,
                            keyboardType: TextInputType.text,
                            validator: _validateRut,
                            onChanged: _formatRut,
                            decoration: InputDecoration(
                              labelText: 'RUT *',
                              hintText: '12.345.678-9',
                              prefixIcon: const Icon(Icons.badge_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _companyController,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            validator: _validateCompany,
                            decoration: InputDecoration(
                              labelText: 'Compañía de Bomberos *',
                              hintText: 'Primera Compañía de Santiago',
                              prefixIcon: const Icon(
                                Icons.local_fire_department_outlined,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '* Todos los campos son obligatorios',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
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
                                      'Completar Registro',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
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


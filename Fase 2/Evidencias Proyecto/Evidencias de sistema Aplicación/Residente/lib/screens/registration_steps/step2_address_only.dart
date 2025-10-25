import 'package:flutter/material.dart';
import '../../models/registration_data.dart';
import '../../utils/app_styles.dart';

/// Paso 2 del registro - Solo dirección (simplificado del Step 3 actual)
class Step2AddressOnly extends StatefulWidget {
  final RegistrationData registrationData;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const Step2AddressOnly({
    super.key,
    required this.registrationData,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<Step2AddressOnly> createState() => _Step2AddressOnlyState();
}

class _Step2AddressOnlyState extends State<Step2AddressOnly> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.registrationData.address ?? '';
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      widget.registrationData.address = _addressController.text.trim();
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.residencePrimary, AppColors.residenceSecondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.residencePrimary.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dirección',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Ubicación de tu domicilio',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),

        // Formulario
        Expanded(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo de dirección
                  Text('Dirección Completa', style: AppTextStyles.heading4),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Calle, número, comuna, región...',
                      prefixIcon: const Icon(Icons.home),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.residencePrimary, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa la dirección de tu domicilio';
                      }
                      if (value.trim().length < 10) {
                        return 'La dirección debe ser más específica';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Información adicional
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.info),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'En el siguiente paso podrás agregar las coordenadas exactas de tu ubicación.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onPrevious,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.residencePrimary,
                            side: BorderSide(color: AppColors.residencePrimary),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Anterior',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.residencePrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Siguiente',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

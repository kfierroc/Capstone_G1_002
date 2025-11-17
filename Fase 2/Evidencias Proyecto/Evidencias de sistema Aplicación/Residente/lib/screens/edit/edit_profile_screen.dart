import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/registration_data.dart';
import '../../utils/validators.dart';
import '../../utils/app_styles.dart';
import '../../utils/input_formatters.dart';

/// Pantalla optimizada para editar perfil del titular
/// Refactorizada para ser < 300 líneas usando componentes reutilizables
class EditProfileScreen extends StatefulWidget {
  final RegistrationData registrationData;
  final Function(RegistrationData) onSave;

  const EditProfileScreen({
    super.key,
    required this.registrationData,
    required this.onSave,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rutController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _rutController.text = widget.registrationData.rut ?? '';
    _phoneController.text = widget.registrationData.phoneNumber ?? '';
  }

  @override
  void dispose() {
    _rutController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final updatedData = widget.registrationData.copyWith(
        rut: _rutController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() => _isLoading = false);
        widget.onSave(updatedData);
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Perfil actualizado correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.settingsPrimary,
        foregroundColor: AppColors.textWhite,
        title: const Text('Editar Perfil'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPersonalInfoSection(),
                  ],
                ),
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Información Personal', style: AppTextStyles.heading3),
        const SizedBox(height: AppSpacing.lg),

        // RUT (No editable - es el ID)
        TextFormField(
          controller: _rutController,
          enabled: false, // ← No editable
          decoration: InputDecoration(
            labelText: 'RUT (no editable)',
            hintText: '12.345.678-9',
            prefixIcon: const Icon(Icons.badge_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            filled: true,
            fillColor: const Color(0xFFE0E0E0), // Gris para indicar deshabilitado
            helperText: 'El RUT no se puede modificar',
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Teléfono
        TextFormField(
          controller: _phoneController,
          validator: Validators.validatePhone,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            PhoneInputFormatter(), // ← Formateo automático
          ],
          decoration: InputDecoration(
            labelText: 'Teléfono *',
            hintText: '9 1234 5678',
            prefixIcon: const Icon(Icons.phone_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            helperText: 'Se formatea automáticamente',
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.medium,
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  side: BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.settingsPrimary,
                  foregroundColor: AppColors.textWhite,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
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
                        'Guardar Cambios',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

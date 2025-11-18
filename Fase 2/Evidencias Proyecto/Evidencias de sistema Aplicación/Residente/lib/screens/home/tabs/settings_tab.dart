import 'package:flutter/material.dart';
import '../../../models/registration_data.dart';
import '../../../services/unified_auth_service.dart';
import '../../../utils/app_styles.dart';
import '../../../utils/format_utils.dart';
import '../../../widgets/common_widgets.dart';
import '../../edit/edit_profile_screen.dart';

/// Tab optimizado para configuración
class SettingsTab extends StatelessWidget {
  final RegistrationData registrationData;
  final Function(RegistrationData) onUpdate;
  final VoidCallback onLogout;

  const SettingsTab({
    super.key,
    required this.registrationData,
    required this.onUpdate,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final authService = UnifiedAuthService();
    final userEmail = authService.userEmail;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.settings,
            title: 'Configuración de cuenta',
            subtitle: 'Gestiona tu cuenta y preferencias',
            gradientColors: [AppColors.settingsPrimary, AppColors.settingsSecondary],
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildPersonalInfoCard(userEmail),
          const SizedBox(height: AppSpacing.xl),
          ActionButton(
            onPressed: () => _editProfile(context),
            label: 'Editar perfil',
            icon: Icons.edit,
            backgroundColor: AppColors.settingsPrimary,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(String? userEmail) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Información personal', style: AppTextStyles.heading3),
          const Divider(height: AppSpacing.xxl),
          DetailRow(
            label: 'RUT:',
            value: registrationData.rut != null 
                ? FormatUtils.formatRut(registrationData.rut!)
                : 'No especificado',
          ),
          const SizedBox(height: AppSpacing.lg),
          DetailRow(
            label: 'Email:',
            value: userEmail ?? 'No especificado',
          ),
          const SizedBox(height: AppSpacing.lg),
          DetailRow(
            label: 'Teléfono:',
            value: registrationData.mainPhone != null 
                ? FormatUtils.formatPhone(registrationData.mainPhone!)
                : 'No especificado',
          ),
          const SizedBox(height: AppSpacing.lg),
          DetailRow(
            label: 'Edad:',
            value: registrationData.age != null &&
                    registrationData.birthYear != null
                ? '${registrationData.age} años (${registrationData.birthYear})'
                : 'No especificado',
          ),
          if (registrationData.medicalConditions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: AppSpacing.xxl),
            Text(
              'Condiciones médicas:',
              style: AppTextStyles.labelText,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: registrationData.medicalConditions
                  .map((condition) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          condition,
                          style: AppTextStyles.chipText.copyWith(color: Colors.red.shade900),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _editProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          registrationData: registrationData,
          onSave: onUpdate,
        ),
      ),
    );
  }
}


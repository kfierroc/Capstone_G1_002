import 'package:flutter/material.dart';
import '../../../models/registration_data.dart';
import '../../../utils/app_styles.dart';
import '../../../widgets/common_widgets.dart';
import '../../edit/edit_residence_info_screen.dart';

/// Tab optimizado para información de residencia
class ResidenceTab extends StatelessWidget {
  final RegistrationData registrationData;
  final Function(RegistrationData) onUpdate;

  const ResidenceTab({
    super.key,
    required this.registrationData,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.home,
            title: 'Información del Domicilio',
            subtitle: 'Revisa y actualiza los datos de tu domicilio',
            gradientColors: [AppColors.residencePrimary, AppColors.residenceSecondary],
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildAddressCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildHousingDetailsCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildContactCard(),
          const SizedBox(height: AppSpacing.xl),
          ActionButton(
            onPressed: () => _editResidenceInfo(context),
            label: 'Editar información',
            icon: Icons.edit,
            backgroundColor: AppColors.residencePrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return InfoCard(
      title: 'Dirección',
      value: registrationData.address ?? 'No especificada',
    );
  }

  Widget _buildHousingDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detalles de la Vivienda', style: AppTextStyles.heading4),
          const Divider(height: AppSpacing.xxl),
          DetailRow(
            label: 'Tipo de vivienda',
            value: registrationData.housingType ?? 'No especificado',
          ),
          const SizedBox(height: AppSpacing.lg),
          DetailRow(
            label: 'Número de pisos',
            value: registrationData.numberOfFloors != null
                ? '${registrationData.numberOfFloors} ${registrationData.numberOfFloors == 1 ? 'piso' : 'pisos'}'
                : 'No especificado',
          ),
          const SizedBox(height: AppSpacing.lg),
          DetailRow(
            label: 'Material',
            value: registrationData.constructionMaterial ?? 'No especificado',
          ),
          const SizedBox(height: AppSpacing.lg),
          DetailRow(
            label: 'Estado',
            value: registrationData.housingCondition ?? 'No especificado',
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Teléfonos de emergencia', style: AppTextStyles.heading4),
          const Divider(height: AppSpacing.xxl),
          DetailRow(
            label: 'Principal',
            value: registrationData.mainPhone ?? 'No especificado',
          ),
          if (registrationData.alternatePhone != null &&
              registrationData.alternatePhone!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            DetailRow(
              label: 'Alternativo',
              value: registrationData.alternatePhone!,
            ),
          ],
        ],
      ),
    );
  }

  void _editResidenceInfo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditResidenceInfoScreen(
          registrationData: registrationData,
          onSave: onUpdate,
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import '../../models/registration_data.dart';
import '../../utils/app_styles.dart';
import '../../widgets/address_form_widget.dart';
import '../../widgets/housing_details_form.dart';

/// Pantalla optimizada para editar información de residencia
/// Refactorizada para ser < 300 líneas usando componentes reutilizables
class EditResidenceInfoScreen extends StatefulWidget {
  final RegistrationData registrationData;
  final Function(RegistrationData) onSave;

  const EditResidenceInfoScreen({
    super.key,
    required this.registrationData,
    required this.onSave,
  });

  @override
  State<EditResidenceInfoScreen> createState() =>
      _EditResidenceInfoScreenState();
}

class _EditResidenceInfoScreenState extends State<EditResidenceInfoScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Controladores de dirección
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _specialInstructionsController = TextEditingController();

  // Variables de vivienda
  String? _selectedHousingType;
  String? _numberOfFloors;
  String? _selectedMaterial;
  String? _selectedCondition;

  bool _showManualCoordinates = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Inicializar controladores de domicilio
    _addressController.text = widget.registrationData.address ?? '';
    _latitudeController.text =
        widget.registrationData.latitude?.toString() ?? '';
    _longitudeController.text =
        widget.registrationData.longitude?.toString() ?? '';
    _specialInstructionsController.text = widget.registrationData.specialInstructions ?? '';

    if (_latitudeController.text.isNotEmpty) {
      _showManualCoordinates = true;
    }

    // Inicializar variables de vivienda
    _selectedHousingType = widget.registrationData.housingType;
    _numberOfFloors = widget.registrationData.numberOfFloors?.toString();
    _selectedMaterial = widget.registrationData.constructionMaterial;
    _selectedCondition = widget.registrationData.housingCondition;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final updatedData = widget.registrationData.copyWith(
          address: _addressController.text.trim(),
          latitude: double.tryParse(_latitudeController.text),
          longitude: double.tryParse(_longitudeController.text),
          housingType: _selectedHousingType,
          numberOfFloors: _numberOfFloors != null
              ? int.parse(_numberOfFloors!)
              : null,
          constructionMaterial: _selectedMaterial,
          housingCondition: _selectedCondition,
          specialInstructions: _specialInstructionsController.text.trim().isNotEmpty ? _specialInstructionsController.text.trim() : null,
        );

        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          setState(() => _isLoading = false);
          widget.onSave(updatedData);
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Información actualizada correctamente'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.residencePrimary,
        foregroundColor: AppColors.textWhite,
        title: const Text('Editar Información de Residencia'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textWhite,
          unselectedLabelColor: const Color(0xB3FFFFFF),
          indicatorColor: AppColors.textWhite,
          tabs: const [
            Tab(icon: Icon(Icons.location_on), text: 'Dirección'),
            Tab(icon: Icon(Icons.home), text: 'Vivienda'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildAddressTab(), _buildHousingTab()],
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AddressFormWidget(
            addressController: _addressController,
            latitudeController: _latitudeController,
            longitudeController: _longitudeController,
            showManualCoordinates: _showManualCoordinates,
            onToggleManualCoordinates: (value) {
              setState(() => _showManualCoordinates = value);
            },
            onConfirmLocation: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Ubicación confirmada'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSpecialInstructionsField(),
        ],
      ),
    );
  }

  Widget _buildHousingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: HousingDetailsForm(
        selectedHousingType: _selectedHousingType,
        numberOfFloors: _numberOfFloors,
        selectedMaterial: _selectedMaterial,
        selectedCondition: _selectedCondition,
        onHousingTypeChanged: (value) =>
            setState(() => _selectedHousingType = value),
        onFloorsChanged: (value) => setState(() => _numberOfFloors = value),
        onMaterialChanged: (value) => setState(() => _selectedMaterial = value),
        onConditionChanged: (value) =>
            setState(() => _selectedCondition = value),
      ),
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
                  backgroundColor: AppColors.residencePrimary,
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


  Widget _buildSpecialInstructionsField() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Instrucciones Especiales', style: AppTextStyles.heading4),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _specialInstructionsController,
            decoration: InputDecoration(
              hintText: 'Ingresa instrucciones especiales para la residencia',
              prefixIcon: const Icon(Icons.info_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            maxLines: 3,
            keyboardType: TextInputType.multiline,
          ),
        ],
      ),
    );
  }
}

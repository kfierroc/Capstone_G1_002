import 'package:flutter/material.dart';
import '../../models/registration_data.dart';
import '../../utils/app_styles.dart';
import '../../utils/validators.dart';

/// Paso 1 del registro - Datos del titular (antes Step 2)
class Step1HolderData extends StatefulWidget {
  final RegistrationData registrationData;
  final VoidCallback onNext;

  const Step1HolderData({
    super.key,
    required this.registrationData,
    required this.onNext,
  });

  @override
  State<Step1HolderData> createState() => _Step1HolderDataState();
}

class _Step1HolderDataState extends State<Step1HolderData>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();
  final TextEditingController _otherConditionController = TextEditingController();

  late TabController _tabController;
  List<String> _selectedConditions = [];

  // Categorías de condiciones
  final Map<String, List<String>> _conditionCategories = {
    'Enfermedades Crónicas': [
      'Diabetes',
      'Hipertensión',
      'Problemas cardíacos',
      'Enfermedades respiratorias',
      'Epilepsia o convulsiones',
      'Cáncer en tratamiento',
      'Enfermedades mentales',
    ],
    'Movilidad y Sentidos': [
      'Persona postrada',
      'Problemas de audición',
      'Problemas de visión',
      'Vértigo o pérdida de equilibrio',
      'Dificultad para moverse o caminar',
      'Problemas de coordinación',
    ],
    'Otras Condiciones': [
      'Menisco roto',
      'Problemas de columna',
      'Artritis o reumatismo',
      'Problemas de memoria',
      'Alzheimer o demencia',
      'Otras condiciones',
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _conditionCategories.length, vsync: this);
    
    // Cargar datos existentes
    _rutController.text = widget.registrationData.rut ?? '';
    _phoneController.text = widget.registrationData.phoneNumber ?? '';
    _birthYearController.text = widget.registrationData.birthYear?.toString() ?? '';
    _selectedConditions = List.from(widget.registrationData.medicalConditions);
  }

  @override
  void dispose() {
    _rutController.dispose();
    _phoneController.dispose();
    _birthYearController.dispose();
    _otherConditionController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _toggleCondition(String condition) {
    setState(() {
      if (_selectedConditions.contains(condition)) {
        _selectedConditions.remove(condition);
      } else {
        _selectedConditions.add(condition);
      }
    });
  }

  void _addCustomCondition() {
    if (_otherConditionController.text.trim().isNotEmpty) {
      setState(() {
        _selectedConditions.add(_otherConditionController.text.trim());
        _otherConditionController.clear();
      });
    }
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      // Guardar datos
      widget.registrationData.rut = _rutController.text.trim();
      widget.registrationData.phoneNumber = _phoneController.text.trim();
      widget.registrationData.birthYear = int.tryParse(_birthYearController.text);
      widget.registrationData.medicalConditions = _selectedConditions;
      
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
              colors: [AppColors.familyPrimary, AppColors.familySecondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.familyPrimary.withValues(alpha: 0.3),
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
                  Icons.person,
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
                      'Datos del Titular',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Información personal del responsable',
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
                  // RUT
                  Text('RUT', style: AppTextStyles.heading4),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _rutController,
                    decoration: InputDecoration(
                      hintText: '12.345.678-9',
                      prefixIcon: const Icon(Icons.badge),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.familyPrimary, width: 2),
                      ),
                    ),
                    validator: Validators.validateRut,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Teléfono
                  Text('Teléfono', style: AppTextStyles.heading4),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '+56 9 1234 5678',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.familyPrimary, width: 2),
                      ),
                    ),
                    validator: Validators.validatePhone,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Año de nacimiento
                  Text('Año de Nacimiento', style: AppTextStyles.heading4),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _birthYearController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '1990',
                      prefixIcon: const Icon(Icons.cake),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.familyPrimary, width: 2),
                      ),
                    ),
                    validator: Validators.validateBirthYear,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Condiciones médicas
                  Text('Condiciones Médicas', style: AppTextStyles.heading4),
                  const SizedBox(height: AppSpacing.md),
                  
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          labelColor: AppColors.familyPrimary,
                          unselectedLabelColor: AppColors.textTertiary,
                          indicatorColor: AppColors.familyPrimary,
                          tabs: _conditionCategories.keys.map((category) => 
                            Tab(text: category)).toList(),
                        ),
                        SizedBox(
                          height: 200,
                          child: TabBarView(
                            controller: _tabController,
                            children: _conditionCategories.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                child: SingleChildScrollView(
                                  child: Wrap(
                                    spacing: AppSpacing.sm,
                                    runSpacing: AppSpacing.sm,
                                    children: entry.value.map((condition) {
                                      final isSelected = _selectedConditions.contains(condition);
                                      return FilterChip(
                                        label: Text(condition),
                                        selected: isSelected,
                                        onSelected: (_) => _toggleCondition(condition),
                                        selectedColor: AppColors.familyAccent,
                                        checkmarkColor: AppColors.familyPrimary,
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Campo personalizado
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _otherConditionController,
                          decoration: InputDecoration(
                            hintText: 'Otra condición...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.familyPrimary, width: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ElevatedButton(
                        onPressed: _addCustomCondition,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.familyPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Condiciones seleccionadas
                  if (_selectedConditions.isNotEmpty) ...[
                    Text('Condiciones seleccionadas:', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _selectedConditions.map((condition) {
                        return Chip(
                          label: Text(condition),
                          onDeleted: () => _toggleCondition(condition),
                          backgroundColor: AppColors.familyAccent,
                          deleteIconColor: AppColors.familyPrimary,
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xxxl),

                  // Botón siguiente
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.familyPrimary,
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

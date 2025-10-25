import 'package:flutter/material.dart';
import '../../models/registration_data.dart';
import '../../utils/app_styles.dart';

/// Paso 4 del registro - Detalles de la vivienda (igual al Step 4 actual)
class Step4HousingDetails extends StatefulWidget {
  final RegistrationData registrationData;
  final VoidCallback onPrevious;
  final VoidCallback onComplete;

  const Step4HousingDetails({
    super.key,
    required this.registrationData,
    required this.onPrevious,
    required this.onComplete,
  });

  @override
  State<Step4HousingDetails> createState() => _Step4HousingDetailsState();
}

class _Step4HousingDetailsState extends State<Step4HousingDetails> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedHousingType;
  String? _numberOfFloors;
  String? _selectedMaterial;
  String? _selectedCondition;
  final bool _isLoading = false;

  final List<String> _housingTypes = [
    'Casa',
    'Departamento',
    'Empresa',
    'Local comercial',
    'Oficina',
    'Bodega',
    'Otro',
  ];

  final List<int> _floorOptions = List.generate(62, (index) => index + 1);

  final List<String> _materials = [
    'Hormigón/Concreto',
    'Ladrillo',
    'Madera',
    'Adobe',
    'Metal',
    'Material ligero',
    'Mixto',
    'Otro',
  ];

  final List<String> _conditions = [
    'Excelente',
    'Muy bueno',
    'Bueno',
    'Regular',
    'Malo',
    'Muy malo',
  ];

  @override
  void initState() {
    super.initState();
    _selectedHousingType = widget.registrationData.housingType;
    _numberOfFloors = widget.registrationData.numberOfFloors?.toString();
    _selectedMaterial = widget.registrationData.constructionMaterial;
    _selectedCondition = widget.registrationData.housingCondition;
  }

  void _handleComplete() {
    if (_formKey.currentState!.validate()) {
      // Guardar datos
      widget.registrationData.housingType = _selectedHousingType;
      widget.registrationData.numberOfFloors = int.tryParse(_numberOfFloors ?? '1');
      widget.registrationData.constructionMaterial = _selectedMaterial;
      widget.registrationData.housingCondition = _selectedCondition;
      
      widget.onComplete();
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
                  Icons.home_work,
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
                      'Detalles de la Vivienda',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Características de tu hogar',
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
                  // Tipo de vivienda
                  Text('Tipo de Vivienda', style: AppTextStyles.heading4),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedHousingType,
                    decoration: InputDecoration(
                      hintText: 'Selecciona el tipo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.residencePrimary, width: 2),
                      ),
                    ),
                    items: _housingTypes.map((type) => 
                      DropdownMenuItem(value: type, child: Text(type))
                    ).toList(),
                    onChanged: (value) => setState(() => _selectedHousingType = value),
                    validator: (value) => value == null ? 'Selecciona el tipo de vivienda' : null,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Número de pisos
                  Text('Número de Pisos', style: AppTextStyles.heading4),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: _numberOfFloors,
                    decoration: InputDecoration(
                      hintText: 'Selecciona el número',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.residencePrimary, width: 2),
                      ),
                    ),
                    items: _floorOptions.map((floors) => 
                      DropdownMenuItem(
                        value: floors.toString(), 
                        child: Text('$floors ${floors == 1 ? 'piso' : 'pisos'}')
                      )
                    ).toList(),
                    onChanged: (value) => setState(() => _numberOfFloors = value),
                    validator: (value) => value == null ? 'Selecciona el número de pisos' : null,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Material de construcción
                  Text('Material de Construcción', style: AppTextStyles.heading4),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedMaterial,
                    decoration: InputDecoration(
                      hintText: 'Selecciona el material',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.residencePrimary, width: 2),
                      ),
                    ),
                    items: _materials.map((material) => 
                      DropdownMenuItem(value: material, child: Text(material))
                    ).toList(),
                    onChanged: (value) => setState(() => _selectedMaterial = value),
                    validator: (value) => value == null ? 'Selecciona el material' : null,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Estado de la vivienda
                  Text('Estado de la Vivienda', style: AppTextStyles.heading4),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCondition,
                    decoration: InputDecoration(
                      hintText: 'Selecciona el estado',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.residencePrimary, width: 2),
                      ),
                    ),
                    items: _conditions.map((condition) => 
                      DropdownMenuItem(value: condition, child: Text(condition))
                    ).toList(),
                    onChanged: (value) => setState(() => _selectedCondition = value),
                    validator: (value) => value == null ? 'Selecciona el estado' : null,
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
                          onPressed: _isLoading ? null : _handleComplete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.residencePrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
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

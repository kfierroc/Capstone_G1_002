import 'package:flutter/material.dart';
import '../../models/registration_data.dart';
import '../../utils/responsive.dart';

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
  bool _isLoading = false;

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

  Future<void> _handleComplete() async {
    if (_formKey.currentState!.validate()) {
      widget.registrationData.housingType = _selectedHousingType;
      widget.registrationData.numberOfFloors = _numberOfFloors != null
          ? int.parse(_numberOfFloors!)
          : null;
      widget.registrationData.constructionMaterial = _selectedMaterial;
      widget.registrationData.housingCondition = _selectedCondition;

      setState(() {
        _isLoading = true;
      });

      // Aquí iría la lógica para guardar en Supabase
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Mostrar diálogo de éxito
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Text('¡Registro Exitoso!'),
              ],
            ),
            content: const Text(
              'Tu información ha sido registrada correctamente. Los bomberos podrán acceder a ella en caso de emergencia.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onComplete();
                },
                child: const Text('Finalizar'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final isTablet = ResponsiveHelper.isTablet(context) ||
                      ResponsiveHelper.isDesktop(context);
    
    return Column(
      children: [
        Expanded(
          child: ResponsiveContainer(
            maxWidth: isTablet ? 800 : null,
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              padding: padding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalles de la Vivienda',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 28,
                          tablet: 32,
                          desktop: 36,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Proporciona información adicional sobre tu vivienda que ayudará a los bomberos en caso de emergencia',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 18,
                        ),
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: isTablet ? 40 : 32),

                  // Tipo de vivienda
                  DropdownButtonFormField<String>(
                    initialValue: _selectedHousingType,
                    decoration: InputDecoration(
                      labelText: 'Tipo de vivienda *',
                      hintText: 'Selecciona el tipo de vivienda',
                      prefixIcon: const Icon(Icons.home_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: _housingTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedHousingType = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor selecciona el tipo de vivienda';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Número de pisos
                  DropdownButtonFormField<String>(
                    initialValue: _numberOfFloors,
                    decoration: InputDecoration(
                      labelText: 'Número de pisos *',
                      hintText:
                          'Indica la cantidad total de pisos de la vivienda',
                      prefixIcon: const Icon(Icons.layers_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: _floorOptions.map((floors) {
                      return DropdownMenuItem(
                        value: floors.toString(),
                        child: Text(
                          '$floors ${floors == 1 ? 'piso' : 'pisos'}',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _numberOfFloors = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor selecciona el número de pisos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Material de construcción
                  DropdownButtonFormField<String>(
                    initialValue: _selectedMaterial,
                    decoration: InputDecoration(
                      labelText: 'Material principal de construcción *',
                      hintText: 'Selecciona el material',
                      prefixIcon: const Icon(Icons.construction_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: _materials.map((material) {
                      return DropdownMenuItem(
                        value: material,
                        child: Text(material),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMaterial = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor selecciona el material';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Estado de la vivienda
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCondition,
                    decoration: InputDecoration(
                      labelText: 'Estado general de la vivienda *',
                      hintText: 'Selecciona el estado',
                      prefixIcon: const Icon(
                        Icons.home_repair_service_outlined,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: _conditions.map((condition) {
                      return DropdownMenuItem(
                        value: condition,
                        child: Text(condition),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCondition = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor selecciona el estado';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // Resumen de información
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.summarize,
                              color: Colors.blue.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Resumen de tu información',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildSummaryItem(
                          'Dirección:',
                          widget.registrationData.address ?? 'No especificado',
                        ),
                        const SizedBox(height: 10),
                        _buildSummaryItem(
                          'Tipo:',
                          _selectedHousingType ?? 'No especificado',
                        ),
                        const SizedBox(height: 10),
                        _buildSummaryItem(
                          'Pisos:',
                          _numberOfFloors != null
                              ? '$_numberOfFloors ${int.parse(_numberOfFloors!) == 1 ? 'piso' : 'pisos'}'
                              : 'No especificado',
                        ),
                        const SizedBox(height: 10),
                        _buildSummaryItem(
                          'Material:',
                          _selectedMaterial ?? 'No especificado',
                        ),
                        const SizedBox(height: 10),
                        _buildSummaryItem(
                          'Estado:',
                          _selectedCondition ?? 'No especificado',
                        ),
                        const SizedBox(height: 10),
                        _buildSummaryItem(
                          'Contacto:',
                          widget.registrationData.mainPhone ??
                              'No especificado',
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

        // Botones
        Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : widget.onPrevious,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Anterior', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                          'Completar configuración',
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
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/registration_data.dart';
import '../../utils/validators.dart';
import '../../utils/responsive.dart';

class Step2HolderData extends StatefulWidget {
  final RegistrationData registrationData;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const Step2HolderData({
    super.key,
    required this.registrationData,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<Step2HolderData> createState() => _Step2HolderDataState();
}

class _Step2HolderDataState extends State<Step2HolderData>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();
  final TextEditingController _otherConditionController =
      TextEditingController();

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
      'Asma o problemas para respirar',
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _rutController.text = widget.registrationData.rut ?? '';
    _phoneController.text = widget.registrationData.phoneNumber ?? '';
    _birthYearController.text =
        widget.registrationData.birthYear?.toString() ?? '';
    _selectedConditions = List.from(widget.registrationData.medicalConditions);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rutController.dispose();
    _phoneController.dispose();
    _birthYearController.dispose();
    _otherConditionController.dispose();
    super.dispose();
  }

  void _addOtherCondition() {
    final condition = _otherConditionController.text.trim();
    if (condition.isNotEmpty && !_selectedConditions.contains(condition)) {
      setState(() {
        _selectedConditions.add(condition);
        _otherConditionController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Condición "$condition" agregada'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } else if (_selectedConditions.contains(condition)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta condición ya fue agregada'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      widget.registrationData.rut = _rutController.text.trim();
      widget.registrationData.phoneNumber = _phoneController.text.trim();
      widget.registrationData.birthYear = int.parse(_birthYearController.text);

      // Calcular edad aproximada
      final currentYear = DateTime.now().year;
      widget.registrationData.age =
          currentYear - widget.registrationData.birthYear!;

      widget.registrationData.medicalConditions = _selectedConditions;
      
      print('✅ Datos del paso 2 guardados:');
      print('   - rut: ${widget.registrationData.rut}');
      print('   - phone: ${widget.registrationData.phoneNumber}');
      
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final isTablet =
        ResponsiveHelper.isTablet(context) ||
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
                      'Datos del Titular',
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
                      'Completa tu información como titular del domicilio',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 18,
                        ),
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: isTablet ? 40 : 32),

                    // RUT
                    TextFormField(
                      controller: _rutController,
                      validator: Validators.validateRut,
                      decoration: InputDecoration(
                        labelText: 'RUT *',
                        hintText: '12.345.678-9',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Teléfono
                    TextFormField(
                      controller: _phoneController,
                      validator: Validators.validatePhone,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Teléfono *',
                        hintText: '9 1234 5678',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Año de nacimiento
                    TextFormField(
                      controller: _birthYearController,
                      validator: Validators.validateBirthYear,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Año de nacimiento *',
                        hintText: '1985',
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Condiciones médicas
                    const Text(
                      'Condiciones médicas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selecciona todas las condiciones que apliquen',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Nota importante
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ingrese solo condiciones relevantes para el rescate; no registre enfermedades o datos sensibles que no sean útiles para la emergencia.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tabs de categorías
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          TabBar(
                            controller: _tabController,
                            labelColor: Colors.blue.shade700,
                            unselectedLabelColor: Colors.grey.shade600,
                            indicatorColor: Colors.blue.shade700,
                            tabs: const [
                              Tab(text: 'Enfermedades Crónicas'),
                              Tab(text: 'Movilidad y Sentidos'),
                            ],
                          ),
                          SizedBox(
                            height: 300,
                            child: TabBarView(
                              controller: _tabController,
                              children: _conditionCategories.entries.map((
                                entry,
                              ) {
                                return ListView(
                                  padding: const EdgeInsets.all(16),
                                  children: entry.value.map((condition) {
                                    final isSelected = _selectedConditions
                                        .contains(condition);
                                    return CheckboxListTile(
                                      title: Text(condition),
                                      value: isSelected,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedConditions.add(condition);
                                          } else {
                                            _selectedConditions.remove(
                                              condition,
                                            );
                                          }
                                        });
                                      },
                                      activeColor: Colors.blue.shade700,
                                    );
                                  }).toList(),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Condiciones seleccionadas
                    if (_selectedConditions.isNotEmpty) ...[
                      const Text(
                        'Condiciones seleccionadas:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedConditions.map((condition) {
                          return Chip(
                            label: Text(condition),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              setState(() {
                                _selectedConditions.remove(condition);
                              });
                            },
                            backgroundColor: Colors.blue.shade50,
                            labelStyle: TextStyle(color: Colors.blue.shade700),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Otra condición especial
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _otherConditionController,
                            decoration: InputDecoration(
                              labelText: 'Otra condición especial (opcional)',
                              hintText: 'Ingrese otra condición no listada',
                              prefixIcon: const Icon(
                                Icons.medical_services_outlined,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            onFieldSubmitted: (_) => _addOtherCondition(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.green.shade700,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: _addOtherCondition,
                            tooltip: 'Agregar condición',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Nota adicional para otra condición
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ingrese solo condiciones relevantes para el rescate; no registre enfermedades o datos sensibles que no sean útiles para la emergencia.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade800,
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
                  onPressed: widget.onPrevious,
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
                child: ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

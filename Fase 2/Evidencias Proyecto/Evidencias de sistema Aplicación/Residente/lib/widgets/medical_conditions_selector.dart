import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import '../utils/app_data.dart';

/// Widget reutilizable para seleccionar condiciones médicas
class MedicalConditionsSelector extends StatefulWidget {
  final List<String> initialConditions;
  final Function(List<String>) onConditionsChanged;

  const MedicalConditionsSelector({
    super.key,
    required this.initialConditions,
    required this.onConditionsChanged,
  });

  @override
  State<MedicalConditionsSelector> createState() =>
      _MedicalConditionsSelectorState();
}

class _MedicalConditionsSelectorState
    extends State<MedicalConditionsSelector>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Set<String> _selectedConditions;
  final _otherConditionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedConditions = Set.from(widget.initialConditions);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      widget.onConditionsChanged(_selectedConditions.toList());
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Condición "$condition" agregada'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (_selectedConditions.contains(condition)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Esta condición ya fue agregada'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Condiciones médicas', style: AppTextStyles.heading4),
        const SizedBox(height: AppSpacing.sm),
        
        // Tabs de categorías
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'Enfermedades Crónicas'),
                  Tab(text: 'Movilidad y Sentidos'),
                ],
              ),
              SizedBox(
                height: 200,
                child: TabBarView(
                  controller: _tabController,
                  children: MedicalConditions.categories.entries
                      .map((entry) => _buildConditionsList(entry.value))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppSpacing.lg),
        
        // Condiciones seleccionadas
        if (_selectedConditions.isNotEmpty) ...[
          Text('Condiciones seleccionadas:', style: AppTextStyles.labelText),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _selectedConditions.map(_buildConditionChip).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
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
                  prefixIcon: const Icon(Icons.medical_services_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFFAFAFA),
                ),
                onFieldSubmitted: (_) => _addOtherCondition(),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: _addOtherCondition,
                tooltip: 'Agregar condición',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        
        // Nota importante
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: const Color(0xFFFFB74D)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.warning,
                size: AppIconSizes.sm,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Ingrese solo condiciones relevantes para el rescate; no registre enfermedades o datos sensibles que no sean útiles para la emergencia.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF5D4037),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConditionsList(List<String> conditions) {
    return ListView.builder(
      itemCount: conditions.length,
      itemBuilder: (context, index) {
        final condition = conditions[index];
        return CheckboxListTile(
          title: Text(condition, style: AppTextStyles.bodySmall),
          value: _selectedConditions.contains(condition),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedConditions.add(condition);
              } else {
                _selectedConditions.remove(condition);
              }
            });
            widget.onConditionsChanged(_selectedConditions.toList());
          },
          dense: true,
          activeColor: AppColors.primary,
        );
      },
    );
  }

  Widget _buildConditionChip(String condition) {
    return Chip(
      label: Text(condition, style: AppTextStyles.chipText),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () {
        setState(() {
          _selectedConditions.remove(condition);
        });
        widget.onConditionsChanged(_selectedConditions.toList());
      },
      backgroundColor: const Color(0xFFE3F2FD),
      labelStyle: TextStyle(color: AppColors.info),
    );
  }
}


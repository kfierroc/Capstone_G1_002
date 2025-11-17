import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/family_member.dart';
import '../utils/app_styles.dart';
import '../utils/validators.dart';
import 'medical_conditions_selector.dart';

/// Diálogo optimizado para agregar/editar persona
class PersonDialog extends StatefulWidget {
  final FamilyMember? initialData;
  final Function(FamilyMember) onSave;

  const PersonDialog({
    super.key,
    this.initialData,
    required this.onSave,
  });

  @override
  State<PersonDialog> createState() => _PersonDialogState();
}

class _PersonDialogState extends State<PersonDialog> {
  final _formKey = GlobalKey<FormState>();
  final _birthYearController = TextEditingController();
  List<String> _selectedConditions = [];

  @override
  void initState() {
    super.initState();

    if (widget.initialData != null) {
      _birthYearController.text = widget.initialData!.birthYear.toString();
      _selectedConditions = List.from(widget.initialData!.conditions);
    }
  }

  @override
  void dispose() {
    _birthYearController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final birthYear = int.parse(_birthYearController.text);
      final age = DateTime.now().year - birthYear;

      final member = FamilyMember(
        id: widget.initialData?.id ?? DateTime.now().toString(),
        // RUT no se incluye - solo para grupo familiar (titular), no para integrantes
        age: age,
        birthYear: birthYear,
        conditions: _selectedConditions.toList(),
      );

      widget.onSave(member);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700, maxWidth: 500),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildContent()),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.info,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_add, color: AppColors.textWhite),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              widget.initialData != null ? 'Editar persona' : 'Agregar Persona',
              style: AppTextStyles.heading2,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textWhite),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Año de Nacimiento
            TextFormField(
              controller: _birthYearController,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: InputDecoration(
                labelText: 'Año de nacimiento',
                hintText: '1985',
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                filled: true,
                fillColor: const Color(0xFFFAFAFA),
              ),
              keyboardType: TextInputType.number,
              validator: Validators.validateBirthYear,
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            // Selector de condiciones médicas (widget reutilizable)
            MedicalConditionsSelector(
              initialConditions: _selectedConditions,
              onConditionsChanged: (conditions) {
                setState(() => _selectedConditions = conditions);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
              ),
              child: const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }
}


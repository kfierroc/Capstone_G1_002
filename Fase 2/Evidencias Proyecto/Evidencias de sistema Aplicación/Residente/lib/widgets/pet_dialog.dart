import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../utils/app_styles.dart';
import '../utils/app_data.dart';

/// Diálogo optimizado para agregar/editar mascota
class PetDialog extends StatefulWidget {
  final Pet? initialData;
  final Function(Pet) onSave;

  const PetDialog({
    super.key,
    this.initialData,
    required this.onSave,
  });

  @override
  State<PetDialog> createState() => _PetDialogState();
}

class _PetDialogState extends State<PetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedSpecies;
  String? _selectedSize;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _nameController.text = widget.initialData!.name;
      _selectedSpecies = widget.initialData!.species;
      _selectedSize = widget.initialData!.size;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final pet = Pet(
        id: widget.initialData?.id ?? DateTime.now().toString(),
        name: _nameController.text.trim(),
        species: _selectedSpecies!,
        size: _selectedSize!,
      );

      widget.onSave(pet);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500, maxWidth: 500),
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
        color: AppColors.petsPrimary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.pets, color: AppColors.textWhite),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              widget.initialData != null ? 'Editar mascota' : 'Agregar Mascota',
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
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre de la mascota',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<String>(
              value: _selectedSpecies,
              decoration: InputDecoration(
                labelText: 'Selecciona la especie',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              items: PetData.species
                  .map((species) => DropdownMenuItem(
                        value: species,
                        child: Text(species),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedSpecies = value),
              validator: (value) => value == null ? 'Requerido' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<String>(
              value: _selectedSize,
              decoration: InputDecoration(
                labelText: 'Selecciona el tamaño',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              items: PetData.sizes
                  .map((size) => DropdownMenuItem(
                        value: size,
                        child: Text(size),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedSize = value),
              validator: (value) => value == null ? 'Requerido' : null,
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
                backgroundColor: AppColors.petsPrimary,
              ),
              child: const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }
}


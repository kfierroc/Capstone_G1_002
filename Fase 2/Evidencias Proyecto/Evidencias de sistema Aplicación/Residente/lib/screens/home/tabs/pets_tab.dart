import 'package:flutter/material.dart';
import '../../../models/mascota.dart';
import '../../../utils/app_styles.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/pet_card.dart';
import '../../../widgets/pet_dialog.dart';

/// Tab optimizado para gestión de mascotas
class PetsTab extends StatefulWidget {
  final List<Mascota> pets;
  final Function(Mascota) onAdd;
  final Function(int, Mascota) onEdit;
  final Function(int) onDelete;

  const PetsTab({
    super.key,
    required this.pets,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<PetsTab> createState() => _PetsTabState();
}

class _PetsTabState extends State<PetsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.pets,
            title: 'Gestión de Mascotas',
            subtitle: 'Agrega y gestiona tus mascotas',
            gradientColors: [AppColors.petsPrimary, AppColors.petsSecondary],
          ),
          const SizedBox(height: AppSpacing.xl),
          ActionButton(
            onPressed: _showAddDialog,
            label: 'Agregar nueva mascota',
            icon: Icons.add,
            backgroundColor: AppColors.petsPrimary,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (widget.pets.isNotEmpty) ...[
            Text(
              'Mascotas registradas (${widget.pets.length})',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.lg),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.pets.length,
              itemBuilder: (context, index) {
                final pet = widget.pets[index];
                return PetCard(
                  pet: pet,
                  onEdit: () => _showEditDialog(pet, index),
                  onDelete: () => _confirmDelete(index),
                );
              },
            ),
          ] else
            const EmptyStateWidget(
              icon: Icons.pets_outlined,
              message: 'No hay mascotas registradas',
            ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => PetDialog(
        onSave: widget.onAdd,
      ),
    );
  }

  void _showEditDialog(Mascota pet, int index) {
    showDialog(
      context: context,
      builder: (context) => PetDialog(
        initialData: pet,
        onSave: (updatedPet) => widget.onEdit(index, updatedPet),
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar mascota'),
        content: const Text('¿Estás seguro que deseas eliminar esta mascota?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              widget.onDelete(index);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}


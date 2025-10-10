import 'package:flutter/material.dart';
import '../../../models/family_member.dart';
import '../../../utils/app_styles.dart';
import '../../../widgets/common_widgets.dart';
import '../../../widgets/family_member_card.dart';
import '../../../widgets/person_dialog.dart';

/// Tab optimizado para gestión de familia
/// Implementa lazy loading - solo se construye cuando se necesita
class FamilyTab extends StatefulWidget {
  final List<FamilyMember> familyMembers;
  final Function(FamilyMember) onAdd;
  final Function(int, FamilyMember) onEdit;
  final Function(int) onDelete;

  const FamilyTab({
    super.key,
    required this.familyMembers,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<FamilyTab> createState() => _FamilyTabState();
}

class _FamilyTabState extends State<FamilyTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Mantener estado al cambiar tabs

  @override
  Widget build(BuildContext context) {
    super.build(context); // Requerido para AutomaticKeepAliveClientMixin
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.people,
            title: 'Gestión de Familia',
            subtitle: 'Agrega y gestiona los miembros de tu familia',
            gradientColors: [AppColors.familyPrimary, AppColors.familySecondary],
          ),
          const SizedBox(height: AppSpacing.xl),
          ActionButton(
            onPressed: _showAddDialog,
            label: 'Agregar nueva persona',
            icon: Icons.add,
            backgroundColor: AppColors.familyPrimary,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (widget.familyMembers.isNotEmpty) ...[
            Text(
              'Miembros de la familia (${widget.familyMembers.length})',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.lg),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.familyMembers.length,
              itemBuilder: (context, index) {
                final member = widget.familyMembers[index];
                return FamilyMemberCard(
                  member: member,
                  index: index,
                  onEdit: () => _showEditDialog(member, index),
                  onDelete: () => _confirmDelete(index),
                );
              },
            ),
          ] else
            const EmptyStateWidget(
              icon: Icons.people_outline,
              message: 'No hay miembros registrados',
            ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => PersonDialog(
        onSave: widget.onAdd,
      ),
    );
  }

  void _showEditDialog(FamilyMember member, int index) {
    showDialog(
      context: context,
      builder: (context) => PersonDialog(
        initialData: member,
        onSave: (updatedMember) => widget.onEdit(index, updatedMember),
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar persona'),
        content: const Text('¿Estás seguro que deseas eliminar esta persona?'),
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


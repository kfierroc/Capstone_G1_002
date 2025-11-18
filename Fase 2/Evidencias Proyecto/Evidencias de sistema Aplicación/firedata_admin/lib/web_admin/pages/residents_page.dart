import 'package:firedata_admin/models/resident.dart';
import 'package:firedata_admin/models/family_group_info.dart';
import 'package:firedata_admin/models/mascota.dart';
import 'package:firedata_admin/web_admin/services/residents_admin_service.dart';
import 'package:firedata_admin/web_admin/services/integrantes_admin_service.dart';
import 'package:firedata_admin/web_admin/services/mascotas_admin_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResidentsPage extends StatefulWidget {
  const ResidentsPage({super.key});

  @override
  State<ResidentsPage> createState() => _ResidentsPageState();
}

class _ResidentsPageState extends State<ResidentsPage> {
  final TextEditingController _searchController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');
  bool _isLoading = true;
  List<Resident> _residents = [];
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadResidents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadResidents() async {
    setState(() => _isLoading = true);
    try {
      final data = await ResidentsAdminService.instance.fetchResidents(
        search: _searchTerm,
      );
      setState(() => _residents = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar residentes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showFamilyGroupDialog(Resident resident) async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final familyInfo = await ResidentsAdminService.instance
        .fetchFamilyGroupInfo(resident.idGroup);

    if (!mounted) return;
    Navigator.of(context).pop(); // Cerrar loading

    if (familyInfo == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo cargar la información del grupo familiar'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 700,
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.groups, color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Grupo Familiar #${resident.idGroup}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              if (resident.fullName.isNotEmpty) ...[
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade300,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                              ],
                              Flexible(
                                child: Text(
                                  resident.fullName.isNotEmpty
                                      ? 'Titular: ${resident.fullName}'
                                      : 'Titular: No especificado',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Resumen con cards
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.people,
                              title: 'Integrantes',
                              value: familyInfo.integrantesCount.toString(),
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.pets,
                              title: 'Mascotas',
                              value: familyInfo.mascotasCount.toString(),
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.medical_services,
                              title: 'Condiciones Médicas',
                              value: familyInfo.condicionesMedicasCount.toString(),
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Integrantes
                      if (familyInfo.integrantes.isNotEmpty) ...[
                        Text(
                          'Integrantes (${familyInfo.integrantes.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ...familyInfo.integrantes.asMap().entries.map((entry) {
                          final index = entry.key;
                          final integrante = entry.value;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                child: Icon(
                                  Icons.person,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                'Persona ${index + 1}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (integrante.edad != null)
                                    Text('Edad: ${integrante.edad} años'),
                                  if (integrante.padecimiento != null &&
                                      integrante.padecimiento!.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.medical_services,
                                            size: 16,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              integrante.padecimiento!,
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                      ],
                      // Mascotas
                      if (familyInfo.mascotas.isNotEmpty) ...[
                        Text(
                          'Mascotas (${familyInfo.mascotas.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ...familyInfo.mascotas.map((mascota) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange.withOpacity(0.1),
                                child: const Icon(
                                  Icons.pets,
                                  color: Colors.orange,
                                ),
                              ),
                              title: Text(
                                mascota.nombre,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                '${mascota.especie} - ${mascota.tamanio}',
                              ),
                            ),
                          );
                        }),
                      ],
                      if (familyInfo.integrantes.isEmpty &&
                          familyInfo.mascotas.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text(
                              'No hay integrantes ni mascotas registradas',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showManageFamilyGroupDialog(Resident resident) async {
    // Cargar información actual del grupo familiar
    final familyInfo = await ResidentsAdminService.instance
        .fetchFamilyGroupInfo(resident.idGroup);

    if (!mounted) return;

    if (familyInfo == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo cargar la información del grupo familiar'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 800,
            constraints: const BoxConstraints(maxHeight: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gestionar Grupo Familiar #${resident.idGroup}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'RUT: ${resident.rut}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Botones de acción
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                await _showIntegranteDialog(resident.idGroup);
                                // Recargar información
                                final updatedInfo = await ResidentsAdminService.instance
                                    .fetchFamilyGroupInfo(resident.idGroup);
                                if (mounted && updatedInfo != null) {
                                  setState(() {
                                    // Actualizar estado
                                  });
                                  await _loadResidents();
                                }
                                if (mounted) Navigator.of(context).pop();
                                await _showManageFamilyGroupDialog(resident);
                              },
                              icon: const Icon(Icons.person_add),
                              label: const Text('Agregar Integrante'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await _showMascotaDialog(resident.idGroup);
                                // Recargar información
                                final updatedInfo = await ResidentsAdminService.instance
                                    .fetchFamilyGroupInfo(resident.idGroup);
                                if (mounted && updatedInfo != null) {
                                  setState(() {
                                    // Actualizar estado
                                  });
                                  await _loadResidents();
                                }
                                if (mounted) Navigator.of(context).pop();
                                await _showManageFamilyGroupDialog(resident);
                              },
                              icon: const Icon(Icons.pets),
                              label: const Text('Agregar Mascota'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Integrantes
                        Text(
                          'Integrantes (${familyInfo.integrantes.length})',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        if (familyInfo.integrantes.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text(
                                'No hay integrantes registrados',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ...familyInfo.integrantes.map((integrante) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  child: Icon(
                                    Icons.person,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                title: Text(
                                  integrante.edad != null
                                      ? 'Edad: ${integrante.edad} años'
                                      : 'Integrante #${integrante.idIntegrante}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: integrante.padecimiento != null &&
                                        integrante.padecimiento!.isNotEmpty
                                    ? Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.medical_services,
                                              size: 16,
                                              color: Colors.red,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                integrante.padecimiento!,
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : null,
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Eliminar integrante'),
                                        content: const Text(
                                            '¿Seguro que deseas eliminar este integrante?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(false),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      try {
                                        await IntegrantesAdminService.instance
                                            .deleteIntegrante(integrante.idIntegrante);
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Integrante eliminado'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                        if (mounted) Navigator.of(context).pop();
                                        await _showManageFamilyGroupDialog(resident);
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Error: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                ),
                                onTap: () async {
                                  await _showIntegranteDialog(
                                    resident.idGroup,
                                    integrante: integrante,
                                  );
                                  if (mounted) Navigator.of(context).pop();
                                  await _showManageFamilyGroupDialog(resident);
                                },
                              ),
                            );
                          }),
                        const SizedBox(height: 24),
                        // Mascotas
                        Text(
                          'Mascotas (${familyInfo.mascotas.length})',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        if (familyInfo.mascotas.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text(
                                'No hay mascotas registradas',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ...familyInfo.mascotas.map((mascota) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange.withOpacity(0.1),
                                  child: const Icon(
                                    Icons.pets,
                                    color: Colors.orange,
                                  ),
                                ),
                                title: Text(
                                  mascota.nombre,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text('${mascota.especie} - ${mascota.tamanio}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Eliminar mascota'),
                                        content: const Text(
                                            '¿Seguro que deseas eliminar esta mascota?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(false),
                                            child: const Text('Cancelar'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      try {
                                        await MascotasAdminService.instance
                                            .deleteMascota(mascota.idMascota);
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Mascota eliminada'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                        if (mounted) Navigator.of(context).pop();
                                        await _showManageFamilyGroupDialog(resident);
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Error: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                ),
                                onTap: () async {
                                  await _showMascotaDialog(
                                    resident.idGroup,
                                    mascota: mascota,
                                  );
                                  if (mounted) Navigator.of(context).pop();
                                  await _showManageFamilyGroupDialog(resident);
                                },
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showIntegranteDialog(
    int idGrupof, {
    IntegranteInfo? integrante,
  }) async {
    final formKey = GlobalKey<FormState>();
    final anioNacController = TextEditingController(
      text: integrante?.anioNac != null ? integrante!.anioNac.toString() : '',
    );
    final otherConditionController = TextEditingController();

    // Categorías de condiciones médicas (igual que en app de Residente)
    final Map<String, List<String>> conditionCategories = {
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

    // Parsear condiciones existentes
    List<String> selectedConditions = [];
    String otherCondition = '';
    
    if (integrante?.padecimiento != null && integrante!.padecimiento!.isNotEmpty) {
      final conditions = integrante.padecimiento!.split(',').map((e) => e.trim()).toList();
      // Separar condiciones predefinidas de la condición especial
      final allPredefined = conditionCategories.values.expand((list) => list).toList();
      for (final condition in conditions) {
        if (allPredefined.contains(condition)) {
          selectedConditions.add(condition);
        } else {
          otherCondition = condition;
        }
      }
      if (otherCondition.isNotEmpty) {
        otherConditionController.text = otherCondition;
      }
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return DefaultTabController(
          length: conditionCategories.length,
          child: StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
          title: Text(integrante != null ? 'Editar integrante' : 'Agregar integrante'),
        content: SizedBox(
            width: 600,
            height: 600,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                      controller: anioNacController,
                    decoration: const InputDecoration(
                        labelText: 'Año de nacimiento',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obligatorio';
                        }
                        final anio = int.tryParse(value);
                        if (anio == null) {
                          return 'Ingresa un año válido';
                        }
                        if (anio < 1900 || anio > DateTime.now().year) {
                          return 'Ingresa un año válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Condiciones médicas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Selecciona todas las condiciones que apliquen',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          TabBar(
                            labelColor: Theme.of(context).colorScheme.primary,
                            unselectedLabelColor: Colors.grey.shade600,
                            tabs: conditionCategories.keys.map((key) => Tab(text: key)).toList(),
                          ),
                          SizedBox(
                            height: 250,
                            child: TabBarView(
                              children: conditionCategories.entries.map((entry) {
                                return ListView(
                                  padding: const EdgeInsets.all(16),
                                  children: entry.value.map((condition) {
                                    final isSelected = selectedConditions.contains(condition);
                                    return CheckboxListTile(
                                      title: Text(condition),
                                      value: isSelected,
                                      onChanged: (value) {
                                        setDialogState(() {
                                          if (value == true) {
                                            selectedConditions.add(condition);
                                          } else {
                                            selectedConditions.remove(condition);
                                          }
                                        });
                                      },
                                      activeColor: Theme.of(context).colorScheme.primary,
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
                    if (selectedConditions.isNotEmpty) ...[
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
                        children: selectedConditions.map((condition) {
                          return Chip(
                            label: Text(condition),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              setDialogState(() {
                                selectedConditions.remove(condition);
                              });
                            },
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: otherConditionController,
                            decoration: InputDecoration(
                              labelText: 'Otra condición especial (opcional)',
                              hintText: 'Ingrese otra condición no listada',
                              prefixIcon: const Icon(Icons.medical_services_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
              child: Text(integrante != null ? 'Guardar' : 'Agregar'),
            ),
          ],
        ),
          ),
        );
      },
    );

    if (confirmed == true) {
      try {
        final anioNac = int.parse(anioNacController.text.trim());
        
        // Combinar condiciones seleccionadas y condición especial
        List<String> allConditions = List.from(selectedConditions);
        final otherCondition = otherConditionController.text.trim();
        if (otherCondition.isNotEmpty) {
          allConditions.add(otherCondition);
        }
        
        final padecimiento = allConditions.isEmpty
            ? null
            : allConditions.join(', ');

        if (integrante != null) {
          // Editar
          await IntegrantesAdminService.instance.updateIntegranteInfo(
            idIntegrante: integrante.idIntegrante,
            anioNac: anioNac,
            padecimiento: padecimiento,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Integrante actualizado'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // Crear
          await IntegrantesAdminService.instance.insertIntegrante(
            idGrupof: idGrupof,
            anioNac: anioNac,
            padecimiento: padecimiento,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Integrante agregado'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
        await _loadResidents();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showMascotaDialog(
    int idGrupof, {
    MascotaInfo? mascota,
  }) async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: mascota?.nombre ?? '');
    final especieController = TextEditingController(text: mascota?.especie ?? '');
    final tamanioController = TextEditingController(text: mascota?.tamanio ?? '');

    String? selectedTamanio = mascota?.tamanio;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(mascota != null ? 'Editar mascota' : 'Agregar mascota'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: especieController,
                    decoration: const InputDecoration(
                      labelText: 'Especie',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedTamanio,
                    decoration: const InputDecoration(
                      labelText: 'Tamaño',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Muy pequeño', 'Pequeño', 'Mediano', 'Grande', 'Muy grande']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedTamanio = value;
                        if (value != null) {
                          tamanioController.text = value;
                        }
                      });
                    },
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obligatorio' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
              child: Text(mascota != null ? 'Guardar' : 'Agregar'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      try {
        if (mascota != null) {
          // Editar - necesito obtener la mascota completa
          final mascotas = await MascotasAdminService.instance.fetchMascotas(idGrupof);
          final mascotaCompleta = mascotas.firstWhere(
            (m) => m.idMascota == mascota.idMascota,
          );
          final updated = Mascota(
            idMascota: mascotaCompleta.idMascota,
            nombreM: nombreController.text.trim(),
            especie: especieController.text.trim(),
            tamanio: tamanioController.text.trim(),
            fechaRegM: mascotaCompleta.fechaRegM,
            idGrupof: mascotaCompleta.idGrupof,
          );
          await MascotasAdminService.instance.updateMascota(updated);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mascota actualizada'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // Crear
          await MascotasAdminService.instance.insertMascota(
            idGrupof: idGrupof,
            nombreM: nombreController.text.trim(),
            especie: especieController.text.trim(),
            tamanio: tamanioController.text.trim(),
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mascota agregada'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
        await _loadResidents();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showResidentDialog({Resident? resident}) async {
    final formKey = GlobalKey<FormState>();
    
    // Asegurar que los datos se inicializan correctamente
    final isEditing = resident != null;
    final rutController = TextEditingController(text: resident?.rut?.trim() ?? '');
    final emailController = TextEditingController(text: resident?.email?.trim() ?? '');
    final phoneController = TextEditingController(text: resident?.phone?.trim() ?? '');

    bool addFamilyGroup = false; // Flag para agregar grupo familiar después

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isEditing ? 'Editar residente' : 'Agregar residente'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // RUT: Solo lectura cuando se está editando (es parte de la primary key)
                  if (isEditing)
                  TextFormField(
                      controller: rutController,
                    decoration: const InputDecoration(
                        labelText: 'RUT titular (No editable)',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey,
                        prefixIcon: Icon(Icons.lock, color: Colors.grey),
                      ),
                      enabled: false,
                      style: const TextStyle(color: Colors.black54),
                    )
                  else
                    TextFormField(
                      controller: rutController,
                      decoration: const InputDecoration(
                        labelText: 'RUT titular',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono titular',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  if (!isEditing) ...[
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Agregar grupo familiar después'),
                      subtitle: const Text('Permite agregar integrantes, mascotas y condiciones médicas'),
                      value: addFamilyGroup,
                      onChanged: (value) {
                        setDialogState(() {
                          addFamilyGroup = value ?? false;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: Text(isEditing ? 'Guardar cambios' : 'Crear'),
          ),
        ],
        ),
      ),
    );

    if (confirmed == true) {
      Resident newResident;
      int? createdIdGroup;
      
      if (isEditing) {
        // Al editar, mantener el ID original y los datos del titular (RUT)
        // Solo permitir editar teléfono y email
        newResident = Resident(
          idGroup: resident!.idGroup,
          rut: resident.rut, // Mantener RUT original
          firstName: resident.firstName, // Mantener nombre original (no editable)
          lastName: resident.lastName, // Mantener apellido original (no editable)
          email: emailController.text.trim(), // Permitir editar email
          phone: phoneController.text.trim(), // Permitir editar teléfono
          createdAt: resident.createdAt,
        );
      } else {
        // Al crear, usar todos los datos del formulario
        // Los campos nombre y apellido se omiten ya que no están en el formulario
        // Usar valores por defecto para cumplir con NOT NULL en la base de datos
        newResident = Resident(
          idGroup: 0,
        rut: rutController.text.trim(),
          firstName: 'Sin nombre', // Valor por defecto para cumplir con NOT NULL
          lastName: 'Sin apellido', // Valor por defecto para cumplir con NOT NULL
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
          createdAt: DateTime.now(),
      );
      }

      try {
        if (isEditing) {
          await ResidentsAdminService.instance.updateResident(newResident);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Grupo familiar actualizado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
          // Si se está editando, permitir editar grupo familiar
          await _loadResidents();
          if (mounted && resident != null) {
            final updatedResident = _residents.firstWhere(
              (r) => r.idGroup == resident.idGroup,
              orElse: () => resident,
            );
            await _showManageFamilyGroupDialog(updatedResident);
          }
        } else {
          await ResidentsAdminService.instance.insertResident(newResident);
          // Obtener el ID del grupo familiar creado
          final createdResident = _residents.isNotEmpty 
              ? _residents.first 
              : null;
          createdIdGroup = createdResident?.idGroup;
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Grupo familiar creado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
        }
        await _loadResidents();
          
          // Si se marcó agregar grupo familiar, mostrar diálogo de gestión
          if (mounted && addFamilyGroup && createdIdGroup != null) {
            final createdResident = _residents.firstWhere(
              (r) => r.idGroup == createdIdGroup,
              orElse: () => newResident,
            );
            await _showManageFamilyGroupDialog(createdResident);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se pudo guardar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteResident(Resident resident) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar residente'),
        content: Text(
          '¿Seguro que deseas eliminar al titular ${resident.fullName} (RUT ${resident.rut})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ResidentsAdminService.instance.deleteResident(resident.idGroup);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Grupo familiar eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await _loadResidents();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se pudo eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final padding = isMobile ? 12.0 : isTablet ? 16.0 : 24.0;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header moderno
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 8 : 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.groups,
                    color: Theme.of(context).colorScheme.primary,
                    size: isMobile ? 24 : 28,
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Residentes',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 20 : null,
                            ),
                      ),
                      Text(
                        '${_residents.length} residentes registrados',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                              fontSize: isMobile ? 12 : null,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 24),
            // Barra de búsqueda y acciones
            isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) {
                          _searchTerm = _searchController.text;
                          _loadResidents();
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Buscar...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      _searchController.clear();
                                      _searchTerm = '';
                                      _loadResidents();
                                    },
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Actualizar'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : () => _showResidentDialog(),
                              icon: const Icon(Icons.person_add, size: 18),
                              label: const Text('Agregar'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 400, minWidth: 200),
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) {
                            _searchTerm = _searchController.text;
                            _loadResidents();
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Buscar por nombre, RUT o email',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () {
                                _searchController.clear();
                                _searchTerm = '';
                                _loadResidents();
                              },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Actualizar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _showResidentDialog(),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Agregar titular'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: isMobile ? 16 : 24),
            // Tabla
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _residents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: isMobile ? 48 : 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No se encontraron residentes.',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: isMobile ? 14 : 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final scrollController = ScrollController();
                              return Scrollbar(
                                controller: scrollController,
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: constraints.maxWidth,
                                    ),
                                    child: DataTable(
                                      headingRowColor: MaterialStateProperty.resolveWith(
                                        (states) => Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.08),
                                      ),
                                      headingRowHeight: isMobile ? 48 : 56,
                                      dataRowMinHeight: isMobile ? 56 : 64,
                                      dataRowMaxHeight: isMobile ? 72 : 80,
                                      columns: [
                                        DataColumn(
                                          label: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.tag,
                                                size: isMobile ? 16 : 18,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              SizedBox(width: isMobile ? 2 : 4),
                                              Text(
                                                'ID',
                                                style: TextStyle(fontSize: isMobile ? 12 : null),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataColumn(
                                          label: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.person,
                                                size: isMobile ? 16 : 18,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              SizedBox(width: isMobile ? 2 : 4),
                                              Text(
                                                'Titular',
                                                style: TextStyle(fontSize: isMobile ? 12 : null),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!isMobile)
                                          DataColumn(
                                            label: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.badge,
                                                  size: 18,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                const Text('RUT'),
                                              ],
                                            ),
                                          ),
                                        if (!isMobile)
                                          DataColumn(
                                            label: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.phone,
                                                  size: 18,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                const Text('Teléfono'),
                                              ],
                                            ),
                                          ),
                                        DataColumn(
                                          label: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.email,
                                                size: isMobile ? 16 : 18,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              SizedBox(width: isMobile ? 2 : 4),
                                              Text(
                                                'Email',
                                                style: TextStyle(fontSize: isMobile ? 12 : null),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataColumn(
                                          label: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.family_restroom,
                                                size: isMobile ? 16 : 18,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              SizedBox(width: isMobile ? 2 : 4),
                                              Flexible(
                                                child: Text(
                                                  isMobile ? 'Grupo' : 'Grupo Familiar',
                                                  style: TextStyle(fontSize: isMobile ? 12 : null),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!isMobile)
                                          DataColumn(
                                            label: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  size: 18,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                const Text('Fecha creación'),
                                              ],
                                            ),
                                          ),
                                        DataColumn(
                                          label: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.settings,
                                                size: isMobile ? 16 : 18,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              SizedBox(width: isMobile ? 2 : 4),
                                              Text(
                                                'Acciones',
                                                style: TextStyle(fontSize: isMobile ? 12 : null),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      rows: _residents.map((resident) {
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(
                                              resident.idGroup.toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: isMobile ? 12 : null,
                                              ),
                                            )),
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (resident.fullName.isNotEmpty) ...[
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green,
                                                      size: isMobile ? 14 : 16,
                                                    ),
                                                    const SizedBox(width: 6),
                                                  ],
                                                  Flexible(
                                                    child: Text(
                                                      resident.fullName.isNotEmpty
                                                          ? resident.fullName
                                                          : 'No especificado',
                                                      style: TextStyle(fontSize: isMobile ? 12 : null),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (!isMobile) DataCell(Text(resident.rut)),
                                            if (!isMobile)
                                              DataCell(Text(
                                                resident.phone.isEmpty ? '-' : resident.phone,
                                              )),
                                            DataCell(Text(
                                              resident.email,
                                              style: TextStyle(fontSize: isMobile ? 11 : null),
                                            )),
                                            DataCell(
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: isMobile ? 8 : 12,
                                                  vertical: isMobile ? 6 : 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.blue.shade200,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.people,
                                                      size: isMobile ? 14 : 16,
                                                      color: Colors.blue.shade700,
                                                    ),
                                                    SizedBox(width: isMobile ? 4 : 6),
                                                    Text(
                                                      '${resident.integrantesCount ?? 0}',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.blue.shade700,
                                                        fontSize: isMobile ? 11 : null,
                                                      ),
                                                    ),
                                                    SizedBox(width: isMobile ? 6 : 8),
                                                    Icon(
                                                      Icons.pets,
                                                      size: isMobile ? 14 : 16,
                                                      color: Colors.orange.shade700,
                                                    ),
                                                    SizedBox(width: isMobile ? 4 : 6),
                                                    Text(
                                                      '${resident.mascotasCount ?? 0}',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.orange.shade700,
                                                        fontSize: isMobile ? 11 : null,
                                                      ),
                                                    ),
                                                    SizedBox(width: isMobile ? 6 : 8),
                                                    Icon(
                                                      Icons.medical_services,
                                                      size: isMobile ? 14 : 16,
                                                      color: Colors.red.shade700,
                                                    ),
                                                    SizedBox(width: isMobile ? 4 : 6),
                                                    Text(
                                                      '${resident.condicionesMedicasCount ?? 0}',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.red.shade700,
                                                        fontSize: isMobile ? 11 : null,
                                                      ),
                                                    ),
                                                    SizedBox(width: isMobile ? 6 : 8),
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.visibility,
                                                        size: isMobile ? 16 : 18,
                                                        color: Colors.blue.shade700,
                                                      ),
                                                      onPressed: () =>
                                                          _showFamilyGroupDialog(resident),
                                                      tooltip: 'Ver detalles',
                                                      padding: EdgeInsets.zero,
                                                      constraints: const BoxConstraints(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (!isMobile)
                                              DataCell(Text(
                                                resident.createdAt != null
                                                    ? _dateFormat.format(resident.createdAt!)
                                                    : '-',
                                              )),
                                            DataCell(
                                              Wrap(
                                                spacing: isMobile ? 4 : 8,
                                                children: [
                                                  IconButton(
                                                    tooltip: 'Editar',
                                                    icon: Icon(
                                                      Icons.edit_outlined,
                                                      size: isMobile ? 18 : null,
                                                    ),
                                                    color: Colors.blue,
                                                    onPressed: () =>
                                                        _showResidentDialog(resident: resident),
                                                    padding: EdgeInsets.zero,
                                                    constraints: BoxConstraints(
                                                      minWidth: isMobile ? 32 : 48,
                                                      minHeight: isMobile ? 32 : 48,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    tooltip: 'Gestionar grupo familiar',
                                                    icon: Icon(
                                                      Icons.group_add,
                                                      size: isMobile ? 18 : null,
                                                    ),
                                                    color: Colors.green,
                                                    onPressed: () =>
                                                        _showManageFamilyGroupDialog(resident),
                                                    padding: EdgeInsets.zero,
                                                    constraints: BoxConstraints(
                                                      minWidth: isMobile ? 32 : 48,
                                                      minHeight: isMobile ? 32 : 48,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    tooltip: 'Eliminar',
                                                    icon: Icon(
                                                      Icons.delete_outline,
                                                      size: isMobile ? 18 : null,
                                                    ),
                                                    color: Colors.red,
                                                    onPressed: () => _deleteResident(resident),
                                                    padding: EdgeInsets.zero,
                                                    constraints: BoxConstraints(
                                                      minWidth: isMobile ? 32 : 48,
                                                      minHeight: isMobile ? 32 : 48,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:firedata_admin/models/bombero.dart';
import 'package:firedata_admin/web_admin/services/firefighters_admin_service.dart';
import 'package:flutter/material.dart';

class FirefightersPage extends StatefulWidget {
  const FirefightersPage({super.key});

  @override
  State<FirefightersPage> createState() => _FirefightersPageState();
}

class _FirefightersPageState extends State<FirefightersPage> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<Bombero> _firefighters = [];
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadFirefighters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFirefighters() async {
    setState(() => _isLoading = true);
    try {
      final data = await FirefightersAdminService.instance.fetchFirefighters(
        search: _searchTerm,
      );
      setState(() => _firefighters = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar bomberos: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showBomberoDialog({Bombero? bombero}) async {
    final formKey = GlobalKey<FormState>();
    final rutController = TextEditingController(text: bombero?.rutCompleto ?? '');
    final firstNameController = TextEditingController(text: bombero?.nombBombero ?? '');
    final lastNameController = TextEditingController(text: bombero?.apePBombero ?? '');
    final companyController = TextEditingController(text: bombero?.compania ?? '');
    final emailController = TextEditingController(text: bombero?.emailB ?? '');

    final isEditing = bombero != null;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar bombero' : 'Agregar bombero'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: rutController,
                    decoration: const InputDecoration(labelText: 'RUT'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: firstNameController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'Apellido paterno'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: companyController,
                    decoration: const InputDecoration(labelText: 'Compañía'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obligatorio' : null,
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
            child: Text(isEditing ? 'Guardar cambios' : 'Crear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final parsed = Bombero.fromRutCompleto(
        rutController.text.trim(),
        companyController.text.trim(),
      );

      final newBombero = Bombero(
        rutNum: parsed.rutNum,
        rutDv: parsed.rutDv,
        compania: companyController.text.trim(),
        nombBombero: firstNameController.text.trim(),
        apePBombero: lastNameController.text.trim(),
        emailB: emailController.text.trim(),
        cutCom: bombero?.cutCom ?? parsed.cutCom,
      );

      try {
        if (isEditing) {
          await FirefightersAdminService.instance.updateFirefighter(newBombero);
        } else {
          await FirefightersAdminService.instance.insertFirefighter(newBombero);
        }
        await _loadFirefighters();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo guardar: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteBombero(Bombero bombero) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar bombero'),
        content: Text(
          '¿Seguro que deseas eliminar a ${bombero.nombBombero} ${bombero.apePBombero} (RUT ${bombero.rutCompleto})?',
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
        await FirefightersAdminService.instance.deleteFirefighter(bombero.rutNum);
        await _loadFirefighters();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo eliminar: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final padding = isMobile ? 12.0 : 24.0;
    
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
                    Icons.fire_extinguisher,
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
                        'Bomberos',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 20 : null,
                            ),
                      ),
                      Text(
                        '${_firefighters.length} bomberos registrados',
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
            // Barra de búsqueda y acciones - usar el mismo patrón que houses_page
            isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) {
                          _searchTerm = _searchController.text;
                          _loadFirefighters();
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
                                      _loadFirefighters();
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
                              onPressed: _isLoading ? null : () => _showBomberoDialog(),
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
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) {
                              _searchTerm = _searchController.text;
                              _loadFirefighters();
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
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () {
                                _searchController.clear();
                                _searchTerm = '';
                                _loadFirefighters();
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
                        onPressed: _isLoading ? null : () => _showBomberoDialog(),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Agregar bombero'),
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
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _firefighters.isEmpty
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
                                'No se encontraron bomberos.',
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
                              return Scrollbar(
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: constraints.maxWidth,
                                    ),
                                    child: DataTable(
                                      headingRowColor: MaterialStateProperty.resolveWith(
                                        (states) =>
                                            Theme.of(context).colorScheme.primary.withOpacity(0.08),
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
                                                Icons.badge,
                                                size: isMobile ? 16 : 18,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              SizedBox(width: isMobile ? 2 : 4),
                                              Text(
                                                'RUT',
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
                                                'Nombre',
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
                                                  Icons.person_outline,
                                                  size: 18,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                const Text('Apellido paterno'),
                                              ],
                                            ),
                                          ),
                                        DataColumn(
                                          label: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.local_fire_department,
                                                size: isMobile ? 16 : 18,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              SizedBox(width: isMobile ? 2 : 4),
                                              Text(
                                                'Compañía',
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
                                                  Icons.email,
                                                  size: 18,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                const Text('Email'),
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
                                      rows: _firefighters.map((bombero) {
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(
                                              bombero.rutCompleto,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: isMobile ? 12 : null,
                                              ),
                                            )),
                                            DataCell(Text(
                                              bombero.nombBombero,
                                              style: TextStyle(fontSize: isMobile ? 12 : null),
                                            )),
                                            if (!isMobile)
                                              DataCell(Text(bombero.apePBombero)),
                                            DataCell(Text(
                                              bombero.compania,
                                              style: TextStyle(fontSize: isMobile ? 12 : null),
                                            )),
                                            if (!isMobile)
                                              DataCell(Text(bombero.emailB ?? '-')),
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
                                                        _showBomberoDialog(bombero: bombero),
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
                                                    onPressed: () => _deleteBombero(bombero),
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




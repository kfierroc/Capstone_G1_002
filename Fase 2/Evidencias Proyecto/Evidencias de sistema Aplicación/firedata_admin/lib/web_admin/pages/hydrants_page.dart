import 'package:firedata_admin/models/grifo.dart';
import 'package:firedata_admin/web_admin/services/hydrants_admin_service.dart';
import 'package:flutter/material.dart';

class HydrantsPage extends StatefulWidget {
  const HydrantsPage({super.key});

  @override
  State<HydrantsPage> createState() => _HydrantsPageState();
}

class _HydrantsPageState extends State<HydrantsPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<Grifo> _hydrants = [];
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadHydrants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHydrants() async {
    setState(() => _isLoading = true);
    try {
      final data = await HydrantsAdminService.instance.fetchHydrants(
        search: _searchTerm,
      );
      setState(() => _hydrants = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar grifos: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showHydrantDialog({Grifo? grifo}) async {
    final formKey = GlobalKey<FormState>();
    final latController =
        TextEditingController(text: grifo?.lat.toString() ?? '');
    final lonController =
        TextEditingController(text: grifo?.lon.toString() ?? '');
    final cutComController =
        TextEditingController(text: grifo?.cutCom.toString() ?? '');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(grifo == null ? 'Agregar grifo' : 'Editar grifo'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: latController,
                    decoration: const InputDecoration(labelText: 'Latitud'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) =>
                        value == null || double.tryParse(value) == null
                            ? 'Ingresa una latitud válida'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: lonController,
                    decoration: const InputDecoration(labelText: 'Longitud'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) =>
                        value == null || double.tryParse(value) == null
                            ? 'Ingresa una longitud válida'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: cutComController,
                    decoration: const InputDecoration(labelText: 'CUT Comuna'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || int.tryParse(value) == null
                            ? 'Ingresa un CUT numérico válido'
                            : null,
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
            child: Text(grifo == null ? 'Crear' : 'Guardar cambios'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Al editar, mantener el ID original (no permitir cambiar el ID)
      final updated = Grifo(
        idGrifo: grifo != null ? grifo.idGrifo : 0,
        lat: double.parse(latController.text.trim()),
        lon: double.parse(lonController.text.trim()),
        cutCom: int.parse(cutComController.text.trim()),
      );

      try {
        if (grifo == null) {
          await HydrantsAdminService.instance.insertHydrant(updated);
        } else {
          await HydrantsAdminService.instance.updateHydrant(updated);
        }
        await _loadHydrants();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo guardar: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteHydrant(Grifo grifo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar grifo'),
        content: Text(
          '¿Seguro que deseas eliminar el grifo #${grifo.idGrifo}?',
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
        await HydrantsAdminService.instance.deleteHydrant(grifo.idGrifo);
        await _loadHydrants();
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
                    Icons.water_drop,
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
                        'Grifos',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 20 : null,
                            ),
                      ),
                      Text(
                        '${_hydrants.length} grifos registrados',
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
                          _loadHydrants();
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
                                      _loadHydrants();
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
                              onPressed: _isLoading ? null : () => _showHydrantDialog(),
                              icon: const Icon(Icons.water_drop, size: 18),
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
                              _loadHydrants();
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: 'Buscar por ID, coordenadas o CUT',
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
                                _loadHydrants();
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
                        onPressed: _isLoading ? null : () => _showHydrantDialog(),
                        icon: const Icon(Icons.water_drop),
                        label: const Text('Agregar grifo'),
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
                  : _hydrants.isEmpty
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
                                'No se encontraron grifos.',
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
                                                Icons.navigation,
                                                size: isMobile ? 16 : 18,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              SizedBox(width: isMobile ? 2 : 4),
                                              Text(
                                                'Latitud',
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
                                                Icons.navigation,
                                                size: isMobile ? 16 : 18,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              SizedBox(width: isMobile ? 2 : 4),
                                              Text(
                                                'Longitud',
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
                                                Icons.map,
                                                size: isMobile ? 16 : 18,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              SizedBox(width: isMobile ? 2 : 4),
                                              Text(
                                                'CUT Comuna',
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
                                      rows: _hydrants.map((grifo) {
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(
                                              grifo.idGrifo.toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: isMobile ? 12 : null,
                                              ),
                                            )),
                                            DataCell(Text(
                                              grifo.lat.toStringAsFixed(6),
                                              style: TextStyle(fontSize: isMobile ? 12 : null),
                                            )),
                                            DataCell(Text(
                                              grifo.lon.toStringAsFixed(6),
                                              style: TextStyle(fontSize: isMobile ? 12 : null),
                                            )),
                                            DataCell(Text(
                                              grifo.cutCom.toString(),
                                              style: TextStyle(fontSize: isMobile ? 12 : null),
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
                                                        _showHydrantDialog(grifo: grifo),
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
                                                    onPressed: () => _deleteHydrant(grifo),
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




import 'package:firedata_admin/models/residencia.dart';
import 'package:firedata_admin/models/registro_v.dart';
import 'package:firedata_admin/web_admin/services/houses_admin_service.dart';
import 'package:firedata_admin/web_admin/services/registro_v_admin_service.dart';
import 'package:flutter/material.dart';

class HousesPage extends StatefulWidget {
  const HousesPage({super.key});

  @override
  State<HousesPage> createState() => _HousesPageState();
}

class _HousesPageState extends State<HousesPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<Residencia> _houses = [];
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadHouses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHouses() async {
    setState(() => _isLoading = true);
    try {
      final data = await HousesAdminService.instance.fetchHouses(search: _searchTerm);
      setState(() => _houses = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar viviendas: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showHouseDialog({Residencia? house}) async {
    final formKey = GlobalKey<FormState>();
    final addressController = TextEditingController(text: house?.direccion ?? '');
    final latController = TextEditingController(text: house?.lat.toString() ?? '');
    final lonController = TextEditingController(text: house?.lon.toString() ?? '');
    final cutComController = TextEditingController(text: house?.cutCom.toString() ?? '');
    
    // Campos de registro_v (Vivienda)
    String? selectedTipo = house?.tipo;
    String? selectedPisos = house?.pisos?.toString() ?? '1';
    String? selectedMaterial = house?.material;
    String? selectedEstado = house?.estado ?? 'Activo';
    
    // RUT del residente (solo lectura)
    final rutResidenteController = TextEditingController(text: house?.rutResidente ?? '');

    final isEditing = house != null;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return DefaultTabController(
          length: 2,
          child: StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: Text(isEditing ? 'Editar vivienda' : 'Agregar vivienda'),
              content: SizedBox(
                width: 600,
                height: 600,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TabBar(
                        labelColor: Theme.of(context).colorScheme.primary,
                        unselectedLabelColor: Colors.grey,
                        tabs: const [
                          Tab(icon: Icon(Icons.location_on), text: 'Domicilio'),
                          Tab(icon: Icon(Icons.home), text: 'Vivienda'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                        children: [
                          // Tab Domicilio
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: addressController,
                                  decoration: const InputDecoration(
                                    labelText: 'Dirección *',
                                    prefixIcon: Icon(Icons.location_on),
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) =>
                                      value == null || value.isEmpty ? 'Campo obligatorio' : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: latController,
                                  decoration: const InputDecoration(
                                    labelText: 'Latitud *',
                                    prefixIcon: Icon(Icons.navigation),
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (value) =>
                                      value == null || double.tryParse(value) == null
                                          ? 'Ingresa una latitud válida'
                                          : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: lonController,
                                  decoration: const InputDecoration(
                                    labelText: 'Longitud *',
                                    prefixIcon: Icon(Icons.navigation),
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (value) =>
                                      value == null || double.tryParse(value) == null
                                          ? 'Ingresa una longitud válida'
                                          : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: cutComController,
                                  decoration: const InputDecoration(
                                    labelText: 'CUT Comuna *',
                                    prefixIcon: Icon(Icons.map),
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) =>
                                      value == null || int.tryParse(value) == null
                                          ? 'Ingresa un CUT numérico válido'
                                          : null,
                                ),
                                // Mostrar RUT del residente relacionado (solo lectura)
                                if (isEditing && house?.rutResidente != null && house!.rutResidente!.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: rutResidenteController,
                                    decoration: const InputDecoration(
                                      labelText: 'RUT del residente relacionado (Solo lectura)',
                                      prefixIcon: Icon(Icons.person),
                                      filled: true,
                                      fillColor: Colors.grey,
                                      border: OutlineInputBorder(),
                                    ),
                                    enabled: false,
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Tab Vivienda
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Detalles de la Vivienda',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Tipo de vivienda
                                DropdownButtonFormField<String>(
                                  value: selectedTipo,
                                  decoration: const InputDecoration(
                                    labelText: 'Tipo de vivienda *',
                                    prefixIcon: Icon(Icons.home_outlined),
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const ['Casa', 'Departamento', 'Empresa', 'Local comercial', 'Oficina', 'Bodega', 'Otro']
                                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                      .toList(),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      selectedTipo = value;
                                    });
                                  },
                                  validator: (value) =>
                                      value == null || value.isEmpty ? 'Campo obligatorio' : null,
                                ),
                                const SizedBox(height: 16),
                                // Número de pisos
                                DropdownButtonFormField<String>(
                                  value: selectedPisos,
                                  decoration: InputDecoration(
                                    labelText: selectedTipo == 'Casa' || selectedTipo == 'Departamento' 
                                        ? 'Piso en el que resides *' 
                                        : 'Número de pisos *',
                                    prefixIcon: const Icon(Icons.layers_outlined),
                                    border: const OutlineInputBorder(),
                                  ),
                                  items: List.generate(62, (index) => index + 1)
                                      .map((floors) => DropdownMenuItem(
                                            value: floors.toString(),
                                            child: Text('$floors ${floors == 1 ? 'piso' : 'pisos'}'),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      selectedPisos = value;
                                    });
                                  },
                                  validator: (value) =>
                                      value == null || value.isEmpty ? 'Campo obligatorio' : null,
                                ),
                                const SizedBox(height: 16),
                                // Material de construcción
                                DropdownButtonFormField<String>(
                                  value: selectedMaterial,
                                  decoration: const InputDecoration(
                                    labelText: 'Material principal *',
                                    prefixIcon: Icon(Icons.construction_outlined),
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    'Hormigón/Concreto',
                                    'Ladrillo',
                                    'Madera',
                                    'Adobe',
                                    'Metal',
                                    'Material ligero',
                                    'Mixto',
                                    'Otro'
                                  ]
                                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                      .toList(),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      selectedMaterial = value;
                                    });
                                  },
                                  validator: (value) =>
                                      value == null || value.isEmpty ? 'Campo obligatorio' : null,
                                ),
                                const SizedBox(height: 16),
                                // Estado de la vivienda
                                DropdownButtonFormField<String>(
                                  value: selectedEstado,
                                  decoration: const InputDecoration(
                                    labelText: 'Estado general *',
                                    prefixIcon: Icon(Icons.home_repair_service_outlined),
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    'Excelente',
                                    'Bueno',
                                    'Regular',
                                    'Malo',
                                    'Muy malo',
                                    'Activo',
                                  ]
                                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                      .toList(),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      selectedEstado = value;
                                    });
                                  },
                                  validator: (value) =>
                                      value == null || value.isEmpty ? 'Campo obligatorio' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                child: Text(isEditing ? 'Guardar cambios' : 'Crear'),
              ),
            ],
          ),
          ),
        );
      },
    );

    if (confirmed == true) {
      try {
        // Al editar, mantener el ID original (no permitir cambiar el ID)
        final newHouse = Residencia(
          idResidencia: isEditing ? house!.idResidencia : 0,
          direccion: addressController.text.trim(),
          lat: double.parse(latController.text.trim()),
          lon: double.parse(lonController.text.trim()),
          cutCom: int.parse(cutComController.text.trim()),
          telefonoPrincipal: null, // Campo no existe en la tabla residencia
          numeroPisos: null, // No existe en la tabla residencia, se guarda en registro_v
          instruccionesEspeciales: house?.instruccionesEspeciales, // Se obtiene de registro_v, no de residencia
        );

        if (isEditing) {
          await HousesAdminService.instance.updateHouse(newHouse);
          // Actualizar o crear registro_v
          if (house?.idRegistro != null) {
            // Actualizar registro_v existente
            final registroV = RegistroV(
              idRegistro: house!.idRegistro!,
              vigente: house.vigente ?? true,
              estado: selectedEstado ?? 'Activo',
              material: selectedMaterial ?? '',
              tipo: selectedTipo ?? '',
              pisos: int.tryParse(selectedPisos ?? '1') ?? 1,
              fechaIniR: house.fechaIniR ?? DateTime.now(),
              fechaFinR: house.fechaFinR,
              idResidencia: house.idResidencia,
              idGrupof: house.idGrupof ?? 0,
              instruccionesEspeciales: house.instruccionesEspeciales,
            );
            await RegistroVAdminService.instance.updateRegistroV(registroV);
          } else {
            // Crear nuevo registro_v si no existe
            final registroV = RegistroV(
              idRegistro: DateTime.now().millisecondsSinceEpoch ~/ 1000,
              vigente: true,
              estado: selectedEstado ?? 'Activo',
              material: selectedMaterial ?? '',
              tipo: selectedTipo ?? '',
              pisos: int.tryParse(selectedPisos ?? '1') ?? 1,
              fechaIniR: DateTime.now(),
              fechaFinR: null,
              idResidencia: house!.idResidencia,
              idGrupof: house.idGrupof ?? 0,
              instruccionesEspeciales: house.instruccionesEspeciales,
            );
            await RegistroVAdminService.instance.insertRegistroV(registroV);
          }
        } else {
          await HousesAdminService.instance.insertHouse(newHouse);
          // Crear registro_v después de insertar vivienda
          // Necesitamos obtener el ID de la vivienda insertada
          await _loadHouses();
          final insertedHouse = _houses.firstWhere(
            (h) => h.direccion == newHouse.direccion && 
                   h.lat == newHouse.lat && 
                   h.lon == newHouse.lon,
            orElse: () => newHouse,
          );
          
          // Crear registro_v sin grupo familiar (se puede relacionar después)
          final registroV = RegistroV(
            idRegistro: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            vigente: true,
            estado: selectedEstado ?? 'Activo',
            material: selectedMaterial ?? '',
            tipo: selectedTipo ?? '',
            pisos: int.tryParse(selectedPisos ?? '1') ?? 1,
            fechaIniR: DateTime.now(),
            fechaFinR: null,
            idResidencia: insertedHouse.idResidencia,
            idGrupof: 0, // Se puede actualizar después
          );
          await RegistroVAdminService.instance.insertRegistroV(registroV);
        }
        await _loadHouses();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo guardar: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteHouse(Residencia house) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar vivienda'),
        content: Text('¿Seguro que deseas eliminar ${house.direccion}?'),
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
        await HousesAdminService.instance.deleteHouse(house.idResidencia);
        await _loadHouses();
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
                    Icons.house,
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
                        'Viviendas',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 20 : null,
                            ),
                      ),
                      Text(
                        '${_houses.length} viviendas registradas',
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
                          _loadHouses();
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
                                      _loadHouses();
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
                              onPressed: _isLoading ? null : () => _showHouseDialog(),
                              icon: const Icon(Icons.add_home, size: 18),
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
                              _loadHouses();
                            },
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: 'Buscar por dirección',
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
                                _loadHouses();
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
                        onPressed: _isLoading ? null : () => _showHouseDialog(),
                        icon: const Icon(Icons.add_home),
                        label: const Text('Agregar vivienda'),
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
                  : _houses.isEmpty
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
                                'No se encontraron viviendas.',
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
                                                Icons.location_on,
                                                size: isMobile ? 16 : 18,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              SizedBox(width: isMobile ? 2 : 4),
                                              Text(
                                                'Dirección',
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
                                                  Icons.navigation,
                                                  size: 18,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                const Text('Latitud'),
                                              ],
                                            ),
                                          ),
                                        if (!isMobile)
                                          DataColumn(
                                            label: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.navigation,
                                                  size: 18,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                const Text('Longitud'),
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
                                        if (!isMobile)
                                          DataColumn(
                                            label: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.person,
                                                  size: 18,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                const Text('RUT Residente'),
                                              ],
                                            ),
                                          ),
                                        if (!isMobile)
                                          DataColumn(
                                            label: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.home,
                                                  size: 18,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                const Text('Pisos'),
                                              ],
                                            ),
                                          ),
                                        if (!isMobile)
                                          DataColumn(
                                            label: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  size: 18,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                const Text('Estado'),
                                              ],
                                            ),
                                          ),
                                        if (!isMobile)
                                          DataColumn(
                                            label: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.build,
                                                  size: 18,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                const Text('Material'),
                                              ],
                                            ),
                                          ),
                                        if (!isMobile)
                                          DataColumn(
                                            label: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.category,
                                                  size: 18,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                const Text('Tipo'),
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
                                      rows: _houses.map((house) {
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(
                                              house.idResidencia.toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: isMobile ? 12 : null,
                                              ),
                                            )),
                                            DataCell(Text(
                                              house.direccion,
                                              style: TextStyle(fontSize: isMobile ? 12 : null),
                                            )),
                                            if (!isMobile)
                                              DataCell(Text(house.lat.toStringAsFixed(6))),
                                            if (!isMobile)
                                              DataCell(Text(house.lon.toStringAsFixed(6))),
                                            DataCell(Text(
                                              house.cutCom.toString(),
                                              style: TextStyle(fontSize: isMobile ? 12 : null),
                                            )),
                                            if (!isMobile)
                                              DataCell(Text(
                                                house.rutResidente ?? '-',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontStyle: house.rutResidente == null 
                                                      ? FontStyle.italic 
                                                      : FontStyle.normal,
                                                  color: house.rutResidente == null 
                                                      ? Colors.grey 
                                                      : null,
                                                ),
                                              )),
                                            if (!isMobile)
                                              DataCell(Text(
                                                house.pisos?.toString() ?? '-',
                                                style: const TextStyle(fontSize: 12),
                                              )),
                                            if (!isMobile)
                                              DataCell(Text(
                                                house.estado ?? '-',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: house.estado == 'Activo' 
                                                      ? Colors.green 
                                                      : Colors.grey,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )),
                                            if (!isMobile)
                                              DataCell(Text(
                                                house.material ?? '-',
                                                style: const TextStyle(fontSize: 12),
                                              )),
                                            if (!isMobile)
                                              DataCell(Text(
                                                house.tipo ?? '-',
                                                style: const TextStyle(fontSize: 12),
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
                                                        _showHouseDialog(house: house),
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
                                                    onPressed: () => _deleteHouse(house),
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




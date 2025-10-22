import 'package:flutter/material.dart';
import '../models/residencia.dart';

/// Widget para manejar las instrucciones especiales de una residencia
/// Permite agregar, editar y eliminar instrucciones de diferentes tipos
class InstruccionesEspecialesWidget extends StatefulWidget {
  final Residencia residencia;
  final Function(Residencia) onResidenciaChanged;
  final bool readOnly;

  const InstruccionesEspecialesWidget({
    super.key,
    required this.residencia,
    required this.onResidenciaChanged,
    this.readOnly = false,
  });

  @override
  State<InstruccionesEspecialesWidget> createState() => _InstruccionesEspecialesWidgetState();
}

class _InstruccionesEspecialesWidgetState extends State<InstruccionesEspecialesWidget> {
  late Residencia _residenciaActual;

  @override
  void initState() {
    super.initState();
    _residenciaActual = widget.residencia;
  }

  @override
  void didUpdateWidget(InstruccionesEspecialesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.residencia != oldWidget.residencia) {
      _residenciaActual = widget.residencia;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Instrucciones Especiales',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!widget.readOnly)
                  IconButton(
                    onPressed: _mostrarDialogoAgregar,
                    icon: const Icon(Icons.add),
                    tooltip: 'Agregar instrucción',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_residenciaActual.instruccionesEspeciales == null || 
                _residenciaActual.instruccionesEspeciales!.isEmpty)
              _buildEmptyState()
            else
              _buildInstruccionesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No hay instrucciones especiales registradas',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruccionesList() {
    final instrucciones = _residenciaActual.instruccionesEspeciales!;
    
    return Column(
      children: instrucciones.entries.map((entry) {
        return _buildInstruccionItem(entry.key, entry.value as String);
      }).toList(),
    );
  }

  Widget _buildInstruccionItem(String tipo, String instruccion) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: _getIconForTipo(tipo),
        title: Text(
          _capitalizarPrimeraLetra(tipo),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(instruccion),
        trailing: widget.readOnly 
            ? null 
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _editarInstruccion(tipo, instruccion),
                    icon: const Icon(Icons.edit, size: 20),
                    tooltip: 'Editar',
                  ),
                  IconButton(
                    onPressed: () => _eliminarInstruccion(tipo),
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    tooltip: 'Eliminar',
                  ),
                ],
              ),
      ),
    );
  }

  Icon _getIconForTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'general':
        return const Icon(Icons.info, color: Colors.blue);
      case 'acceso':
        return const Icon(Icons.door_front_door, color: Colors.green);
      case 'emergencia':
        return const Icon(Icons.warning, color: Colors.red);
      case 'contacto':
        return const Icon(Icons.phone, color: Colors.orange);
      case 'observaciones':
        return const Icon(Icons.visibility, color: Colors.purple);
      case 'acceso_emergencia':
        return const Icon(Icons.emergency, color: Colors.red);
      case 'hidrantes':
        return const Icon(Icons.water_drop, color: Colors.blue);
      case 'escaleras':
        return const Icon(Icons.stairs, color: Colors.brown);
      case 'contacto_emergencia':
        return const Icon(Icons.emergency_share, color: Colors.red);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  void _mostrarDialogoAgregar() {
    _mostrarDialogoInstruccion();
  }

  void _editarInstruccion(String tipo, String instruccionActual) {
    _mostrarDialogoInstruccion(tipo: tipo, instruccion: instruccionActual);
  }

  void _mostrarDialogoInstruccion({String? tipo, String? instruccion}) {
    final controller = TextEditingController(text: instruccion ?? '');
    String tipoSeleccionado = tipo ?? Residencia.tipoGeneral;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(tipo == null ? 'Agregar Instrucción' : 'Editar Instrucción'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: tipoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo de instrucción',
                  border: OutlineInputBorder(),
                ),
                items: _getTiposInstrucciones().map((String tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Text(_capitalizarPrimeraLetra(tipo)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      tipoSeleccionado = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Instrucción',
                  border: OutlineInputBorder(),
                  hintText: 'Ingrese la instrucción especial...',
                ),
                maxLines: 3,
                maxLength: 500,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  _guardarInstruccion(tipoSeleccionado, controller.text.trim());
                  Navigator.of(context).pop();
                }
              },
              child: Text(tipo == null ? 'Agregar' : 'Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  void _guardarInstruccion(String tipo, String instruccion) {
    final nuevaResidencia = _residenciaActual.agregarInstruccion(tipo, instruccion);
    setState(() {
      _residenciaActual = nuevaResidencia;
    });
    widget.onResidenciaChanged(nuevaResidencia);
  }

  void _eliminarInstruccion(String tipo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de que desea eliminar la instrucción de "$tipo"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final nuevaResidencia = _residenciaActual.eliminarInstruccion(tipo);
              setState(() {
                _residenciaActual = nuevaResidencia;
              });
              widget.onResidenciaChanged(nuevaResidencia);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  List<String> _getTiposInstrucciones() {
    return [
      Residencia.tipoGeneral,
      Residencia.tipoAcceso,
      Residencia.tipoEmergencia,
      Residencia.tipoContacto,
      Residencia.tipoObservaciones,
      Residencia.tipoAccesoEmergencia,
      Residencia.tipoHidrantes,
      Residencia.tipoEscaleras,
      Residencia.tipoContactoEmergencia,
    ];
  }

  String _capitalizarPrimeraLetra(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }
}

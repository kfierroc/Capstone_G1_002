import 'package:flutter/material.dart';
import '../models/residencia.dart';
import '../widgets/instrucciones_especiales_widget.dart';

/// Ejemplo de uso del widget de instrucciones especiales
/// Muestra cómo implementar el manejo de instrucciones en JSON
class InstruccionesEspecialesExample extends StatefulWidget {
  const InstruccionesEspecialesExample({super.key});

  @override
  State<InstruccionesEspecialesExample> createState() => _InstruccionesEspecialesExampleState();
}

class _InstruccionesEspecialesExampleState extends State<InstruccionesEspecialesExample> {
  late Residencia _residencia;

  @override
  void initState() {
    super.initState();
    _residencia = _crearResidenciaEjemplo();
  }

  Residencia _crearResidenciaEjemplo() {
    return Residencia(
      idResidencia: 1,
      direccion: 'Av. Principal 123, Santiago',
      lat: -33.4489,
      lon: -70.6693,
      cutCom: 13101, // Cambiado de outCom a cutCom
      telefonoPrincipal: '+56 9 1234 5678',
      numeroPisos: 2,
      instruccionesEspeciales: {
        Residencia.tipoGeneral: 'Casa de dos pisos con jardín frontal',
        Residencia.tipoAcceso: 'Portón automático, código 1234',
        Residencia.tipoEmergencia: 'Llave bajo la maceta de la entrada',
        Residencia.tipoContacto: 'Llamar al 987654321 antes de llegar',
        Residencia.tipoObservaciones: 'Mascota en el patio, no asustarse',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejemplo: Instrucciones Especiales'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información básica de la residencia
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Residencia de Ejemplo',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Dirección: ${_residencia.direccion}'),
                    Text('Teléfono: ${_residencia.telefonoPrincipal ?? 'No especificado'}'),
                    Text('Pisos: ${_residencia.numeroPisos ?? 'No especificado'}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Widget de instrucciones especiales (modo editable)
            InstruccionesEspecialesWidget(
              residencia: _residencia,
              onResidenciaChanged: _actualizarResidencia,
              readOnly: false,
            ),
            
            const SizedBox(height: 16),
            
            // Widget de instrucciones especiales (modo solo lectura)
            Text(
              'Vista de Solo Lectura:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InstruccionesEspecialesWidget(
              residencia: _residencia,
              onResidenciaChanged: _actualizarResidencia,
              readOnly: true,
            ),
            
            const SizedBox(height: 24),
            
            // Información técnica
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Técnica',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('JSON actual:'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _residencia.instruccionesEspeciales?.toString() ?? 'null',
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Instrucciones formateadas:'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(_residencia.obtenerInstruccionesFormateadas()),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botones de ejemplo
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _agregarInstruccionEjemplo,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Ejemplo'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _limpiarInstrucciones,
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpiar Todo'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _actualizarResidencia(Residencia nuevaResidencia) {
    setState(() {
      _residencia = nuevaResidencia;
    });
    
    // Aquí podrías guardar en la base de datos
    // debugPrint('Residencia actualizada: ${nuevaResidencia.instruccionesEspeciales}');
  }

  void _agregarInstruccionEjemplo() {
    final ejemplos = [
      {'tipo': Residencia.tipoHidrantes, 'texto': 'Hidrante en el patio trasero'},
      {'tipo': Residencia.tipoEscaleras, 'texto': 'Escalera de emergencia en el costado derecho'},
      {'tipo': Residencia.tipoContactoEmergencia, 'texto': 'Vecino: Juan Pérez, teléfono 987654321'},
    ];
    
    final ejemplo = ejemplos[DateTime.now().millisecond % ejemplos.length];
    final nuevaResidencia = _residencia.agregarInstruccion(
      ejemplo['tipo'] as String,
      ejemplo['texto'] as String,
    );
    
    setState(() {
      _residencia = nuevaResidencia;
    });
  }

  void _limpiarInstrucciones() {
    setState(() {
      _residencia = _residencia.copyWith(instruccionesEspeciales: null);
    });
  }
}

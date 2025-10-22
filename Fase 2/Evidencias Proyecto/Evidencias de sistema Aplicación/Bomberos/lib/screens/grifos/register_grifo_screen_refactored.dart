import 'package:flutter/material.dart';
import '../../models/grifo.dart';
import '../../models/info_grifo.dart';
import '../../services/grifo/grifo_service_refactored.dart';
import '../../services/info_grifo/info_grifo_service.dart';
import '../../services/comuna/comuna_service.dart';
import '../../services/supabase_auth_service.dart';
import '../../constants/grifo_colors.dart';
import '../../utils/responsive_constants.dart';
import '../../utils/validation_system.dart';
import '../../widgets/forms/reusable_buttons.dart';

/// Pantalla de registro de grifo refactorizada
/// Aplicando principios SOLID y Clean Code
class RegisterGrifoScreenRefactored extends StatefulWidget {
  const RegisterGrifoScreenRefactored({super.key});

  @override
  State<RegisterGrifoScreenRefactored> createState() => _RegisterGrifoScreenRefactoredState();
}

class _RegisterGrifoScreenRefactoredState extends State<RegisterGrifoScreenRefactored> {
  // Controladores de formulario
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _comunaController = TextEditingController();
  final TextEditingController _notasController = TextEditingController();
  
  // Estado del formulario
  String _tipo = 'Alto flujo';
  String _estado = 'Sin verificar';
  double _lat = -33.4489;
  double _lng = -70.6693;
  bool _isLoading = false;

  // Servicios
  final GrifoServiceRefactored _grifoService = GrifoServiceRefactored();
  final InfoGrifoService _infoGrifoService = InfoGrifoService();
  final ComunaService _comunaService = ComunaService();

  @override
  void dispose() {
    _direccionController.dispose();
    _comunaController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  /// Procesa el registro del grifo
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _processGrifoRegistration();
      } catch (e) {
        _showErrorSnackBar('Error al registrar grifo: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  /// Procesa el registro completo del grifo
  Future<void> _processGrifoRegistration() async {
    // Obtener el código CUT de la comuna
    final cutComResult = await _comunaService.obtenerCutComPorNombre(_comunaController.text.trim());
    
    if (!cutComResult.isSuccess) {
      throw Exception('Error al obtener código de comuna: ${cutComResult.error}');
    }

    // Crear el grifo
    final nuevoGrifo = Grifo(
      idGrifo: 0, // Se asignará automáticamente por la base de datos
      lat: _lat,
      lon: _lng,
      cutCom: cutComResult.data!.cutCom,
    );

    // Guardar el grifo en Supabase
    final grifoResult = await _grifoService.insertGrifo(nuevoGrifo);
    
    if (grifoResult.isSuccess && grifoResult.data != null) {
      await _createGrifoInfo(grifoResult.data!);
    } else {
      throw Exception(grifoResult.error ?? 'Error al registrar el grifo');
    }
  }

  /// Crea la información inicial del grifo
  Future<void> _createGrifoInfo(Grifo grifo) async {
    // Obtener el RUT del bombero autenticado
    final authService = SupabaseAuthService();
    final bombero = await authService.getCurrentUserBombero();
    
    if (bombero == null) {
      throw Exception('No se pudo obtener la información del bombero autenticado. Por favor, inicie sesión nuevamente.');
    }
    
    // Crear la información inicial del grifo
    final infoGrifo = InfoGrifo(
      idRegGrifo: 0, // Se asignará automáticamente por la base de datos
      idGrifo: grifo.idGrifo,
      fechaRegistro: DateTime.now(),
      estado: _estado,
      rutNum: bombero.rutNum,
    );

    // Guardar la información del grifo
    final infoResult = await _infoGrifoService.insertInfoGrifo(infoGrifo);
    
    if (infoResult.isSuccess) {
      _showSuccessAndNavigate(grifo);
    } else {
      throw Exception(infoResult.error ?? 'Error al guardar información del grifo');
    }
  }

  /// Muestra mensaje de éxito y navega de vuelta
  void _showSuccessAndNavigate(Grifo grifo) {
    if (mounted) {
      Navigator.pop(context, grifo);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grifo registrado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Muestra mensaje de error
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GrifoColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: ResponsiveConstants.getResponsivePadding(
            context,
            mobile: const EdgeInsets.all(16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 24, tablet: 32)),
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: GrifoColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Registrar Grifo',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 20, tablet: 24)),
      decoration: BoxDecoration(
        color: GrifoColors.primary,
        borderRadius: BorderRadius.circular(ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 12, tablet: 16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.water_drop,
            color: Colors.white,
            size: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 40, tablet: 48),
          ),
          SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 8, tablet: 12)),
          Text(
            'Registrar Nuevo Grifo',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveConstants.getResponsiveFontSize(MediaQuery.of(context).size.width, mobile: 20, tablet: 24, desktop: 28),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 6, tablet: 8)),
          Text(
            'Complete la información del grifo de agua',
            style: TextStyle(
              color: Colors.white70,
              fontSize: ResponsiveConstants.getResponsiveFontSize(MediaQuery.of(context).size.width, mobile: 14, tablet: 16, desktop: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: EdgeInsets.all(ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 20, tablet: 24)),
      decoration: BoxDecoration(
        color: GrifoColors.surface,
        borderRadius: BorderRadius.circular(ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 12, tablet: 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del Grifo',
              style: TextStyle(
                fontSize: ResponsiveConstants.getResponsiveFontSize(MediaQuery.of(context).size.width, mobile: 18, tablet: 20, desktop: 22),
                fontWeight: FontWeight.bold,
                color: GrifoColors.primary,
              ),
            ),
            SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 16, tablet: 20)),
            TextFormField(
              controller: _direccionController,
              decoration: const InputDecoration(
                labelText: 'Dirección *',
                hintText: 'Ej: Av. Libertador Bernardo O\'Higgins 1234',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) => ValidationSystem.validateRequired(value),
            ),
            SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 16, tablet: 20)),
            TextFormField(
              controller: _comunaController,
              decoration: const InputDecoration(
                labelText: 'Comuna *',
                hintText: 'Ej: Santiago',
                prefixIcon: Icon(Icons.location_city_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) => ValidationSystem.validateRequired(value),
            ),
            SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 16, tablet: 20)),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _tipo,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Grifo',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Alto flujo', child: Text('Alto flujo')),
                      DropdownMenuItem(value: 'Medio flujo', child: Text('Medio flujo')),
                      DropdownMenuItem(value: 'Bajo flujo', child: Text('Bajo flujo')),
                    ],
                    onChanged: (value) => setState(() => _tipo = value ?? 'Alto flujo'),
                  ),
                ),
                SizedBox(width: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 12, tablet: 16)),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _estado,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Sin verificar', child: Text('Sin verificar')),
                      DropdownMenuItem(value: 'Funcionando', child: Text('Funcionando')),
                      DropdownMenuItem(value: 'Dañado', child: Text('Dañado')),
                      DropdownMenuItem(value: 'Fuera de servicio', child: Text('Fuera de servicio')),
                    ],
                    onChanged: (value) => setState(() => _estado = value ?? 'Sin verificar'),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 16, tablet: 20)),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _lat.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Latitud',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _lat = double.tryParse(value) ?? _lat),
                  ),
                ),
                SizedBox(width: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 12, tablet: 16)),
                Expanded(
                  child: TextFormField(
                    initialValue: _lng.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Longitud',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _lng = double.tryParse(value) ?? _lng),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 16, tablet: 20)),
            TextFormField(
              controller: _notasController,
              decoration: const InputDecoration(
                labelText: 'Notas adicionales',
                hintText: 'Información adicional sobre el grifo...',
                prefixIcon: Icon(Icons.note_outlined),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: ResponsiveConstants.getResponsiveValue(MediaQuery.of(context).size.width, mobile: 20, tablet: 24)),
            PrimaryButton(
              text: 'Registrar Grifo',
              onPressed: _submitForm,
              isLoading: _isLoading,
              icon: Icons.water_drop,
            ),
          ],
        ),
      ),
    );
  }
}

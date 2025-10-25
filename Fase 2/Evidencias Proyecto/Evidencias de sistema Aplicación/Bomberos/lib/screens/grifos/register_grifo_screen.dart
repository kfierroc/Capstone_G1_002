import 'package:flutter/material.dart';
import '../../models/grifo.dart';
import '../../models/info_grifo.dart';
import '../../services/services.dart';
import '../../constants/grifo_colors.dart';
import '../../constants/grifo_styles.dart';
import '../../utils/responsive.dart';

class RegisterGrifoScreen extends StatefulWidget {
  const RegisterGrifoScreen({super.key});

  @override
  State<RegisterGrifoScreen> createState() => _RegisterGrifoScreenState();
}

class _RegisterGrifoScreenState extends State<RegisterGrifoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _direccionController = TextEditingController();
  final _comunaController = TextEditingController();
  final _notasController = TextEditingController();
  
  String _tipo = 'Alto flujo';
  String _estado = 'Sin verificar';
  double _lat = -33.4489;
  double _lng = -70.6693;
  bool _isLoading = false;

  final List<String> _tipos = ['Alto flujo', 'Seco', 'Hidrante', 'Bomba'];
  final List<String> _estados = ['Operativo', 'Dañado', 'Mantenimiento', 'Sin verificar'];

  // Servicios
  final GrifoService _grifoService = GrifoService();
  final InfoGrifoService _infoGrifoService = InfoGrifoService();

  @override
  void dispose() {
    _direccionController.dispose();
    _comunaController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Registrar Grifo',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: isTablet ? 24 : 20),
                _buildForm(),
                SizedBox(height: isTablet ? 32 : 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.water_drop_rounded,
              color: Colors.white,
              size: isTablet ? 32 : 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registrar Nuevo Grifo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 20,
                      tablet: 24,
                      desktop: 28,
                    ),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete la información del grifo de agua',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Información del Grifo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _direccionController,
            label: 'Dirección',
            hint: 'Ej: Av. Libertador 1234',
            icon: Icons.location_on,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese la dirección';
              }
              return null;
            },
          ),
          SizedBox(height: isTablet ? 16 : 12),
          _buildTextField(
            controller: _comunaController,
            label: 'Comuna',
            hint: 'Ej: Santiago, Las Condes, Providencia',
            icon: Icons.location_city,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese la comuna';
              }
              if (value.trim().length < 2) {
                return 'Ingrese un nombre de comuna válido';
              }
              return null;
            },
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Tipo',
                  value: _tipo,
                  items: _tipos,
                  onChanged: (value) => setState(() => _tipo = value!),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: _buildDropdown(
                  label: 'Estado',
                  value: _estado,
                  items: _estados,
                  onChanged: (value) => setState(() => _estado = value!),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          _buildTextField(
            controller: _notasController,
            label: 'Notas',
            hint: 'Información adicional sobre el grifo...',
            icon: Icons.note,
            maxLines: 3,
          ),
          SizedBox(height: isTablet ? 16 : 12),
          _buildCoordinatesSection(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: GrifoColors.surfaceVariant,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GrifoStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: GrifoColors.surfaceVariant,
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCoordinatesSection() {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: GrifoColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Coordenadas',
            style: GrifoStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _lat.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Latitud',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    _lat = double.tryParse(value) ?? _lat;
                  },
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: TextFormField(
                  initialValue: _lng.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Longitud',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    _lng = double.tryParse(value) ?? _lng;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            'Coordenadas por defecto: Santiago Centro',
            style: GrifoStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SizedBox(
        width: double.infinity,
        height: isTablet ? 64 : 56,
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _submitForm,
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.save_rounded, size: 20),
          label: Text(
            _isLoading ? 'Registrando...' : 'Registrar Grifo',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Obtener el código CUT de la comuna
        final cutComResult = await _grifoService.obtenerCutComPorNombre(_comunaController.text.trim());
        
        if (!cutComResult.isSuccess) {
          throw Exception('Error al obtener código de comuna: ${cutComResult.error}');
        }

        // Crear el grifo
        final nuevoGrifo = Grifo(
          idGrifo: DateTime.now().millisecondsSinceEpoch,
          lat: _lat,
          lon: _lng,
          cutCom: cutComResult.data!, // Usar el código CUT obtenido
        );

        // Guardar el grifo en Supabase
        final grifoResult = await _grifoService.insertGrifo(nuevoGrifo);
        
        if (grifoResult.isSuccess && grifoResult.data != null) {
          // Obtener el RUT del bombero autenticado
          final authService = SupabaseAuthService();
          final bombero = await authService.getCurrentUserBombero();
          
          if (bombero == null) {
            debugPrint('❌ No se pudo obtener la información del bombero autenticado');
            throw Exception('No se pudo obtener la información del bombero autenticado. Por favor, inicie sesión nuevamente.');
          }
          
          debugPrint('✅ Bombero autenticado encontrado: ${bombero.rutCompleto} (${bombero.nombBombero} ${bombero.apePBombero})');
          
          // Crear la información inicial del grifo
          final infoGrifo = InfoGrifo(
            idRegGrifo: DateTime.now().millisecondsSinceEpoch,
            idGrifo: grifoResult.data!.idGrifo,
            fechaRegistro: DateTime.now(),
            estado: _estado,
            rutNum: bombero.rutNum, // Usar el RUT del bombero autenticado
          );

          debugPrint('📝 Insertando info_grifo con RUT: ${bombero.rutNum}');
          debugPrint('📝 Datos info_grifo: ${infoGrifo.toInsertData()}');

          // Guardar la información del grifo
          final infoResult = await _infoGrifoService.insertInfoGrifo(infoGrifo);
          
          if (infoResult.isSuccess) {
            if (mounted) {
              Navigator.pop(context, grifoResult.data);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Grifo registrado exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            throw Exception(infoResult.error ?? 'Error al guardar información del grifo');
          }
        } else {
          throw Exception(grifoResult.error ?? 'Error al registrar el grifo');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al registrar grifo: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

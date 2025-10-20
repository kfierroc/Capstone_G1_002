import 'package:flutter/material.dart';
import '../../models/grifo.dart';
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

  final List<String> _tipos = ['Alto flujo', 'Seco', 'Hidrante', 'Bomba'];
  final List<String> _estados = ['Operativo', 'Dañado', 'Mantenimiento', 'Sin verificar'];

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
      backgroundColor: GrifoColors.background,
      appBar: AppBar(
        backgroundColor: GrifoColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Registrar Grifo',
          style: TextStyle(color: Colors.white),
        ),
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
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: GrifoColors.primary,
        borderRadius: GrifoStyles.borderRadiusMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.water_drop,
            color: Colors.white,
            size: isTablet ? 48 : 40,
          ),
          SizedBox(height: isTablet ? 12 : 8),
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
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            'Complete la información del grifo de agua',
            style: TextStyle(
              color: Colors.white70,
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
    );
  }

  Widget _buildForm() {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: GrifoColors.surface,
        borderRadius: GrifoStyles.borderRadiusMedium,
        boxShadow: GrifoStyles.shadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información del Grifo',
            style: GrifoStyles.titleLarge,
          ),
          SizedBox(height: isTablet ? 20 : 16),
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
            hint: 'Ej: Las Condes',
            icon: Icons.location_city,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese la comuna';
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
    
    return SizedBox(
      width: double.infinity,
      height: isTablet ? 64 : 56,
      child: ElevatedButton.icon(
        onPressed: _submitForm,
        icon: const Icon(Icons.save),
        label: const Text('Registrar Grifo'),
        style: ElevatedButton.styleFrom(
          backgroundColor: GrifoColors.secondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final nuevoGrifo = Grifo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        direccion: _direccionController.text,
        comuna: _comunaController.text,
        tipo: _tipo,
        estado: _estado,
        ultimaInspeccion: DateTime.now(),
        notas: _notasController.text,
        reportadoPor: 'Capitán Rodriguez',
        fechaReporte: DateTime.now(),
        lat: _lat,
        lng: _lng,
      );

      Navigator.pop(context, nuevoGrifo);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grifo registrado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

import 'package:flutter/material.dart';
import '../../utils/responsive.dart';
import '../../services/mock_auth_service.dart';
import '../auth/login.dart';
import 'search_results.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Cargar perfil del usuario desde Supabase
  Future<void> _loadUserProfile() async {
    try {
      // TEMPORAL: Para desarrollo sin autenticación
      setState(() {
        _userProfile = {'full_name': 'Usuario Demo'};
        _isLoadingProfile = false;
      });

      // Código original comentado para desarrollo:
      /*
      final user = SupabaseConfig.client.auth.currentUser;
      if (user != null) {
        final response = await SupabaseConfig.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        setState(() {
          _userProfile = response;
          _isLoadingProfile = false;
        });
      }
      */
    } catch (e) {
      setState(() {
        _isLoadingProfile = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar perfil: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // Función de búsqueda
  void _searchAddress() {
    if (_searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un domicilio'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navegar a la pantalla de resultados
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SearchResultsScreen(searchQuery: _searchController.text.trim()),
      ),
    );
  }

  // Cerrar sesión
  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // TEMPORAL: Para desarrollo sin autenticación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cerrando sesión...'),
          backgroundColor: Colors.blue,
        ),
      );

      // Simular logout en el servicio mock
      final mockAuth = MockAuthService();
      await mockAuth.signOut();

      // Navegar de vuelta al login
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }

      // Código original comentado para desarrollo:
      // await SupabaseConfig.client.auth.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        toolbarHeight: ResponsiveHelper.getAppBarHeight(context),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: isTablet ? 28 : 24),
          tooltip: 'Volver',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Navegando hacia atrás...'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sistema de Emergencias',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 16,
                  desktop: 18,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isLoadingProfile)
              SizedBox(
                height: isTablet ? 16 : 12,
                width: isTablet ? 16 : 12,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white70,
                ),
              )
            else if (_userProfile != null)
              Text(
                'Bienvenido, ${_userProfile!['full_name'] ?? 'Bombero'}',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 11,
                    tablet: 13,
                    desktop: 15,
                  ),
                  fontWeight: FontWeight.normal,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: isTablet ? 28 : 24),
            tooltip: 'Cerrar Sesión',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // ============================================
              // ALERTA DE MODO EMERGENCIA
              // ============================================
              Container(
                width: double.infinity,
                margin: ResponsiveHelper.getResponsiveMargin(context),
                padding: EdgeInsets.all(isTablet ? 28 : 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade600, Colors.red.shade800],
                  ),
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.3),
                      blurRadius: 15,
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
                          padding: EdgeInsets.all(isTablet ? 14 : 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(
                              isTablet ? 14 : 10,
                            ),
                          ),
                          child: Icon(
                            Icons.emergency,
                            color: Colors.white,
                            size: isTablet ? 36 : 28,
                          ),
                        ),
                        SizedBox(width: isTablet ? 16 : 12),
                        Expanded(
                          child: Text(
                            ' MODO EMERGENCIA ACTIVO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 16,
                                tablet: 20,
                                desktop: 24,
                              ),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                    Text(
                      'Este sistema proporciona información importante para situaciones de emergencia. Verifica siempre la información y mantén comunicación con la central de comunicaciónes.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ============================================
              // BÚSQUEDA DE DOMICILIO
              // ============================================
              Container(
                margin: ResponsiveHelper.getResponsiveMargin(context),
                padding: EdgeInsets.all(isTablet ? 32 : 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isTablet ? 14 : 10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(
                              isTablet ? 14 : 10,
                            ),
                          ),
                          child: Icon(
                            Icons.search,
                            color: Colors.blue.shade700,
                            size: isTablet ? 36 : 28,
                          ),
                        ),
                        SizedBox(width: isTablet ? 16 : 12),
                        Text(
                          'Búsqueda de Domicilio',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 18,
                              tablet: 24,
                              desktop: 28,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 16 : 10),
                    Text(
                      'Ingresa la dirección para obtener información crítica del domicilio',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: isTablet ? 24 : 20),

                    // Campo de búsqueda
                    TextField(
                      controller: _searchController,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ej: Ricardo Rios, Colipi 231',
                        hintStyle: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 14,
                            tablet: 16,
                            desktop: 18,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.location_on,
                          size: isTablet ? 28 : 24,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  size: isTablet ? 24 : 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            isTablet ? 16 : 12,
                          ),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            isTablet ? 16 : 12,
                          ),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            isTablet ? 16 : 12,
                          ),
                          borderSide: BorderSide(
                            color: Colors.blue.shade600,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 20 : 16,
                          vertical: isTablet ? 20 : 16,
                        ),
                      ),
                      onSubmitted: (_) => _searchAddress(),
                      onChanged: (value) {
                        setState(() {}); // Para actualizar el botón clear
                      },
                    ),
                    SizedBox(height: isTablet ? 24 : 20),

                    // Botón de búsqueda
                    SizedBox(
                      width: double.infinity,
                      height: isTablet ? 64 : 56,
                      child: ElevatedButton(
                        onPressed: _searchAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              isTablet ? 16 : 12,
                            ),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Buscar',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 16,
                              tablet: 18,
                              desktop: 20,
                            ),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isTablet ? 20 : 16),

              // ============================================
              // GUÍA RÁPIDA DE USO
              // ============================================
              Container(
                width: double.infinity,
                margin: ResponsiveHelper.getResponsiveMargin(context),
                padding: EdgeInsets.all(isTablet ? 32 : 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                  border: Border.all(color: Colors.orange.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título principal
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.menu_book,
                            color: Colors.orange.shade700,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Guía Rápida de Uso',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Sección: En Emergencia Activa
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.emergency,
                                color: Colors.red.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                ' En Emergencia Activa:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildBulletPoint(
                            'Busca la dirección exacta del incidente',
                          ),
                          _buildBulletPoint(
                            'Revisa información de personas con condiciones especiales',
                          ),
                          _buildBulletPoint(
                            'Identifica número total de ocupantes esperados',
                          ),
                          _buildBulletPoint(
                            'Verifica información de mascotas para rescate',
                          ),
                          _buildBulletPoint(
                            'Contacta números de emergencia si es necesario',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Sección: Protocolos de Búsqueda
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.fact_check,
                                color: Colors.blue.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                ' Protocolos de Búsqueda:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildBulletPoint(
                            'Si no hay registro: Seguir el POE de su Cuerpo de Bomberos',
                          ),
                          _buildBulletPoint(
                            'Verificar con vecinos información de ocupantes',
                          ),
                          _buildBulletPoint(
                            'Documentar hallazgos para futuros registros',
                          ),
                          _buildBulletPoint(
                            'Mantener comunicación con la central',
                          ),
                          _buildBulletPoint(
                            'Priorizar personas con condiciones especiales',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper para bullet points
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../utils/responsive.dart';
import 'address_detail.dart';

class SearchResultsScreen extends StatelessWidget {
  final String searchQuery;

  const SearchResultsScreen({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    // Datos de ejemplo - En producción vendrían de Supabase
    final results = [
      {
        'id': '1',
        'address': 'Av. Libertador 1234, Depto 5B, Las Condes, Santiago',
        'people_count': 4,
        'pets_count': 2,
        'last_update': '2024-01-15',
      },
      {
        'id': '2',
        'address': 'Calle Principal 567, Casa 12, Maipú, Santiago',
        'people_count': 3,
        'pets_count': 1,
        'last_update': '2024-01-10',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        title: Text(
          'Resultados de Búsqueda',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
          ),
        ),
        elevation: 2,
        toolbarHeight: ResponsiveHelper.getAppBarHeight(context),
      ),
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Búsqueda y controles
              Container(
                margin: ResponsiveHelper.getResponsiveMargin(context),
                padding: EdgeInsets.all(isTablet ? 28 : 20),
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
                    Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.blue.shade700,
                          size: isTablet ? 36 : 28,
                        ),
                        SizedBox(width: isTablet ? 16 : 12),
                        Text(
                          'Búsqueda de Domicilio',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 18,
                              tablet: 22,
                              desktop: 26,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    Text(
                      'Ingresa la dirección para obtener información importante del domicilio',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 20 : 16),
                    TextField(
                      controller: TextEditingController(text: searchQuery),
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
                          size: isTablet ? 24 : 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            isTablet ? 16 : 12,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 20 : 16,
                          vertical: isTablet ? 20 : 16,
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: isTablet ? 56 : 48,
                            child: ElevatedButton(
                              onPressed: () {
                                // Buscar de nuevo
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    isTablet ? 14 : 10,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Buscar',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                        context,
                                        mobile: 14,
                                        tablet: 16,
                                        desktop: 18,
                                      ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: isTablet ? 16 : 12),
                        Expanded(
                          child: SizedBox(
                            height: isTablet ? 56 : 48,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                                side: BorderSide(color: Colors.grey.shade400),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    isTablet ? 14 : 10,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Limpiar',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                        context,
                                        mobile: 14,
                                        tablet: 16,
                                        desktop: 18,
                                      ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Contador de resultados
              Padding(
                padding: ResponsiveHelper.getResponsiveMargin(context),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 16,
                      vertical: isTablet ? 12 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      'Resultados de Búsqueda (${results.length})',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: isTablet ? 16 : 12),

              // Lista de resultados
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: ResponsiveHelper.getResponsiveMargin(context),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(isTablet ? 24 : 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Dirección
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.red.shade600,
                                    size: isTablet ? 24 : 20,
                                  ),
                                  SizedBox(width: isTablet ? 12 : 8),
                                  Expanded(
                                    child: Text(
                                      result['address'] as String,
                                      style: TextStyle(
                                        fontSize:
                                            ResponsiveHelper.getResponsiveFontSize(
                                              context,
                                              mobile: 14,
                                              tablet: 16,
                                              desktop: 18,
                                            ),
                                        fontWeight: FontWeight.bold,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isTablet ? 16 : 12),

                              // Información resumida
                              Row(
                                children: [
                                  _buildInfoChip(
                                    context,
                                    Icons.people,
                                    '${result['people_count']} persona(s)',
                                    Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildInfoChip(
                                    context,
                                    Icons.pets,
                                    '${result['pets_count']} mascota(s)',
                                    Colors.orange,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Última actualización
                              Row(
                                children: [
                                  Icon(
                                    Icons.update,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Última actualización: ${result['last_update']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const Divider(height: 1),

                        // Botón Ver Detalles
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddressDetailScreen(
                                  addressId: result['id'] as String,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(isTablet ? 20 : 16),
                            bottomRight: Radius.circular(isTablet ? 20 : 16),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 18 : 14,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Ver Detalles',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        ResponsiveHelper.getResponsiveFontSize(
                                          context,
                                          mobile: 13,
                                          tablet: 15,
                                          desktop: 17,
                                        ),
                                  ),
                                ),
                                SizedBox(width: isTablet ? 6 : 4),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.blue.shade700,
                                  size: isTablet ? 20 : 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 14 : 10,
        vertical: isTablet ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isTablet ? 20 : 16, color: color),
          SizedBox(width: isTablet ? 6 : 4),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 11,
                tablet: 13,
                desktop: 15,
              ),
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

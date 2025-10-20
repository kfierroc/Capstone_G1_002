import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

/// Widget reutilizable para la guía rápida de uso
class QuickGuideSection extends StatelessWidget {
  final String title;
  final List<GuideSection> sections;

  const QuickGuideSection({
    super.key,
    this.title = 'Guía Rápida de Uso',
    this.sections = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final defaultSections = sections.isEmpty ? _getDefaultSections() : sections;
    
    return Container(
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
          _buildHeader(context, isTablet),
          SizedBox(height: isTablet ? 24 : 20),
          ...defaultSections.map((section) => _buildGuideSection(context, section)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isTablet) {
    return Row(
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGuideSection(BuildContext context, GuideSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: section.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: section.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  section.icon,
                  color: section.iconColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...section.items.map((item) => _buildBulletPoint(item)),
          ],
        ),
      ),
    );
  }

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

  List<GuideSection> _getDefaultSections() {
    return [
      GuideSection(
        title: 'En Emergencia Activa:',
        icon: Icons.emergency,
        iconColor: Colors.red.shade700,
        backgroundColor: Colors.red.shade50,
        borderColor: Colors.red.shade200,
        items: const [
          'Busca la dirección exacta del incidente',
          'Revisa información de personas con condiciones especiales',
          'Identifica número total de ocupantes esperados',
          'Verifica información de mascotas para rescate',
          'Contacta números de emergencia si es necesario',
        ],
      ),
      GuideSection(
        title: 'Protocolos de Búsqueda:',
        icon: Icons.fact_check,
        iconColor: Colors.blue.shade700,
        backgroundColor: Colors.blue.shade50,
        borderColor: Colors.blue.shade200,
        items: const [
          'Si no hay registro: Seguir el POE de su Cuerpo de Bomberos',
          'Verificar con vecinos información de ocupantes',
          'Documentar hallazgos para futuros registros',
          'Mantener comunicación con la central',
          'Priorizar personas con condiciones especiales',
        ],
      ),
    ];
  }
}

/// Clase para definir secciones de la guía
class GuideSection {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final List<String> items;

  const GuideSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.items,
  });
}

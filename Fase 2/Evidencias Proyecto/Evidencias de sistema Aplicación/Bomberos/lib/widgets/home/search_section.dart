import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

/// Widget reutilizable para la sección de búsqueda de domicilio
class SearchSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback? onClear;
  final String hintText;
  final String title;
  final String description;

  const SearchSection({
    super.key,
    required this.controller,
    required this.onSearch,
    this.onClear,
    this.hintText = 'Ej: Ricardo Rios, Colipi 231',
    this.title = 'Búsqueda de Domicilio',
    this.description = 'Ingresa la dirección para obtener información crítica del domicilio',
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Container(
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
          _buildHeader(context, isTablet),
          SizedBox(height: isTablet ? 16 : 10),
          _buildDescription(context, isTablet),
          SizedBox(height: isTablet ? 24 : 20),
          _buildSearchField(context, isTablet),
          SizedBox(height: isTablet ? 24 : 20),
          _buildSearchButton(context, isTablet),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isTablet) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 14 : 10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(isTablet ? 14 : 10),
          ),
          child: Icon(
            Icons.search,
            color: Colors.blue.shade700,
            size: isTablet ? 36 : 28,
          ),
        ),
        SizedBox(width: isTablet ? 16 : 12),
        Text(
          title,
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
    );
  }

  Widget _buildDescription(BuildContext context, bool isTablet) {
    return Text(
      description,
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
    );
  }

  Widget _buildSearchField(BuildContext context, bool isTablet) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontSize: ResponsiveHelper.getResponsiveFontSize(
          context,
          mobile: 16,
          tablet: 18,
          desktop: 20,
        ),
      ),
      decoration: InputDecoration(
        hintText: hintText,
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
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  size: isTablet ? 24 : 20,
                ),
                onPressed: onClear,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
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
      onSubmitted: (_) => onSearch(),
      onChanged: (value) {
        // Trigger rebuild to show/hide clear button
        (context as Element).markNeedsBuild();
      },
    );
  }

  Widget _buildSearchButton(BuildContext context, bool isTablet) {
    return SizedBox(
      width: double.infinity,
      height: isTablet ? 64 : 56,
      child: ElevatedButton(
        onPressed: onSearch,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
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
    );
  }
}

import 'package:flutter/material.dart';
import '../../app.dart';
import 'address_detail_refactored.dart';

/// Pantalla de resultados de búsqueda - Refactorizada
class SearchResultsScreen extends StatefulWidget {
  final String searchQuery;

  const SearchResultsScreen({super.key, required this.searchQuery});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final SearchService _searchService = SearchService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _loadSearchResults();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Carga los resultados de búsqueda
  Future<void> _loadSearchResults() async {
    if (!_searchService.isValidSearchQuery(widget.searchQuery)) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final result = await _searchService.searchAddresses(widget.searchQuery);
      if (mounted) {
        setState(() {
          _results = result.isSuccess ? result.data ?? [] : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Error al buscar: ${e.toString()}');
      }
    }
  }

  /// Realiza una nueva búsqueda
  void _performSearch() {
    if (_searchController.text.length < 3) {
      _showErrorSnackBar('Por favor ingresa al menos 3 caracteres');
      return;
    }

    setState(() {
      _isLoading = true;
    });
    _loadSearchResults();
  }

  /// Limpia la búsqueda
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _results = [];
    });
  }

  /// Muestra mensaje de error
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: const EmergencyAppBar(title: 'Buscando...'),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
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
          'Resultados de Búsqueda',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSearchSection(),
              _buildResultsCount(),
              _buildResultsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: ResponsiveHelper.getResponsiveMargin(context),
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowLight,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchHeader(),
          const SizedBox(height: AppTheme.spacingMd),
          _buildSearchField(),
          const SizedBox(height: AppTheme.spacingMd),
          _buildSearchButtons(),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Icon(
            Icons.search,
            color: AppTheme.primaryBlue,
            size: 28,
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Text(
          'Búsqueda de Domicilio',
          style: AppTextStyles.titleLarge,
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Ej: Ricardo Rios, Colipi 231',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: Color(0xFF3B82F6),
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onSubmitted: (_) => _performSearch(),
      ),
    );
  }

  Widget _buildSearchButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _performSearch,
              icon: const Icon(Icons.search, size: 20),
              label: const Text(
                'Buscar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear, size: 20),
              label: const Text(
                'Limpiar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
                side: const BorderSide(color: Color(0xFF3B82F6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsCount() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Resultados de Búsqueda (${_results.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    if (_results.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: ResponsiveHelper.getResponsiveMargin(context),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return _buildResultCard(result);
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: ResponsiveHelper.getResponsiveMargin(context),
      padding: const EdgeInsets.all(AppTheme.spacingXl),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'No se encontraron resultados',
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Intenta con una búsqueda diferente',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: AppTheme.shadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAddressRow(result),
                const SizedBox(height: AppTheme.spacingMd),
                _buildInfoChips(result),
                const SizedBox(height: AppTheme.spacingSm),
                _buildLastUpdateRow(result),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildViewDetailsButton(result),
        ],
      ),
    );
  }

  Widget _buildAddressRow(Map<String, dynamic> result) {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          color: AppTheme.emergencyRed,
          size: 20,
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Expanded(
          child: Text(
            result['address'] as String,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChips(Map<String, dynamic> result) {
    final integrantes = result['integrantes'] as List<dynamic>? ?? [];
    final mascotas = result['mascotas'] as List<dynamic>? ?? [];
    
    return Row(
      children: [
        _buildInfoChip(
          Icons.people,
          '${integrantes.length} integrante(s)',
          AppTheme.primaryBlue,
        ),
        const SizedBox(width: AppTheme.spacingSm),
        _buildInfoChip(
          Icons.pets,
          '${mascotas.length} mascota(s)',
          AppTheme.primaryOrange,
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppTheme.spacingXs),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdateRow(Map<String, dynamic> result) {
    return Row(
      children: [
        Icon(
          Icons.update,
          size: 14,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: AppTheme.spacingXs),
        Text(
          'Última actualización: ${_formatLastUpdated(result['last_updated'])}',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildViewDetailsButton(Map<String, dynamic> result) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddressDetailScreen(
              residenceData: result,
            ),
          ),
        );
      },
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(AppTheme.radiusLg),
        bottomRight: Radius.circular(AppTheme.radiusLg),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ver Detalles',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppTheme.spacingXs),
            Icon(
              Icons.arrow_forward,
              color: AppTheme.primaryBlue,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastUpdated(dynamic lastUpdated) {
    if (lastUpdated == null || lastUpdated.toString().toLowerCase() == 'null') {
      return 'No registrada';
    }
    
    try {
      final dateTime = DateTime.parse(lastUpdated.toString());
      
      // Formato: día/mes/año
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year.toString();
      
      return '$day/$month/$year';
    } catch (e) {
      return 'No registrada';
    }
  }
}

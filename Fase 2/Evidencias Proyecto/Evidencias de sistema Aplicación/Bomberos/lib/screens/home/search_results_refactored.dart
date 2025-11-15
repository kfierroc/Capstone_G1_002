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
      body: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveHelper.getMaxContentWidth(context),
        ),
        width: double.infinity,
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResultsCount(),
              _buildResultsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCount() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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

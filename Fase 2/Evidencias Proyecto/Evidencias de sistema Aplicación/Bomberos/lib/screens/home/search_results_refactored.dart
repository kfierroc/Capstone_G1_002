import 'package:flutter/material.dart';
import '../../app.dart';
import 'address_detail.dart';

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
      final results = await _searchService.searchAddresses(widget.searchQuery);
      if (mounted) {
        setState(() {
          _results = results;
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
    if (!_searchService.isValidSearchQuery(_searchController.text)) {
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
      appBar: EmergencyAppBar(
        title: 'Resultados de Búsqueda',
        onBackPressed: () => Navigator.pop(context),
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
    return TextField(
      controller: _searchController,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Ej: Ricardo Rios, Colipi 231',
        hintStyle: AppTextStyles.bodyMedium,
        prefixIcon: const Icon(Icons.location_on),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      onSubmitted: (_) => _performSearch(),
    );
  }

  Widget _buildSearchButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _performSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Buscar'),
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: OutlinedButton(
            onPressed: _clearSearch,
            child: const Text('Limpiar'),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsCount() {
    return Padding(
      padding: ResponsiveHelper.getResponsiveMargin(context),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLg,
            vertical: AppTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
          ),
          child: Text(
            'Resultados de Búsqueda (${_results.length})',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
    return Row(
      children: [
        _buildInfoChip(
          Icons.people,
          '${result['people_count']} persona(s)',
          AppTheme.primaryBlue,
        ),
        const SizedBox(width: AppTheme.spacingSm),
        _buildInfoChip(
          Icons.pets,
          '${result['pets_count']} mascota(s)',
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
          'Última actualización: ${result['last_update']}',
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
              addressId: result['id'] as String,
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
}

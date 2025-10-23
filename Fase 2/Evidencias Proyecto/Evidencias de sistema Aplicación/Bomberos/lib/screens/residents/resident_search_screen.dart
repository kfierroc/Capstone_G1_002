import 'package:flutter/material.dart';
import '../../services/search_service.dart';
import '../../constants/grifo_colors.dart';
import '../../constants/grifo_styles.dart';
import '../../widgets/resident_info_card.dart';

/// Pantalla para buscar información de residentes
class ResidentSearchScreen extends StatefulWidget {
  const ResidentSearchScreen({super.key});

  @override
  State<ResidentSearchScreen> createState() => _ResidentSearchScreenState();
}

class _ResidentSearchScreenState extends State<ResidentSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();
  
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _selectedResident;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchResidents() async {
    final query = _searchController.text.trim();
    
    if (query.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingrese una dirección para buscar';
        _searchResults = [];
      });
      return;
    }

    if (!_searchService.isValidSearchQuery(query)) {
      setState(() {
        _errorMessage = 'La búsqueda debe tener al menos 3 caracteres';
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResults = [];
    });

    try {
      final result = await _searchService.searchAddresses(query);
      
      if (result.isSuccess && result.data != null) {
        setState(() {
          _searchResults = result.data!;
          _isLoading = false;
          _errorMessage = null;
        });
        
        if (result.data!.isEmpty) {
          setState(() {
            _errorMessage = 'No se encontraron resultados para "$query"';
          });
        }
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Error desconocido en la búsqueda';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _showResidentDetails(Map<String, dynamic> resident) {
    setState(() {
      _selectedResident = resident;
    });
  }

  void _closeResidentDetails() {
    setState(() {
      _selectedResident = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Búsqueda de Residentes'),
        backgroundColor: GrifoColors.primary,
        foregroundColor: GrifoColors.textOnPrimary,
      ),
      body: Stack(
        children: [
          // Contenido principal
          Column(
            children: [
              // Barra de búsqueda
              Container(
                padding: const EdgeInsets.all(16),
                color: GrifoColors.surface,
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar por dirección...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchResults = [];
                                    _errorMessage = null;
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: GrifoColors.surfaceVariant,
                      ),
                      onChanged: (value) => setState(() {}),
                      onSubmitted: (_) => _searchResidents(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _searchResidents,
                        icon: _isLoading 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.search),
                        label: Text(_isLoading ? 'Buscando...' : 'Buscar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GrifoColors.primary,
                          foregroundColor: GrifoColors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Resultados de búsqueda
              Expanded(
                child: _buildSearchResults(),
              ),
            ],
          ),

          // Detalles del residente (overlay)
          if (_selectedResident != null)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
                  child: ResidentInfoCard(
                    residentData: _selectedResident!,
                    onClose: _closeResidentDetails,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Buscando residentes...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: GrifoColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: GrifoStyles.bodyLarge.copyWith(
                color: GrifoColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
              },
              child: const Text('Intentar de nuevo'),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: GrifoColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron residentes',
              style: GrifoStyles.bodyLarge.copyWith(
                color: GrifoColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intente con una búsqueda diferente',
              style: GrifoStyles.bodyMedium.copyWith(
                color: GrifoColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final resident = _searchResults[index];
        final grupoFamiliar = resident['grupo_familiar'] as Map<String, dynamic>? ?? {};
        final integrantes = resident['integrantes'] as List<dynamic>? ?? [];
        final mascotas = resident['mascotas'] as List<dynamic>? ?? [];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: GrifoColors.primary,
              child: Icon(
                Icons.home,
                color: GrifoColors.textOnPrimary,
              ),
            ),
            title: Text(
              resident['address'] ?? 'Dirección no especificada',
              style: GrifoStyles.titleMedium,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RUT: ${grupoFamiliar['rut_titular'] ?? 'No especificado'}'),
                Text('Teléfono: ${grupoFamiliar['telefono_titular'] ?? 'No especificado'}'),
                Text('Integrantes: ${integrantes.length}, Mascotas: ${mascotas.length}'),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showResidentDetails(resident),
          ),
        );
      },
    );
  }
}

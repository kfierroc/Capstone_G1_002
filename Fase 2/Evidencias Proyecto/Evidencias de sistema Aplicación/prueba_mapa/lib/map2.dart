import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapaBusquedaPredictiva(),
    );
  }
}

class PlaceSuggestion {
  final String displayName;
  final double lat;
  final double lon;
  final Map<String, dynamic>? address;

  PlaceSuggestion({
    required this.displayName,
    required this.lat,
    required this.lon,
    this.address,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> j) {
    return PlaceSuggestion(
      displayName: j['display_name'] ?? '',
      lat: double.tryParse(j['lat']?.toString() ?? '') ?? 0.0,
      lon: double.tryParse(j['lon']?.toString() ?? '') ?? 0.0,
      address: j['address'] as Map<String, dynamic>?,
    );
  }
}

class MapaBusquedaPredictiva extends StatefulWidget {
  const MapaBusquedaPredictiva({super.key});
  @override
  State<MapaBusquedaPredictiva> createState() => _MapaBusquedaPredictivaState();
}

class _MapaBusquedaPredictivaState extends State<MapaBusquedaPredictiva> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  LatLng _center = const LatLng(-33.45, -70.66);
  String _coords = '';
  List<PlaceSuggestion> _suggestions = [];
  Timer? _debounce;
  bool _loading = false;
  String? _error;

  static const String _userAgent = 'prueba_mapa_app (your.email@example.com)';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _error = null;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final q = _searchController.text.trim();
      if (q.isEmpty) {
        setState(() {
          _suggestions = [];
          _loading = false;
        });
        return;
      }
      _fetchSuggestions(q);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    setState(() => _loading = true);
    final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=jsonv2&addressdetails=1&limit=6&q=${Uri.encodeComponent(query)}');
    try {
      final resp = await http.get(uri, headers: {'User-Agent': _userAgent});
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as List<dynamic>;
        final list = data.map((e) => PlaceSuggestion.fromJson(e)).toList();
        setState(() {
          _suggestions = list;
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _error = 'Error ${resp.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Error de red: $e';
      });
    }
  }

  void _selectSuggestion(PlaceSuggestion s) {
    setState(() {
      _center = LatLng(s.lat, s.lon);
      _coords = 'Lat: ${s.lat.toStringAsFixed(6)}, Lng: ${s.lon.toStringAsFixed(6)}';
      _suggestions = [];
      _searchController.text = s.displayName;
      _focusNode.unfocus();
    });
    _mapController.move(_center, 17);
  }

  Widget _buildSuggestions() {
    if (_loading) return const ListTile(leading: CircularProgressIndicator(), title: Text('Buscando...'));
    if (_error != null) return ListTile(title: Text(_error!, style: const TextStyle(color: Colors.red)));
    if (_suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
      color: Colors.white,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _suggestions.length,
        itemBuilder: (context, i) {
          final s = _suggestions[i];
          return ListTile(
            title: Text(s.displayName, maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () => _selectSuggestion(s),
            trailing: const Icon(Icons.place),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa con autocompletado')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: _focusNode,
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar dirección',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _suggestions = [];
                                  _coords = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) _fetchSuggestions(v.trim());
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final q = _searchController.text.trim();
                    if (q.isNotEmpty) _fetchSuggestions(q);
                  },
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
          _buildSuggestions(),
          if (_coords.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_coords, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                // sin 'center' ni 'zoom' como parámetros nombrados
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.tuapp',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

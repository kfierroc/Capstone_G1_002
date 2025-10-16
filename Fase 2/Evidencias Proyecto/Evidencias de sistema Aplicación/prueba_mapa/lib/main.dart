import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:geocoding/geocoding.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GoogleMapExample(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GoogleMapExample extends StatefulWidget {
  const GoogleMapExample({super.key});

  @override
  State<GoogleMapExample> createState() => _GoogleMapExampleState();
}

class _GoogleMapExampleState extends State<GoogleMapExample> {
  late GoogleMapController mapController;
  final TextEditingController _searchController = TextEditingController();

  final LatLng _center = const LatLng(-33.4489, -70.6693); // Santiago de Chile
  LatLng? _selectedLocation;
  String? _address;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onMapLongPress(LatLng position) async {
    setState(() {
      _selectedLocation = position;
    });
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      setState(() {
        _address = '${place.street}, ${place.locality}, ${place.country}';
      });
    }
  }

  void _moveCamera(LatLng position) {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps con búsqueda')),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _center, zoom: 12),
            myLocationEnabled: true,
            compassEnabled: true,
            onLongPress: _onMapLongPress,
            markers: {
              if (_selectedLocation != null)
                Marker(
                  markerId: const MarkerId('seleccionado'),
                  position: _selectedLocation!,
                ),
            },
          ),

          // 🔍 Barra de búsqueda sobre el mapa
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: GooglePlaceAutoCompleteTextField(
                textEditingController: _searchController,
                googleAPIKey: "",
                debounceTime: 800,
                countries: ["cl"], // Solo Chile
                isLatLngRequired: true,
                inputDecoration: const InputDecoration(
                  hintText: "Buscar dirección en Chile...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
                itemClick: (Prediction prediction) {
                  _searchController.text = prediction.description ?? "";
                  _searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: prediction.description?.length ?? 0),
                  );
                },
                getPlaceDetailWithLatLng: (Prediction prediction) {
                  if (prediction.lat != null && prediction.lng != null) {
                    final lat = double.parse(prediction.lat!);
                    final lng = double.parse(prediction.lng!);
                    setState(() {
                      _selectedLocation = LatLng(lat, lng);
                      _address = prediction.description;
                    });
                    _moveCamera(LatLng(lat, lng));
                  }
                },
              ),
            ),
          ),

          // 📌 Coordenadas y dirección abajo
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedLocation != null) ...[
                    Text(
                      'Coordenadas: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (_address != null)
                      Text(_address!, textAlign: TextAlign.center),
                  ] else
                    const Text(
                      'Mantén presionado el mapa para seleccionar una ubicación',
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

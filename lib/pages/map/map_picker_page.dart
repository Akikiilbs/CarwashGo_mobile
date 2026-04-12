import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'package:geolocator/geolocator.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  LatLng? selectedPoint;
  bool loadingGPS = false;
  final MapController _mapController = MapController();

  // Search
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool searching = false;

  // ===============================================================
  // SEARCH API (Nominatim OpenStreetMap)
  // ===============================================================
  Future<void> searchLocation(String query) async {
    if (query.length < 3) {
      if (mounted) setState(() => searchResults = []);
      return;
    }

    if (mounted) setState(() => searching = true);

    try {
      final uri = Uri.parse(
          "https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5");

      final response = await http.get(uri, headers: {
        "User-Agent": "FlutterApp",
      });

      if (response.statusCode == 200 && mounted) {
        setState(() {
          searchResults = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print("Search error: $e");
    } finally {
      if (mounted) setState(() => searching = false);
    }
  }

  // ===============================================================
  // GET GPS (all platforms)
  // ===============================================================
  Future<LatLng?> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Izin GPS ditolak")),
        );
      }
      return null;
    }

    Position pos =
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    return LatLng(pos.latitude, pos.longitude);
  }

  // ===============================================================
  // GO TO CURRENT LOCATION
  // ===============================================================
  Future<void> _goToMyLocation() async {
    if (mounted) setState(() => loadingGPS = true);

    LatLng? gps = await _getCurrentLocation();

    if (gps != null && mounted) {
      _mapController.move(gps, 16);
      setState(() => selectedPoint = gps);
    }

    if (mounted) setState(() => loadingGPS = false);
  }

  // ===============================================================
  // Convert to simple address
  // ===============================================================
  String _fakeAddress(LatLng point) {
    return "${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}";
  }

  // ===============================================================
  // UI
  // ===============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Lokasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Stack(
        children: [
          // =================== THIS IS THE MAP ===================
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(0.4634, 101.3908), // Pekanbaru default
              initialZoom: 13,
              onTap: (tapPos, point) {
                setState(() => selectedPoint = point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c', 'd'],
              ),
              if (selectedPoint != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selectedPoint!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_pin,
                          color: Colors.red, size: 40),
                    ),
                  ],
                ),
            ],
          ),

          // =================== SEARCH BAR ===================
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(1, 2))
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: searchLocation,
                    decoration: const InputDecoration(
                      hintText: "Cari lokasi...",
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.blueAccent),
                    ),
                  ),
                ),

                // =================== SEARCH RESULT LIST ===================
                if (searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(1, 2))
                      ],
                    ),
                    child: Column(
                      children: List.generate(searchResults.length, (i) {
                        final item = searchResults[i];
                        return ListTile(
                          dense: true,
                          title: Text(item["display_name"],
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          onTap: () {
                            final double lat =
                                double.parse(item["lat"].toString());
                            final double lon =
                                double.parse(item["lon"].toString());

                            LatLng newPoint = LatLng(lat, lon);

                            _mapController.move(newPoint, 16);
                            setState(() {
                              selectedPoint = newPoint;
                              searchResults = [];
                              _searchController.clear();
                            });
                          },
                        );
                      }),
                    ),
                  )
              ],
            ),
          ),

          // =================== GPS BUTTON ===================
          Positioned(
            right: 20,
            bottom: 140,
            child: FloatingActionButton(
              heroTag: "gps_fab",
              backgroundColor: Colors.white,
              child: loadingGPS
                  ? const CircularProgressIndicator(color: Colors.blueAccent)
                  : const Icon(Icons.my_location, color: Colors.blueAccent),
              onPressed: _goToMyLocation,
            ),
          ),

          // =================== BUTTON: USE LOCATION ===================
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: selectedPoint == null
                  ? null
                  : () {
                      Navigator.pop(context, {
                        "address": _fakeAddress(selectedPoint!),
                        "latitude": selectedPoint!.latitude,
                        "longitude": selectedPoint!.longitude,
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                "Gunakan Lokasi Ini",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

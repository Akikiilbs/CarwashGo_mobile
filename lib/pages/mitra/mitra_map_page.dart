import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MitraMapPage extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String username;
  final String address;

  const MitraMapPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.username,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text("Lokasi $username"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: point,
          initialZoom: 16,
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.carwashgo.app',
          ),

          MarkerLayer(
            markers: [
              Marker(
                width: 60,
                height: 60,
                point: point,
                child: const Icon(
                  Icons.location_on,
                  size: 40,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            const Icon(Icons.location_pin,
                color: Colors.blueAccent, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                address,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/order_model.dart';

class TrackMitraPage extends StatelessWidget {
  final Order order;

  const TrackMitraPage({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = order.status.toLowerCase();
    final customerPoint = const LatLng(0.4634, 101.3908);
    final partnerPoint = _resolvePartnerPoint(normalizedStatus);
    final statusLabel = _statusLabel(normalizedStatus);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Lacak Mitra",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: customerPoint,
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c', 'd'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: customerPoint,
                      width: 56,
                      height: 56,
                      child: const Icon(
                        Icons.home_rounded,
                        color: Colors.blueAccent,
                        size: 36,
                      ),
                    ),
                    Marker(
                      point: partnerPoint,
                      width: 56,
                      height: 56,
                      child: const Icon(
                        Icons.directions_car_rounded,
                        color: Colors.redAccent,
                        size: 36,
                      ),
                    ),
                  ],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [partnerPoint, customerPoint],
                      color: Colors.blueAccent,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Booking ID: ${order.bookingId}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Status Mitra: $statusLabel",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tujuan: ${order.location}, ${order.detailAddress}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LatLng _resolvePartnerPoint(String status) {
    switch (status) {
      case "menunggu":
      case "menunggu mitra":
        return const LatLng(0.5175, 101.4475);
      case "pengerjaan":
      case "dalam pengerjaan":
        return const LatLng(0.4708, 101.4026);
      case "dalam perjalanan":
        return const LatLng(0.4850, 101.4189);
      default:
        return const LatLng(0.4634, 101.3908);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case "menunggu":
      case "menunggu mitra":
        return "Menunggu Konfirmasi Mitra";
      case "pengerjaan":
      case "dalam pengerjaan":
        return "Mitra Sedang Proses";
      case "dalam perjalanan":
        return "Mitra Dalam Perjalanan";
      case "selesai":
      case "selesai pengerjaan":
        return "Pesanan Selesai";
      case "ditolak":
        return "Pesanan Ditolak Mitra";
      default:
        return "Status Tidak Diketahui";
    }
  }
}

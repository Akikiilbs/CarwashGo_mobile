import 'package:flutter/material.dart';
import '../models/mitra_station.dart';
import '../core/network/dio_client.dart';
import 'mitra_provider.dart';

class StationProvider extends ChangeNotifier {
  final List<MitraStation> _stations = [];
  bool _isLoading = false;
  String? _error;

  List<MitraStation> get stations => List.unmodifiable(_stations);
  bool get isLoading => _isLoading;
  String? get error => _error;

  final DioClient _dioClient = DioClient();

  // ✅ FETCH DATA DARI BACKEND DATABASE
  Future<void> fetchStations({double? lat, double? lng}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dioClient.dio.get(
        '/marketplace/partners',
        queryParameters: {
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
          'radius_km': 15, // Default sesuai permintaan user
        },
      );

      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        _stations.clear();
        _stations.addAll(data.map((item) => MitraStation.fromJson(item)).toList());
      } else {
        _error = "Gagal memuat data stasiun: ${response.statusCode}";
      }
    } catch (e) {
      _error = "Terjadi kesalahan: $e";
      print("❌ StationProvider Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // SINKRON DATA DARI MITRA KE USER (LOCAL)
  void upsertFromMitra(MitraProvider mitra) {
    final index = _stations.indexWhere((s) => s.id == "mitra");

    final station = MitraStation(
      id: "mitra",
      name: mitra.nama,
      location: mitra.alamat,
      description: mitra.deskripsi,
      jamOperasional: mitra.jamOperasional,
      hariOperasional: mitra.hariOperasional,
      harga: mitra.harga,
      rating: 5.0,
      image: "assets/images/on1.png",
    );

    if (index == -1) {
      _stations.add(station);
    } else {
      _stations[index] = station;
    }

    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import '../models/mitra_station.dart';
import 'mitra_provider.dart';

class StationProvider extends ChangeNotifier {
  final List<MitraStation> _stations = [
    MitraStation(
      id: "1",
      name: "Pak De Station",
      location: "Tampan, Pekanbaru",
      description: "Cuci cepat dan bersih",
      jamOperasional: "08.00 - 17.00",
      hariOperasional: "Senin - Sabtu",
      harga: "Rp 50.000",
      rating: 5.0,
      image: "assets/images/mobil1.png",
    ),
  ];

  List<MitraStation> get stations => List.unmodifiable(_stations);

  // ✅ SINKRON DATA DARI MITRA KE USER
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

import 'package:flutter/material.dart';

class MitraProvider with ChangeNotifier {
  // Data dasar (opsional, kalau kamu masih pakai di beberapa halaman)
  String nama = "";
  String email = "";
  String phone = "";
  String alamat = "";
  String deskripsi = "";
  String jamOperasional = "";
  String hariOperasional = "";
  String harga = "";

  // Data dari tabel partner (backend)
  String businessName = "";
  double? latitude;
  double? longitude;
  String outletPhotoUrl = "";

  void setMitra({
    required String nama,
    required String email,
    required String phone,
    required String alamat,
    required String deskripsi,
    required String jamOperasional,
    required String hariOperasional,
    required String harga,
  }) {
    this.nama = nama;
    this.email = email;
    this.phone = phone;
    this.alamat = alamat;
    this.deskripsi = deskripsi;
    this.jamOperasional = jamOperasional;
    this.hariOperasional = hariOperasional;
    this.harga = harga;
    notifyListeners();
  }

  // ✅ isi dari /auth/me (data.partner)
  void setFromApi({
    required String businessName,
    required String alamat,
    required double? latitude,
    required double? longitude,
    required String outletPhotoUrl,
  }) {
    this.businessName = businessName;
    this.alamat = alamat;
    this.latitude = latitude;
    this.longitude = longitude;
    this.outletPhotoUrl = outletPhotoUrl;
    notifyListeners();
  }

  void clear() {
    nama = "";
    email = "";
    phone = "";
    alamat = "";
    deskripsi = "";
    jamOperasional = "";
    hariOperasional = "";
    harga = "";
    businessName = "";
    latitude = null;
    longitude = null;
    outletPhotoUrl = "";
    notifyListeners();
  }
}

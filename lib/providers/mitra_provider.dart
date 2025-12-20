import 'package:flutter/material.dart';

class MitraProvider with ChangeNotifier {
  String nama = "";
  String email = "";
  String phone = "";
  String alamat = "";
  String deskripsi = "";
  String jamOperasional = "";
  String hariOperasional = "";
  String harga = ""; // ✅ WAJIB ADA

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
}

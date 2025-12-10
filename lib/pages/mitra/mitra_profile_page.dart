import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/mitra_provider.dart';
import '../../providers/station_provider.dart';
import '../navigation/bottom_nav_mitra.dart';
import '../navigation/detail_station_page.dart';

class MitraProfilePage extends StatefulWidget {
  const MitraProfilePage({super.key});

  @override
  State<MitraProfilePage> createState() => _MitraProfilePageState();
}

class _MitraProfilePageState extends State<MitraProfilePage> {
  bool _isEditMode = false;

  final _namaController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ================== TOGGLE EDIT PROFIL DASAR ==================
  void _toggleEdit(MitraProvider mitra) {
    if (_isEditMode) {
      mitra.setMitra(
        nama: _namaController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        alamat: mitra.alamat,
        deskripsi: mitra.deskripsi,
        jamOperasional: mitra.jamOperasional,
        hariOperasional: mitra.hariOperasional,
        harga: mitra.harga, // ✅ STRING, AMAN
      );

      // ✅ Sinkron langsung ke home user
      context.read<StationProvider>().upsertFromMitra(mitra);
    }

    setState(() => _isEditMode = !_isEditMode);
  }

  // ================== BUKA HALAMAN DETAIL STATION ==================
  void _openDetailStation(MitraProvider mitra) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailStationPage(
          image: "assets/images/on1.png",
          name: mitra.nama.isEmpty ? "Nama Perusahaan" : mitra.nama,
          location: mitra.alamat.isEmpty ? "Belum diisi" : mitra.alamat,
          rating: 5.0,
          description: mitra.deskripsi,
          operationalHours: mitra.jamOperasional,
          operationalDays: mitra.hariOperasional,
          price: mitra.harga, // ✅ STRING
          isEditable: true,
        ),
      ),
    );

    // ✅ ✅ ✅ FIX UTAMA ADA DI SINI
    if (result is Map) {
      final newAlamat =
          (result["alamat"] ?? mitra.alamat).toString();

      final newDesc =
          (result["description"] ?? mitra.deskripsi).toString();

      final newJam =
          (result["operationalHours"] ?? mitra.jamOperasional).toString();

      final newHari =
          (result["operationalDays"] ?? mitra.hariOperasional).toString();

      final String newHarga =
          (result["price"] ?? mitra.harga).toString(); // ✅ FIX ERROR Object → String

      mitra.setMitra(
        nama: mitra.nama,
        email: mitra.email,
        phone: mitra.phone,
        alamat: newAlamat,
        deskripsi: newDesc,
        jamOperasional: newJam,
        hariOperasional: newHari,
        harga: newHarga, // ✅ SUDAH STRING 100%
      );

      // ✅ Update ke home user
      context.read<StationProvider>().upsertFromMitra(mitra);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mitra = context.watch<MitraProvider>();

    _namaController.text = mitra.nama;
    _phoneController.text = mitra.phone;
    _emailController.text = mitra.email;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Profil Mitra",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.save : Icons.edit),
            onPressed: () => _toggleEdit(mitra),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent.withOpacity(0.3),
              child: const Icon(Icons.store, size: 60, color: Colors.blueAccent),
            ),

            const SizedBox(height: 12),

            _isEditMode
                ? SizedBox(
                    width: 220,
                    child: TextField(
                      controller: _namaController,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: "Nama Perusahaan",
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  )
                : Text(
                    mitra.nama.isEmpty ? "Nama Perusahaan" : mitra.nama,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),

            const SizedBox(height: 30),

            _fieldTile(Icons.phone, "Nomor Telepon", _phoneController),
            const SizedBox(height: 10),

            _fieldTile(Icons.email, "Email", _emailController),
            const SizedBox(height: 14),

            // ✅ DETAIL STATION (EDIT TERPISAH)
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              leading:
                  const Icon(Icons.store_mall_directory, color: Colors.blueAccent),
              title: const Text("Detail Station"),
              subtitle: const Text("Atur alamat, harga, jam & hari"),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => _openDetailStation(mitra),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login-mitra',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Keluar",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const BottomNavMitra(currentIndex: 2),
    );
  }

  // ===================== TILE FIELD =====================
  Widget _fieldTile(
    IconData icon,
    String title,
    TextEditingController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 4),
                _isEditMode
                    ? TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                        ),
                      )
                    : Text(
                        controller.text.isEmpty
                            ? "Belum diisi"
                            : controller.text,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

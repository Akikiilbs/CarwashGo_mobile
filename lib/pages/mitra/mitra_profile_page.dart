import 'package:flutter/material.dart';
import '../../pages/navigation/bottom_nav_mitra.dart';

class MitraProfilePage extends StatelessWidget {
  const MitraProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profil Mitra",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 15),

            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent.withOpacity(0.3),
              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.blueAccent,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "Mitra CarWashGo",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 30),

            _infoTile(Icons.phone, "Nomor Telepon", "+628123456789"),
            const SizedBox(height: 10),

            _infoTile(Icons.location_on, "Alamat Usaha", "Belum diatur"),
            const SizedBox(height: 10),

            _infoTile(Icons.local_car_wash, "Jenis Layanan", "Cuci Premium"),
            const SizedBox(height: 25),

            // ==========================
            //        LOGOUT FIX
            // ==========================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login-mitra',
                    (route) => false,   // clear history -> FIX MACET
                  );
                },
                child: const Text(
                  "Keluar",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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

  Widget _infoTile(IconData icon, String title, String value) {
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

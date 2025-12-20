import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/station_provider.dart';
import '../../models/mitra_station.dart';
import '../navigation/detail_station_page.dart';
import '../navigation/bottom_nav.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final stationProv = context.watch<StationProvider>();
    final List<MitraStation> stations = stationProv.stations;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              const SizedBox(height: 10),
              const Text(
                "Welcome 👋",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Have a good day",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 24),

              // ================= PROMO CARD =================
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Special Offer",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "50% OFF",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "For your first wash",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Image.asset("assets/images/on1.png"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // ================= TITLE =================
              const Text(
                "Recommended Station",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 16),

              // ================= LIST STATION =================
              Column(
                children: stations
                    .map(
                      (station) => _stationCard(
                        context: context,
                        station: station,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),

      // ✅ NAVBAR TETAP 3: HOME - NOTIF - PROFIL
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  // ===================== STATION CARD =====================
  Widget _stationCard({
    required BuildContext context,
    required MitraStation station,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ================= IMAGE =================
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              station.image,
              width: 75,
              height: 75,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          // ================= INFO =================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 15,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        station.location,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      station.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(width: 12),

                    if (station.harga.isNotEmpty)
                      Text(
                        "Rp ${station.harga}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueAccent,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ================= BUTTON =================
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailStationPage(
                    image: station.image,
                    name: station.name,
                    location: station.location,
                    rating: station.rating,
                    description: station.description,
                    operationalHours: station.jamOperasional,  // ✅ FIX
                    operationalDays: station.hariOperasional,  // ✅ FIX
                    price: station.harga,                     // ✅ STRING
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Book",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/station_provider.dart';
import '../../models/mitra_station.dart';
import '../navigation/detail_station_page.dart';
import '../navigation/bottom_nav.dart';
import '../../providers/notification_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // ✅ Trigger fetch data dari backend saat pertama kali buka Home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StationProvider>().fetchStations();
      context.read<NotificationProvider>().initFirebase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stationProv = context.watch<StationProvider>();
    final List<MitraStation> stations = stationProv.stations;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => stationProv.fetchStations(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                _buildPromoCard(),

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
                if (stationProv.isLoading && stations.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: CircularProgressIndicator(color: Colors.blueAccent),
                    ),
                  )
                else if (stationProv.error != null && stations.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Text(
                        stationProv.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else if (stations.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Text("Tidak ada stasiun ditemukan di sekitar Anda."),
                    ),
                  )
                else
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
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  Widget _buildPromoCard() {
    return Container(
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
            child: Image.asset("assets/images/on1.png",
                errorBuilder: (c, e, s) => const Icon(Icons.image, size: 50, color: Colors.white70)),
          ),
        ],
      ),
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
            child: station.image.startsWith('http')
                ? Image.network(
                    station.image,
                    width: 75,
                    height: 75,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      width: 75,
                      height: 75,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.storefront_rounded, color: Colors.grey),
                    ),
                  )
                : Image.asset(
                    station.image,
                    width: 75,
                    height: 75,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      width: 75,
                      height: 75,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.storefront_rounded, color: Colors.grey),
                    ),
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
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(
                      station.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 13),
                    ),
                    if (station.harga.isNotEmpty)
                      Text(
                        "Rp ${station.harga}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueAccent,
                        ),
                      ),
                    if (station.distanceKm != null)
                      Text(
                        "${station.distanceKm!.toStringAsFixed(1)} km",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
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
                    id: station.id,
                    image: station.image,
                    name: station.name,
                    location: station.location,
                    rating: station.rating,
                    description: station.description,
                    operationalHours: station.jamOperasional,
                    operationalDays: station.hariOperasional,
                    price: station.harga,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
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

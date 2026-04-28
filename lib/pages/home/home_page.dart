import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/station_provider.dart';
import '../../models/mitra_station.dart';
import '../navigation/detail_station_page.dart';
import '../navigation/bottom_nav.dart';
import '../../providers/notification_provider.dart';
import '../../providers/user_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserProvider>();
      context.read<StationProvider>().fetchStations(
        lat: user.latitude,
        lng: user.longitude,
      );
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
          onRefresh: () async {
            final user = context.read<UserProvider>();
            await stationProv.fetchStations(
              lat: user.latitude,
              lng: user.longitude,
            );
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= HEADER =================
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Selamat Datang 👋",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Semoga harimu menyenangkan",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    Consumer<NotificationProvider>(
                      builder: (context, notifProv, child) {
                        final hasUnread = notifProv.getCustomerUnreadCount() > 0;
                        return Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_none_rounded, color: Colors.blueAccent, size: 30),
                              onPressed: () {
                                Navigator.pushNamed(context, '/notification');
                              },
                            ),
                            if (hasUnread)
                              Positioned(
                                right: 10,
                                top: 10,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ================= PROMO CARD =================
                _buildPromoCard(),

                const SizedBox(height: 26),

                // ================= TITLE =================
                const Text(
                  "Stasiun Cuci disekitar anda",
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
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor.withOpacity(0.85), Theme.of(context).primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
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
                    Icon(
                      Icons.location_on_rounded,
                      size: 15,
                      color: Theme.of(context).primaryColor,
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            station.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    if (station.harga.isNotEmpty)
                      Text(
                        "Rp ${station.harga}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    if (station.distanceKm != null)
                      Text(
                        "${station.distanceKm!.toStringAsFixed(1)} km",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
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

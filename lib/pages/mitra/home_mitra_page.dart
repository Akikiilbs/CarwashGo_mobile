import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/review_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/order_model.dart';
import '../navigation/bottom_nav_mitra.dart';
import 'detail_service_mitra_page.dart';

class HomeMitraPage extends StatefulWidget {
  const HomeMitraPage({super.key});

  @override
  State<HomeMitraPage> createState() => _HomeMitraPageState();
}

class _HomeMitraPageState extends State<HomeMitraPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<WalletProvider>().loadAll();
      context.read<OrderProvider>().loadPartnerOrders();
      context.read<NotificationProvider>().initFirebase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ================= HEADER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "assets/images/icon.png",
                        width: 32,
                        height: 32,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "CarWashGo",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications, size: 26),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "Selamat Datang, Mitra",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 20),

              // ============= INFO CARDS =============
              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      onTap: () => Navigator.pushNamed(context, "/mitra-income"),
                      icon: Icons.attach_money,
                      color: Colors.black,
                      title: context.watch<WalletProvider>().summary == null
                          ? "Rp 0"
                          : _rupiah(context.watch<WalletProvider>().summary!.totalNetEarned),
                      subtitle: "Pendapatan hari ini",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Consumer<OrderProvider>(
                      builder: (context, orderProv, _) {
                        final completedCount = orderProv.orders.where((o) => o.status == 'completed').length;
                        return _infoCard(
                          onTap: () => Navigator.pushNamed(context, "/mitra-orders"),
                          icon: Icons.directions_car_filled,
                          color: Colors.blueAccent,
                          title: "$completedCount Mobil",
                          subtitle: "Jumlah Mobil Dicuci",
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      onTap: () =>
                          Navigator.pushNamed(context, "/mitra-orders"),
                      icon: Icons.calendar_today,
                      color: Colors.redAccent,
                      title: "Pesanan",
                      subtitle: "Jadwal Hari Ini",
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ✅ ✅ ✅ RATING TERHUBUNG KE REVIEW PROVIDER
                  Expanded(
                    child: Consumer<ReviewProvider>(
                      builder: (context, reviewProv, _) {
                        final avg = reviewProv.averageRating;
                        final total = reviewProv.totalReview;

                        return _infoCard(
                          onTap: () =>
                              Navigator.pushNamed(context, "/mitra-rating"),
                          icon: Icons.star,
                          color: Colors.orange,
                          title: total == 0
                              ? "0.0/5"
                              : "${avg.toStringAsFixed(1)}/5",
                          subtitle: total == 0
                              ? "Belum ada ulasan"
                              : "Dari $total ulasan",
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const Text(
                "Grafik Pendapatan",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.blue.shade50,
                ),
                child: const Center(
                  child: Text(
                    "📊 Grafik akan ditambahkan\n(Flutter Chart / Sync from backend)",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Booking Terbaru",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              Consumer<OrderProvider>(
                builder: (context, orderProv, _) {
                  if (orderProv.isLoading && orderProv.orders.isEmpty) {
                    return const Center(child: LinearProgressIndicator());
                  }

                  if (orderProv.orders.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text("Belum ada booking terbaru.", style: TextStyle(color: Colors.black54)),
                      ),
                    );
                  }

                  final recentOrders = orderProv.orders.take(3).toList();

                  return Column(
                    children: recentOrders.map((o) {
                      Color c;
                      switch (o.status) {
                        case 'completed': c = Colors.green; break;
                        case 'pending': c = Colors.grey; break;
                        case 'rejected':
                        case 'cancelled': c = Colors.red; break;
                        default: c = Colors.orange;
                      }

                      String statusText = o.status == 'pending' ? 'Menunggu' :
                                          o.status == 'completed' ? 'Selesai' :
                                          o.status == 'cancelled' ? 'Batal' :
                                          o.status == 'rejected' ? 'Ditolak' :
                                          o.status == 'accepted' ? 'Diterima' : 'Sesuai Proses';

                      return _bookingCard(
                        o.title,
                        o.carType,
                        statusText,
                        c,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DetailServiceMitraPage(order: o)),
                          ).then((_) => context.read<OrderProvider>().loadPartnerOrders());
                        },
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const BottomNavMitra(currentIndex: 0),
    );
  }
}

// ================= INFO CARD WIDGET =================
Widget _infoCard({
  required VoidCallback onTap,
  required IconData icon,
  required Color color,
  required String title,
  required String subtitle,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );
}

// ================= BOOKING CARD WIDGET =================
Widget _bookingCard(
  String name,
  String service,
  String status,
  Color color, {
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(service, style: const TextStyle(color: Colors.black54)),
          ],
        ),
        Text(
          status,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
      ),
    ),
  );
}

String _rupiah(int value) {
  final s = value.toString();
  final rev = s.split('').reversed.toList();
  final chunks = <String>[];
  for (var i = 0; i < rev.length; i += 3) {
    chunks.add(rev.skip(i).take(3).toList().reversed.join());
  }
  return 'Rp ${chunks.reversed.join('.')}' ;
}

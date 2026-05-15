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
                  Consumer<NotificationProvider>(
                    builder: (context, notifProv, _) {
                      final hasUnread = notifProv.getMitraUnreadCount() > 0;
                      return Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications, size: 26),
                            onPressed: () {
                              Navigator.pushNamed(context, "/mitra-notification");
                            },
                          ),
                          if (hasUnread)
                            Positioned(
                              right: 12,
                              top: 12,
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

              const SizedBox(height: 20),

              const Text(
                "Selamat Datang 👋",
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
                      subtitle: "Pendapatan Mitra Cuci anda",
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
                "Grafik Jumlah Pesanan",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              const OrderChartWidget(),

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
                        case 'completed': c = Colors.green.shade600; break;
                        case 'pending': c = Colors.orange.shade600; break;
                        case 'rejected':
                        case 'cancelled': c = Colors.red.shade600; break;
                        case 'accepted': c = Colors.blue.shade600; break;
                        default: c = Colors.grey.shade700;
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
                        profilePicture: o.profilePicture,
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: 12),
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
  String? profilePicture,
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.hardEdge,
              child: (profilePicture != null && profilePicture.isNotEmpty)
                  ? Image.network(
                      profilePicture,
                      fit: BoxFit.cover,
                      headers: const {'ngrok-skip-browser-warning': 'true'},
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.person, color: color),
                    )
                  : Icon(Icons.person, color: color),
            ),
            const SizedBox(width: 12),
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
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
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

// ================= CHART WIDGET DENGAN FILTER =================
class OrderChartWidget extends StatefulWidget {
  const OrderChartWidget({super.key});

  @override
  State<OrderChartWidget> createState() => _OrderChartWidgetState();
}

class _OrderChartWidgetState extends State<OrderChartWidget> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProv, _) {
        final orders = orderProv.orders;

        final now = DateTime.now();
        final List<Map<String, dynamic>> chartData = [];
        int maxCount = 0;

        for (int i = _selectedDays - 1; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

          String label;
          if (_selectedDays <= 7) {
            label = _getDayName(date.weekday);
          } else {
            label = "${date.day}/${date.month}";
          }

          final count = orders.where((o) {
            if (o.date.isEmpty) return false;
            return o.date.startsWith(dateString);
          }).length;

          if (count > maxCount) maxCount = count;

          chartData.add({
            'label': label,
            'count': count,
          });
        }

        if (maxCount == 0) maxCount = 1;

        return Container(
          height: 260,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$_selectedDays Hari Terakhir",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  DropdownButton<int>(
                    value: _selectedDays,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                    underline: const SizedBox(),
                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedDays = newValue;
                        });
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 7, child: Text("7 Hari")),
                      DropdownMenuItem(value: 14, child: Text("14 Hari")),
                      DropdownMenuItem(value: 30, child: Text("1 Bulan")),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true, // starts from right (most recent)
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: chartData.map((data) {
                      final double heightFactor = data['count'] / maxCount;
                      // Lebar bar disesuaikan agar tidak terlalu padat
                      double barWidth = _selectedDays == 7 ? 30 : (_selectedDays == 14 ? 20 : 12);
                      double marginWidth = _selectedDays == 7 ? 10 : 6;

                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: marginWidth),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              data['count'].toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: data['count'] > 0 ? Colors.blueAccent : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Flexible(
                              child: FractionallySizedBox(
                                heightFactor: heightFactor > 0 ? heightFactor : 0.05,
                                child: Container(
                                  width: barWidth,
                                  decoration: BoxDecoration(
                                    color: data['count'] > 0 ? Colors.blueAccent : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['label'],
                              style: const TextStyle(fontSize: 10, color: Colors.black54),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Sen';
      case 2: return 'Sel';
      case 3: return 'Rab';
      case 4: return 'Kam';
      case 5: return 'Jum';
      case 6: return 'Sab';
      case 7: return 'Min';
      default: return '';
    }
  }
}

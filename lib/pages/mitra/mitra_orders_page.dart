import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../navigation/bottom_nav_mitra.dart';
import 'detail_service_mitra_page.dart';

class MitraOrdersPage extends StatefulWidget {
  const MitraOrdersPage({super.key});

  @override
  State<MitraOrdersPage> createState() => _MitraOrdersPageState();
}

class _MitraOrdersPageState extends State<MitraOrdersPage> {
  final Map<String, String> _addrCache = {};

  bool _looksLikeCoord(String s) {
    final lower = s.toLowerCase();
    return lower.contains('latitude') || lower.contains('longitude');
  }

  Future<String?> _reverseGeocode(double lat, double lon) async {
    final dio = Dio(
      BaseOptions(headers: {'User-Agent': 'CarWashGo/1.0 (reverse-geocode)'}),
    );

    final res = await dio.get(
      'https://nominatim.openstreetmap.org/reverse',
      queryParameters: {'format': 'jsonv2', 'lat': lat, 'lon': lon},
    );

    final data = res.data;
    if (data is Map && data['display_name'] is String) {
      final s = (data['display_name'] as String).trim();
      return s.isEmpty ? null : s;
    }
    return null;
  }

  Future<String> _getPrettyAddress(Order o) async {
    // kalau sudah ada cache -> pakai
    final key = o.bookingId;
    if (_addrCache.containsKey(key)) return _addrCache[key]!;

    // kalau bukan koordinat -> tampilkan lokasi apa adanya
    if (!_looksLikeCoord(o.location)) {
      _addrCache[key] = o.location;
      return o.location;
    }

    // butuh lat/lng dari model order
    final lat = o.latitude;
    final lng = o.longitude;
    if (lat == null || lng == null) {
      _addrCache[key] = o.location;
      return o.location;
    }

    final addr = await _reverseGeocode(lat, lng);
    final finalAddr =
        (addr == null || addr.trim().isEmpty) ? o.location : addr.trim();
    _addrCache[key] = finalAddr;
    return finalAddr;
  }

  Widget _addressLine(Order o, {int maxLines = 1}) {
    return FutureBuilder<String>(
      future: _getPrettyAddress(o),
      builder: (context, snap) {
        final text = snap.data ?? o.location;
        return Text(
          text,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black54),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<OrderProvider>().loadPartnerOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FF),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          title: const Text('Pesanan Mitra'),
          bottom: const TabBar(
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blueAccent,
            tabs: [
              Tab(text: 'Pesanan Baru'),
              Tab(text: 'Aktif / Riwayat'),
            ],
          ),
        ),
        body: Consumer<OrderProvider>(
          builder: (context, prov, _) {
            final orders = prov.orders;

            if (prov.isLoading && orders.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (prov.errorMessage != null && orders.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        prov.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<OrderProvider>().loadPartnerOrders(),
                        child: const Text('Coba lagi'),
                      )
                    ],
                  ),
                ),
              );
            }

            final newOrders =
                orders.where((o) => o.status == 'pending').toList();
            final activeOrders =
                orders.where((o) => o.status != 'pending').toList();

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<OrderProvider>().loadPartnerOrders(),
              child: TabBarView(
                children: [
                  _listNewOrders(context, newOrders),
                  _listActiveOrders(context, activeOrders),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: const BottomNavMitra(currentIndex: 1),
      ),
    );
  }

  Widget _listNewOrders(BuildContext context, List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada pesanan baru.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, i) {
        final o = orders[i];
        final orderId = int.tryParse(o.bookingId) ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
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
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: (o.profilePicture != null && o.profilePicture!.isNotEmpty)
                        ? Image.network(
                            o.profilePicture!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.person, color: Theme.of(context).primaryColor),
                          )
                        : Icon(Icons.person, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      o.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    children: [
                      const _StatusBadge(status: 'pending'),
                      const SizedBox(width: 8),
                      _PaymentBadge(paymentStatus: o.paymentStatus),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Jadwal: ${o.date} ${o.time}'),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Alamat: ',
                      style: TextStyle(color: Colors.black87)),
                  Expanded(child: _addressLine(o, maxLines: 2)),
                ],
              ),
              const SizedBox(height: 4),
              Text('Plat: ${o.plateNumber.isEmpty ? '-' : o.plateNumber}'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: orderId == 0
                          ? null
                          : () async {
                              final res = await context
                                  .read<OrderProvider>()
                                  .partnerReject(orderId);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(res.message)));
                              await context
                                  .read<OrderProvider>()
                                  .loadPartnerOrders();
                            },
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      label: const Text('Tolak',
                          style: TextStyle(color: Colors.redAccent)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent),
                      onPressed: orderId == 0
                          ? null
                          : () async {
                              final res = await context
                                  .read<OrderProvider>()
                                  .partnerAccept(orderId);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(res.message)));
                              await context
                                  .read<OrderProvider>()
                                  .loadPartnerOrders();
                            },
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text('Terima',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _listActiveOrders(BuildContext context, List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada pesanan aktif/riwayat.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, i) {
        final o = orders[i];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => DetailServiceMitraPage(order: o)),
            ).then((_) {
              // refresh setelah balik
              context.read<OrderProvider>().loadPartnerOrders();
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
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
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: (o.profilePicture != null && o.profilePicture!.isNotEmpty)
                      ? Image.network(
                          o.profilePicture!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.person, color: Theme.of(context).primaryColor),
                        )
                      : Icon(Icons.person, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('${o.date} ${o.time}',
                          style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 4),
                      _addressLine(o, maxLines: 1),
                      if (o.status == 'accepted' &&
                          o.paymentStatus != 'paid') ...[
                        const SizedBox(height: 6),
                        const Text(
                          'Menunggu pembayaran customer',
                          style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  children: [
                    _StatusBadge(status: o.status),
                    const SizedBox(width: 8),
                    _PaymentBadge(paymentStatus: o.paymentStatus),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final String paymentStatus;
  const _PaymentBadge({required this.paymentStatus});

  @override
  Widget build(BuildContext context) {
    final st = paymentStatus.toLowerCase();
    final bool isPaid = st == 'paid' || st == 'settlement' || st == 'capture';
    final Color color = isPaid ? Colors.green : Colors.orange;

    final String text = isPaid ? 'Sudah Bayar' : 'Belum Bayar';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case 'pending':
        color = Colors.grey;
        text = 'Menunggu';
        break;
      case 'accepted':
        color = Colors.blue;
        text = 'Diterima';
        break;
      case 'on_the_way':
        color = Colors.orange;
        text = 'Menuju';
        break;
      case 'in_progress':
        color = Colors.orange;
        text = 'Proses';
        break;
      case 'completed':
        color = Colors.green;
        text = 'Selesai';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Ditolak';
        break;
      case 'cancelled':
        color = Colors.redAccent;
        text = 'Batal';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}

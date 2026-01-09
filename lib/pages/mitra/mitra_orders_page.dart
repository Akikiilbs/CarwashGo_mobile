import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Map + distance
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

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
  LatLng? _mitraPos;
  String? _mitraPosError;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      context.read<OrderProvider>().loadPartnerOrders();
      _loadMitraLocation();
    });
  }

  Future<void> _loadMitraLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _mitraPosError = 'Lokasi belum aktif');
        return;
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        setState(() => _mitraPosError = 'Izin lokasi ditolak');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _mitraPos = LatLng(pos.latitude, pos.longitude);
        _mitraPosError = null;
      });
    } catch (e) {
      setState(() => _mitraPosError = 'Gagal ambil lokasi mitra');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FF),
        appBar: AppBar(
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
                        onPressed: () => context.read<OrderProvider>().loadPartnerOrders(),
                        child: const Text('Coba lagi'),
                      )
                    ],
                  ),
                ),
              );
            }

            final newOrders = orders.where((o) => o.status == 'pending').toList();
            final activeOrders = orders.where((o) => o.status != 'pending').toList();

            return RefreshIndicator(
              onRefresh: () => context.read<OrderProvider>().loadPartnerOrders(),
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

  // ---------- Helpers: parse coords from location string ----------
  LatLng? _parseCustomerLatLng(String raw) {
    // expected examples:
    // "Latitude: 1.10868, Longitude: 104.07715"
    final reg = RegExp(r'Latitude\s*:\s*([-0-9\.]+)\s*,\s*Longitude\s*:\s*([-0-9\.]+)', caseSensitive: false);
    final m = reg.firstMatch(raw);
    if (m == null) return null;
    final lat = double.tryParse(m.group(1) ?? '');
    final lng = double.tryParse(m.group(2) ?? '');
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  double? _distanceKm(LatLng a, LatLng b) {
    final meters = Geolocator.distanceBetween(a.latitude, a.longitude, b.latitude, b.longitude);
    return meters / 1000.0;
  }

  Widget _miniMap({
    required LatLng mitra,
    required LatLng customer,
  }) {
    final center = LatLng((mitra.latitude + customer.latitude) / 2, (mitra.longitude + customer.longitude) / 2);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 160,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 13,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.carwashgo.app',
            ),
            PolylineLayer(
              polylines: [
                Polyline(points: [mitra, customer], strokeWidth: 4),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: mitra,
                  width: 44,
                  height: 44,
                  child: const Icon(Icons.store_mall_directory, size: 34, color: Colors.blueAccent),
                ),
                Marker(
                  point: customer,
                  width: 44,
                  height: 44,
                  child: const Icon(Icons.location_on, size: 34, color: Colors.redAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- New Orders (pending): accept/reject stays ----------
  Widget _listNewOrders(BuildContext context, List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text('Tidak ada pesanan baru.', style: TextStyle(color: Colors.black54)),
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
                color: Colors.black12.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_car_wash, color: Colors.blueAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(o.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const _StatusBadge(status: 'pending'),
                ],
              ),
              const SizedBox(height: 8),
              Text('Jadwal: ${o.date} ${o.time}'),
              const SizedBox(height: 4),
              Text('Alamat: ${o.location}', maxLines: 2, overflow: TextOverflow.ellipsis),
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
                              final res = await context.read<OrderProvider>().partnerReject(orderId);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
                              await context.read<OrderProvider>().loadPartnerOrders();
                            },
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      label: const Text('Tolak', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                      onPressed: orderId == 0
                          ? null
                          : () async {
                              final res = await context.read<OrderProvider>().partnerAccept(orderId);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
                              await context.read<OrderProvider>().loadPartnerOrders();
                            },
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text('Terima', style: TextStyle(color: Colors.white)),
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

  // ---------- Active / History: show map, distance, single-step status update ----------
  Widget _listActiveOrders(BuildContext context, List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text('Belum ada pesanan aktif/riwayat.', style: TextStyle(color: Colors.black54)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, i) {
        final o = orders[i];
        final orderId = int.tryParse(o.bookingId) ?? 0;

        final customerPos = _parseCustomerLatLng(o.location);
        final mitraPos = _mitraPos; // lokasi mitra dari GPS device
        final canMap = (customerPos != null && mitraPos != null);

        final km = (canMap) ? _distanceKm(mitraPos!, customerPos!) : null;

        final next = _nextStatus(o.status);
        final nextLabel = next?.label;
        final nextColor = next != null ? _statusColor(next.code) : Colors.grey;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header
              Row(
                children: [
                  const Icon(Icons.local_car_wash, color: Colors.blueAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${o.date} ${o.time}', style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                  _StatusBadge(status: o.status),
                ],
              ),

              const SizedBox(height: 10),

              // map + distance
              if (canMap) ...[
                _miniMap(mitra: mitraPos!, customer: customerPos!),
                const SizedBox(height: 8),
                Text('Jarak Mitra → Customer: ${km!.toStringAsFixed(2)} km',
                    style: const TextStyle(color: Colors.black87)),
              ] else ...[
                Row(
                  children: [
                    const Icon(Icons.map_outlined, size: 18, color: Colors.black45),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _mitraPosError != null
                            ? 'Peta tidak tampil: $_mitraPosError'
                            : 'Peta tidak tampil: koordinat customer belum tersedia',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadMitraLocation,
                      child: const Text('Coba lokasi'),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 10),
              Text('Alamat: ${o.location}', maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('Plat: ${o.plateNumber.isEmpty ? '-' : o.plateNumber}'),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DetailServiceMitraPage(order: o)),
                        );
                      },
                      child: const Text('Detail'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: next != null ? nextColor : Colors.grey.shade400,
                      ),
                      onPressed: (orderId == 0 || next == null)
                          ? null
                          : () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Perbarui status?'),
                                  content: const Text('Pastikan sudah sesuai proses pengerjaan!'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                                    ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ya, Perbarui')),
                                  ],
                                ),
                              );

                              if (ok != true) return;

                              final res = await context.read<OrderProvider>().partnerUpdateStatus(
                                    orderId: orderId,
                                    status: next.code,
                                  );

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
                              await context.read<OrderProvider>().loadPartnerOrders();
                            },
                      child: Text(nextLabel != null ? 'Set: $nextLabel' : 'Tidak ada update',
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  _NextStatus? _nextStatus(String current) {
    // flow: accepted -> on_the_way -> in_progress -> completed
    switch (current) {
      case 'accepted':
        return const _NextStatus(code: 'on_the_way', label: 'Menuju Lokasi');
      case 'on_the_way':
        return const _NextStatus(code: 'in_progress', label: 'Dalam Pengerjaan');
      case 'in_progress':
        return const _NextStatus(code: 'completed', label: 'Selesai');
      default:
        return null; // completed/rejected/cancelled/etc
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.grey;
      case 'accepted':
        return Colors.blue;
      case 'on_the_way':
        return Colors.orange;
      case 'in_progress':
        return Colors.deepPurple;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}

class _NextStatus {
  final String code;
  final String label;
  const _NextStatus({required this.code, required this.label});
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
        text = 'Pending';
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
        color = Colors.deepPurple;
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
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}

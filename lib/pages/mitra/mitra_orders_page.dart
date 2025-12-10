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

class _MitraOrdersPageState extends State<MitraOrdersPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  /// ✅ Update status di provider
  void _updateOrderStatus(
      BuildContext context, int providerIndex, String newStatus) {
    context.read<OrderProvider>().updateOrderStatus(
          providerIndex,
          newStatus,
        );
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();

    /// ✅ Ambil hanya pesanan milik mitra ini
    final allMitraOrders =
        orderProv.orders.where((o) => o.mitraId == "mitra").toList();

    final newOrders = allMitraOrders
        .where((o) => o.status == "menunggu mitra")
        .toList();

    final activeOrders = allMitraOrders
        .where((o) => o.status != "menunggu mitra")
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),

      appBar: AppBar(
        title: const Text(
          "Pesanan Mitra",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Notifikasi"),
            Tab(text: "Pesanan Aktif"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [

          // ======================
          // ✅ TAB 1 — PESANAN BARU
          // ======================
          newOrders.isEmpty
              ? const Center(child: Text("Tidak ada pesanan baru"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: newOrders.length,
                  itemBuilder: (context, index) {
                    final order = newOrders[index];

                    /// ✅ Index asli di provider
                    final providerIndex =
                        orderProv.orders.indexOf(order);

                    return _orderCard(
                      title: order.username,
                      subtitle: order.carType,
                      status: "Pesanan Baru",
                      statusColor: Colors.orange,
                      onTap: () =>
                          _showConfirmDialog(context, providerIndex),
                    );
                  },
                ),

          // ======================
          // ✅ TAB 2 — PESANAN AKTIF
          // ======================
          activeOrders.isEmpty
              ? const Center(child: Text("Belum ada pesanan aktif"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activeOrders.length,
                  itemBuilder: (context, index) {
                    final order = activeOrders[index];

                    final providerIndex =
                        orderProv.orders.indexOf(order);

                    return _orderCard(
                      title: order.username,
                      subtitle: order.carType,
                      status: order.status,
                      statusColor: order.status == "selesai"
                          ? Colors.green
                          : Colors.blue,
                      onTap: () => _openDetail(
                        context,
                        order,
                        providerIndex,
                      ),
                    );
                  },
                ),
        ],
      ),

      bottomNavigationBar: const BottomNavMitra(currentIndex: 1),
    );
  }

  // ===========================
  // ✅ CARD UI
  // ===========================
  Widget _orderCard({
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(color: Colors.black54)),
              ],
            ),
            Text(
              status,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================
  // ✅ DIALOG TERIMA PESANAN
  // ===========================
  void _showConfirmDialog(BuildContext context, int providerIndex) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Terima pesanan?"),
          content:
              const Text("Pesanan ini akan masuk ke Pesanan Aktif."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                /// ✅ UBAH STATUS
                _updateOrderStatus(
                    context, providerIndex, "pengerjaan");

                /// ✅ PINDAH KE TAB AKTIF
                _tabController.animateTo(1);
              },
              child: const Text("Terima"),
            ),
          ],
        );
      },
    );
  }

  // ===========================
  // ✅ BUKA DETAIL SERVICE MITRA
  // ===========================
  void _openDetail(
      BuildContext context,
      Order order,
      int providerIndex,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailServiceMitraPage(
          providerIndex: providerIndex, // ✅ KUNCI UPDATE STATUS
          username: order.username,
          phoneNumber: order.phoneNumber,
          bookingId: order.bookingId,
          date: order.date,
          time: order.time,
          carType: order.carType,
          price: order.price,
          servicePrice: order.servicePrice,
          tax: order.tax,
          discount: order.discount,
          address: order.location,
          detailAddress: order.detailAddress,
          plateNumber: order.plateNumber,
          total: order.total,
        ),
      ),
    );
  }
}

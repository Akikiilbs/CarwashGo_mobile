import 'package:flutter/material.dart';
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

  // ================================
  // DUMMY DATA
  // ================================
  List<Map<String, dynamic>> newOrders = [
    {
      "username": "Abelino Simatupang",
      "phone": "081234567890",
      "carType": "Cuci Premium",
      "status": "Baru",
      "address": "Tampan, Pekanbaru",
      "detail": "Blok C No.12",
      "plate": "BP 1234 AB",
      "date": "Sun 11",
      "time": "09.00 - 10.00",
      "price": 55000,
      "servicePrice": 25000,
      "tax": 5000,
      "discount": 0,
      "lat": 0.4634,
      "lng": 101.3908,
    },
  ];

  List<Map<String, dynamic>> activeOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void acceptOrder(int index) {
    final order = newOrders[index];
    setState(() {
      activeOrders.add({...order, "status": "Menunggu"});
      newOrders.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pesanan diterima")),
    );

    _tabController.animateTo(1);
  }

  void updateStatus(int index) {
    setState(() {
      final current = activeOrders[index]["status"];

      if (current == "Menunggu") {
        activeOrders[index]["status"] = "Dalam Proses";
      } else if (current == "Dalam Proses") {
        activeOrders[index]["status"] = "Selesai";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          // TAB 1 — NOTIFIKASI
          // ======================
          newOrders.isEmpty
              ? const Center(child: Text("Tidak ada pesanan baru"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: newOrders.length,
                  itemBuilder: (context, index) {
                    final o = newOrders[index];
                    return _orderCard(
                      title: o["username"],
                      subtitle: o["carType"],
                      status: "Pesanan Baru",
                      statusColor: Colors.orange,
                      onTap: () => _showConfirmDialog(index),
                    );
                  },
                ),

          // ======================
          // TAB 2 — PESANAN AKTIF
          // ======================
          activeOrders.isEmpty
              ? const Center(child: Text("Belum ada pesanan aktif"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activeOrders.length,
                  itemBuilder: (context, index) {
                    final o = activeOrders[index];
                    return _orderCard(
                      title: o["username"],
                      subtitle: o["carType"],
                      status: o["status"],
                      statusColor: o["status"] == "Selesai"
                          ? Colors.green
                          : Colors.blue,
                      onTap: () => _openDetail(o, index),
                    );
                  },
                ),
        ],
      ),

      bottomNavigationBar: const BottomNavMitra(currentIndex: 1),
    );
  }

  // ===========================
  // CARD UI
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
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
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
  // DIALOG KONFIRMASI
  // ===========================
  void _showConfirmDialog(int index) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Terima pesanan?"),
          content: const Text("Pesanan ini akan masuk ke Pesanan Aktif."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                acceptOrder(index);
              },
              child: const Text("Terima"),
            ),
          ],
        );
      },
    );
  }

  // ===========================
  // OPEN DETAIL SERVICE MITRA
  // ===========================
  void _openDetail(Map<String, dynamic> order, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailServiceMitraPage(
          username: order["username"],
          phoneNumber: order["phone"],
          bookingId: "ID-0001",
          date: order["date"],
          time: order["time"],
          carType: order["carType"],
          price: order["price"],
          servicePrice: order["servicePrice"],
          tax: order["tax"],
          discount: order["discount"],
          address: order["address"],
          detailAddress: order["detail"],
          plateNumber: order["plate"],
          total: order["price"] +
              order["servicePrice"] +
              order["tax"] -
              order["discount"],
        ),
      ),
    ).then((_) {
      updateStatus(index);
    });
  }
}

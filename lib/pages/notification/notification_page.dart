import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';
import '../navigation/bottom_nav.dart'; // ✅ perbaikan path

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifProv = Provider.of<NotificationProvider>(context);

    final notifications = notifProv.getCustomerNotifications();
    final current = notifications.where((n) => n.isNew).toList();
    final prev = notifications.where((n) => !n.isNew).toList();

    return Scaffold(
      backgroundColor: const Color(0xff3B8EF3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Notification",
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.blue),
            tooltip: 'Tandai semua dibaca',
            onPressed: () {
              notifProv.markAllAsRead(role: 'customer');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            tooltip: 'Hapus semua notifikasi',
            onPressed: () {
              notifProv.clearNotifications(role: 'customer');
            },
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (current.isNotEmpty)
              const Text(
                "Currently",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 10),
            ...current.map((n) => _notifCard(context, n)),
            const SizedBox(height: 20),
            if (prev.isNotEmpty)
              const Text(
                "Previously",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 10),
            ...prev.map((n) => _notifCard(context, n)),
          ],
        ),
      ),

      // ✅ hapus bottomNavigationBar
    );
  }

  Widget _notifCard(BuildContext context, AppNotification n) {
    return GestureDetector(
      onTap: () {
        // Jika ada route, otomatis arahkan
        if (n.route != null && n.route!.isNotEmpty) {
          Navigator.pushNamed(context, n.route!);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white30,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              n.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Row(children: [
              const Icon(Icons.access_time, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(n.time, style: const TextStyle(color: Colors.white)),
            ])
          ]),
          const SizedBox(height: 10),
          Text(n.message, style: const TextStyle(color: Colors.white)),
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';

class MitraNotificationPage extends StatelessWidget {
  const MitraNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifProv = Provider.of<NotificationProvider>(context);

    final notifications = notifProv.getMitraNotifications();
    final current = notifications.where((n) => n.isNew).toList();
    final prev = notifications.where((n) => !n.isNew).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Notifikasi Mitra",
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.blueAccent),
            tooltip: 'Tandai semua dibaca',
            onPressed: () {
              notifProv.markAllAsRead(role: 'mitra');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            tooltip: 'Hapus semua notifikasi',
            onPressed: () {
              notifProv.clearNotifications(role: 'mitra');
            },
          )
        ],
      ),

      body: notifications.isEmpty
          ? const Center(
              child: Text(
                "Belum ada notifikasi.",
                style: TextStyle(color: Colors.black54),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (current.isNotEmpty) ...[
                    const Text(
                      "Terbaru",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...current.map((n) => _notifCard(context, n)),
                    const SizedBox(height: 20),
                  ],
                  if (prev.isNotEmpty) ...[
                    const Text(
                      "Sebelumnya",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...prev.map((n) => _notifCard(context, n)),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _notifCard(BuildContext context, AppNotification n) {
    return GestureDetector(
      onTap: () {
        if (n.route != null && n.route!.isNotEmpty) {
          Navigator.pushNamed(context, n.route!);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    n.title,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: n.isNew ? FontWeight.bold : FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                ),
                if (n.isNew)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              n.message,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.grey, size: 14),
                const SizedBox(width: 4),
                Text(
                  n.time,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

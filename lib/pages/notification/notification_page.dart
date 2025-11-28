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

    final current = notifProv.notifications.where((n) => n.isNew).toList();
    final prev = notifProv.notifications.where((n) => !n.isNew).toList();

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
            ...current.map(_notifCard),
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
            ...prev.map(_notifCard),
          ],
        ),
      ),

      // ✅ hapus const
      bottomNavigationBar: BottomNav(currentIndex: 1),
    );
  }

  Widget _notifCard(AppNotification n) {
    return Container(
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
    );
  }
}

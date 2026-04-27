import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';
import '../navigation/bottom_nav.dart'; // ✅ perbaikan path

class NotificationPage extends StatelessWidget {
  final String role;
  
  const NotificationPage({super.key, this.role = 'customer'});

  @override
  Widget build(BuildContext context) {
    final notifProv = Provider.of<NotificationProvider>(context);

    final notifications = role == 'mitra' 
        ? notifProv.getMitraNotifications() 
        : notifProv.getCustomerNotifications();
        
    final current = notifications.where((n) => n.isNew).toList();
    final prev = notifications.where((n) => !n.isNew).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Modern sleek background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          role == 'mitra' ? "Notifikasi Mitra" : "Notifikasi",
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.blueAccent),
            tooltip: 'Tandai semua dibaca',
            onPressed: () {
              notifProv.markAllAsRead(role: role);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Hapus semua notifikasi',
            onPressed: () {
              notifProv.clearNotifications(role: role);
            },
          )
        ],
      ),

      body: notifications.isEmpty 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text("Belum ada notifikasi", style: TextStyle(color: Colors.grey[500], fontSize: 16)),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (current.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      "Baru",
                      style: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...current.map((n) => _notifCard(context, n, isNew: true)),
                  const SizedBox(height: 24),
                ],
                if (prev.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      "Sebelumnya",
                      style: TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...prev.map((n) => _notifCard(context, n, isNew: false)),
                ],
              ],
            ),
          ),
    );
  }

  IconData _getIconForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('baru')) return Icons.fiber_new_rounded;
    if (t.contains('dibatalkan') || t.contains('ditolak')) return Icons.cancel_outlined;
    if (t.contains('diterima') || t.contains('berhasil')) return Icons.check_circle_outline;
    if (t.contains('menuju')) return Icons.directions_car_filled_outlined;
    if (t.contains('dicuci') || t.contains('progress')) return Icons.local_car_wash_outlined;
    if (t.contains('selesai')) return Icons.done_all;
    if (t.contains('pembayaran') || t.contains('uang') || t.contains('bayar')) return Icons.payments_outlined;
    if (t.contains('ulasan') || t.contains('bintang')) return Icons.star_border_rounded;
    return Icons.notifications_none_rounded;
  }

  Color _getColorForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('baru') || t.contains('diterima') || t.contains('berhasil') || t.contains('selesai')) return Colors.green;
    if (t.contains('dibatalkan') || t.contains('ditolak')) return Colors.redAccent;
    if (t.contains('pembayaran')) return Colors.blueAccent;
    if (t.contains('ulasan')) return Colors.amber;
    if (t.contains('menuju') || t.contains('dicuci')) return Colors.orange;
    return Colors.blueAccent;
  }

  String _formatTime(String timeStr) {
    try {
      final dt = DateTime.parse(timeStr);
      final now = DateTime.now();
      final diff = now.difference(dt);
      
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inHours < 1) return '${diff.inMinutes} mnt lalu';
      if (diff.inDays < 1) return '${diff.inHours} jam lalu';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return timeStr;
    }
  }

  Widget _notifCard(BuildContext context, AppNotification n, {required bool isNew}) {
    final iconColor = _getColorForTitle(n.title);
    
    return GestureDetector(
      onTap: () {
        if (n.route != null && n.route!.isNotEmpty) {
          Navigator.pushNamed(context, n.route!);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isNew ? Colors.white : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isNew ? 0.05 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: isNew ? Border.all(color: Colors.blueAccent.withOpacity(0.1)) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIconForTitle(n.title), color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
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
                            fontWeight: isNew ? FontWeight.bold : FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(n.time),
                        style: TextStyle(
                          color: isNew ? Colors.blueAccent : Colors.grey[500],
                          fontSize: 12,
                          fontWeight: isNew ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    n.message,
                    style: TextStyle(
                      color: isNew ? Colors.black87 : Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

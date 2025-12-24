import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class DetailServiceMitraPage extends StatefulWidget {
  final Order order;

  const DetailServiceMitraPage({super.key, required this.order});

  @override
  State<DetailServiceMitraPage> createState() => _DetailServiceMitraPageState();
}

class _DetailServiceMitraPageState extends State<DetailServiceMitraPage> {
  late String _status;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.order.status;
  }

  String _labelStatus(String s) {
    switch (s) {
      case 'pending':
        return 'Menunggu';
      case 'accepted':
        return 'Diterima';
      case 'on_the_way':
        return 'Menuju Lokasi';
      case 'in_progress':
        return 'Dalam Pengerjaan';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return s;
    }
  }

  List<String> _allowedNextStatuses(String current) {
    // boleh bebas (biar tidak ngeblok partner saat testing)
    // (backend juga akan validasi)
    const all = ['accepted', 'on_the_way', 'in_progress', 'completed'];
    if (current == 'completed' || current == 'rejected' || current == 'cancelled') return const [];
    if (current == 'pending') return const ['accepted'];
    return all;
  }

  Future<void> _updateStatus(String newStatus) async {
    final orderId = int.tryParse(widget.order.bookingId) ?? 0;
    if (orderId == 0) return;

    setState(() => _saving = true);
    final res = await context.read<OrderProvider>().partnerUpdateStatus(orderId: orderId, status: newStatus);
    if (!mounted) return;

    setState(() => _saving = false);

    if (res.isSuccess) {
      setState(() => _status = newStatus);
      await context.read<OrderProvider>().loadPartnerOrders();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status diperbarui: ${_labelStatus(newStatus)}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final next = _allowedNextStatuses(_status);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF6F8FF),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    o.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text('Jadwal: ${o.date} ${o.time}', style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 6),
                  Text('Plat: ${o.plateNumber}', style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 6),
                  Text('Alamat: ${o.location}', maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.flag, size: 18, color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      Text(
                        'Status: ${_labelStatus(_status)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (next.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Tidak ada perubahan status (order sudah final).',
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Update Status', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: next.map((s) {
                        return ElevatedButton(
                          onPressed: _saving ? null : () => _updateStatus(s),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(_labelStatus(s)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

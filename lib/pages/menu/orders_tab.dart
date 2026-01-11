import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/order_provider.dart';
import '../../providers/review_provider.dart';
import '../../models/review_model.dart';

import '../../core/network/dio_client.dart';

import '../booking/detail_order_page.dart';
import '../review/review_popup.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  bool _popupShown = false;

  // ✅ FLAG LOKAL: MENANDAI ORDER YANG SUDAH DIREVIEW
  final Set<String> _reviewedOrderIds = {};

  // ===================== PAYMENT (MIDTRANS SNAP) =====================
  Future<void> _startPayment(BuildContext context, dynamic order) async {
    // order: Order model dari provider
    if ((order.status ?? '').toString() != 'accepted') {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Belum bisa bayar'),
          content:
              const Text('Silahkan tunggu pesanan anda diterima oleh mitra!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final int? orderId = int.tryParse((order.bookingId ?? '').toString());
    if (orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order ID tidak valid')),
      );
      return;
    }

    try {
      final dio = DioClient().dio;
      final res = await dio.post(
        '/orders/$orderId/payments',
        data: const {'payment_method': 'midtrans_snap'},
      );

      final body = res.data;
      final data = (body is Map) ? body['data'] : null;
      final redirectUrl =
          (data is Map) ? data['redirect_url']?.toString() : null;

      if (redirectUrl == null || redirectUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('redirect_url tidak ditemukan')),
        );
        return;
      }

      final ok = await launchUrl(
        Uri.parse(redirectUrl),
        mode: LaunchMode.externalApplication,
      );

      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka halaman pembayaran')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Silahkan selesaikan pembayaran di Midtrans')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat pembayaran: $e')),
      );
    }
  }

  Widget _paymentBadge(String status) {
    final s = status.toLowerCase();
    final isPaid = s == 'paid' || s == 'settlement';
    final color = isPaid ? Colors.green : Colors.orange;
    final label = isPaid ? 'Sudah Bayar' : 'Belum Bayar';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Ambil data pesanan dari API setiap membuka tab
    Future.microtask(() {
      if (!mounted) return;
      context.read<OrderProvider>().loadCustomerOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;

    // ✅ POPUP REVIEW ketika ada order selesai dan belum direview
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_popupShown) return;

      try {
        final selesaiOrder = orders.firstWhere(
          (o) =>
              o.status == "completed" &&
              !_reviewedOrderIds.contains(o.bookingId),
        );

        // ✅ TUNGGU UI SELESAI
        await Future.delayed(const Duration(milliseconds: 300));

        if (!mounted) return;
        _popupShown = true;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => ReviewPopup(mitraName: selesaiOrder.title),
        ).then((result) {
          if (result != null) {
            final int rating = result["rating"];
            final String review = result["review"];

            // ✅ SIMPAN KE REVIEW PROVIDER (NYAMBUNG KE MITRA)
            context.read<ReviewProvider>().addReview(
                  ReviewModel(
                    orderId: selesaiOrder.bookingId,
                    username: selesaiOrder.username,
                    rating: rating,
                    comment: review,
                    createdAt: DateTime.now(),
                  ),
                );

            setState(() {
              _reviewedOrderIds.add(selesaiOrder.bookingId);
              _popupShown = false;
            });
          } else {
            _popupShown = false;
          }
        });
      } catch (_) {
        _popupShown = false;
      }
    });

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.assignment_turned_in, size: 60, color: Colors.grey),
            SizedBox(height: 10),
            Text("Belum ada pesanan", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          Color statusColor;
          String statusText;

          switch (order.status) {
            case "pending":
              statusColor = Colors.grey;
              statusText = "Menunggu";
              break;
            case "accepted":
              statusColor = Colors.blueAccent;
              statusText = "Diterima";
              break;
            case "rejected":
              statusColor = Colors.redAccent;
              statusText = "Ditolak";
              break;
            case "on_the_way":
              statusColor = Colors.orange;
              statusText = "Menuju Lokasi";
              break;
            case "in_progress":
              statusColor = Colors.purple;
              statusText = "Dalam Pengerjaan";
              break;
            case "completed":
              statusColor = Colors.green;
              statusText = "Selesai";
              break;
            case "cancelled":
              statusColor = Colors.redAccent;
              statusText = "Dibatalkan";
              break;
            default:
              statusColor = Colors.grey;
              statusText = order.status;
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailOrderPage(
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
                    showDelete: false,
                    fromOrderPage: true,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.local_car_wash, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(order.date,
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          order.location,
                          style: const TextStyle(color: Colors.black54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 10),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _paymentBadge(order.paymentStatus ?? 'unpaid'),
                      const SizedBox(height: 10),
                      if (order.status == 'accepted' &&
                          ((order.paymentStatus ?? 'unpaid') != 'paid'))
                        SizedBox(
                          height: 34,
                          child: ElevatedButton(
                            onPressed: () => _startPayment(context, order),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                            ),
                            child: const Text(
                              'Bayar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

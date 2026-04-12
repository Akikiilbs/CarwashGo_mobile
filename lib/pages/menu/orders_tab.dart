import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../../providers/review_provider.dart';
import '../../models/review_model.dart';
import '../../features/payment/data/midtrans_api.dart';
import '../payment/midtrans_checkout_page.dart';

import '../booking/detail_order_page.dart';
import '../review/review_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  bool _popupShown = false;
  final Set<String> _reviewedOrderIds = {};

  final MidtransApi _midtransApi = MidtransApi();

  // ===================== PAYMENT (MIDTRANS WEBVIEW) =====================
  Future<void> _startPayment(BuildContext context, dynamic order) async {
    if ((order.status ?? '').toString() != 'accepted') {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Belum bisa bayar'),
          content: const Text('Silahkan tunggu pesanan anda diterima oleh mitra!'),
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

    // Tampilkan Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await _midtransApi.createCheckout(orderId: orderId);
      
      if (!mounted) return;
      Navigator.pop(context); // Tutup Loading

      // Navigasi ke WebView di dalam aplikasi (PREMIUM FLOW)
      final payResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MidtransCheckoutPage(
            checkoutUrl: result.redirectUrl,
          ),
        ),
      );

      // Refresh data setelah balik dari pembayaran
      if (mounted) {
        context.read<OrderProvider>().loadCustomerOrders();
        
        if (payResult == 'success' || payResult == 'pending') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pembayaran sedang diproses. Silahakan cek status berkala.')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Tutup Loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat pembayaran: ${e.toString().replaceAll('Exception: ', '')}')),
      );
    }
  }

  Widget _paymentBadge(String status) {
    final s = status.toLowerCase();
    final isPaid = s == 'paid' || s == 'settlement' || s == 'capture';
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

  Future<void> _loadReviewedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('reviewed_orders') ?? [];
    if (mounted) {
      setState(() {
        _reviewedOrderIds.addAll(list);
      });
    }
  }

  Future<void> _markAsDismissedOrReviewed(String orderId) async {
    setState(() {
      _reviewedOrderIds.add(orderId);
      _popupShown = false;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('reviewed_orders', _reviewedOrderIds.toList());
  }

  @override
  void initState() {
    super.initState();
    _loadReviewedIds();
    Future.microtask(() {
      if (!mounted) return;
      context.read<OrderProvider>().loadCustomerOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;

    // POPUP REVIEW
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_popupShown) return;
      try {
        final selesaiOrder = orders.firstWhere(
          (o) {
             if (o.status != "completed" || _reviewedOrderIds.contains(o.bookingId)) return false;
             
             // Jangan terus2an spam review jika order sudah selesai > 3 hari yang lalu
             try {
                final orderDate = DateTime.parse('${o.date} 00:00:00'); // Menggunakan date saja buat aproksimasi
                if (DateTime.now().difference(orderDate).inDays > 3) return false;
             } catch(_) {}
             return true;
          },
        );
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        _popupShown = true;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => ReviewPopup(mitraName: selesaiOrder.title),
        ).then((result) async {
          if (result != null) {
            final int rating = result["rating"];
            final String review = result["review"];
            final int? orderIdVal = int.tryParse(selesaiOrder.bookingId);
            
            if (orderIdVal != null) {
              try {
                await context.read<ReviewProvider>().submitReview(orderIdVal, rating, review);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terima kasih, ulasan Anda berhasil dikirim!')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengirim ulasan: ${e.toString().replaceAll('Exception: ', '')}')));
                }
              }
            }

            if (mounted) {
              _markAsDismissedOrReviewed(selesaiOrder.bookingId);
            }
          } else {
            if (mounted) {
              _markAsDismissedOrReviewed(selesaiOrder.bookingId);
            }
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
      child: RefreshIndicator(
        onRefresh: () => context.read<OrderProvider>().loadCustomerOrders(),
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
                statusText = "Pengerjaan";
                break;
              case "completed":
                statusColor = Colors.green;
                statusText = "Selesai";
                break;
              case "cancelled":
                statusColor = Colors.redAccent;
                statusText = "Batal";
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
                      partnerId: order.partnerId ?? 0,
                      customerLatitude: order.latitude ?? 0,
                      customerLongitude: order.longitude ?? 0,
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
                  boxShadow: [
                    BoxShadow(color: Colors.black12.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
                  ]
                ),
                child: Row(
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.local_car_wash, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(order.date, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(order.location, style: const TextStyle(color: Colors.black54, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                          decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                          child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                        const SizedBox(height: 6),
                        _paymentBadge(order.paymentStatus ?? 'unpaid'),
                        const SizedBox(height: 8),
                        if (order.status == 'accepted' && ((order.paymentStatus ?? 'unpaid') != 'paid' && (order.paymentStatus ?? '') != 'settlement'))
                          SizedBox(
                            height: 32,
                            child: ElevatedButton(
                              onPressed: () => _startPayment(context, order),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                              ),
                              child: const Text('Bayar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
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
      ),
    );
  }
}

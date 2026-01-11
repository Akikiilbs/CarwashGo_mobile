import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/order_provider.dart';
import '../../providers/review_provider.dart';
import '../../models/review_model.dart';
import '../../features/payment/models/payment_model.dart';

import '../../features/order/data/order_api.dart';

import '../booking/detail_service_page.dart';
import '../booking/detail_order_page.dart';
import '../review/review_popup.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  bool _popupShown = false;

  final OrderApi _orderApi = OrderApi();

  /// Cache Future agar tidak spam request ketika list rebuild.
  final Map<int, Future<PaymentModel?>> _latestPaymentFutures = {};

  // ✅ FLAG LOKAL: MENANDAI ORDER YANG SUDAH DIREVIEW
  final Set<String> _reviewedOrderIds = {};

  int? _toIntOrderId(String raw) {
    final v = int.tryParse(raw);
    if (v == null || v <= 0) return null;
    return v;
  }

  Future<PaymentModel?> _getLatestPayment(int orderId) {
    return _latestPaymentFutures.putIfAbsent(orderId, () async {
      final list = await _orderApi.fetchPaymentsByOrder(orderId);
      if (list.isEmpty) return null;
      list.sort((a, b) => b.id.compareTo(a.id));
      return list.first;
    });
  }

  Future<void> _payNow(BuildContext context, int orderId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Lanjut bayar?'),
        content:
            const Text('Pembayaran akan dibuka melalui Midtrans (Sandbox).'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Bayar')),
        ],
      ),
    );

    if (ok != true) return;

    final res = await _orderApi.createMidtransSnapPayment(orderId: orderId);
    if (!mounted) return;

    if (res.status != 'success') {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res.message)));
      return;
    }

    final data = res.data;
    final redirectUrl = (data is Map && data['redirect_url'] != null)
        ? data['redirect_url'].toString()
        : (data is Map &&
                data['payment'] is Map &&
                (data['payment']['redirect_url'] != null))
            ? data['payment']['redirect_url'].toString()
            : null;

    if (redirectUrl == null || redirectUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('redirect_url tidak ditemukan')));
      return;
    }

    await launchUrl(Uri.parse(redirectUrl),
        mode: LaunchMode.externalApplication);

    // refresh future supaya pas balik ke app bisa fetch ulang status (optional)
    _latestPaymentFutures.remove(orderId);
    setState(() {});
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
    final orderProv = Provider.of<OrderProvider>(context);
    final orders = orderProv.orders;

    if (orderProv.isLoading && orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orderProv.errorMessage != null && orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                orderProv.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    context.read<OrderProvider>().loadCustomerOrders(),
                child: const Text('Coba lagi'),
              )
            ],
          ),
        ),
      );
    }

    // ✅ CEK OTOMATIS: ADA PESANAN SELESAI & BELUM DIREVIEW → MUNCULKAN POPUP
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_popupShown) return;

      try {
        final selesaiOrder = orders.firstWhere(
          (o) =>
              o.status == "completed" &&
              !_reviewedOrderIds.contains(o.bookingId),
        );

        _popupShown = true;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => ReviewPopup(
            mitraName: selesaiOrder.title,
          ),
        ).then((result) {
          if (result != null) {
            final int rating = result["rating"];
            final String review = result["review"];

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
      } catch (e) {
        _popupShown = false;
      }
    });

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/empty_box.png", height: 160),
            const SizedBox(height: 20),
            const Text(
              "Belum ada pesanan",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Pesanan kamu akan muncul di sini setelah pembayaran berhasil.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black45),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<OrderProvider>().loadCustomerOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          // ✅ STATUS BADGE COLOR
          Color statusColor;
          String statusText;

          switch (order.status) {
            case "pending":
              statusColor = Colors.grey;
              statusText = "Menunggu Konfirmasi";
              break;
            case "accepted":
              statusColor = Colors.blue;
              statusText = "Diterima";
              break;
            case "on_the_way":
              statusColor = Colors.orange;
              statusText = "Menuju Lokasi";
              break;
            case "in_progress":
              statusColor = Colors.orange;
              statusText = "Dalam Pengerjaan";
              break;
            case "completed":
              statusColor = Colors.green;
              statusText = _reviewedOrderIds.contains(order.bookingId)
                  ? "Selesai • Sudah Diulas"
                  : "Selesai";
              break;
            case "rejected":
              statusColor = Colors.red;
              statusText = "Ditolak";
              break;
            case "cancelled":
              statusColor = Colors.redAccent;
              statusText = "Dibatalkan";
              break;
            default:
              statusColor = Colors.grey;
              statusText = order.status;
          }

          final int? orderIdInt = _toIntOrderId(order.bookingId);
          final Future<PaymentModel?>? payFuture =
              (orderIdInt != null) ? _getLatestPayment(orderIdInt) : null;

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
            child: FutureBuilder<PaymentModel?>(
              future: payFuture,
              builder: (context, snap) {
                final latestPay = snap.data;

                Color payColor = Colors.grey;
                String payText = 'Belum bayar';
                if (latestPay != null) {
                  switch (latestPay.status) {
                    case 'paid':
                      payColor = Colors.green;
                      payText = 'Paid';
                      break;
                    case 'pending':
                      payColor = Colors.orange;
                      payText = 'Pending';
                      break;
                    case 'failed':
                      payColor = Colors.red;
                      payText = 'Failed';
                      break;
                    case 'expired':
                      payColor = Colors.redAccent;
                      payText = 'Expired';
                      break;
                    default:
                      payText = latestPay.status;
                  }
                }

                final bool canPay = (orderIdInt != null) &&
                    (latestPay == null || latestPay.status != 'paid');

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          order.image,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
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
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: payColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: payColor.withOpacity(0.35)),
                                  ),
                                  child: Text(
                                    'Payment: $payText',
                                    style: TextStyle(
                                      color: payColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (canPay)
                                  SizedBox(
                                    height: 28,
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          _payNow(context, orderIdInt!),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text('Bayar',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
                      )
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

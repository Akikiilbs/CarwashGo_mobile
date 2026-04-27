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
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  bool _popupShown = false;
  final Set<String> _reviewedOrderIds = {};

  @override
  void initState() {
    super.initState();
    _loadReviewedIds();
    Future.microtask(() {
      if (!mounted) return;
      context.read<OrderProvider>().loadCustomerOrders();
    });
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

  // ===================== PAYMENT (MANUAL QRIS) =====================
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

    // Tampilkan Dialog Instruksi QRIS Manual
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ManualQRISBottomSheet(order: order),
    );
  }



  Widget _paymentBadge(String status) {
    final s = status.toLowerCase();
    final isPaid = s == 'paid' || s == 'settlement' || s == 'capture';
    final isPending = s == 'pending_verification';
    
    final color = isPaid ? Colors.green : (isPending ? Colors.blueAccent : Colors.orange);
    final label = isPaid ? 'Sudah Bayar' : (isPending ? 'Verifikasi' : 'Belum Bayar');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;

    // POPUP REVIEW removed and moved to detail_order_page.dart

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
                      order: order,
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
                          decoration: BoxDecoration(
                            color: statusColor, 
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(color: statusColor.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))
                            ],
                          ),
                          child: Text(statusText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                        ),
                        const SizedBox(height: 6),
                        _paymentBadge(order.paymentStatus ?? 'unpaid'),
                        const SizedBox(height: 8),
                        if (order.status == 'accepted' && 
                           ((order.paymentStatus ?? 'unpaid') != 'paid' && 
                            (order.paymentStatus ?? '') != 'settlement' &&
                            (order.paymentStatus ?? '') != 'pending_verification'))
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

// ===================== WIDGET BOTTOM SHEET MANUAL QRIS =====================

class ManualQRISBottomSheet extends StatefulWidget {
  final dynamic order;
  const ManualQRISBottomSheet({super.key, required this.order});

  @override
  State<ManualQRISBottomSheet> createState() => _ManualQRISBottomSheetState();
}

class _ManualQRISBottomSheetState extends State<ManualQRISBottomSheet> {
  File? _image;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _upload(BuildContext context) async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih foto bukti transfer terlebih dahulu')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final orderProv = context.read<OrderProvider>();
      final orderId = int.parse(widget.order.bookingId);
      final res = await orderProv.uploadPaymentProof(
        orderId: orderId,
        filePath: _image!.path,
      );

      if (!mounted) return;

      if (res.status == 'success') {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bukti berhasil diunggah! Menunggu verifikasi')),
        );
        orderProv.loadCustomerOrders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Pembayaran QRIS Manual",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.qr_code_scanner, size: 80, color: Colors.blueAccent.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        const Text(
                          "Pindai & Bayar",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Silakan pindai QRIS dan bayar sesuai nominal di bawah.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Detail Pesanan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _rowInfo("Booking ID", "#${order.bookingId}"),
                  _rowInfo("Total Pembayaran", "Rp ${order.total}"),
                  const Divider(height: 32),
                  const Text(
                    "Upload Bukti Transfer",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _isUploading ? null : _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                      ),
                      child: _image != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(_image!, width: double.infinity, height: 160, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black54,
                                    radius: 16,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                      onPressed: () => setState(() => _image = null),
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text("Ketuk untuk pilih foto", style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: (_isUploading || _image == null) ? null : () => _upload(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Kirim Bukti Pembayaran",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

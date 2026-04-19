import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/notification_model.dart';
import '../../models/order_model.dart';
import '../../providers/notification_provider.dart';
import '../../providers/order_provider.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const PaymentPage({
    super.key,
    required this.bookingData,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isPaying = false;

  void _savePaidOrder() {
    final bookingData = widget.bookingData;

    Provider.of<OrderProvider>(context, listen: false).addOrder(
      Order(
        mitraId: bookingData['mitraId']?.toString(), // Ambil dari bookingData jika ada
        title: 'Cuci Mobil',
        date: bookingData['date']?.toString() ?? '-',
        time: bookingData['time']?.toString() ?? '-',
        status: 'menunggu mitra',
        image: 'assets/images/mobil1.png',
        location: bookingData['address']?.toString() ?? '-',
        detailAddress: bookingData['detailAddress']?.toString() ?? '-',
        plateNumber: bookingData['plateNumber']?.toString() ?? '-',
        username: bookingData['username']?.toString() ?? 'User',
        phoneNumber: bookingData['phoneNumber']?.toString() ?? '-',
        bookingId: bookingData['bookingId']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        carType: bookingData['carType']?.toString() ?? '-',
        price: (bookingData['price'] as num?)?.toInt() ?? 0,
        servicePrice: (bookingData['servicePrice'] as num?)?.toInt() ?? 0,
        tax: (bookingData['tax'] as num?)?.toInt() ?? 0,
        discount: (bookingData['discount'] as num?)?.toInt() ?? 0,
        total: (bookingData['total'] as num?)?.toInt() ?? 0,
      ),
    );

    Provider.of<NotificationProvider>(context, listen: false).addNotification(
      AppNotification(
        title: 'Pembayaran Menunggu Konfirmasi',
        message: 'Pesanan Anda berhasil dibuat dan menunggu verifikasi pembayaran oleh.',
        time: 'Baru saja',
        isNew: true,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pembayaran disimpan dan menunggu verifikasi')),
    );

    // Kembali ke home
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.bookingData["username"];
    final phoneNumber = widget.bookingData["phoneNumber"];
    final address = widget.bookingData["address"];
    final detailAddress = widget.bookingData["detailAddress"];
    final plateNumber = widget.bookingData["plateNumber"];
    final carType = widget.bookingData["carType"];
    final price = widget.bookingData["price"] as int;
    final servicePrice = widget.bookingData["servicePrice"] as int;
    final tax = widget.bookingData["tax"] as int;
    final discount = widget.bookingData["discount"] as int;
    final total = widget.bookingData["total"] as int;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Pembayaran Manual QRIS",
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Instruksi Pembayaran",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.qr_code_scanner, size: 80, color: Colors.blueAccent.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    "Gambar QRIS Tersedia Segera",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Pindai kode QRIS menggunakan M-Banking atau E-Wallet kesayangan Anda (OVO, GoPay, Dana, dll). Pastikan nama Merchant sesuai.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Ringkasan Pesanan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _rowText("Nama", username),
                  _rowText("No. HP", phoneNumber),
                  _rowText("Jenis Mobil", carType),
                  _rowText("Plat Nomor", plateNumber),
                  const SizedBox(height: 8),
                  const Text(
                    "Alamat Service",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("$address\n$detailAddress"),
                  const SizedBox(height: 12),
                  const Divider(),
                  _rowText("Harga Mobil", "Rp $price"),
                  _rowText("Harga Layanan", "Rp $servicePrice"),
                  _rowText("Pajak", "Rp $tax"),
                  _rowText("Diskon", "$discount%"),
                  const Divider(),
                  _rowText("Total Pembayaran", "Rp $total", bold: true),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isPaying ? null : () {
                  setState(() => _isPaying = true);
                  // Simulasikan delay network sedikit
                  Future.delayed(const Duration(seconds: 1), () {
                    _savePaidOrder();
                  });
                },
                child: _isPaying
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Saya Sudah Transfer",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowText(String left, Object? right, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left),
          Text(
            "$right",
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

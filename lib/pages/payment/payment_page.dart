import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../../providers/order_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _handlePayment() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih foto bukti transfer terlebih dahulu')),
      );
      return;
    }

    setState(() => _isPaying = true);

    try {
      final orderProv = context.read<OrderProvider>();
      final bookingIdStr = widget.bookingData['bookingId']?.toString();
      final orderId = int.tryParse(bookingIdStr ?? '');

      if (orderId == null) {
        throw Exception('ID Pesanan tidak valid');
      }

      // 1. Upload ke Backend
      final res = await orderProv.uploadPaymentProof(
        orderId: orderId,
        filePath: _image!.path,
      );

      if (!mounted) return;

      if (res.status == 'success') {
        // 2. Notifikasi Lokal & Navigator
        Provider.of<NotificationProvider>(context, listen: false).addNotification(
          AppNotification(
            title: 'Pembayaran Menunggu Konfirmasi',
            message: 'Bukti pembayaran berhasil diunggah dan sedang diverifikasi oleh admin.',
            time: 'Baru saja',
            isNew: true,
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bukti berhasil diunggah! Menunggu verifikasi admin.')),
        );

        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim bukti: $e')),
      );
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
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
            const SizedBox(height: 24),
            const Text(
              "Upload Bukti Transfer",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _isPaying ? null : _pickImage,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!, width: 1.5),
                ),
                child: _image != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(_image!, width: double.infinity, height: 180, fit: BoxFit.cover),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () => setState(() => _image = null),
                              ),
                            ),
                          )
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_rounded, size: 40, color: Colors.blueAccent.withOpacity(0.5)),
                          const SizedBox(height: 10),
                          const Text("Pilih Foto Bukti Transfer", style: TextStyle(color: Colors.black54)),
                        ],
                      ),
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
                onPressed: (_isPaying || _image == null) ? null : _handlePayment,
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
                        "Kirim Bukti Pembayaran",
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

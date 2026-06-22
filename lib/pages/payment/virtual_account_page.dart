import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';

class VirtualAccountPage extends StatefulWidget {
  final String bankName;
  final String vaNumber;
  final int totalAmount;

  const VirtualAccountPage({
    super.key,
    required this.bankName,
    required this.vaNumber,
    required this.totalAmount,
  });

  @override
  State<VirtualAccountPage> createState() => _VirtualAccountPageState();
}

class _VirtualAccountPageState extends State<VirtualAccountPage> {
  bool _isPaymentVerified = false;
  bool _isButtonEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _simulatePaymentNotification();
  }

  // 🔔 Simulasi notifikasi pembayaran berhasil dari sistem
  Future<void> _simulatePaymentNotification() async {
    setState(() => _isLoading = true);

    // ⏱ simulasi delay 5 detik untuk menunggu verifikasi sistem
    await Future.delayed(const Duration(seconds: 5));

    setState(() {
      _isPaymentVerified = true;
      _isLoading = false;
    });

    _showAutoSuccessNotification();
  }

  // ✅ Tampilkan popup notifikasi otomatis
  void _showAutoSuccessNotification() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text(
                "Pembayaran Berhasil!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Terima kasih, pembayaran Anda untuk ${widget.bankName} sebesar Rp ${widget.totalAmount} telah diterima.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Tutup pop-up notif
                    setState(() => _isButtonEnabled = true);

                    // ✅ Tambah data ke provider setelah sukses
                    Provider.of<OrderProvider>(context, listen: false).addOrder(
                      Order(
                        title: "Cuci Mobil Reguler",
                        location: "Batu Aji, Batam",
                        date: "11/11/2025",
                        time: "10:45 AM",
                        image: "assets/images/mobil1.png",
                        status: "menunggu",
                        detailAddress: "-",
                        plateNumber: "-",
                        username: "Guest",
                        phoneNumber: "-",
                        bookingId: "VA-${widget.totalAmount}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
                        carType: "Mobil",
                        price: widget.totalAmount,
                        servicePrice: 0,
                        tax: 0,
                        discount: 0,
                        total: widget.totalAmount,
                      ),
                    );

                    Provider.of<NotificationProvider>(context, listen: false)
                        .addNotification(
                      AppNotification(
                        title: "Pembayaran Berhasil",
                        message:
                            "Pesanan kamu telah diterima dan sedang menunggu konfirmasi mitra.",
                        time: "10:45 AM",
                        isNew: true,
                      ),
                    );
                  },
                  child: const Text(
                    "Oke",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Pembayaran Virtual Account",
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏦 Info VA
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(1, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.bankName} Virtual Account",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.vaNumber,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.blueAccent),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Nomor VA disalin ke clipboard"),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 💰 Total Pembayaran
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Pembayaran",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Rp ${widget.totalAmount}",
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Instruksi Pembayaran",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _buildInstruction("1. Buka aplikasi atau mesin ATM bank kamu."),
            _buildInstruction("2. Pilih menu Transfer → Virtual Account Billing."),
            _buildInstruction("3. Masukkan nomor VA sesuai yang tertera di atas."),
            _buildInstruction("4. Konfirmasi detail pembayaran dan selesaikan transaksi."),
            _buildInstruction("5. Tunggu notifikasi sistem untuk verifikasi pembayaran."),

            const Spacer(),

            // 🔘 Tombol “Saya Sudah Bayar”
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isButtonEnabled
                      ? Colors.blueAccent
                      : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isButtonEnabled
                    ? () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                        );
                      }
                    : null,
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Menunggu Notifikasi...",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        "Saya Sudah Bayar",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }
}

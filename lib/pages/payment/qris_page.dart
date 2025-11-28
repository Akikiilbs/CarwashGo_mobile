import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';

class QRISPage extends StatefulWidget {
  final String username;
  final String phoneNumber;
  final String address;       // alamat dari map picker
  final String detailAddress; // detail alamat
  final String plateNumber;   // plat mobil
  final String carType;

  final int price;
  final int servicePrice;
  final int tax;
  final int discount;
  final int total;

  const QRISPage({
    super.key,
    required this.username,
    required this.phoneNumber,
    required this.address,
    required this.detailAddress,
    required this.plateNumber,
    required this.carType,
    required this.price,
    required this.servicePrice,
    required this.tax,
    required this.discount,
    required this.total,
  });

  @override
  State<QRISPage> createState() => _QRISPageState();
}

class _QRISPageState extends State<QRISPage> {
  bool _isPaymentSuccess = false;
  bool _popupShown = false;

  @override
  void initState() {
    super.initState();

    // Simulasi pembayaran
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _isPaymentSuccess = true);
      _showSuccessPopup();
    });
  }

  void _showSuccessPopup() {
    if (_popupShown || !mounted) return;
    _popupShown = true;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.green, size: 90),
                const SizedBox(height: 16),
                const Text(
                  "Pembayaran Berhasil!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Pesanan Anda telah diterima.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _finishPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Selesai",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _finishPayment() {
    final orderProvider =
        Provider.of<OrderProvider>(context, listen: false);

    // Tambahkan pesanan baru → konsisten dengan BookingPage
    orderProvider.addOrder(
      Order(
        title: "Cuci Mobil",
        date: DateTime.now().toString().substring(0, 10),
        time: "Menunggu Konfirmasi",
        status: "menunggu mitra",
        image: "assets/images/mobil1.png",
        location: widget.address,
        detailAddress: widget.detailAddress,
        plateNumber: widget.plateNumber,
        username: widget.username,
        phoneNumber: widget.phoneNumber,
        bookingId: DateTime.now().millisecondsSinceEpoch.toString(),
        carType: widget.carType,
        price: widget.price,
        servicePrice: widget.servicePrice,
        tax: widget.tax,
        discount: widget.discount,
        total: widget.total,
      ),
    );

    // Tambahkan notifikasi
    Provider.of<NotificationProvider>(context, listen: false)
        .addNotification(
      AppNotification(
        title: "Pembayaran Berhasil",
        message:
            "Pesanan Anda berhasil dibuat dan menunggu konfirmasi mitra.",
        time: "Baru saja",
        isNew: true,
      ),
    );

    Navigator.pop(context); // tutup popup
    Navigator.pushNamedAndRemoveUntil(
      context,
      "/home",
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "QRIS Payment",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset("assets/images/logo_qris.png", height: 70),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/qris.jpg",
                    height: 260,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Silakan scan kode QR untuk melakukan pembayaran.",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    _isPaymentSuccess ? _showSuccessPopup : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isPaymentSuccess ? Colors.blueAccent : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _isPaymentSuccess
                      ? "Pembayaran Selesai"
                      : "Menunggu Pembayaran...",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

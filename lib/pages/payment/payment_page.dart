import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/payment/data/midtrans_api.dart';
import '../../models/notification_model.dart';
import '../../models/order_model.dart';
import '../../providers/notification_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/deep_link_service.dart';
import 'midtrans_checkout_page.dart';

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
  final MidtransApi _midtransApi = MidtransApi();
  bool _isPaying = false;
  StreamSubscription<Uri>? _deepLinkSub;

  Future<void> _startMidtransPayment() async {
    if (_isPaying) return;

    setState(() => _isPaying = true);
    try {
      final checkout = await _midtransApi.createCheckout(
        bookingData: widget.bookingData,
      );

      if (!mounted) return;

      const useExternalBrowser = false;
      if (useExternalBrowser) {
        _listenForFinishDeepLink();
      }

      final completed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => MidtransCheckoutPage(
            checkoutUrl: checkout.redirectUrl,
            useExternalBrowser: useExternalBrowser,
          ),
        ),
      );

      // Cek status transaksi setelah kembali dari WebView
      final transactionStatus =
          await _midtransApi.getTransactionStatus(checkout.orderId);

      final isPaid = transactionStatus == 'settlement' ||
          transactionStatus == 'capture' ||
          completed == true;

      if (!mounted) return;

      if (isPaid) {
        _savePaidOrder();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              transactionStatus.isEmpty
                  ? 'Pembayaran belum selesai'
                  : 'Status pembayaran: $transactionStatus',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memulai pembayaran Midtrans: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPaying = false);
      }
    }
  }

  void _listenForFinishDeepLink() {
    _deepLinkSub?.cancel();
    _deepLinkSub = DeepLinkService.instance.stream.listen((uri) {
      if (_isFinishLink(uri) && mounted) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
      }
    });
  }

  bool _isFinishLink(Uri uri) {
    return uri.scheme == 'carwashgo' &&
        uri.host == 'payment' &&
        uri.path == '/finish';
  }

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
        title: 'Pembayaran Berhasil',
        message: 'Pesanan Anda berhasil dibuat dan menunggu konfirmasi mitra.',
        time: 'Baru saja',
        isNew: true,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pembayaran berhasil')),
    );

    // Kembali ke home
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    super.dispose();
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
          "Pembayaran",
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
              "Metode Pembayaran",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blueAccent,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(1, 2),
                  )
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.account_balance_wallet_outlined,
                      color: Colors.blueAccent, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Midtrans (QRIS / VA / E-Wallet)",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Icon(Icons.check_circle, color: Colors.blueAccent),
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
                onPressed: _isPaying ? null : _startMidtransPayment,
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
                        "Bayar dengan Midtrans",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    "/qris",
                    arguments: widget.bookingData,
                  );
                },
                child: const Text("Metode QRIS Lama"),
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

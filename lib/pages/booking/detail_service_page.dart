import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../../core/network/dio_client.dart';
import '../navigation/bottom_nav.dart';

class DetailServicePage extends StatefulWidget {
  final String username;
  final String phoneNumber;
  final String bookingId;
  final String date;
  final String time;
  final String carType;
  final int price;
  final int servicePrice;
  final int tax;
  final int discount;
  final String address;
  final String detailAddress;
  final String plateNumber;
  final int total;
  final String partnerId;
  final int vehicleTypeId;
  final int partnerServiceId;
  final double? latitude;
  final double? longitude;

  final bool showDelete;
  final bool fromOrderPage;

  const DetailServicePage({
    super.key,
    required this.username,
    required this.phoneNumber,
    required this.bookingId,
    required this.date,
    required this.time,
    required this.carType,
    required this.vehicleTypeId,
    required this.partnerServiceId,
    required this.price,
    required this.servicePrice,
    required this.tax,
    required this.discount,
    required this.address,
    this.latitude,
    this.longitude,
    required this.detailAddress,
    required this.plateNumber,
    required this.total,
    required this.partnerId,
    this.showDelete = true,
    this.fromOrderPage = false,
  });

  @override
  State<DetailServicePage> createState() => _DetailServicePageState();
}

class _DetailServicePageState extends State<DetailServicePage> {
  bool _isSubmitting = false;

  Future<void> _handleConfirm() async {
    setState(() => _isSubmitting = true);

    try {
      // 1. Prepare Date/Time
      final now = DateTime.now();
      final scheduledDate = "${now.year}-${(now.month).toString().padLeft(2, '0')}-${widget.date.split(' ')[1].padLeft(2, '0')}";
      final scheduledTime = widget.time.split(' - ')[0].replaceAll('.', ':');

      // 2. Create Order call
      final orderProv = context.read<OrderProvider>();
      final result = await orderProv.createOrder(
        partnerId: int.parse(widget.partnerId),
        vehicleTypeId: widget.vehicleTypeId,
        vehicleBrand: widget.carType, // snapshot literal
        vehicleModel: "", 
        plateNumber: widget.plateNumber,
        address: "${widget.address} (${widget.detailAddress})",
        latitude: widget.latitude,
        longitude: widget.longitude,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        items: [
          {'partner_service_id': widget.partnerServiceId, 'quantity': 1}
        ],
      );

      if (result.status == 'success' || result.status == 'ok') {
        if (!mounted) return;
        
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text("Berhasil!"),
            content: const Text("Pesanan Anda telah dibuat. Silahkan tunggu mitra menerima pesanan Anda sebelum melakukan pembayaran."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const BottomNav(currentIndex: 2)),
                    (route) => false,
                  );
                },
                child: const Text("OK"),
              )
            ],
          ),
        );
      } else {
        throw Exception(result.message);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal membuat pesanan: ${e.toString().replaceAll('Exception: ', '')}")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5F1FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5F1FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Detail Layanan",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow("Nama", widget.username),
                  _infoRow("No. HP", widget.phoneNumber),
                  _infoRow("ID Booking", widget.bookingId),
                  _infoRow("Tanggal", widget.date),
                  _infoRow("Jam", widget.time),
                  const SizedBox(height: 12),
                  const Divider(),
                  _infoRow("Jenis Mobil", widget.carType),
                  _infoRow("Plat Nomor", widget.plateNumber),
                  const SizedBox(height: 12),
                  const Divider(),
                  _addressCard(widget.address, widget.detailAddress),
                  const Divider(),
                  _infoRow("Harga Mobil", "Rp ${widget.price}"),
                  _infoRow("Layanan Tambahan", "Rp ${widget.servicePrice}"),
                  _infoRow("Pajak", "Rp ${widget.tax}"),
                  _infoRow("Diskon", "${widget.discount}%"),
                  const Divider(),
                  _infoRow("Total Pembayaran", "Rp ${widget.total}", bold: true, big: true),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (widget.showDelete)
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red, width: 1.4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("BATAL", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      if (widget.showDelete) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _handleConfirm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              "KONFIRMASI",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          if (_isSubmitting)
            Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget _infoRow(String title, dynamic value, {bool bold = false, bool big = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
          Text(
            "$value",
            style: TextStyle(fontSize: big ? 18 : 15, fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _addressCard(String mainAddress, String detail) {
    // Jika mainAddress adalah koordinat, kita tampilkan lebih cantik
    final bool isCoord = mainAddress.contains(",");
    
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.blueAccent, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Alamat Lengkap", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                const SizedBox(height: 5),
                Text(
                  isCoord ? "Lokasi Maps: $mainAddress" : mainAddress,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                if (detail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(detail, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

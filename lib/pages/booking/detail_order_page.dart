import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../../models/order_model.dart';

class DetailOrderPage extends StatelessWidget {
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

  final bool showDelete;
  final bool fromOrderPage;

  const DetailOrderPage({
    super.key,
    required this.username,
    required this.phoneNumber,
    required this.bookingId,
    required this.date,
    required this.time,
    required this.carType,
    required this.price,
    required this.servicePrice,
    required this.tax,
    required this.discount,
    required this.address,
    required this.detailAddress,
    required this.plateNumber,
    required this.total,
    this.showDelete = true,
    this.fromOrderPage = false,
  });

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.read<OrderProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFE5F1FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5F1FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Detail Service",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow("Nama Pengguna", username),
              _infoRow("Nomor Telepon", phoneNumber),
              _infoRow("Booking ID", bookingId),
              _infoRow("Tanggal", date),
              _infoRow("Jam", time),
              const SizedBox(height: 12),
              const Divider(),
              _infoRow("Jenis Mobil", carType),
              _infoRow("Plat Nomor", plateNumber),
              const SizedBox(height: 12),
              const Divider(),
              _addressCard(address, detailAddress),
              const Divider(),
              _infoRow("Harga Mobil", "Rp $price"),
              _infoRow("Harga Layanan", "Rp $servicePrice"),
              _infoRow("Pajak", "Rp $tax"),
              _infoRow("Diskon", "$discount%"),
              const Divider(),
              _infoRow("Total", "Rp $total", bold: true, big: true),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (showDelete)
                    SizedBox(
                      height: 45,
                      width: 120,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red, width: 1.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "DELETE",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (showDelete) const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          if (fromOrderPage) {
                            Navigator.pop(context);
                          } else {
                            // ================================
                            // ✅ TAMBAHKAN PESANAN KE MITRA
                            // ================================

                            final newOrder = Order(
                              mitraId: "mitra", // ✅ WAJIB: ID MITRA YANG DITUJU
                              title: username,
                              date: date,
                              time: time,
                              status: "Pesanan Baru",
                              image: "assets/images/on1.png",
                              location: address,
                              detailAddress: detailAddress,
                              plateNumber: plateNumber,
                              username: username,
                              phoneNumber: phoneNumber,
                              bookingId: bookingId,
                              carType: carType,
                              price: price,
                              servicePrice: servicePrice,
                              tax: tax,
                              discount: discount,
                              total: total,
                            );

                            orderProvider.addOrder(newOrder);

                            // =====================================================
                            // ✅ FLOW BARU: pembayaran hanya bisa setelah mitra ACCEPT
                            // =====================================================
                            // Jadi setelah membuat pesanan, customer hanya menunggu.
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => AlertDialog(
                                title: const Text('Pesanan dibuat'),
                                content: const Text(
                                  'Silahkan tunggu pesanan anda diterima oleh mitra!',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // close dialog
                                      Navigator.pop(
                                          context); // back from detail page
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "CONFIRM",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 15,
                          ),
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
    );
  }

  Widget _infoRow(String title, dynamic value,
      {bool bold = false, bool big = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black87)),
          Text(
            "$value",
            style: TextStyle(
              fontSize: big ? 18 : 15,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressCard(String mainAddress, String detail) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.blueAccent, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Alamat Lengkap",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 5),
                Text("$mainAddress\n$detail"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

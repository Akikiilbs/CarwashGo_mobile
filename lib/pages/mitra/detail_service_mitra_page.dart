import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../../pages/mitra/mitra_map_page.dart';

class DetailServiceMitraPage extends StatefulWidget {
  final int providerIndex; // ✅ WAJIB
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

  const DetailServiceMitraPage({
    super.key,
    required this.providerIndex, // ✅ WAJIB
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
  });

  @override
  State<DetailServiceMitraPage> createState() => _DetailServiceMitraPageState();
}

class _DetailServiceMitraPageState extends State<DetailServiceMitraPage> {
  String selectedStatus = "pengerjaan";

  final List<String> statusList = [
    "pengerjaan",
    "dalam perjalanan",
    "selesai",
  ];

  @override
  Widget build(BuildContext context) {
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
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow("Nama Pengguna", widget.username),
              _infoRow("Nomor Telepon", widget.phoneNumber),
              _infoRow("Booking ID", widget.bookingId),
              _infoRow("Tanggal", widget.date),
              _infoRow("Jam", widget.time),

              const Divider(),

              _infoRow("Jenis Mobil", widget.carType),
              _infoRow("Plat Nomor", widget.plateNumber),

              const Divider(),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MitraMapPage(
                        latitude: 0.4634,
                        longitude: 101.3908,
                        username: widget.username,
                        address:
                            "${widget.address}, ${widget.detailAddress}",
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.blueAccent, size: 26),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Alamat Lengkap",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent),
                            ),
                            Text(
                                "${widget.address}\n${widget.detailAddress}"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(),

              _infoRow("Harga Mobil", "Rp ${widget.price}"),
              _infoRow("Harga Layanan", "Rp ${widget.servicePrice}"),
              _infoRow("Pajak", "Rp ${widget.tax}"),
              _infoRow("Diskon", "${widget.discount}%"),

              const Divider(),

              _infoRow("Total", "Rp ${widget.total}",
                  bold: true, big: true),

              const SizedBox(height: 20),

              const Text(
                "Update Status Pesanan",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: selectedStatus,
                items: statusList
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() => selectedStatus = v!);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ✅✅✅ SAVE KE PROVIDER
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<OrderProvider>().updateOrderStatus(
                          widget.providerIndex,
                          selectedStatus,
                        );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text("Status diperbarui: $selectedStatus"),
                      ),
                    );

                    Navigator.pop(context); // ✅ PENTING agar refresh
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "SIMPAN STATUS",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 15),
                  ),
                ),
              ),
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
              style:
                  const TextStyle(fontWeight: FontWeight.w600)),
          Text(
            "$value",
            style: TextStyle(
              fontSize: big ? 18 : 15,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

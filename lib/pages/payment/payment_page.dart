import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const PaymentPage({
    super.key,
    required this.bookingData,
  });

  @override
  Widget build(BuildContext context) {
    final username = bookingData["username"];
    final phoneNumber = bookingData["phoneNumber"];
    final address = bookingData["address"];
    final detailAddress = bookingData["detailAddress"];
    final plateNumber = bookingData["plateNumber"];
    final carType = bookingData["carType"];
    final price = bookingData["price"] as int;
    final servicePrice = bookingData["servicePrice"] as int;
    final tax = bookingData["tax"] as int;
    final discount = bookingData["discount"] as int;
    final total = bookingData["total"] as int;

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
            // METODE PEMBAYARAN (hanya QRIS)
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
                  Icon(Icons.qr_code_2_rounded,
                      color: Colors.blueAccent, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "QRIS",
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

            // RINGKASAN PESANAN
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

            // BUTTON LANJUTKAN KE QRIS
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
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    "/qris",
                    arguments: bookingData,
                  );
                },
                child: const Text(
                  "Lanjutkan Pembayaran QRIS",
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

  Widget _rowText(String left, Object right, {bool bold = false}) {
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

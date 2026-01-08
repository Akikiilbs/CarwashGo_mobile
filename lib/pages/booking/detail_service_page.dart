import 'package:flutter/material.dart';

import '../booking/booking_page.dart';

/// Detail station/service untuk customer.
/// Menampilkan informasi mitra (station) + daftar paket (service x vehicle type) dari backend marketplace.
/// Kalau ada data yang belum tersedia dari backend, ditampilkan sebagai dummy.
class DetailServicePage extends StatefulWidget {
  final Map<String, dynamic> partner;
  final List<Map<String, dynamic>> offers;

  const DetailServicePage({
    super.key,
    required this.partner,
    required this.offers,
  });

  @override
  State<DetailServicePage> createState() => _DetailServicePageState();
}

class _DetailServicePageState extends State<DetailServicePage> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final partner = widget.partner;
    final name = partner['business_name']?.toString() ??
        partner['name']?.toString() ??
        '-';
    final address = partner['address']?.toString() ?? '-';

    // Dummy (karena backend belum tentu menyediakan)
    final rating = partner['rating']?.toString() ?? '4.7 (dummy)';
    final openHours =
        partner['open_hours']?.toString() ?? '08:00 - 18:00 (dummy)';
    final description = partner['description']?.toString() ??
        'Layanan cuci mobil di lokasi Anda. Pilih paket, lalu isi data booking. (dummy)';

    final offers = List<Map<String, dynamic>>.from(widget.offers);
    // sort by price asc
    offers.sort((a, b) {
      final pa = (a['price'] is num)
          ? (a['price'] as num).toDouble()
          : double.tryParse(a['price']?.toString() ?? '') ?? 0;
      final pb = (b['price'] is num)
          ? (b['price'] as num).toDouble()
          : double.tryParse(b['price']?.toString() ?? '') ?? 0;
      return pa.compareTo(pb);
    });

    final selectedOffer = (_selectedIndex != null &&
            _selectedIndex! >= 0 &&
            _selectedIndex! < offers.length)
        ? offers[_selectedIndex!]
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detail Service',
          style:
              TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Station
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F1FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/on1.png',
                      width: 74,
                      height: 74,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                size: 16, color: Colors.blueAccent),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                address,
                                style: const TextStyle(fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _chip('⭐ $rating'),
                            _chip('🕒 $openHours'),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 14),
            Text(
              description,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),

            const SizedBox(height: 18),
            const Text(
              'Pilih Paket',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (offers.isEmpty)
              _emptyOffers()
            else
              Column(
                children: List.generate(offers.length, (i) {
                  final it = offers[i];
                  final service =
                      (it['service'] as Map?)?.cast<String, dynamic>() ?? {};
                  final vt =
                      (it['vehicle_type'] as Map?)?.cast<String, dynamic>() ??
                          {};
                  final serviceName =
                      service['name']?.toString() ?? 'Layanan (dummy)';
                  final vehicleTypeName =
                      vt['name']?.toString() ?? 'Tipe (dummy)';
                  final price = it['price']?.toString() ?? '-';

                  final selected = _selectedIndex == i;

                  return InkWell(
                    onTap: () => setState(() => _selectedIndex = i),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.blue.withOpacity(0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? Colors.blueAccent : Colors.black12,
                          width: selected ? 1.2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Radio<int>(
                            value: i,
                            groupValue: _selectedIndex,
                            onChanged: (v) =>
                                setState(() => _selectedIndex = v),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  serviceName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tipe: $vehicleTypeName',
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Rp $price',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: selectedOffer == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BookingPage(serviceItem: selectedOffer),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _emptyOffers() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: const Text('Belum ada paket layanan. (dummy)',
          style: TextStyle(color: Colors.black54)),
    );
  }
}

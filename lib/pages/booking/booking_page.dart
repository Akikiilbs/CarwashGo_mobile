import 'package:flutter/material.dart';
import '../map/map_picker_page.dart';
import 'detail_service_page.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String? selectedCar;
  String? selectedService;
  String? selectedAddress;

  int selectedDateIndex = 0;
  int selectedTimeIndex = -1;
  double selectedDistance = 0;

  // Controller baru
  final TextEditingController detailAddressController = TextEditingController();
  final TextEditingController plateNumberController = TextEditingController();

  final List<String> cars = [
    "Small Car (Agya/Brio)",
    "Medium Car (Avanza/Xenia)",
    "Big Car (Alphard/Fortuner)",
  ];

  final List<int> carPrices = [55000, 75000, 95000];

  final List<String> services = ["Cuci Luar", "Cuci Luar & Dalam"];
  final List<int> servicePrices = [25000, 50000];

  final List<String> dates = [
    "Sun 11",
    "Mon 12",
    "Tue 13",
    "Wed 14",
    "Thu 15",
    "Fri 16",
    "Sat 17"
  ];

  final List<String> times = [
    "09.00 - 10.00",
    "10.00 - 11.00",
    "11.00 - 12.00",
    "13.00 - 14.00",
    "14.00 - 15.00",
    "15.00 - 16.00",
  ];

  @override
  void dispose() {
    detailAddressController.dispose();
    plateNumberController.dispose();
    super.dispose();
  }

  // ================== PRICE LOGIC ====================
  int getCarPrice() =>
      selectedCar == null ? 0 : carPrices[cars.indexOf(selectedCar!)];

  int getServicePrice() =>
      selectedService == null ? 0 : servicePrices[services.indexOf(selectedService!)];

  int getDistancePrice() => (selectedDistance * 2000).round();

  int calculateTotal() =>
      getCarPrice() + getServicePrice() + getDistancePrice();

  String estimateDriverArrival() {
    if (selectedDistance == 0) return "-";
    int minutes = (selectedDistance * 3).round();
    return "$minutes menit tiba";
  }

  // ====================================================
  // ===================== UI BUILD =====================
  // ====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "CarWashGo",
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                "assets/images/mobil1.png",
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 25),

            // CAR DROPDOWN
            _buildDropdown(
              hint: "Pilih Jenis Mobil",
              value: selectedCar,
              items: cars,
              onChanged: (value) => setState(() => selectedCar = value),
            ),

            const SizedBox(height: 16),

            // SERVICE DROPDOWN
            _buildDropdown(
              hint: "Pilih Jenis Layanan",
              value: selectedService,
              items: services,
              onChanged: (value) => setState(() => selectedService = value),
            ),

            const SizedBox(height: 20),

            // MAP PICKER BUTTON
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MapPickerPage()),
                );

                if (result != null && result is Map) {
                  setState(() {
                    selectedAddress = result["address"];
                    selectedDistance = result["distance"];
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Pilih Lokasi di Peta",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),

            if (selectedAddress != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Alamat dipilih:\n$selectedAddress",
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // DETAIL ALAMAT
            const Text(
              "Detail Alamat",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: detailAddressController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Contoh: Perumahan Griya Indah Blok C No.12",
                prefixIcon: const Icon(Icons.home_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // PLAT NOMOR
            const Text(
              "Plat Kendaraan",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: plateNumberController,
              decoration: InputDecoration(
                hintText: "Contoh: BP 1234 AB",
                prefixIcon: const Icon(Icons.directions_car_filled_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // DATE PICKER
            _buildSectionTitle("Pilih Tanggal"),
            const SizedBox(height: 12),
            _buildDatePicker(),

            const SizedBox(height: 20),

            // TIME PICKER
            _buildSectionTitle("Pilih Jam"),
            const SizedBox(height: 12),
            _buildTimePicker(),

            const SizedBox(height: 30),

            // PRICE SECTION
            _buildPriceSection(),

            const SizedBox(height: 30),

            // BOOK BUTTON
            _buildBookingButton(context),
          ],
        ),
      ),
    );
  }

  // ================== COMPONENTS =====================
  Widget _buildSectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      );

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueAccent, width: 1.5),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint),
        isExpanded: true,
        underline: const SizedBox(),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDatePicker() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final isSelected = selectedDateIndex == index;

          return GestureDetector(
            onTap: () => setState(() => selectedDateIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  dates[index],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimePicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(times.length, (index) {
        final isSelected = selectedTimeIndex == index;

        return GestureDetector(
          onTap: () => setState(() => selectedTimeIndex = index),
          child: Container(
            width: 120,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.blueAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              times[index],
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ringkasan Harga",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 10),

          _priceRow("Harga Mobil", getCarPrice()),
          _priceRow("Harga Layanan", getServicePrice()),
          _priceRow(
            "Biaya Jarak (${selectedDistance.toStringAsFixed(1)} km)",
            getDistancePrice(),
          ),

          const Divider(),

          _priceRow("Total", calculateTotal(), bold: true),
          const SizedBox(height: 10),

          Text("Driver ETA: ${estimateDriverArrival()}"),
        ],
      ),
    );
  }

  Widget _priceRow(String title, int value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            "Rp $value",
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {
          if (selectedAddress == null ||
              selectedCar == null ||
              selectedService == null ||
              selectedTimeIndex == -1 ||
              detailAddressController.text.isEmpty ||
              plateNumberController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Harap lengkapi semua data dulu.")),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailServicePage(
                username: "User CarWashGo",
                phoneNumber: "081234567890",
                bookingId: DateTime.now().millisecondsSinceEpoch.toString(),
                date: dates[selectedDateIndex],
                time: times[selectedTimeIndex],
                carType: selectedCar!,
                price: getCarPrice(),
                servicePrice: getServicePrice(),
                tax: 5000,
                discount: 0,
                address: selectedAddress!,
                detailAddress: detailAddressController.text,
                plateNumber: plateNumberController.text,
                total: calculateTotal(),
              ),
            ),
          );
        },
        child: const Text(
          "Pesan Sekarang",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

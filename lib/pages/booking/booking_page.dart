import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carwashgo/core/network/dio_client.dart';
import '../../features/partner/models/meta_models.dart';
import '../../features/partner/models/partner_service_dto.dart';
import '../../providers/user_provider.dart';
import '../../providers/order_provider.dart';
import '../map/map_picker_page.dart';
import 'detail_service_page.dart';
import '../navigation/bottom_nav.dart';

class BookingPage extends StatefulWidget {
  final String partnerId;
  const BookingPage({super.key, required this.partnerId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  // Data dinamis dari API
  List<VehicleTypeDto> _vTypes = [];
  List<PartnerServiceDto> _allServices = [];
  bool _loading = true;

  List<String> _availableDates = [];
  List<DateTime> _availableDatesObj = [];
  List<String> _availableTimes = [];
  bool _fetchingTimes = false;
  bool _errorFetchingTimes = false;
  
  VehicleTypeDto? _selectedVType;
  PartnerServiceDto? _selectedPService;
  String? selectedAddress;
  double? latitude;
  double? longitude;

  int selectedDateIndex = 0;
  int selectedTimeIndex = -1;
  double selectedDistance = 0;
  final int tax = 5000;
  final int discountPercent = 0;

  final TextEditingController detailAddressController = TextEditingController();
  final TextEditingController plateNumberController = TextEditingController();

  final Map<int, String> _dayMap = {
    DateTime.monday: "Senin",
    DateTime.tuesday: "Selasa",
    DateTime.wednesday: "Rabu",
    DateTime.thursday: "Kamis",
    DateTime.friday: "Jumat",
    DateTime.saturday: "Sabtu",
    DateTime.sunday: "Minggu",
  };

  @override
  void initState() {
    super.initState();
    _loadMeta();
  }

  Future<void> _loadMeta() async {
    try {
      final dio = DioClient().dio;
      final results = await Future.wait([
        dio.get('/meta/vehicle-types'),
        dio.get('/marketplace/services', queryParameters: {'partner_id': widget.partnerId}),
        dio.get('/marketplace/partners', queryParameters: {'partner_id': widget.partnerId}),
      ]);

      final vTypes = (results[0].data['data'] as List)
          .map((e) => VehicleTypeDto.fromJson(e as Map<String, dynamic>))
          .toList();
      
      final pServices = (results[1].data['data'] as List)
          .map((e) => PartnerServiceDto.fromJson(e as Map<String, dynamic>))
          .toList();

      final partnerData = (results[2].data['data'] as List).firstOrNull;
      
      // Parse operating constraints
      String opDays = partnerData?['hariOperasional']?.toString() ?? partnerData?['operating_days']?.toString() ?? 'Senin,Selasa,Rabu,Kamis,Jumat,Sabtu,Minggu';
      String opHours = partnerData?['jamOperasional']?.toString() ?? partnerData?['operating_hours']?.toString() ?? '08:00,09:00,10:00,11:00,12:00,13:00,14:00,15:00,16:00,17:00';

      if (opDays == 'Senin - Minggu' || opDays == 'Setiap Hari') {
        opDays = 'Senin,Selasa,Rabu,Kamis,Jumat,Sabtu,Minggu';
      }
      if (opHours.contains(' - ')) {
        // basic fallback for old "08.00 - 17.00" string
        opHours = '08:00,09:00,10:00,11:00,12:00,13:00,14:00,15:00,16:00,17:00';
      }

      final List<String> activeDays = opDays.split(',').map((e) => e.trim()).toList();
      final List<String> activeHours = opHours.split(',').map((e) => e.trim().replaceAll('.', ':')).toList();

      // Generate dynamic dates (next 7 days, filtered by activeDays)
      final List<String> filteredDates = [];
      final List<DateTime> dateObjs = [];
      final daysShort = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
      for (int i = 0; i < 14; i++) {
        final d = DateTime.now().add(Duration(days: i));
        final dayNameIndo = _dayMap[d.weekday];
        if (activeDays.contains(dayNameIndo)) {
          filteredDates.add("${daysShort[d.weekday % 7]} ${d.day}");
          dateObjs.add(d);
        }
        if (filteredDates.length >= 7) break;
      }

      setState(() {
        _vTypes = vTypes;
        _allServices = pServices;
        _availableDates = filteredDates;
        _availableDatesObj = dateObjs;
        _loading = false;
      });

      if (dateObjs.isNotEmpty) {
        _fetchAvailableTimes(dateObjs.first);
      }
    } catch (e) {
      debugPrint("❌ Error loading booking meta: $e");
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchAvailableTimes(DateTime date) async {
    setState(() => _fetchingTimes = true);
    try {
      final dio = DioClient().dio;
      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final res = await dio.get('/partners/${widget.partnerId}/available-slots', queryParameters: {'date': dateStr});
      
      final List times = res.data['data']?['available_times'] ?? [];
      
      if (mounted) {
        setState(() {
          _availableTimes = times.map((e) => e.toString()).toList();
          selectedTimeIndex = -1;
          _fetchingTimes = false;
          _errorFetchingTimes = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetch times: $e");
      if (mounted) {
        setState(() {
          _availableTimes = [];
          selectedTimeIndex = -1;
          _fetchingTimes = false;
          _errorFetchingTimes = true;
        });
      }
    }
  }

  int getServicePrice() => _selectedPService?.price ?? 0;

  int getDistancePrice() => (selectedDistance * 2000).round();

  int calculateTotal() {
    final subtotal = getServicePrice() + getDistancePrice();
    final discountValue = ((subtotal + tax) * discountPercent / 100).round();
    return subtotal + tax - discountValue;
  }

  String estimateDriverArrival() {
    if (selectedDistance == 0) return "-";
    int minutes = (selectedDistance * 3).round();
    return "$minutes menit tiba";
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Filter services based on vehicle type
    final availableServices = _allServices.where((s) => s.vehicleTypeId == _selectedVType?.id).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("Booking CarWash", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                "assets/images/mobil1.png",
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.directions_car_filled_rounded, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 25),
            _buildDropdownVType(
              hint: "Pilih Jenis Mobil",
              value: _selectedVType,
              items: _vTypes,
              onChanged: (v) {
                setState(() {
                  _selectedVType = v;
                  _selectedPService = null; // reset service when car type changes
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDropdownPService(
              hint: "Pilih Jenis Layanan",
              value: _selectedPService,
              items: availableServices,
              onChanged: (v) => setState(() => _selectedPService = v),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MapPickerPage()),
                );

                if (result != null && result is Map && mounted) {
                  setState(() {
                    selectedAddress = result["address"]?.toString();
                    selectedDistance = (result["distance"] as num?)?.toDouble() ?? 0.0;
                    latitude = (result["latitude"] as num?)?.toDouble();
                    longitude = (result["longitude"] as num?)?.toDouble();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Pilih Lokasi di Peta", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            if (selectedAddress != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blueAccent, 
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))
                  ],
                ),
                child: Text("Alamat dipilih:\n$selectedAddress", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ],
            const SizedBox(height: 20),
            _buildSectionTitle("Detail Alamat"),
            const SizedBox(height: 8),
            TextField(
              controller: detailAddressController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Contoh: Perumahan Griya Indah Blok C No.12",
                prefixIcon: const Icon(Icons.home_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Plat Kendaraan"),
            const SizedBox(height: 8),
            TextField(
              controller: plateNumberController,
              decoration: InputDecoration(
                hintText: "Contoh: BP 1234 AB",
                prefixIcon: const Icon(Icons.directions_car_filled_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 25),
            _buildSectionTitle("Pilih Tanggal"),
            const SizedBox(height: 12),
            _buildDatePicker(),
            const SizedBox(height: 20),
            _buildSectionTitle("Pilih Jam"),
            const SizedBox(height: 12),
            _buildTimePicker(),
            const SizedBox(height: 30),
            _buildPriceSection(),
            const SizedBox(height: 30),
            _buildBookingButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      );

  Widget _buildDropdownVType({
    required String hint,
    required VehicleTypeDto? value,
    required List<VehicleTypeDto> items,
    required ValueChanged<VehicleTypeDto?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<VehicleTypeDto>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item.name))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDropdownPService({
    required String hint,
    required PartnerServiceDto? value,
    required List<PartnerServiceDto> items,
    required ValueChanged<PartnerServiceDto?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PartnerServiceDto>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text("${item.serviceName ?? 'Layanan'} - Rp${item.price}"))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _availableDates.length,
        itemBuilder: (context, index) {
          final isSelected = selectedDateIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() => selectedDateIndex = index);
              _fetchAvailableTimes(_availableDatesObj[index]);
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blueAccent : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                _availableDates[index],
                textAlign: TextAlign.center,
                style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimePicker() {
    if (_fetchingTimes) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    }
    if (_errorFetchingTimes) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text("Gagal memuat slot waktu.", style: TextStyle(color: Colors.redAccent)),
            TextButton(
              onPressed: () => _fetchAvailableTimes(_availableDatesObj[selectedDateIndex]),
              child: const Text("Coba Lagi"),
            )
          ],
        ),
      );
    }
    if (_availableTimes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Maaf, tidak ada slot waktu tersedia pada tanggal ini.", style: TextStyle(color: Colors.redAccent)),
      );
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(_availableTimes.length, (index) {
        final isSelected = selectedTimeIndex == index;
        return GestureDetector(
          onTap: () => setState(() => selectedTimeIndex = index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blueAccent : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _availableTimes[index],
              style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
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
        color: Colors.blueAccent, 
        borderRadius: BorderRadius.circular(16), 
        boxShadow: [
          BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          _priceRow("Harga Layanan", getServicePrice(), color: Colors.white),
          _priceRow("Biaya Antar", getDistancePrice(), suffix: " (${selectedDistance.toStringAsFixed(1)} km)", color: Colors.white70),
          _priceRow("Pajak", tax, color: Colors.white70),
          if (discountPercent > 0) _priceRow("Diskon", discountPercent, suffix: "%", color: Colors.white70),
          const Divider(height: 24, color: Colors.white38),
          _priceRow("Total Pembayaran", calculateTotal(), bold: true, color: Colors.white),
          const SizedBox(height: 12),
          Text("Driver ETA: ${estimateDriverArrival()}", style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _priceRow(String title, int value, {bool bold = false, String suffix = "", Color color = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: color)),
          Text(suffix.isEmpty ? "Rp $value" : (suffix.startsWith(' ') ? "Rp $value$suffix" : "$value$suffix"), 
               style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }

  Widget _buildBookingButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        onPressed: () {
          if (selectedAddress == null || _selectedVType == null || _selectedPService == null || selectedTimeIndex == -1 || detailAddressController.text.isEmpty || plateNumberController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harap lengkapi semua data dulu.")));
            return;
          }
          final user = context.read<UserProvider>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailServicePage(
                username: user.name.isEmpty ? "User CarWashGo" : user.name,
                phoneNumber: user.phone.isEmpty ? "081234567890" : user.phone,
                bookingId: DateTime.now().millisecondsSinceEpoch.toString().substring(7),
                date: _availableDates[selectedDateIndex],
                rawDate: "${_availableDatesObj[selectedDateIndex].year}-${_availableDatesObj[selectedDateIndex].month.toString().padLeft(2, '0')}-${_availableDatesObj[selectedDateIndex].day.toString().padLeft(2, '0')}",
                time: _availableTimes[selectedTimeIndex],
                carType: _selectedVType!.name,
                vehicleTypeId: _selectedVType!.id,
                partnerServiceId: _selectedPService!.id,
                price: _selectedPService!.price,
                servicePrice: 0, // combined in dynamic
                tax: tax,
                discount: discountPercent,
                address: selectedAddress!,
                latitude: latitude,
                longitude: longitude,
                detailAddress: detailAddressController.text,
                plateNumber: plateNumberController.text,
                total: calculateTotal(),
                partnerId: widget.partnerId,
              ),
            ),
          );
        },
        child: const Text("Pesan Sekarang", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}

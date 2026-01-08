import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/network/dio_client.dart';
import '../navigation/bottom_nav.dart';
import '../booking/detail_service_page.dart';

/// Home customer: menampilkan layanan mitra yang tersedia.
/// - Jika izin lokasi diberikan, daftar akan diurutkan berdasarkan jarak (nearest first)
/// - Jika izin lokasi tidak diberikan, daftar tetap tampil (tanpa jarak)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Dio _dio = DioClient().dio;
  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;
  String? _error;
  Position? _userPosition;

  /// data item contoh dari API:
  /// {
  ///   id, price, distance_km,
  ///   partner: { business_name, address },
  ///   service: { name },
  ///   vehicle_type: { name }
  /// }
  List<Map<String, dynamic>> _services = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    // Coba minta lokasi (opsional). Kalau gagal/ditolak, tetap fetch tanpa lokasi.
    final pos = await _tryGetUserLocation();
    _userPosition = pos;

    await _fetchServices();
  }

  Future<Position?> _tryGetUserLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _fetchServices() async {
    try {
      final qp = <String, dynamic>{
        'per_page': 20,
      };

      final q = _searchController.text.trim();
      if (q.isNotEmpty) qp['q'] = q;

      if (_userPosition != null) {
        qp['lat'] = _userPosition!.latitude;
        qp['lng'] = _userPosition!.longitude;
        qp['radius_km'] = 10; // default: 10km (ubah sesuai kebutuhan)
      }

      final res = await _dio.get('/marketplace/services', queryParameters: qp);
      final body = res.data as Map<String, dynamic>;
      final data = (body['data'] as List).cast<dynamic>();

      setState(() {
        _services = data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _loading = false;
        _error = null;
      });
    } on DioException catch (e) {
      // final msg = (e.response?.data is Map<String, dynamic>)
      //     ? (e.response?.data['message']?.toString() ?? 'Gagal memuat data')
      //     : 'Gagal memuat data';
      // setState(() {
      //   _loading = false;
      //   _error = msg;
      // });
      debugPrint('Marketplace error status: ${e.response?.statusCode}');
      debugPrint('Marketplace error data: ${e.response?.data}');
      final msg = (e.response?.data is Map<String, dynamic>)
          ? (e.response?.data['message']?.toString() ?? 'Gagal memuat data')
          : (e.response?.data?.toString() ?? 'Gagal memuat data');
      setState(() {
        _loading = false;
        _error = msg;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Gagal memuat data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _init(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Welcome !!!",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const Text(
                  "Have a good day",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 16),

                // Search
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _fetchServices(),
                  decoration: InputDecoration(
                    hintText: 'Cari layanan / mitra…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _fetchServices();
                      },
                      icon: const Icon(Icons.clear),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Location info
                _buildLocationInfo(context),

                const SizedBox(height: 18),

                // SPECIAL OFFER (tetap)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Special Offer !!!",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "50% OFF",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "On First Service",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: Image.asset("assets/images/on1.png"))
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Layanan Tersedia",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 12),

                if (_loading) ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                ] else if (_error != null) ...[
                  _buildErrorCard(_error!),
                ] else if (_services.isEmpty) ...[
                  _buildEmptyCard(),
                ] else ...[
                  Builder(builder: (_) {
                    final stations = _groupStations(_services);
                    if (stations.isEmpty) return _buildEmptyCard();
                    return Column(
                      children: stations
                          .map((s) => _buildStationCard(context, s))
                          .toList(),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  Widget _buildLocationInfo(BuildContext context) {
    final hasLoc = _userPosition != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            hasLoc ? Icons.my_location : Icons.location_off,
            color: Colors.blueAccent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasLoc
                  ? 'Lokasi aktif • Menampilkan layanan terdekat (radius 10 km)'
                  : 'Lokasi belum aktif • Layanan tidak diurutkan berdasarkan jarak',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () async {
              final pos = await _tryGetUserLocation();
              setState(() => _userPosition = pos);
              await _fetchServices();
            },
            child: Text(hasLoc ? 'Refresh' : 'Aktifkan'),
          )
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: const TextStyle(fontSize: 13)),
          ),
          TextButton(
            onPressed: _fetchServices,
            child: const Text('Coba lagi'),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'Belumn ada layanan tersedia di sekitar Anda.',
        style: TextStyle(fontSize: 13),
      ),
    );
  }

  /// Group marketplace items menjadi 1 kartu per mitra (station).
  List<_StationVM> _groupStations(List<Map<String, dynamic>> items) {
    final Map<int, _StationVM> map = {};

    for (final it in items) {
      final partner = (it['partner'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};
      final pidRaw = it['partner_id'] ?? partner['id'];
      final pid = int.tryParse(pidRaw?.toString() ?? '') ?? 0;
      if (pid == 0) continue;

      final priceRaw = it['price'];
      final price = (priceRaw is num)
          ? priceRaw.toInt()
          : int.tryParse(priceRaw?.toString() ?? '') ?? 0;

      final distanceRaw = it['distance_km'];
      final distanceKm = (distanceRaw is num)
          ? distanceRaw.toDouble()
          : double.tryParse(distanceRaw?.toString() ?? '') ?? 0.0;

      final service = (it['service'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};
      final vt = (it['vehicle_type'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};

      final serviceName = service['name']?.toString();
      final vehicleTypeName = vt['name']?.toString();

      final vm = map.putIfAbsent(pid, () {
        final name = partner['business_name']?.toString() ??
            partner['name']?.toString() ??
            '-';
        final addr = partner['address']?.toString() ?? '-';
        return _StationVM(
          partnerId: pid,
          partner: partner,
          name: name,
          address: addr,
          minPrice: price == 0 ? 999999999 : price,
          distanceKm: distanceKm == 0 ? null : distanceKm,
          offers: [],
        );
      });

      vm.offers.add(Map<String, dynamic>.from(it));
      if (price > 0 && price < vm.minPrice) vm.minPrice = price;
      if (vm.distanceKm == null && distanceKm > 0) vm.distanceKm = distanceKm;

      if (serviceName != null && serviceName.isNotEmpty)
        vm.services.add(serviceName);
      if (vehicleTypeName != null && vehicleTypeName.isNotEmpty)
        vm.vehicleTypes.add(vehicleTypeName);
    }

    final list = map.values.toList();
    // Urutkan terdekat kalau ada
    list.sort((a, b) {
      final da = a.distanceKm ?? 1e18;
      final db = b.distanceKm ?? 1e18;
      return da.compareTo(db);
    });
    return list;
  }

  Widget _buildStationCard(BuildContext context, _StationVM station) {
    final distanceText = (station.distanceKm == null)
        ? null
        : '${station.distanceKm!.toStringAsFixed(1)} km';

    final vehicleLabel = station.vehicleTypes.isEmpty
        ? 'Tipe: -'
        : 'Tipe: ${station.vehicleTypes.take(2).join(', ')}${station.vehicleTypes.length > 2 ? '…' : ''}';

    final minPriceText =
        (station.minPrice == 999999999) ? '-' : station.minPrice.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              "assets/images/on1.png",
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: Colors.blueAccent, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        station.address,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _chip(vehicleLabel),
                    _chip('Mulai Rp $minPriceText'),
                    if (distanceText != null) _chip(distanceText),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Flow customer: Home -> Detail Service -> Booking
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailServicePage(
                    partner: station.partner,
                    offers: station.offers,
                  ),
                ),
              );
            },
            child: const Text("Book Now",
                style: TextStyle(color: Colors.blueAccent)),
          )
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _StationVM {
  final int partnerId;
  final Map<String, dynamic> partner;
  final String name;
  final String address;
  final List<Map<String, dynamic>> offers;

  double? distanceKm;
  int minPrice;

  final Set<String> vehicleTypes = {};
  final Set<String> services = {};

  _StationVM({
    required this.partnerId,
    required this.partner,
    required this.name,
    required this.address,
    required this.offers,
    required this.minPrice,
    required this.distanceKm,
  });
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/network/dio_client.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class DetailOrderPage extends StatefulWidget {
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

  /// String dari API (kadang "Latitude: x, Longitude: y")
  final String address;

  /// kalau ada alamat detail, isi. kalau kosong aman.
  final String detailAddress;

  final String plateNumber;
  final int total;

  /// ✅ untuk map + alamat
  final int partnerId;
  final double customerLatitude;
  final double customerLongitude;

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
    required this.partnerId,
    required this.customerLatitude,
    required this.customerLongitude,
    this.showDelete = true,
    this.fromOrderPage = false,
  });

  @override
  State<DetailOrderPage> createState() => _DetailOrderPageState();
}

class _DetailOrderPageState extends State<DetailOrderPage> {
  final Dio _dio = DioClient().dio;

  LatLng? _partnerLatLng;
  String? _resolvedCustomerAddress;

  bool _loadingPartner = false;
  bool _loadingAddress = false;

  LatLng get _customerLatLng =>
      LatLng(widget.customerLatitude, widget.customerLongitude);

  @override
  void initState() {
    super.initState();
    _loadPartnerLocation();
    _resolveCustomerAddressIfNeeded();
  }

  // =========================
  // 1) Reverse geocode alamat customer
  // =========================
  Future<void> _resolveCustomerAddressIfNeeded() async {
    // kalau address bukan koordinat, biarkan apa adanya
    final lower = widget.address.toLowerCase();
    final looksCoord =
        lower.contains('latitude') || lower.contains('longitude');
    if (!looksCoord) return;

    setState(() => _loadingAddress = true);
    try {
      final addr = await _reverseGeocode(
          _customerLatLng.latitude, _customerLatLng.longitude);
      if (!mounted) return;
      setState(() => _resolvedCustomerAddress = addr);
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  Future<String?> _reverseGeocode(double lat, double lon) async {
    // Nominatim butuh User-Agent
    final dio = Dio(
      BaseOptions(headers: {'User-Agent': 'CarWashGo/1.0 (reverse-geocode)'}),
    );

    final res = await dio.get(
      'https://nominatim.openstreetmap.org/reverse',
      queryParameters: {'format': 'jsonv2', 'lat': lat, 'lon': lon},
    );

    final data = res.data;
    if (data is Map && data['display_name'] is String) {
      final s = (data['display_name'] as String).trim();
      return s.isEmpty ? null : s;
    }
    return null;
  }

  // =========================
  // 2) Fetch koordinat mitra via partnerId (opsi 2)
  // =========================
  Future<void> _loadPartnerLocation() async {
    if (widget.partnerId <= 0) return;

    setState(() => _loadingPartner = true);
    try {
      // ✅ Pastikan backend route: GET /api/v1/partners/{id}/public
      final res = await _dio.get('/partners/${widget.partnerId}/public');

      final body = res.data;
      final data = (body is Map && body['data'] is Map)
          ? Map<String, dynamic>.from(body['data'])
          : <String, dynamic>{};

      final lat = _toDouble(data['latitude']);
      final lng = _toDouble(data['longitude']);

      if (lat != null && lng != null) {
        if (!mounted) return;
        setState(() => _partnerLatLng = LatLng(lat, lng));
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _loadingPartner = false);
    }
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

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
              _infoRow("Nama Pengguna", widget.username),
              _infoRow("Nomor Telepon", widget.phoneNumber),
              _infoRow("Booking ID", widget.bookingId),
              _infoRow("Tanggal", widget.date),
              _infoRow("Jam", widget.time),
              const SizedBox(height: 12),
              const Divider(),
              _infoRow("Jenis Mobil", widget.carType),
              _infoRow("Plat Nomor", widget.plateNumber),
              const SizedBox(height: 12),
              const Divider(),

              // ✅ alamat + map + jarak
              _addressCard(),

              const Divider(),
              _infoRow("Harga Mobil", "Rp ${widget.price}"),
              _infoRow("Harga Layanan", "Rp ${widget.servicePrice}"),
              _infoRow("Pajak", "Rp ${widget.tax}"),
              _infoRow("Diskon", "${widget.discount}%"),
              const Divider(),
              _infoRow("Total", "Rp ${widget.total}", bold: true, big: true),
              const SizedBox(height: 20),

              Row(
                children: [
                  if (widget.showDelete)
                    SizedBox(
                      height: 45,
                      width: 120,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red, width: 1.4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          "DELETE",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if (widget.showDelete) const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.fromOrderPage) {
                            Navigator.pop(context);
                            return;
                          }

                          final newOrder = Order(
                            mitraId: "mitra",
                            title: widget.username,
                            date: widget.date,
                            time: widget.time,
                            status: "Pesanan Baru",
                            image: "assets/images/on1.png",
                            location: widget.address,
                            detailAddress: widget.detailAddress,
                            plateNumber: widget.plateNumber,
                            username: widget.username,
                            phoneNumber: widget.phoneNumber,
                            bookingId: widget.bookingId,
                            carType: widget.carType,
                            price: widget.price,
                            servicePrice: widget.servicePrice,
                            tax: widget.tax,
                            discount: widget.discount,
                            total: widget.total,
                          );

                          orderProvider.addOrder(newOrder);

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => AlertDialog(
                              title: const Text('Pesanan dibuat'),
                              content: const Text(
                                  'Silahkan tunggu pesanan anda diterima oleh mitra!'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          "CONFIRM",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15),
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

  Widget _addressCard() {
    final customer = _customerLatLng;
    final partner = _partnerLatLng;

    // ✅ tampilkan alamat customer (bukan koordinat)
    final mainAddress = _resolvedCustomerAddress?.trim().isNotEmpty == true
        ? _resolvedCustomerAddress!.trim()
        : (widget.address.toLowerCase().contains('latitude')
            ? 'Alamat belum tersedia'
            : widget.address.trim());

    final detail = widget.detailAddress.trim();

    final double? distanceKm = (partner != null)
        ? const Distance().as(LengthUnit.Kilometer, customer, partner)
        : null;

    final center = (partner != null)
        ? LatLng(
            (customer.latitude + partner.latitude) / 2,
            (customer.longitude + partner.longitude) / 2,
          )
        : customer;

    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                          color: Colors.blueAccent),
                    ),
                    const SizedBox(height: 5),
                    if (_loadingAddress)
                      const Text('Mengambil alamat...',
                          style: TextStyle(color: Colors.black54))
                    else ...[
                      Text(mainAddress),
                      if (detail.isNotEmpty) Text(detail),
                    ],
                    const SizedBox(height: 8),
                    if (_loadingPartner)
                      const Text('Mengambil lokasi mitra...',
                          style: TextStyle(color: Colors.black54))
                    else if (distanceKm != null)
                      Text(
                        'Jarak ke mitra: ${distanceKm.toStringAsFixed(2)} km',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.black87),
                      )
                    else
                      const Text(
                        'Lokasi mitra belum tersedia untuk menghitung jarak.',
                        style: TextStyle(color: Colors.black54),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 190,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 13,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.drag |
                        InteractiveFlag.pinchZoom |
                        InteractiveFlag.doubleTapZoom,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'carwashgo',
                  ),
                  if (partner != null)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [customer, partner],
                          strokeWidth: 4,
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: customer,
                        width: 44,
                        height: 44,
                        child: const Icon(
                          Icons.person_pin_circle,
                          color: Colors.redAccent,
                          size: 40,
                        ),
                      ),
                      if (partner != null)
                        Marker(
                          point: partner,
                          width: 44,
                          height: 44,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.blueAccent,
                            size: 40,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

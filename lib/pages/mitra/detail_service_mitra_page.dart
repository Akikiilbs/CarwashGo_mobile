import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/network/dio_client.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class DetailServiceMitraPage extends StatefulWidget {
  final Order order;
  const DetailServiceMitraPage({super.key, required this.order});

  @override
  State<DetailServiceMitraPage> createState() => _DetailServiceMitraPageState();
}

class _DetailServiceMitraPageState extends State<DetailServiceMitraPage> {
  final Dio _dio = DioClient().dio;

  String? _resolvedCustomerAddress;
  bool _loadingAddress = false;

  LatLng? _mitraLatLng;
  bool _loadingMitra = false;

  // ========================
  // State untuk upload bukti pekerjaan
  // ========================
  File? _workProofFile;
  bool _isUpdatingStatus = false;

  LatLng? get _customerLatLng {
    final lat = widget.order.latitude;
    final lng = widget.order.longitude;
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  @override
  void initState() {
    super.initState();
    _resolveCustomerAddressIfNeeded();
    _loadMitraLocation();
  }

  // =========================
  // Reverse geocode alamat customer (biar bukan koordinat)
  // =========================
  Future<void> _resolveCustomerAddressIfNeeded() async {
    final c = _customerLatLng;
    if (c == null) return;

    final lower = widget.order.location.toLowerCase();
    final looksCoord =
        lower.contains('latitude') || lower.contains('longitude');
    if (!looksCoord && widget.order.location.trim().isNotEmpty) return;

    setState(() => _loadingAddress = true);
    try {
      final addr = await _reverseGeocode(c.latitude, c.longitude);
      if (!mounted) return;
      setState(() => _resolvedCustomerAddress = addr);
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  Future<String?> _reverseGeocode(double lat, double lon) async {
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
  // Ambil koordinat mitra dari endpoint mitra login
  // GET /api/v1/partner/profile
  // =========================
  Future<void> _loadMitraLocation() async {
    setState(() => _loadingMitra = true);
    try {
      final res = await _dio.get('/partner/profile');
      final body = res.data;

      final data = (body is Map && body['data'] is Map)
          ? Map<String, dynamic>.from(body['data'])
          : <String, dynamic>{};

      final lat = _toDouble(data['latitude']);
      final lng = _toDouble(data['longitude']);

      if (lat != null && lng != null) {
        if (!mounted) return;
        setState(() => _mitraLatLng = LatLng(lat, lng));
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _loadingMitra = false);
    }
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  // =========================
  // Pilih foto bukti pekerjaan dari galeri / kamera
  // =========================
  Future<void> _pickWorkProof(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _workProofFile = File(picked.path));
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pilih Sumber Foto',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.blueAccent),
              ),
              title: const Text('Ambil Foto (Kamera)'),
              onTap: () {
                Navigator.pop(ctx);
                _pickWorkProof(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.photo_library_rounded, color: Colors.blueAccent),
              ),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _pickWorkProof(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Detail Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _cardInfo(o),
            const SizedBox(height: 14),
            _cardUpdateStatus(o),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _labelPayment(String p) {
    final st = p.toLowerCase();
    if (st == 'paid' || st == 'settlement' || st == 'capture') {
      return 'Sudah Bayar';
    } else if (st == 'pending_verification') {
      return 'Menunggu Verifikasi Admin';
    }
    return 'Belum Bayar';
  }

  Widget _cardInfo(Order o) {
    final customer = _customerLatLng;
    final mitra = _mitraLatLng;

    final addressText = (_resolvedCustomerAddress?.trim().isNotEmpty == true)
        ? _resolvedCustomerAddress!.trim()
        : (o.location.toLowerCase().contains('latitude')
            ? 'Alamat belum tersedia'
            : o.location.trim());

    final distanceKm = (customer != null && mitra != null)
        ? const Distance().as(LengthUnit.Kilometer, customer, mitra)
        : null;

    final center = (customer != null && mitra != null)
        ? LatLng(
            (customer.latitude + mitra.latitude) / 2,
            (customer.longitude + mitra.longitude) / 2,
          )
        : (customer ?? const LatLng(-6.200000, 106.816666));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =========================
          // HEADER : CUSTOMER INFO
          // =========================
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withOpacity(0.1),
                ),
                clipBehavior: Clip.hardEdge,
                child: (o.profilePicture != null && o.profilePicture!.isNotEmpty)
                    ? Image.network(
                        o.profilePicture!,
                        fit: BoxFit.cover,
                        headers: const {'ngrok-skip-browser-warning': 'true'},
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, color: Colors.blueAccent),
                      )
                    : const Icon(Icons.person, color: Colors.blueAccent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  o.title, // nama customer
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.phone, color: Colors.black54, size: 18),
              const SizedBox(width: 8),
              Text(o.phoneNumber.isEmpty ? 'Tidak ada telepon' : o.phoneNumber, style: const TextStyle(fontSize: 15, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),

          // =========================
          // SEMUA DATA ORDER
          // =========================
          _infoRow("Booking ID", o.bookingId),
          _infoRow("Jadwal", "${o.date} ${o.time}"),
          _infoRow("Layanan / Tipe Mobil", o.carType.isEmpty ? "-" : o.carType),
          _infoRow("Plat", o.plateNumber.isEmpty ? "-" : o.plateNumber),
          if (o.notes.trim().isNotEmpty)
             _infoRow("Catatan Khusus", o.notes),
          _infoRow("Status", _labelStatus(o.status)),
          _infoRow("Pembayaran", _labelPayment(o.paymentStatus)),
          const SizedBox(height: 10),
          const Divider(),

          _infoRow("Harga Layanan", "Rp ${o.servicePrice}"),
          _infoRow("Pajak", "Rp ${o.tax}"),
          _infoRow("Diskon", "${o.discount}%"),
          const Divider(),
          _infoRow("Total", "Rp ${o.total}", bold: true),

          const SizedBox(height: 14),

          // =========================
          // ALAMAT + MAP + JARAK
          // =========================
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Alamat Lengkap",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                if (_loadingAddress)
                  const Text(
                    'Mengambil alamat...',
                    style: TextStyle(color: Colors.white70),
                  )
                else ...[
                  Text(addressText, style: const TextStyle(color: Colors.white)),
                  if (o.detailAddress.trim().isNotEmpty)
                    Text(o.detailAddress.trim(), style: const TextStyle(color: Colors.white70)),
                ],
                if (_loadingMitra)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Mengambil lokasi mitra...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                else if (distanceKm != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Jarak ke lokasi mitra: ${distanceKm.toStringAsFixed(2)} km',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                    ),
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
                        if (customer != null && mitra != null)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [customer, mitra],
                                strokeWidth: 4,
                                color: Colors.blueAccent,
                              ),
                            ],
                          ),
                        MarkerLayer(
                          markers: [
                            if (customer != null)
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
                            if (mitra != null)
                              Marker(
                                point: mitra,
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
          ),

          // =========================
          // CARD BUKTI PEKERJAAN (tampil jika work_proof tersedia)
          // =========================
          if (o.workProof != null && o.workProof!.isNotEmpty) ...[
            const SizedBox(height: 14),
            _cardWorkProofDisplay(o.workProof!),
          ],
        ],
      ),
    );
  }

  /// Card tampilan bukti pekerjaan yang sudah diupload
  Widget _cardWorkProofDisplay(String workProofUrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FFF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.check_circle_rounded, color: Colors.green.shade700, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Bukti Pekerjaan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              workProofUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              headers: const {'ngrok-skip-browser-warning': 'true'},
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey.shade100,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.blueAccent,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                height: 120,
                color: Colors.grey.shade100,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image_rounded, color: Colors.grey, size: 40),
                      SizedBox(height: 6),
                      Text('Gagal memuat gambar', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Foto bukti pekerjaan telah diunggah oleh mitra.',
            style: TextStyle(color: Colors.green.shade700, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _cardUpdateStatus(Order o) {
    if (o.status == 'pending' ||
        o.status == 'rejected' ||
        o.status == 'cancelled') {
      return const SizedBox.shrink();
    }

    final List<Map<String, String>> steps = [
      {'status': 'accepted', 'label': 'Diterima'},
      {'status': 'on_the_way', 'label': 'Menuju'},
      {'status': 'in_progress', 'label': 'Proses'},
      {'status': 'completed', 'label': 'Selesai'},
    ];

    int currentIndex = steps.indexWhere((s) => s['status'] == o.status);
    if (currentIndex == -1) currentIndex = 0;

    // Apakah status berikutnya adalah 'completed'?
    final nextStatus = currentIndex < steps.length - 1
        ? steps[currentIndex + 1]['status']!
        : null;
    final nextIsCompleted = nextStatus == 'completed';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Update Status',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          // ========================
          // STEPPER PROGRESS BAR
          // ========================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index % 2 == 1) {
                // Line
                final stepIndex = index ~/ 2;
                final isCompletedLine = currentIndex > stepIndex;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 14),
                    height: 3,
                    color: isCompletedLine
                        ? Colors.blueAccent
                        : Colors.grey.shade300,
                  ),
                );
              } else {
                // Circle Node
                final stepIndex = index ~/ 2;
                final step = steps[stepIndex];
                final isCompleted = currentIndex >= stepIndex;
                final isCurrent = currentIndex == stepIndex;
                final canTap = _canUpdateStatus(o, step['status']!);

                return GestureDetector(
                  onTap: canTap ? () => _handleUpdateStatus(o, step['status']!) : null,
                  child: Column(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? Colors.blueAccent
                              : Colors.grey.shade300,
                          border: isCurrent
                              ? Border.all(
                                  color: Colors.blue.shade100, width: 4)
                              : null,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check,
                                  size: 16, color: Colors.white)
                              : Text('${stepIndex + 1}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        step['label']!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isCompleted || isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isCompleted
                              ? Colors.blueAccent
                              : (canTap ? Colors.black87 : Colors.grey),
                        ),
                      ),
                    ],
                  ),
                );
              }
            }),
          ),
          const SizedBox(height: 24),

          // ========================
          // FORM UPLOAD BUKTI PEKERJAAN (hanya muncul jika next = completed)
          // ========================
          if (nextIsCompleted && _canUpdateStatus(o, 'completed')) ...[
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.camera_alt_rounded, color: Colors.orange.shade700, size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Bukti Pekerjaan',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        'Wajib diunggah untuk menyelesaikan pesanan',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Area preview / picker foto
            GestureDetector(
              onTap: _isUpdatingStatus ? null : _showPickerOptions,
              child: Container(
                width: double.infinity,
                height: _workProofFile != null ? null : 140,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _workProofFile != null
                        ? Colors.blueAccent
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: _workProofFile != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Image.file(
                              _workProofFile!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Tombol ganti foto
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: _isUpdatingStatus ? null : _showPickerOptions,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text('Ganti',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_rounded,
                              size: 38,
                              color: Colors.blueAccent.withOpacity(0.5)),
                          const SizedBox(height: 10),
                          const Text(
                            'Tap untuk ambil / pilih foto',
                            style: TextStyle(color: Colors.black54, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Format: JPG, PNG • Maks 5MB',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 11),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ========================
          // TOMBOL AKSI
          // ========================
          if (o.status == 'completed')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Pesanan Telah Selesai',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700),
                  ),
                ],
              ),
            )
          else if (currentIndex < steps.length - 1 &&
              _canUpdateStatus(o, steps[currentIndex + 1]['status']!))
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isUpdatingStatus
                    ? null
                    : () => _handleUpdateStatus(
                        o, steps[currentIndex + 1]['status']!),
                child: _isUpdatingStatus
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        'Update ke ${steps[currentIndex + 1]['label']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
              ),
            )
          else if (currentIndex < steps.length - 1)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.grey.shade700,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: null,
                child: const Text('Menunggu Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  bool _isPaid(String paymentStatus) {
    final st = paymentStatus.toLowerCase();
    return st == 'paid' || st == 'settlement' || st == 'capture';
  }

  bool _isFinalStatus(String status) {
    final st = status.toLowerCase();
    return st == 'completed' || st == 'rejected' || st == 'cancelled';
  }

  bool _canUpdateStatus(Order o, String targetStatus) {
    if (_isFinalStatus(o.status)) return false;
    if (o.status == targetStatus) return false;

    final paid = _isPaid(o.paymentStatus);
    if (targetStatus == 'accepted') return true;
    if (!paid) return false;

    return true;
  }

  /// Handler utama untuk update status — menginterject form bukti pekerjaan jika diperlukan
  Future<void> _handleUpdateStatus(Order o, String status) async {
    // Jika target status adalah 'completed', wajib ada foto bukti pekerjaan
    if (status == 'completed' && _workProofFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Harap upload foto bukti pekerjaan terlebih dahulu sebelum menyelesaikan pesanan.',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    await _doUpdateStatus(o, status, workProofFilePath: _workProofFile?.path);
  }

  Future<void> _doUpdateStatus(Order o, String status,
      {String? workProofFilePath}) async {
    final orderId = int.tryParse(o.bookingId) ?? 0;
    if (orderId == 0) return;

    setState(() => _isUpdatingStatus = true);

    try {
      final prov = context.read<OrderProvider>();
      final res = await prov.partnerUpdateStatus(
        orderId: orderId,
        status: status,
        workProofFilePath: workProofFilePath,
      );

      if (!mounted) return;

      if (res.status == 'success' || res.status == 'ok') {
        // Bersihkan state file setelah berhasil
        setState(() => _workProofFile = null);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Text('Status berhasil diperbarui!'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message)),
        );
      }

      await prov.loadPartnerOrders();
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  String _labelStatus(String s) {
    switch (s) {
      case 'pending':
        return 'Menunggu';
      case 'accepted':
        return 'Diterima';
      case 'on_the_way':
        return 'Menuju Lokasi';
      case 'in_progress':
        return 'Dalam Pengerjaan';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return s;
    }
  }
}

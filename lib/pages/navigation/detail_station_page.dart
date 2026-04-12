import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/network/dio_client.dart';
import '../booking/booking_page.dart';

class DetailStationPage extends StatefulWidget {
  final String id;
  final String image;
  final String name;
  final String location;
  final double rating;

  final String? description;
  final String? operationalHours;
  final String? price;
  final String? operationalDays;

  final bool isEditable; // user = false, mitra = true

  const DetailStationPage({
    super.key,
    required this.id,
    required this.image,
    required this.name,
    required this.location,
    required this.rating,
    this.description,
    this.operationalHours,
    this.price,
    this.operationalDays,
    this.isEditable = false,
  });

  @override
  State<DetailStationPage> createState() => _DetailStationPageState();
}

class _DetailStationPageState extends State<DetailStationPage> {
  late TextEditingController _alamatController;
  late TextEditingController _descController;
  late TextEditingController _jamController;
  late TextEditingController _hargaController;
  late TextEditingController _hariController;

  bool _loading = true;
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    _alamatController = TextEditingController(text: widget.location);
    _descController = TextEditingController(text: widget.description ?? "");
    _jamController = TextEditingController(text: _formatHours(widget.operationalHours));
    _hargaController = TextEditingController(text: widget.price ?? "");
    _hariController = TextEditingController(text: _formatDays(widget.operationalDays));
    _fetchLatestData();
  }

  Future<void> _fetchLatestData() async {
    try {
      final dio = DioClient().dio;
      final res = await dio.get('/marketplace/partners', queryParameters: {'partner_id': widget.id});
      if (res.statusCode == 200 && mounted) {
        final List data = res.data['data'] ?? [];
        if (data.isNotEmpty) {
          final p = data[0];
          setState(() {
            _descController.text = p['description']?.toString() ?? _descController.text;
            _jamController.text = _formatHours(p['jamOperasional']?.toString() ?? p['operating_hours']?.toString());
            _hariController.text = _formatDays(p['hariOperasional']?.toString() ?? p['operating_days']?.toString());
            // Update harga if min price is found
            final harga = p['harga']?.toString();
            if (harga != null) _hargaController.text = "Mulai dari Rp $harga";
            _loading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("❌ DetailStation Error: $e");
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatHours(String? raw) {
    if (raw == null || raw.isEmpty) return "08.00 - 17.00";
    final slots = raw.split(',').map((e) => e.trim()).toList();
    if (slots.length < 2) return slots.first;
    slots.sort();
    return "${slots.first} - ${slots.last}";
  }

  String _formatDays(String? raw) {
    if (raw == null || raw.isEmpty) return "Senin - Minggu";
    final days = raw.split(',').map((e) => e.trim()).toList();
    if (days.length == 7) return "Setiap Hari";
    if (days.length < 2) return days.first;
    return days.join(', ');
  }

  @override
  void dispose() {
    _alamatController.dispose();
    _descController.dispose();
    _jamController.dispose();
    _hargaController.dispose();
    _hariController.dispose();
    super.dispose();
  }

  Future<void> _pickBannerImage() async {
    if (!widget.isEditable) return;

    final result = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (result != null && mounted) {
      setState(() {
        _pickedImage = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBannerSection(),
                  const SizedBox(height: 18),
                  _buildTitleSection(),
                  const SizedBox(height: 18),
                  _buildAlamatSection(),
                  const SizedBox(height: 18),
                  _buildDescriptionSection(),
                  const SizedBox(height: 18),
                  _buildJamSection(),
                  const SizedBox(height: 18),
                  _buildHargaSection(),
                  const SizedBox(height: 18),
                  _buildHariSection(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 5,
            ),
            onPressed: () {
              if (widget.isEditable) {
                Navigator.pop(context, {
                  "alamat": _alamatController.text.trim(),
                  "description": _descController.text.trim(),
                  "operationalHours": _jamController.text.trim(),
                  "price": _hargaController.text.trim(),
                  "operationalDays": _hariController.text.trim(),
                });
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookingPage(partnerId: widget.id)),
                );
              }
            },
            child: Text(
              widget.isEditable ? "Simpan" : "Book Now",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _pickedImage != null
              ? Image.file(
                  File(_pickedImage!.path),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : widget.image.startsWith('http')
                  ? Image.network(
                      widget.image,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, color: Colors.grey, size: 50),
                      ),
                    )
                  : Image.asset(
                      widget.image,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, color: Colors.grey, size: 50),
                      ),
                    ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        if (widget.isEditable)
          Positioned(
            bottom: 10,
            right: 10,
            child: GestureDetector(
              onTap: _pickBannerImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.blueAccent, size: 22),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.blueAccent,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                widget.rating.toStringAsFixed(1),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlamatSection() {
    return _infoSection("Alamat Usaha", _alamatController, widget.isEditable, Icons.location_on);
  }

  Widget _buildDescriptionSection() {
    return _infoSection("Deskripsi", _descController, widget.isEditable, Icons.description, maxLines: 4);
  }

  Widget _buildJamSection() {
    return _infoSection("Jam Operasional", _jamController, widget.isEditable, Icons.access_time);
  }

  Widget _buildHargaSection() {
    return _infoSection("Harga", _hargaController, widget.isEditable, Icons.payments);
  }

  Widget _buildHariSection() {
    return _infoSection("Hari Operasional", _hariController, widget.isEditable, Icons.calendar_today);
  }

  Widget _infoSection(String title, TextEditingController controller, bool editable, IconData icon, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.blueAccent)),
        const SizedBox(height: 8),
        if (editable)
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF7F9FC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E6F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent)),
            ),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.grey, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.text,
                  style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

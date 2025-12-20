import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../booking/booking_page.dart';

class DetailStationPage extends StatefulWidget {
  final String image;
  final String name;
  final String location; // akan kita pakai sebagai alamat
  final double rating;

  final String? description;
  final String? operationalHours;   // jam operasional
  final String? price;              // harga
  final String? operationalDays;    // hari operasional

  final bool isEditable; // user = false, mitra = true

  const DetailStationPage({
    super.key,
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

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  static const String _defaultDescription =
      "We work dedicatedly towards spreading awareness among car users "
      "about their car hygiene habits, durability of exterior look, "
      "and other cleaning tips. We ensure the best quality wash "
      "service with professional equipment.";

  @override
  void initState() {
    super.initState();
    _alamatController = TextEditingController(text: widget.location);
    _descController = TextEditingController(
      text: widget.description ?? _defaultDescription,
    );
    _jamController = TextEditingController(
      text: widget.operationalHours ?? "",
    );
    _hargaController = TextEditingController(
      text: widget.price ?? "",
    );
    _hariController = TextEditingController(
      text: widget.operationalDays ?? "",
    );
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

    if (result != null) {
      setState(() {
        _pickedImage = result;
      });

      // TODO: simpan ke backend / storage kalau sudah ada API
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

      // tombol di bawah layar
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
              shadowColor: Colors.blueAccent.withOpacity(0.3),
              elevation: 5,
            ),
            onPressed: () {
              if (widget.isEditable) {
                // ✅ KEMBALIKAN SEMUA DATA KE PROFIL MITRA
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
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 650),
                    pageBuilder: (_, __, ___) => const BookingPage(),
                    transitionsBuilder: (_, animation, __, child) {
                      final slide = Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      );

                      final fade = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeIn,
                      );

                      return SlideTransition(
                        position: slide,
                        child: FadeTransition(
                          opacity: fade,
                          child: child,
                        ),
                      );
                    },
                  ),
                );
              }
            },
            child: Text(
              widget.isEditable ? "Simpan" : "Book Now",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.8,
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
              : Image.asset(
                  widget.image,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
        ),

        // tombol back
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),

        // tombol kamera untuk mitra
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.blueAccent,
                  size: 22,
                ),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlamatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Alamat Usaha",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.isEditable)
          TextField(
            controller: _alamatController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: "Tulis alamat lengkap...",
              filled: true,
              fillColor: const Color(0xFFF7F9FC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E6F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blueAccent),
              ),
            ),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Colors.grey, size: 18),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _alamatController.text.isEmpty
                      ? "Belum diisi"
                      : _alamatController.text,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Description",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.isEditable)
          TextField(
            controller: _descController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Tulis deskripsi usaha...",
              filled: true,
              fillColor: const Color(0xFFF7F9FC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E6F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blueAccent),
              ),
            ),
          )
        else
          Text(
            _descController.text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
      ],
    );
  }

  Widget _buildJamSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Jam Operasional",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.isEditable)
          TextField(
            controller: _jamController,
            decoration: InputDecoration(
              hintText: "Contoh: 08.00 - 17.00",
              filled: true,
              fillColor: const Color(0xFFF7F9FC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E6F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blueAccent),
              ),
            ),
          )
        else
          Text(
            _jamController.text.isEmpty
                ? "Belum diisi"
                : _jamController.text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
      ],
    );
  }

  Widget _buildHargaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Harga",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.isEditable)
          TextField(
            controller: _hargaController,
            decoration: InputDecoration(
              hintText: "Contoh: Mulai dari Rp 50.000",
              filled: true,
              fillColor: const Color(0xFFF7F9FC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E6F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blueAccent),
              ),
            ),
          )
        else
          Text(
            _hargaController.text.isEmpty
                ? "Belum diisi"
                : _hargaController.text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
      ],
    );
  }

  Widget _buildHariSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Hari Operasional",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.isEditable)
          TextField(
            controller: _hariController,
            decoration: InputDecoration(
              hintText: "Contoh: Senin - Minggu",
              filled: true,
              fillColor: const Color(0xFFF7F9FC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E6F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blueAccent),
              ),
            ),
          )
        else
          Text(
            _hariController.text.isEmpty
                ? "Belum diisi"
                : _hariController.text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
      ],
    );
  }
}

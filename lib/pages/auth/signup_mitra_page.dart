import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../providers/mitra_provider.dart';
import 'package:carwashgo/features/auth/data/auth_api.dart';
import 'package:carwashgo/features/auth/models/auth_response.dart';

class SignupMitraPage extends StatefulWidget {
  const SignupMitraPage({super.key});

  @override
  State<SignupMitraPage> createState() => _SignupMitraPageState();
}

class _SignupMitraPageState extends State<SignupMitraPage> {
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isObscure = true;
  bool _isObscureConfirm = true;
  bool _isLoading = false;
  bool _isGettingLocation = false;
  bool _isResolvingAddress = false;
  String? _errorMessage;

  final _authApi = AuthApi();
  final _picker = ImagePicker();

  // Foto outlet
  XFile? _outletPhotoFile;
  Uint8List? _outletPhotoBytes;

  // Lokasi
  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _goBackToLogin() {
    Navigator.pushReplacementNamed(context, '/login-mitra');
  }

  Future<void> _pickOutletPhoto() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (file == null) return;

      final bytes = await file.readAsBytes();

      if (!mounted) return;
      setState(() {
        _outletPhotoFile = file;
        _outletPhotoBytes = bytes;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memilih foto.")),
      );
    }
  }

  Future<Position> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw "Layanan lokasi (GPS) belum aktif.";
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw "Izin lokasi ditolak.";
    }

    if (permission == LocationPermission.deniedForever) {
      throw "Izin lokasi ditolak permanen. Aktifkan dari pengaturan.";
    }

    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<String?> _reverseGeocode(double lat, double lng) async {
    // Pakai Nominatim (OpenStreetMap) untuk reverse geocode.
    // Kalau jaringan/error -> return null, nanti alamat tetap bisa diisi manual.
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: const {
            // Nominatim minta user-agent (minimal).
            'User-Agent': 'CarWashGo/1.0 (contact: dev)',
            'Accept': 'application/json',
          },
        ),
      );

      final res = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'jsonv2',
          'lat': lat,
          'lon': lng,
          'zoom': 18,
          'addressdetails': 1,
        },
      );

      if (res.data is Map && res.data['display_name'] != null) {
        return res.data['display_name'].toString();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _applyPickedLocation({
    required double lat,
    required double lng,
    bool showToast = true,
  }) async {
    if (!mounted) return;

    setState(() {
      _latitude = lat;
      _longitude = lng;
      _isResolvingAddress = true;
    });

    final address = await _reverseGeocode(lat, lng);

    if (!mounted) return;
    setState(() => _isResolvingAddress = false);

    if (address != null && address.trim().isNotEmpty) {
      _addressController.text = address;
      if (showToast) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Alamat terisi otomatis dari lokasi.")),
        );
      }
    } else {
      if (showToast) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Lokasi berhasil diambil. Alamat tidak bisa diisi otomatis (silakan isi manual).",
            ),
          ),
        );
      }
    }
  }

  Future<void> _useCurrentLocationAndFillAddress() async {
    setState(() => _isGettingLocation = true);
    try {
      final pos = await _getCurrentPosition();
      await _applyPickedLocation(lat: pos.latitude, lng: pos.longitude);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _openMapPicker() async {
    final initial = (_latitude != null && _longitude != null)
        ? LatLng(_latitude!, _longitude!)
        : const LatLng(1.1324, 104.0530); // Default: Batam (aman untuk awal)

    final picked = await showModalBottomSheet<LatLng>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _MapPickerSheet(
        initial: initial,
        onUseCurrent: _getCurrentPosition,
      ),
    );

    if (picked == null) return;
    await _applyPickedLocation(lat: picked.latitude, lng: picked.longitude);
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final businessName = _businessNameController.text.trim();
    final address = _addressController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty ||
        businessName.isEmpty ||
        address.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap lengkapi semua kolom")),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi password tidak sama.")),
      );
      return;
    }

    if (_outletPhotoBytes == null || _outletPhotoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap upload foto outlet.")),
      );
      return;
    }

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Harap pilih lokasi outlet (map / lokasi saat ini).")),
      );
      return;
    }

    // (Opsional) simpan data awal ke provider
    context.read<MitraProvider>().setMitra(
          nama: name,
          email: email,
          phone: phone,
          alamat: address,
          jamOperasional: "",
          deskripsi: "",
          hariOperasional: "",
          harga: "",
        );

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    AuthResponse res;

    try {
      res = await _authApi.registerPartner(
        name: name,
        email: email,
        phone: phone,
        password: password,
        businessName: businessName,
        address: address,
        latitude: _latitude!,
        longitude: _longitude!,
        outletPhotoBytes: _outletPhotoBytes!,
        outletPhotoFilename: _outletPhotoFile!.name,
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }

    if (!mounted) return;

    if (res.status == 'success') {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Registrasi berhasil"),
          content: const Text(
            "Registrasi berhasil, silahkan tunggu akun disetujui oleh admin.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );

      Navigator.pushReplacementNamed(context, '/login-mitra');
    } else {
      String msg = res.message;

      if (res.errors != null && res.errors!.isNotEmpty) {
        final firstKey = res.errors!.keys.first;
        final firstVal = res.errors![firstKey];
        if (firstVal is List && firstVal.isNotEmpty) {
          msg = firstVal.first.toString();
        } else if (firstVal is String) {
          msg = firstVal;
        }
      }

      setState(() => _errorMessage = msg);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation = _latitude != null && _longitude != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Mitra"),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: _goBackToLogin,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (_errorMessage != null) ...[
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
              ],

              // ================= FOTO OUTLET =================
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Foto Outlet",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickOutletPhoto,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade200,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _outletPhotoBytes != null
                            ? Image.memory(_outletPhotoBytes!,
                                fit: BoxFit.cover)
                            : const Icon(Icons.image_outlined, size: 30),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _outletPhotoFile != null
                              ? _outletPhotoFile!.name
                              : "Tap untuk pilih foto outlet",
                        ),
                      ),
                      const Icon(Icons.upload_file),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ================= NAMA PEMILIK =================
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Nama Pemilik Usaha",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),

              // ================= NAMA USAHA =================
              TextField(
                controller: _businessNameController,
                decoration: InputDecoration(
                  labelText: "Nama Usaha",
                  prefixIcon: const Icon(Icons.store_mall_directory_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),

              // ================= ALAMAT + LOKASI (DIGABUNG) =================
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Alamat Outlet",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Alamat Usaha",
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  hintText: "Pilih lokasi dari map / gunakan lokasi saat ini",
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: "Gunakan lokasi saat ini",
                          onPressed: _isGettingLocation
                              ? null
                              : _useCurrentLocationAndFillAddress,
                          icon: _isGettingLocation
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.my_location),
                        ),
                        IconButton(
                          tooltip: "Pilih lewat map",
                          onPressed: _openMapPicker,
                          icon: const Icon(Icons.map_outlined),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      hasLocation
                          ? "Koordinat: $_latitude, $_longitude"
                          : "Koordinat: belum dipilih",
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                  if (_isResolvingAddress)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // ================= EMAIL =================
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // ================= NOMOR HP =================
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Nomor HP",
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),

              // ================= PASSWORD =================
              TextField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: "Kata Sandi",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),

              // ================= KONFIRMASI PASSWORD =================
              TextField(
                controller: _confirmController,
                obscureText: _isObscureConfirm,
                decoration: InputDecoration(
                  labelText: "Konfirmasi Kata Sandi",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscureConfirm
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _isObscureConfirm = !_isObscureConfirm),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),

              const SizedBox(height: 20),

              // ================= BUTTON DAFTAR =================
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "DAFTAR",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              TextButton(
                onPressed: _goBackToLogin,
                child: const Text("Sudah punya akun? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet map picker (flutter_map).
class _MapPickerSheet extends StatefulWidget {
  final LatLng initial;
  final Future<Position> Function() onUseCurrent;

  const _MapPickerSheet({
    required this.initial,
    required this.onUseCurrent,
  });

  @override
  State<_MapPickerSheet> createState() => _MapPickerSheetState();
}

class _MapPickerSheetState extends State<_MapPickerSheet> {
  late LatLng _selected;
  final _mapController = MapController();

  bool _locLoading = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  Future<void> _useCurrent() async {
    setState(() => _locLoading = true);
    try {
      final pos = await widget.onUseCurrent();
      final latlng = LatLng(pos.latitude, pos.longitude);
      setState(() => _selected = latlng);
      _mapController.move(latlng, 17);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (!mounted) return;
      setState(() => _locLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return SizedBox(
      height: height * 0.85,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Pilih Lokasi Outlet",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selected,
                initialZoom: 15,
                onTap: (tapPos, latLng) => setState(() => _selected = latLng),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.carwashgo.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selected,
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.location_on,
                          size: 42, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _locLoading ? null : _useCurrent,
                        icon: _locLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location),
                        label: const Text("Gunakan lokasi saat ini"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context, _selected),
                        icon: const Icon(Icons.check),
                        label: const Text("Pilih lokasi"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Koordinat terpilih: ${_selected.latitude.toStringAsFixed(6)}, ${_selected.longitude.toStringAsFixed(6)}",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../providers/user_provider.dart';
import 'package:carwashgo/features/auth/data/auth_api.dart';
import 'package:carwashgo/features/auth/models/auth_response.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController(); // ✅ dipakai di UI
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isObscure = true;
  bool _isObscureConfirm = true;

  bool _isLoading = false;
  bool _isGettingLocation = false;
  bool _isResolvingAddress = false;
  String? _errorMessage;

  // (Optional) simpan koordinat customer untuk isi alamat otomatis
  double? _latitude;
  double? _longitude;

  final _authApi = AuthApi();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
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
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: const {
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

  Future<void> _applyPickedLocation(double lat, double lng) async {
    if (!mounted) return;

    setState(() {
      _latitude = lat;
      _longitude = lng;
      _isResolvingAddress = true;
    });

    final addr = await _reverseGeocode(lat, lng);

    if (!mounted) return;
    setState(() => _isResolvingAddress = false);

    if (addr != null && addr.trim().isNotEmpty) {
      _addressController.text = addr;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alamat terisi otomatis dari lokasi.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Lokasi berhasil diambil. Alamat tidak bisa diisi otomatis (isi manual)."),
        ),
      );
    }
  }

  Future<void> _useCurrentLocationAndFillAddress() async {
    setState(() => _isGettingLocation = true);
    try {
      final pos = await _getCurrentPosition();
      await _applyPickedLocation(pos.latitude, pos.longitude);
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
        : const LatLng(1.1324, 104.0530);

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
    await _applyPickedLocation(picked.latitude, picked.longitude);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final password = _passwordController.text;
    final passwordConfirmation = _confirmController.text;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    AuthResponse res;

    try {
      res = await _authApi.register(
        name: name,
        email: email,
        phone: phone,
        address: address, // ✅ wajib dikirim
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }

    if (!mounted) return;

    if (res.status == 'success') {
      final userProv = Provider.of<UserProvider>(context, listen: false);

      // ✅ set user + address
      if (res.user != null) {
        userProv.setUser(
          id: res.user!.id,
          name: res.user!.name,
          email: res.user!.email,
          phone: res.user!.phone,
          role: res.user!.role,
          address: address,
        );
      } else {
        userProv.setUser(
          name: name,
          email: email,
          phone: phone,
          role: 'customer',
          address: address,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res.message.isNotEmpty
                ? res.message
                : 'Akun berhasil dibuat! Silakan login.',
          ),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          "Daftar Akun",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    "Buat Akun Baru",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                const SizedBox(height: 20),

                Text("Nama Lengkap", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: "Masukkan nama lengkap",
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? "Masukkan nama lengkap"
                      : null,
                ),

                const SizedBox(height: 20),

                Text("Nomor Telepon", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.phone_iphone),
                    hintText: "Masukkan nomor telepon",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Masukkan nomor telepon";
                    }
                    if (value.length < 9) return "Nomor tidak valid";
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ✅ ALAMAT + LOKASI (DIGABUNG)
                Text("Alamat ", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  keyboardType: TextInputType.streetAddress,
                  maxLines: 2,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on_outlined),
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
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Masukkan alamat";
                    }
                    if (value.trim().length < 6) {
                      return "Alamat terlalu singkat";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hasLocation
                            ? "Koordinat (opsional): ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}"
                            : "Koordinat (opsional): belum dipilih",
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
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

                const SizedBox(height: 20),

                Text("Alamat Email", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined),
                    hintText: "Masukkan email",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Masukkan email";
                    if (!value.contains("@")) return "Format email tidak valid";
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                Text("Kata Sandi", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    hintText: "Masukkan kata sandi",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _isObscure = !_isObscure),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return "Minimal 6 karakter";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                Text("Konfirmasi Kata Sandi", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _isObscureConfirm,
                  decoration: InputDecoration(
                    hintText: "Konfirmasi kata sandi",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscureConfirm
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(
                          () => _isObscureConfirm = !_isObscureConfirm),
                    ),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return "Password tidak sama";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
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
                        : const Text("DAFTAR"),
                  ),
                ),

                const SizedBox(height: 20),

                // LINK LOGIN
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Sudah punya akun? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      child: Text(
                        "Masuk",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
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
            "Pilih Lokasi",
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
                        label: const Text("Lokasi saat ini"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context, _selected),
                        icon: const Icon(Icons.check),
                        label: const Text("Pilih"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Koordinat: ${_selected.latitude.toStringAsFixed(6)}, ${_selected.longitude.toStringAsFixed(6)}",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

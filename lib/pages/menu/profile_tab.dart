import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'package:carwashgo/features/auth/data/auth_api.dart';
import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  File? _selectedImage;
  Uint8List? _webImage;

  bool _loadingMe = false;
  bool _uploadingPhoto = false;

  final _authApi = AuthApi();

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  // =======================
  // FOTO PROFIL (preview lokal -> URL server -> fallback icon)
  // =======================
  Widget _avatar(UserProvider user) {
    // preview lokal
    if (kIsWeb && _webImage != null) {
      return ClipOval(
        child: Image.memory(_webImage!,
            width: 104, height: 104, fit: BoxFit.cover),
      );
    }
    if (!kIsWeb && _selectedImage != null) {
      return ClipOval(
        child: Image.file(_selectedImage!,
            width: 104, height: 104, fit: BoxFit.cover),
      );
    }

    final url = user.profilePhotoUrl.trim();
    if (url.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url,
          key: ValueKey(url), // ✅ biar refresh kalau url berubah
          width: 104,
          height: 104,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackAvatar(),
        ),
      );
    }

    return _fallbackAvatar();
  }

  Widget _fallbackAvatar() {
    return CircleAvatar(
      radius: 52,
      backgroundColor: Colors.blueAccent.withOpacity(0.15),
      child: const Icon(Icons.person, size: 56, color: Colors.blueAccent),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: kIsWeb,
    );
    if (result == null) return;

    setState(() => _uploadingPhoto = true);

    try {
      if (kIsWeb) {
        final bytes = result.files.first.bytes;
        if (bytes == null) return;

        // preview dulu
        setState(() => _webImage = bytes);

        // upload
        final res = await _authApi.uploadProfilePhoto(
          bytes: bytes,
          filename: result.files.first.name,
        );

        if (!mounted) return;
        if (res.status == 'success') {
          await _loadMe();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil diperbarui')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res.message)),
          );
        }
      } else {
        final path = result.files.first.path;
        if (path == null) return;

        final f = File(path);

        // preview dulu
        setState(() => _selectedImage = f);

        // upload
        final res = await _authApi.uploadProfilePhoto(
          file: f,
          filename: result.files.first.name,
        );

        if (!mounted) return;
        if (res.status == 'success') {
          await _loadMe();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil diperbarui')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res.message)),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  // =======================
  // LOAD /auth/me
  // =======================
  Future<void> _loadMe() async {
    setState(() => _loadingMe = true);

    final res = await _authApi.fetchMe();
    if (!mounted) return;

    setState(() => _loadingMe = false);

    if (!res.isSuccess || res.user == null) return;

    final u = res.user!;
    context.read<UserProvider>().setUser(
          id: u.id,
          name: u.name,
          email: u.email,
          phone: u.phone,
          role: u.role,
          address: u.address,
          profilePhotoUrl: u.profilePhotoUrl,
        );
  }

  // =======================
  // Ambil alamat dari lokasi saat ini
  // =======================
  Future<String?> _getAddressFromCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('GPS belum aktif. Silakan aktifkan lokasi.')),
        );
        return null;
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (!mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin lokasi ditolak.')),
        );
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // reverse geocode via Nominatim (OpenStreetMap)
      try {
        final dio = Dio(
          BaseOptions(
            headers: {'User-Agent': 'carwashgo-app/1.0'},
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

        final res = await dio.get(
          'https://nominatim.openstreetmap.org/reverse',
          queryParameters: {
            'format': 'jsonv2',
            'lat': pos.latitude,
            'lon': pos.longitude,
          },
        );

        final body = res.data;
        if (body is Map && body['display_name'] is String) {
          final display = (body['display_name'] as String).trim();
          if (display.isNotEmpty) return display;
        }
      } catch (_) {
        // kalau reverse geocode gagal, fallback koordinat
      }

      return 'Latitude: ${pos.latitude.toStringAsFixed(5)}, Longitude: ${pos.longitude.toStringAsFixed(5)}';
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ambil lokasi: $e')),
      );
      return null;
    }
  }

  // =======================
  // Edit alamat + tombol "Gunakan lokasi saat ini"
  // =======================
  Future<void> _editAddress() async {
    final user = context.read<UserProvider>();
    final controller = TextEditingController(text: user.address);

    final newAddress = await showDialog<String>(
      context: context,
      builder: (_) {
        bool locating = false;

        return StatefulBuilder(
          builder: (ctx, setStateDialog) => AlertDialog(
            title: const Text('Ubah Alamat Utama'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan alamat...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: locating
                        ? null
                        : () async {
                            setStateDialog(() => locating = true);
                            final addr = await _getAddressFromCurrentLocation();
                            if (addr != null) controller.text = addr;
                            setStateDialog(() => locating = false);
                          },
                    icon: locating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(locating
                        ? 'Mengambil lokasi...'
                        : 'Gunakan lokasi saat ini'),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                child: const Text('Simpan'),
              ),
            ],
          ),
        );
      },
    );

    if (newAddress == null) return;
    if (newAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat tidak boleh kosong')),
      );
      return;
    }

    final res = await _authApi.updateProfile(address: newAddress);
    if (!mounted) return;

    if (res.status == 'success') {
      context.read<UserProvider>().setAddress(newAddress);
      await _loadMe();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat berhasil diperbarui')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message)),
      );
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Kamu akan logout dari aplikasi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await AuthApi().logout();
    if (!mounted) return;

    context.read<UserProvider>().logout();
    context.read<OrderProvider>().clearOrders();

    Navigator.pushNamedAndRemoveUntil(context, '/role', (route) => false);
  }

  Widget _infoTileEditable({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? "-" : value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blueAccent),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? "-" : value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    final name = user.name.isEmpty ? "User CarWashGo" : user.name;
    final email = user.email.isEmpty ? "email@example.com" : user.email;
    final phone = user.phone.isEmpty ? "-" : user.phone;
    final address = user.address.isEmpty ? "-" : user.address;

    return Container(
      color: const Color(0xFFF8F9FB),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_loadingMe) const LinearProgressIndicator(minHeight: 3),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Profil",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: _loadMe,
                  icon: const Icon(Icons.refresh),
                  tooltip: "Refresh",
                ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _uploadingPhoto ? null : _pickAndUploadImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  _avatar(user),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    child: _uploadingPhoto
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.camera_alt,
                            color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(email,
                style: const TextStyle(color: Colors.black54),
                textAlign: TextAlign.center),
            const SizedBox(height: 26),
            _infoTile(icon: Icons.phone, title: "Nomor Telepon", value: phone),
            const SizedBox(height: 10),
            _infoTileEditable(
              icon: Icons.location_on,
              title: "Alamat Utama",
              value: address,
              onEdit: _editAddress,
            ),
            const SizedBox(height: 10),
            _infoTile(
                icon: Icons.history,
                title: "Riwayat Pesanan",
                value: "Lihat di tab Pesanan"),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Keluar",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

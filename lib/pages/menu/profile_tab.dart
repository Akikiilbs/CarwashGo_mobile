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
import '../map/map_picker_page.dart';

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
          headers: const {'ngrok-skip-browser-warning': '69420'},
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
    final result = await FilePicker.pickFiles(
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
  // Edit alamat via MapPickerPage
  // =======================
  bool _updatingLocation = false;

  Future<void> _editAddress() async {
    final picked = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerPage()),
    );

    if (!mounted) return;
    if (picked == null || picked is! Map) return;

    final newLat = double.parse(picked["latitude"].toString());
    final newLng = double.parse(picked["longitude"].toString());
    final newAddress = (picked["address"] ?? "").toString();

    final user = context.read<UserProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Konfirmasi Perubahan Lokasi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Alamat baru: $newAddress"),
              const SizedBox(height: 6),
              Text("Koordinat: $newLat, $newLng"),
              const SizedBox(height: 12),
              const Text("Simpan perubahan lokasi utama?"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _updatingLocation = true);

    try {
      final res = await _authApi.updateProfile(
        address: newAddress,
        latitude: newLat,
        longitude: newLng,
      );

      if (res.status == 'success') {
        context.read<UserProvider>().setAddress(
              newAddress,
              latitude: newLat,
              longitude: newLng,
            );
        await _loadMe();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alamat dan lokasi berhasil diperbarui')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui lokasi: $e')),
      );
    } finally {
      if (mounted) setState(() => _updatingLocation = false);
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
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                        const Row(
                          children: [
                            Icon(Icons.location_on, size: 24, color: Colors.blueAccent),
                            SizedBox(width: 12),
                            Text("Alamat Utama", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                          ]
                        ),
                        TextButton(
                           onPressed: _updatingLocation ? null : _editAddress,
                           style: TextButton.styleFrom(
                             padding: EdgeInsets.zero,
                             minimumSize: const Size(50, 30),
                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                           ),
                           child: _updatingLocation
                               ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                               : const Text("Ubah", style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                     ],
                   ),
                   const SizedBox(height: 10),
                   Text(address, style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black54)),
                   if (user.latitude != null && user.longitude != null) ...[
                     const SizedBox(height: 6),
                     Text("Titik Koordinat: ${user.latitude}, ${user.longitude}", style: const TextStyle(fontSize: 12, color: Colors.black38)),
                   ]
                ],
              ),
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

import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:carwashgo/features/auth/data/auth_api.dart';
import '../../pages/navigation/bottom_nav_mitra.dart';
import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/mitra_provider.dart';

class MitraProfilePage extends StatefulWidget {
  const MitraProfilePage({super.key});

  @override
  State<MitraProfilePage> createState() => _MitraProfilePageState();
}

class _MitraProfilePageState extends State<MitraProfilePage> {
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

        setState(() => _webImage = bytes);

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
        setState(() => _selectedImage = f);

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
          profilePhotoUrl: u.profilePhotoUrl,
        );

    if (res.partner != null) {
      final p = res.partner!;
      context.read<MitraProvider>().setFromApi(
            businessName: p.businessName,
            alamat: p.address,
            latitude: p.latitude,
            longitude: p.longitude,
            outletPhotoUrl: p.outletPhotoUrl.isNotEmpty
                ? p.outletPhotoUrl
                : _authApi.buildStorageUrlFromPath(p.outletPhotoPath),
          );
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Kamu akan logout dari akun mitra.'),
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
    context.read<MitraProvider>().clear();

    Navigator.pushNamedAndRemoveUntil(context, '/role', (route) => false);
  }

  Widget _infoTile(IconData icon, String title, String value) {
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
    final mitra = context.watch<MitraProvider>();

    final name = user.name.isNotEmpty ? user.name : "Mitra CarWashGo";
    final email = user.email.isNotEmpty ? user.email : "email@example.com";
    final phone = user.phone.isNotEmpty ? user.phone : "-";

    final businessName =
        mitra.businessName.isNotEmpty ? mitra.businessName : "Belum diatur";
    final alamat = mitra.alamat.isNotEmpty ? mitra.alamat : "Belum diatur";
    final koordinat = (mitra.latitude != null && mitra.longitude != null)
        ? "${mitra.latitude}, ${mitra.longitude}"
        : "Belum diatur";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        title: const Text(
          "Profil Mitra",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadMe,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_loadingMe) const LinearProgressIndicator(minHeight: 3),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _uploadingPhoto ? null : _pickAndUploadImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  _avatar(user),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                        color: Colors.blueAccent, shape: BoxShape.circle),
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
            _infoTile(Icons.phone, "Nomor Telepon", phone),
            const SizedBox(height: 10),
            _infoTile(Icons.storefront, "Nama Usaha", businessName),
            const SizedBox(height: 10),
            _infoTile(Icons.location_on, "Alamat Usaha", alamat),
            const SizedBox(height: 10),
            _infoTile(Icons.my_location, "Koordinat Outlet", koordinat),
            const SizedBox(height: 22),

            // ====== CRUD Layanan Mitra ======
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.cleaning_services, color: Colors.white),
                label: const Text(
                  "Kelola Layanan Cuci",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () =>
                    Navigator.pushNamed(context, '/mitra-services'),
              ),
            ),
            const SizedBox(height: 12),

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
      bottomNavigationBar: const BottomNavMitra(currentIndex: 2),
    );
  }
}

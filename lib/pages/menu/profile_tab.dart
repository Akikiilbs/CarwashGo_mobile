import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import 'package:carwashgo/features/auth/data/auth_api.dart';

import '../../providers/user_provider.dart';
import '../../providers/order_provider.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  File? _selectedImage;
  Uint8List? _webImage;

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

    // 1) Panggil API logout + delete token
    await AuthApi().logout();

    // 2) Bersihkan state lokal
    if (!mounted) return;
    context.read<UserProvider>().logout();
    context.read<OrderProvider>().clearOrders();

    // 3) Kembali ke role selection
    Navigator.pushNamedAndRemoveUntil(context, '/role', (route) => false);
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      if (kIsWeb) {
        setState(() {
          _webImage = result.files.first.bytes!;
        });
      } else {
        setState(() {
          _selectedImage = File(result.files.first.path!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    ImageProvider profileImage;

    if (kIsWeb && _webImage != null) {
      profileImage = MemoryImage(_webImage!);
    } else if (!kIsWeb && _selectedImage != null) {
      profileImage = FileImage(_selectedImage!);
    } else {
      profileImage = const AssetImage("assets/images/profile.jpg");
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 25),

          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: profileImage,
                ),
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: Colors.white, size: 18),
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          // NAMA USER
          Text(
            user.name.isEmpty ? "User CarWashGo" : user.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          // EMAIL USER
          Text(
            user.email.isEmpty ? "email@example.com" : user.email,
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 20),

          // NOMOR TELEPON
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.blueAccent),
            title: const Text("Nomor Telepon"),
            subtitle: Text(
              user.phone.isEmpty ? "-" : user.phone,
            ),
          ),

          const Divider(),

          // ALAMAT — masih dummy, nanti bisa tambahkan provider tersendiri
          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.blueAccent),
            title: const Text("Alamat Utama"),
            subtitle: const Text("Belum diatur"),
          ),

          const Divider(),

          const SizedBox(height: 25),

          // LOGOUT
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "Keluar",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                _logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}

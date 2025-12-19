// import 'package:flutter/material.dart';
// import '../../pages/navigation/bottom_nav_mitra.dart';

// class MitraProfilePage extends StatelessWidget {
//   const MitraProfilePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FB),

//       appBar: AppBar(
//         backgroundColor: Colors.blueAccent,
//         elevation: 0,
//         centerTitle: true,
//         title: const Text(
//           "Profil Mitra",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const SizedBox(height: 15),

//             CircleAvatar(
//               radius: 50,
//               backgroundColor: Colors.blueAccent.withOpacity(0.3),
//               child: const Icon(
//                 Icons.person,
//                 size: 60,
//                 color: Colors.blueAccent,
//               ),
//             ),

//             const SizedBox(height: 12),

//             const Text(
//               "Mitra CarWashGo",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),

//             const SizedBox(height: 30),

//             _infoTile(Icons.phone, "Nomor Telepon", "+628123456789"),
//             const SizedBox(height: 10),

//             _infoTile(Icons.location_on, "Alamat Usaha", "Belum diatur"),
//             const SizedBox(height: 10),

//             _infoTile(Icons.local_car_wash, "Jenis Layanan", "Cuci Premium"),
//             const SizedBox(height: 25),

//             // ==========================
//             //        LOGOUT FIX
//             // ==========================
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.redAccent,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.pushNamedAndRemoveUntil(
//                     context,
//                     '/login-mitra',
//                     (route) => false,   // clear history -> FIX MACET
//                   );
//                 },
//                 child: const Text(
//                   "Keluar",
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),

//       bottomNavigationBar: const BottomNavMitra(currentIndex: 2),
//     );
//   }

//   Widget _infoTile(IconData icon, String title, String value) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12.withOpacity(0.05),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Icon(icon, size: 24, color: Colors.blueAccent),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     color: Colors.black54,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:carwashgo/features/partner/data/partner_api.dart';
import 'package:carwashgo/features/partner/models/partner_profile.dart';
import '../../pages/navigation/bottom_nav_mitra.dart';
// import Dio atau ApiClient yang kamu pakai
import 'package:dio/dio.dart';

class MitraProfilePage extends StatefulWidget {
  const MitraProfilePage({super.key});

  @override
  State<MitraProfilePage> createState() => _MitraProfilePageState();
}

class _MitraProfilePageState extends State<MitraProfilePage> {
  late PartnerApi _partnerApi;

  PartnerProfile? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;
  String? _error;

  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // SESUAIKAN: pakai Dio yang sama dengan AuthApi
    final dio = Dio(); // ganti dengan instance yang benar (baseUrl, token)
    _partnerApi = PartnerApi(dio);

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await _partnerApi.getProfile();
      setState(() {
        _profile = profile;
        _businessNameController.text = profile.businessName;
        _phoneController.text = profile.user.phone;
        _addressController.text = profile.address;
      });
    } catch (e) {
      // ⬇️ tambahkan log ke console
      // kalau pakai Dio, biasanya: DioException dengan response
      debugPrint('ERROR getProfile: $e');

      setState(() {
        _error = 'Gagal memuat profil mitra';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_profile == null) return;

    final businessName = _businessNameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (businessName.isEmpty || phone.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua kolom')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updated = await _partnerApi.updateProfile(
        businessName: businessName,
        address: address,
        phone: phone,
      );

      setState(() {
        _profile = updated;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan profil')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login-mitra',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profil Mitra",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          if (profile != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  if (!_isEditing) {
                    // reset ke data terakhir kalau batal edit
                    _businessNameController.text = profile.businessName;
                    _phoneController.text = profile.user.phone;
                    _addressController.text = profile.address;
                  }
                });
              },
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : profile == null
                  ? const Center(child: Text('Profil mitra tidak ditemukan'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 15),
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.blueAccent.withOpacity(0.3),
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            profile.user.name.isNotEmpty
                                ? profile.user.name
                                : profile.businessName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // FORM PROFIL
                          _profileField(
                            icon: Icons.store_mall_directory_outlined,
                            label: 'Nama Usaha',
                            controller: _businessNameController,
                            enabled: _isEditing,
                          ),
                          const SizedBox(height: 10),
                          _profileField(
                            icon: Icons.phone,
                            label: 'Nomor Telepon',
                            controller: _phoneController,
                            enabled: _isEditing,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 10),
                          _profileField(
                            icon: Icons.location_on,
                            label: 'Alamat Usaha',
                            controller: _addressController,
                            enabled: _isEditing,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 20),

                          if (_isEditing)
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _isSaving ? null : _saveProfile,
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Simpan Perubahan',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),

                          const SizedBox(height: 30),

                          // LAYANAN AKTIF
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Layanan Aktif',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (profile.services.isEmpty)
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Belum ada layanan yang diaktifkan.',
                                style: TextStyle(color: Colors.black54),
                              ),
                            )
                          else
                            Column(
                              children: profile.services
                                  .where((s) => s.isActive)
                                  .map(
                                    (s) => Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12
                                                .withOpacity(0.05),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  s.serviceName ??
                                                      'Layanan tanpa nama',
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  s.vehicleType ??
                                                      'Tipe kendaraan tidak diketahui',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            'Rp ${s.price.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),

                          const SizedBox(height: 25),

                          // LOGOUT
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _logout,
                              child: const Text(
                                "Keluar",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
      bottomNavigationBar: const BottomNavMitra(currentIndex: 2),
    );
  }

  Widget _profileField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    bool enabled = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF0F2F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carwashgo/core/network/dio_client.dart';
import 'package:provider/provider.dart';

import '../../features/partner/models/meta_models.dart';
import '../../features/partner/models/partner_service_dto.dart';
import '../../providers/partner_services_provider.dart';

void logx(String msg) => debugPrint('🧩 [MitraServicesPage] $msg');

class MitraServicesPage extends StatefulWidget {
  const MitraServicesPage({super.key});

  @override
  State<MitraServicesPage> createState() => _MitraServicesPageState();
}

class _MitraServicesPageState extends State<MitraServicesPage> {
  @override
  void initState() {
    super.initState();
    // load sekali saat page dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<PartnerServicesProvider>();
      if (p.metaServices.isEmpty && !p.loading) {
        p.loadAll();
      } else {
        p.refreshPartnerServices();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PartnerServicesProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: const Text('Kelola Layanan Cuci',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: prov.loading ? null : () => prov.loadAll(),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Column(
        children: [
          if (prov.loading) const LinearProgressIndicator(minHeight: 3),
          if (prov.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      prov.error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                const OutletPhotosSection(),
                const SizedBox(height: 14),
                const _PartnerInfoSection(),
                const SizedBox(height: 14),
                _VerticalServiceCards(
                  services: prov.metaServices,
                  vehicles: prov.vehicleTypes,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnerInfoSection extends StatefulWidget {
  const _PartnerInfoSection();

  @override
  State<_PartnerInfoSection> createState() => _PartnerInfoSectionState();
}

class _PartnerInfoSectionState extends State<_PartnerInfoSection> {
  final _descCtrl = TextEditingController();
  final Set<String> _selectedDays = {};
  final Set<String> _selectedHours = {};
  bool _initialized = false;

  final List<String> _allDays = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"];
  final List<String> _allHours = [
    "08:00", "09:00", "10:00", "11:00", "12:00", "13:00", 
    "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00"
  ];

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  void _initFromProfile(Map<String, dynamic> profile) {
    if (_initialized) return;
    _descCtrl.text = profile['description']?.toString() ?? '';
    
    final daysStr = profile['operating_days']?.toString() ?? '';
    if (daysStr.isNotEmpty) {
      _selectedDays.addAll(daysStr.split(',').map((e) => e.trim()));
    }

    final hoursStr = profile['operating_hours']?.toString() ?? '';
    if (hoursStr.isNotEmpty) {
      _selectedHours.addAll(hoursStr.split(',').map((e) => e.trim()));
    }
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PartnerServicesProvider>();
    final profile = prov.partnerProfile;

    if (profile == null) return const SizedBox.shrink();
    _initFromProfile(profile);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Profil & Operasional', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildField('Deskripsi Outlet', _descCtrl, maxLines: 3, hint: 'Ceritakan tentang keunggulan outlet Anda...'),
          const SizedBox(height: 16),
          const Text('Hari Operasional', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allDays.map((day) {
              final isSelected = _selectedDays.contains(day);
              return FilterChip(
                label: Text(day, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
                selected: isSelected,
                selectedColor: Colors.blueAccent,
                checkmarkColor: Colors.white,
                onSelected: (val) {
                  setState(() {
                    if (val) _selectedDays.add(day);
                    else _selectedDays.remove(day);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Jam Operasional (Slot)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 2.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _allHours.length,
            itemBuilder: (context, index) {
              final hour = _allHours[index];
              final isSelected = _selectedHours.contains(hour);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) _selectedHours.remove(hour);
                    else _selectedHours.add(hour);
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blueAccent : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? Colors.blueAccent : Colors.grey.shade300),
                  ),
                  child: Text(hour, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: prov.loading ? null : () async {
                try {
                  await prov.updatePartnerProfile(
                    businessName: profile['business_name']?.toString() ?? '',
                    address: profile['address']?.toString() ?? '',
                    phone: profile['user']?['phone']?.toString() ?? '',
                    description: _descCtrl.text.trim(),
                    operatingHours: _selectedHours.toList().join(','),
                    operatingDays: _selectedDays.toList().join(','),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil diperbarui')));
                  }
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Simpan Perubahan Profil'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {int maxLines = 1, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }
}

class _VerticalServiceCards extends StatelessWidget {
  final List<MetaService> services;
  final List<VehicleTypeDto> vehicles;

  const _VerticalServiceCards({required this.services, required this.vehicles});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty || vehicles.isEmpty) return const SizedBox.shrink();

    final preferredCodes = ['small', 'medium', 'large'];
    final sortedVehicles = [...vehicles];
    sortedVehicles.sort((a, b) {
      final ai = preferredCodes.indexOf(a.code.toLowerCase());
      final bi = preferredCodes.indexOf(b.code.toLowerCase());
      return (ai == -1 ? 999 : ai).compareTo(bi == -1 ? 999 : bi);
    });
    final displayVehicles = sortedVehicles.take(3).toList();
    final displayServices = services.where((s) => s.isActive).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text('Daftar Layanan & Harga', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        ...displayServices.map((service) => _ServiceCard(service: service, vehicles: displayVehicles)),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final MetaService service;
  final List<VehicleTypeDto> vehicles;

  const _ServiceCard({required this.service, required this.vehicles});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.local_car_wash, color: Colors.blueAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(service.categoryName ?? 'Kategori Umum', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              Text('Base: Rp${service.basePrice}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          ...vehicles.map((v) => _VehiclePriceTile(service: service, vehicle: v)),
        ],
      ),
    );
  }
}

class _VehiclePriceTile extends StatelessWidget {
  final MetaService service;
  final VehicleTypeDto vehicle;
  const _VehiclePriceTile({required this.service, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PartnerServicesProvider>();
    final cell = prov.getCell(service.id, vehicle.id);
    final isActive = cell?.isActive ?? false;
    final price = cell?.price;

    return InkWell(
      onTap: () => _openEditStatic(context, cell, service, vehicle),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vehicle.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(isActive ? 'Aktif' : 'Nonaktif', style: TextStyle(fontSize: 12, color: isActive ? Colors.green : Colors.red)),
                ],
              ),
            ),
            Text(
              price == null ? 'Belum diatur' : 'Rp$price',
              style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.blue.shade900 : Colors.black45),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18, color: Colors.black26),
          ],
        ),
      ),
    );
  }

  // Moved _openEdit logic out to a static-like helper to keep code clean
  Future<void> _openEditStatic(BuildContext context, PartnerServiceDto? existing, MetaService service, VehicleTypeDto vehicle) async {
    final prov = context.read<PartnerServicesProvider>();
    final currentPrice = existing?.price ?? service.basePrice;
    final currentActive = existing?.isActive ?? true;

    final priceCtrl = TextEditingController(text: currentPrice.toString());
    bool active = currentActive;

    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (ctx, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${service.name} • ${vehicle.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Harga (Rp)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    value: active,
                    onChanged: (v) => setState(() => active = v),
                    title: const Text('Aktifkan layanan'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(ctx, false),
                          icon: const Icon(Icons.close),
                          label: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final price = int.tryParse(priceCtrl.text.trim());
                            if (price == null || price < 0) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harga tidak valid')));
                              return;
                            }
                            await prov.upsert(serviceId: service.id, vehicleTypeId: vehicle.id, price: price, isActive: active);
                            if (ctx.mounted) Navigator.pop(ctx, true);
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Simpan'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// ===============================
// OUTLET PHOTOS CRUD SECTION
// Endpoint backend yang dibutuhkan:
// - GET    /api/v1/partner/outlet-photos
// - POST   /api/v1/partner/outlet-photos   (multipart photos[])
// - DELETE /api/v1/partner/outlet-photos/{id}
// - POST   /api/v1/partner/outlet-photos/{id}/primary  (optional)
// ===============================

class _OutletPhotoItem {
  final int id;
  final String pathOrUrl;
  final bool isPrimary;

  _OutletPhotoItem({
    required this.id,
    required this.pathOrUrl,
    required this.isPrimary,
  });

  factory _OutletPhotoItem.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as num).toInt();
    final isPrimary = (json['is_primary'] == true) ||
        (json['isPrimary'] == true) ||
        (json['is_primary'] == 1);
    final url = (json['url'] ?? json['full_url'])?.toString();
    final path =
        (json['path'] ?? json['image_path'] ?? json['photo'])?.toString();
    return _OutletPhotoItem(
      id: id,
      pathOrUrl: (path != null && path.isNotEmpty) ? path : (url ?? ''),
      isPrimary: isPrimary,
    );
  }
}

class OutletPhotosSection extends StatefulWidget {
  const OutletPhotosSection({super.key});

  @override
  State<OutletPhotosSection> createState() => _OutletPhotosSectionState();
}

class _OutletPhotosSectionState extends State<OutletPhotosSection> {
  final _picker = ImagePicker();
  bool _loading = false;
  String? _error;
  List<_OutletPhotoItem> _items = [];

  Dio get _dio => DioClient().dio;

  String _originFromApiBase() {
    final base = _dio.options.baseUrl; // e.g. https://xxx.ngrok-free.app/api/v1
    final uri = Uri.parse(base);
    return uri.hasPort
        ? '${uri.scheme}://${uri.host}:${uri.port}'
        : '${uri.scheme}://${uri.host}';
  }

  String _photoUrl(_OutletPhotoItem item) {
    var s = item.pathOrUrl.trim();
    if (s.isEmpty) return '';

    // Jika sudah full URL (dimulai http), langsung pakai
    if (s.toLowerCase().startsWith('http')) return s;

    // Bersihkan leading slash
    if (s.startsWith('/')) s = s.substring(1);

    // Pastikan tidak double /storage/
    if (s.startsWith('storage/')) {
        return '${_originFromApiBase()}/$s';
    }

    return '${_originFromApiBase()}/storage/$s';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _dio.get('/partner/outlet-photos');

      // API kamu pakai wrapper BaseApiController: {status, message, data}
      final raw = res.data;
      final data = (raw is Map && raw['data'] != null) ? raw['data'] : raw;

      if (data is! List) {
        throw Exception('Response foto outlet harus List di field data.');
      }

      final items = data
          .whereType<Map>()
          .map((e) => _OutletPhotoItem.fromJson(
              e.map((k, v) => MapEntry(k.toString(), v))))
          .toList();

      setState(() => _items = items);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickAndUpload() async {
    try {
      final files = await _picker.pickMultiImage(imageQuality: 85);
      if (files.isEmpty) return;

      setState(() {
        _loading = true;
        _error = null;
      });

      final fd = FormData();
      for (final f in files) {
        final bytes = await f.readAsBytes();
        fd.files.add(
          MapEntry(
              'photos[]', MultipartFile.fromBytes(bytes, filename: f.name)),
        );
      }

      await _dio.post(
        '/partner/outlet-photos',
        data: fd,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto outlet berhasil diupload')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal upload: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(_OutletPhotoItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus foto?'),
        content: const Text('Foto outlet ini akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      await _dio.delete('/partner/outlet-photos/${item.id}');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Foto dihapus')));
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal hapus: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setPrimary(_OutletPhotoItem item) async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      await _dio.post('/partner/outlet-photos/${item.id}/primary');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Foto utama diperbarui')));
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal set utama: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto Outlet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tambah beberapa foto outlet agar pelanggan lebih percaya.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _pickAndUpload,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: const Text('Tambah Foto'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: _loading ? null : _load,
                icon: const Icon(Icons.refresh),
              )
            ],
          ),
          if (_loading) ...[
            const SizedBox(height: 10),
            const LinearProgressIndicator(minHeight: 3),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          if (_items.isEmpty && !_loading)
            const Text('Belum ada foto outlet.',
                style: TextStyle(color: Colors.black54))
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (ctx, i) {
                final item = _items[i];
                final url = _photoUrl(item);

                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        url,
                        headers: const {'ngrok-skip-browser-warning': '69420'},
                        fit: BoxFit.cover,
                        errorBuilder: (_, err, __) {
                          debugPrint(
                              '❌ [OutletPhotos] failed url=$url err=$err');
                          return Container(
                            color: Colors.black12.withOpacity(0.08),
                            child: const Center(
                                child: Icon(Icons.broken_image_outlined)),
                          );
                        },
                      ),
                      if (item.isPrimary)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text('Utama',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11)),
                          ),
                        ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'primary') _setPrimary(item);
                            if (v == 'delete') _delete(item);
                          },
                          itemBuilder: (_) => [
                            if (!item.isPrimary)
                              const PopupMenuItem(
                                  value: 'primary',
                                  child: Text('Jadikan Utama')),
                            const PopupMenuItem(
                                value: 'delete', child: Text('Hapus')),
                          ],
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Icon(Icons.more_vert,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

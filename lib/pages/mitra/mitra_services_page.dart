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
                _MatrixTable(
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

class _MatrixTable extends StatelessWidget {
  final List<MetaService> services;
  final List<VehicleTypeDto> vehicles;

  const _MatrixTable({
    required this.services,
    required this.vehicles,
  });

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty || vehicles.isEmpty) {
      return const Center(
        child: Text('Data layanan belum tersedia.'),
      );
    }

    // Fokus 3 kategori kendaraan yang paling umum (small/medium/large) kalau ada.
    final preferredCodes = ['small', 'medium', 'large'];
    final sortedVehicles = [...vehicles];
    sortedVehicles.sort((a, b) {
      final ai = preferredCodes.indexOf(a.code.toLowerCase());
      final bi = preferredCodes.indexOf(b.code.toLowerCase());
      final av = ai == -1 ? 999 : ai;
      final bv = bi == -1 ? 999 : bi;
      return av.compareTo(bv);
    });
    final displayVehicles = sortedVehicles.take(3).toList();

    // Tampilkan layanan aktif saja (backend sudah filter, tapi biar aman)
    final displayServices = services.where((s) => s.isActive).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Atur harga & status layanan per tipe kendaraan',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 46,
              dataRowMinHeight: 64,
              dataRowMaxHeight: 80,
              columns: [
                const DataColumn(
                  label: Text('Layanan',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ...displayVehicles.map(
                  (v) => DataColumn(
                    label: Text(
                      v.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
              rows: displayServices.map((s) {
                return DataRow(
                  cells: [
                    DataCell(_ServiceLabel(service: s)),
                    ...displayVehicles.map((v) {
                      return DataCell(_ServiceCell(service: s, vehicle: v));
                    }).toList(),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Tips: tekan salah satu kotak harga untuk mengubah harga atau mengaktifkan/nonaktifkan layanan.',
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}

class _ServiceLabel extends StatelessWidget {
  final MetaService service;
  const _ServiceLabel({required this.service});

  @override
  Widget build(BuildContext context) {
    final category = (service.categoryName ?? '').trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          service.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        if (category.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              category,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            'Base: Rp${service.basePrice}',
            style: const TextStyle(fontSize: 12, color: Colors.black45),
          ),
        ),
      ],
    );
  }
}

class _ServiceCell extends StatelessWidget {
  final MetaService service;
  final VehicleTypeDto vehicle;

  const _ServiceCell({
    required this.service,
    required this.vehicle,
  });

  String _rupiah(int v) {
    return 'Rp$v';
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PartnerServicesProvider>();
    final PartnerServiceDto? cell = prov.getCell(service.id, vehicle.id);

    final isActive = cell?.isActive ?? false;
    final price = cell?.price;

    final bg = isActive
        ? Colors.greenAccent.withOpacity(0.18)
        : Colors.black12.withOpacity(0.06);
    final border = isActive
        ? Colors.green.withOpacity(0.35)
        : Colors.black12.withOpacity(0.15);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openEdit(context, cell),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              price == null ? 'Belum diatur' : _rupiah(price),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.green.shade900 : Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isActive ? Icons.check_circle : Icons.remove_circle_outline,
                  size: 16,
                  color: isActive ? Colors.green : Colors.black45,
                ),
                const SizedBox(width: 6),
                Text(
                  isActive ? 'Aktif' : 'Nonaktif',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEdit(
      BuildContext context, PartnerServiceDto? existing) async {
    final prov = context.read<PartnerServicesProvider>();
    final currentPrice = existing?.price ?? service.basePrice;
    final currentActive = existing?.isActive ?? true;

    final priceCtrl = TextEditingController(text: currentPrice.toString());
    bool active = currentActive;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (ctx, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${service.name} • ${vehicle.name}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Harga (Rp)',
                      border: OutlineInputBorder(),
                    ),
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Harga tidak valid')),
                              );
                              return;
                            }

                            // kalau sudah ada: lebih aman pakai upsert aja (backend updateOrCreate)
                            await prov.upsert(
                              serviceId: service.id,
                              vehicleTypeId: vehicle.id,
                              price: price,
                              isActive: active,
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Layanan disimpan')),
                              );
                            }
                            if (ctx.mounted) Navigator.pop(ctx, true);
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Simpan'),
                        ),
                      ),
                    ],
                  ),
                  if (existing != null) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Hapus layanan?'),
                              content: const Text(
                                  'Data layanan untuk kombinasi ini akan dihapus.'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );
                          if (ok != true) return;

                          await prov.remove(existing);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Layanan dihapus')),
                            );
                          }
                          if (ctx.mounted) Navigator.pop(ctx, true);
                        },
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent),
                        label: const Text(
                          'Hapus kombinasi ini',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ]
                ],
              );
            },
          ),
        );
      },
    );

    if (result == true) {
      // no-op: provider sudah update
    }
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
      pathOrUrl: (url != null && url.isNotEmpty) ? url : (path ?? ''),
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

    // Kalau sudah full URL, pakai langsung
    if (s.startsWith('http://') || s.startsWith('https://')) return s;

    // Bersihkan leading slash
    if (s.startsWith('/')) s = s.substring(1);

    // Kalau sudah diawali "storage/", jangan tambahin "storage/" lagi
    if (s.startsWith('storage/')) {
      return '${_originFromApiBase()}/$s';
    }

    // Kalau sudah mengandung "/storage/" di tengah, anggap sudah siap
    if (s.contains('/storage/')) {
      return '${_originFromApiBase()}$s';
    }

    // Default: path relatif di disk public
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

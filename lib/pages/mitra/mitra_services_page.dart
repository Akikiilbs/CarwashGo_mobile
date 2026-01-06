import 'package:flutter/material.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final p = context.read<PartnerServicesProvider>();
      try {
        if (p.metaServices.isEmpty && !p.loading) {
          logx('init -> loadAll()');
          await p.loadAll();
          logx('loadAll() success');
        } else {
          logx('init -> refreshPartnerServices()');
          await p.refreshPartnerServices();
          logx('refreshPartnerServices() success');
        }
      } catch (e, s) {
        logx('init load FAILED: $e');
        logx('stack: $s');
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
            onPressed: prov.loading
                ? null
                : () async {
                    try {
                      logx('tap refresh -> loadAll()');
                      await prov.loadAll();
                      logx('refresh loadAll() success');
                    } catch (e, s) {
                      logx('refresh loadAll() FAILED: $e');
                      logx('stack: $s');
                    }
                  },
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
            child: _MatrixTable(
              services: prov.metaServices,
              vehicles: prov.vehicleTypes,
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
                            // await prov.upsert(
                            //   serviceId: service.id,
                            //   vehicleTypeId: vehicle.id,
                            //   price: price,
                            //   isActive: active,
                            // );

                            try {
                              logx(
                                  'SAVE -> upsert serviceId=${service.id}, vehicleTypeId=${vehicle.id}, price=$price, active=$active');
                              await prov.upsert(
                                serviceId: service.id,
                                vehicleTypeId: vehicle.id,
                                price: price,
                                isActive: active,
                              );
                              logx('SAVE -> upsert success');
                            } catch (e, s) {
                              logx('SAVE -> upsert FAILED: $e');
                              logx('stack: $s');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal simpan: $e')),
                                );
                              }
                              return;
                            }

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

                          //await prov.remove(existing);

                          try {
                            logx('DELETE -> remove id=${existing.id}');
                            await prov.remove(existing);
                            logx('DELETE -> remove success');
                          } catch (e, s) {
                            logx('DELETE -> remove FAILED: $e');
                            logx('stack: $s');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal hapus: $e')),
                              );
                            }
                            return;
                          }

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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/order/data/order_api.dart';
import '../../features/order/models/simple_api_response.dart';
import '../../providers/order_provider.dart';
import '../map/map_picker_page.dart';

class BookingPage extends StatefulWidget {
  /// serviceItem dari marketplace: {
  ///   partner_service_id, price,
  ///   partner{id,business_name,address},
  ///   service{id,name,description},
  ///   vehicle_type{id,name}
  /// }
  final Map<String, dynamic>? serviceItem;

  const BookingPage({super.key, this.serviceItem});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _orderApi = OrderApi();

  String _address = '';
  double? _lat;
  double? _lng;

  late DateTime _selectedDate;
  String _selectedTime = '09:00';

  final _plateController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _notesController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _plateController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<DateTime> get _next7Days {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final d = today.add(Duration(days: i));
      return DateTime(d.year, d.month, d.day);
    });
  }

  List<String> get _timeSlots => const [
        '08:00',
        '09:00',
        '10:00',
        '11:00',
        '12:00',
        '13:00',
        '14:00',
        '15:00',
        '16:00',
        '17:00',
      ];

  String _two(int v) => v < 10 ? '0$v' : '$v';
  String _fmtYmd(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

  int _priceFromServiceItem() {
    final item = widget.serviceItem;
    if (item == null) return 0;
    final p = item['price'];
    if (p is num) return p.toInt();
    return int.tryParse(p?.toString() ?? '') ?? 0;
  }

  Future<void> _pickAddress() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerPage()),
    );
    if (result == null) return;

    setState(() {
      _address = (result['address'] ?? '').toString();
      _lat = result['latitude'] is num
          ? (result['latitude'] as num).toDouble()
          : null;
      _lng = result['longitude'] is num
          ? (result['longitude'] as num).toDouble()
          : null;
    });
  }

  Future<void> _submitOrder() async {
    final item = widget.serviceItem;
    if (item == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Silakan pilih layanan dari Home terlebih dahulu.')),
      );
      return;
    }

    if (_address.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat wajib diisi.')),
      );
      return;
    }

    final partner = item['partner'] is Map
        ? Map<String, dynamic>.from(item['partner'])
        : null;
    final vehicleType = item['vehicle_type'] is Map
        ? Map<String, dynamic>.from(item['vehicle_type'])
        : null;

    final partnerId = int.tryParse(partner?['id']?.toString() ?? '') ?? 0;
    final vehicleTypeId =
        int.tryParse(vehicleType?['id']?.toString() ?? '') ?? 0;

    final partnerServiceId = int.tryParse(
            (item['partner_service_id'] ?? item['id'])?.toString() ?? '') ??
        0;

    if (partnerId == 0 || vehicleTypeId == 0 || partnerServiceId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Data layanan tidak lengkap (partner/service/vehicle).')),
      );
      return;
    }

    setState(() => _loading = true);

    SimpleApiResponse res;
    try {
      res = await _orderApi.createOrderV2(
        partnerId: partnerId,
        vehicleTypeId: vehicleTypeId,
        vehicleBrand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        vehicleModel: _modelController.text.trim().isEmpty
            ? null
            : _modelController.text.trim(),
        vehicleColor: _colorController.text.trim().isEmpty
            ? null
            : _colorController.text.trim(),
        plateNumber: _plateController.text.trim().isEmpty
            ? null
            : _plateController.text.trim(),
        address: _address.trim(),
        latitude: _lat,
        longitude: _lng,
        scheduledDate: _fmtYmd(_selectedDate),
        scheduledTime: _selectedTime,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        discount: 0,
        paymentMethod: null,
        items: [
          {'partner_service_id': partnerServiceId, 'quantity': 1}
        ],
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }

    if (!mounted) return;

    if (res.isSuccess) {
      await context.read<OrderProvider>().loadCustomerOrders();
      // Popup/snackbar sukses dihapus sesuai request.
      Navigator.pushNamedAndRemoveUntil(context, '/menu', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.serviceItem;

    final partner = item?['partner'] is Map
        ? Map<String, dynamic>.from(item?['partner'])
        : null;
    final service = item?['service'] is Map
        ? Map<String, dynamic>.from(item?['service'])
        : null;
    final vehicleType = item?['vehicle_type'] is Map
        ? Map<String, dynamic>.from(item?['vehicle_type'])
        : null;

    final partnerName = partner?['business_name']?.toString() ?? '-';
    final serviceName = service?['name']?.toString() ?? '-';
    final vehicleTypeName = vehicleType?['name']?.toString() ?? '-';
    final price = _priceFromServiceItem();

    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(serviceName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Mitra: $partnerName'),
            Text('Tipe: $vehicleTypeName'),
            Text('Harga: Rp $price'),
            const SizedBox(height: 16),
            ListTile(
              title: Text(_address.isEmpty ? 'Pilih alamat' : _address),
              subtitle: const Text('Gunakan map picker'),
              trailing: const Icon(Icons.map),
              onTap: _pickAddress,
            ),
            const SizedBox(height: 10),
            const Text('Jadwal'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: _next7Days.map((d) {
                final selected = d == _selectedDate;
                return ChoiceChip(
                  label: Text('${d.day}/${d.month}'),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedDate = d),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _timeSlots.map((t) {
                final selected = t == _selectedTime;
                return ChoiceChip(
                  label: Text(t),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedTime = t),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
                controller: _plateController,
                decoration: const InputDecoration(labelText: 'Plat Nomor')),
            TextField(
                controller: _brandController,
                decoration:
                    const InputDecoration(labelText: 'Merk (opsional)')),
            TextField(
                controller: _modelController,
                decoration:
                    const InputDecoration(labelText: 'Model (opsional)')),
            TextField(
                controller: _colorController,
                decoration:
                    const InputDecoration(labelText: 'Warna (opsional)')),
            TextField(
                controller: _notesController,
                decoration:
                    const InputDecoration(labelText: 'Catatan (opsional)')),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _submitOrder,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Buat Pesanan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

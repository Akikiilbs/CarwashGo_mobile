import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../features/partner/data/partner_services_api.dart';
import '../features/partner/models/meta_models.dart';
import '../features/partner/models/partner_service_dto.dart';

class PartnerServicesProvider with ChangeNotifier {
  final PartnerServicesApi _api = PartnerServicesApi();

  bool loading = false;
  String? error;

  List<MetaService> metaServices = [];
  List<VehicleTypeDto> vehicleTypes = [];
  List<PartnerServiceDto> partnerServices = [];
  Map<String, dynamic>? partnerProfile;

  /// key: "$serviceId:$vehicleTypeId"
  final Map<String, PartnerServiceDto> _index = {};

  void _log(String msg) => debugPrint('🧠 [PartnerServicesProvider] $msg');

  PartnerServiceDto? getCell(int serviceId, int vehicleTypeId) {
    return _index['$serviceId:$vehicleTypeId'];
  }

  Future<void> loadAll() async {
    _log('loadAll() start');

    loading = true;
    error = null;
    notifyListeners();

    try {
      _log('fetch meta/services, meta/vehicle-types, partner/services ...');
      final results = await Future.wait([
        _api.getMetaServices(),
        _api.getVehicleTypes(),
        _api.listPartnerServices(),
        _api.getPartnerProfile(),
      ]);

      metaServices = (results[0] as List<MetaService>);
      vehicleTypes = (results[1] as List<VehicleTypeDto>);
      partnerServices = (results[2] as List<PartnerServiceDto>);
      partnerProfile = (results[3] as Map<String, dynamic>);

      _log(
          'metaServices=${metaServices.length}, vehicleTypes=${vehicleTypes.length}, partnerServices=${partnerServices.length}');
      _rebuildIndex();
      _log('index size=${_index.length}');
    } catch (e, s) {
      error = e.toString();
      _log('loadAll() ERROR: $e');
      _log('stack: $s');
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
      _log('loadAll() done (loading=false)');
    }
  }

  Future<void> refreshPartnerServices() async {
    _log('refreshPartnerServices() start');
    try {
      partnerServices = await _api.listPartnerServices();
      _log('partnerServices=${partnerServices.length}');
      _rebuildIndex();
      notifyListeners();
    } catch (e, s) {
      error = e.toString();
      notifyListeners();
      _log('refreshPartnerServices() ERROR: $e');
      _log('stack: $s');
      rethrow;
    }
  }

  Future<PartnerServiceDto?> upsert({
    required int serviceId,
    required int vehicleTypeId,
    required int price,
    required bool isActive,
  }) async {
    _log(
        'upsert(serviceId=$serviceId, vehicleTypeId=$vehicleTypeId, price=$price, isActive=$isActive)');
    try {
      final saved = await _api.upsertPartnerService(
        serviceId: serviceId,
        vehicleTypeId: vehicleTypeId,
        price: price,
        isActive: isActive,
      );

      final idx = partnerServices.indexWhere((p) => p.id == saved.id);
      if (idx >= 0) {
        partnerServices[idx] = saved;
      } else {
        partnerServices.insert(0, saved);
      }

      _index['$serviceId:$vehicleTypeId'] = saved;
      notifyListeners();
      _log('upsert success -> id=${saved.id}');
      return saved;
    } catch (e, s) {
      error = e.toString();
      notifyListeners();
      _log('upsert ERROR: $e');
      _log('stack: $s');
      rethrow;
    }
  }

  Future<PartnerServiceDto?> update({
    required int id,
    int? price,
    bool? isActive,
  }) async {
    _log('update(id=$id, price=$price, isActive=$isActive)');
    try {
      final saved = await _api.updatePartnerService(
        id: id,
        price: price,
        isActive: isActive,
      );

      final idx = partnerServices.indexWhere((p) => p.id == saved.id);
      if (idx >= 0) partnerServices[idx] = saved;

      _index['${saved.serviceId}:${saved.vehicleTypeId}'] = saved;
      notifyListeners();
      _log('update success -> id=${saved.id}');
      return saved;
    } catch (e, s) {
      error = e.toString();
      notifyListeners();
      _log('update ERROR: $e');
      _log('stack: $s');
      rethrow;
    }
  }

  Future<bool> remove(PartnerServiceDto dto) async {
    _log(
        'remove(id=${dto.id}, serviceId=${dto.serviceId}, vehicleTypeId=${dto.vehicleTypeId})');
    try {
      await _api.deletePartnerService(dto.id);
      partnerServices.removeWhere((p) => p.id == dto.id);
      _index.remove('${dto.serviceId}:${dto.vehicleTypeId}');
      notifyListeners();
      _log('remove success');
      return true;
    } catch (e, s) {
      error = e.toString();
      notifyListeners();
      _log('remove ERROR: $e');
      _log('stack: $s');
      rethrow;
    }
  }

  Future<void> updatePartnerProfile({
    required String businessName,
    required String address,
    required String phone,
    String? description,
    String? operatingHours,
    String? operatingDays,
  }) async {
    _log('updatePartnerProfile()');
    try {
      loading = true;
      notifyListeners();

      final updated = await _api.updatePartnerProfile({
        'business_name': businessName,
        'address': address,
        'phone': phone,
        'description': description,
        'operating_hours': operatingHours,
        'operating_days': operatingDays,
      });

      partnerProfile = updated;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _rebuildIndex() {
    _index.clear();
    for (final ps in partnerServices) {
      _index['${ps.serviceId}:${ps.vehicleTypeId}'] = ps;
    }
  }
}

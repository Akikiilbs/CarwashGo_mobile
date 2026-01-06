import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../models/meta_models.dart';
import '../models/partner_service_dto.dart';

class PartnerServicesApi {
  final Dio _dio = DioClient().dio;

  Future<List<MetaService>> getMetaServices() async {
    final res = await _dio.get('/meta/services');
    final list = (res.data['data'] as List<dynamic>? ?? [])
        .map((e) => MetaService.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  Future<List<VehicleTypeDto>> getVehicleTypes() async {
    final res = await _dio.get('/meta/vehicle-types');
    final list = (res.data['data'] as List<dynamic>? ?? [])
        .map((e) => VehicleTypeDto.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  Future<List<PartnerServiceDto>> listPartnerServices() async {
    final res = await _dio.get('/partner/services');
    final list = (res.data['data'] as List<dynamic>? ?? [])
        .map((e) => PartnerServiceDto.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  /// Upsert (updateOrCreate) layanan mitra
  /// POST /partner/services { service_id, vehicle_type_id, price, is_active }
  Future<PartnerServiceDto> upsertPartnerService({
    required int serviceId,
    required int vehicleTypeId,
    required int price,
    required bool isActive,
  }) async {
    final res = await _dio.post(
      '/partner/services',
      data: {
        'service_id': serviceId,
        'vehicle_type_id': vehicleTypeId,
        'price': price,
        'is_active': isActive,
      },
    );
    return PartnerServiceDto.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  /// PATCH /partner/services/{id} { price?, is_active? }
  Future<PartnerServiceDto> updatePartnerService({
    required int id,
    int? price,
    bool? isActive,
  }) async {
    final Map<String, dynamic> body = {};
    if (price != null) body['price'] = price;
    if (isActive != null) body['is_active'] = isActive;

    final res = await _dio.patch('/partner/services/$id', data: body);
    return PartnerServiceDto.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> deletePartnerService(int id) async {
    await _dio.delete('/partner/services/$id');
  }
}

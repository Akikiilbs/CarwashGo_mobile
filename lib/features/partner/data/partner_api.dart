import 'package:dio/dio.dart';
import 'package:carwashgo/features/partner/models/partner_profile.dart';

class PartnerApi {
  final Dio _dio;

  PartnerApi(this._dio);

  Future<PartnerProfile> getProfile() async {
    final res = await _dio.get('/partner/profile');
    final data = res.data['data'] as Map<String, dynamic>;
    return PartnerProfile.fromJson(data);
  }

  Future<PartnerProfile> updateProfile({
    required String businessName,
    required String address,
    required String phone,
    double? latitude,
    double? longitude,
  }) async {
    final res = await _dio.put(
      '/partner/profile',
      data: {
        'business_name': businessName,
        'address': address,
        'phone': phone,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    final data = res.data['data'] as Map<String, dynamic>;
    return PartnerProfile.fromJson(data);
  }
}

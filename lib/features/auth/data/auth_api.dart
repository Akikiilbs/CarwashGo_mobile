import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_response.dart';
import '../models/user.dart';
import '../../../core/network/dio_client.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:typed_data';
import 'dart:io' show File;

class AuthApi {
  final Dio _dio = DioClient().dio;
  final _storage = const FlutterSecureStorage();
  
  Future<bool> hasToken() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }

  /// POST /auth/login
  /// body: { email, password }
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.isSuccess && authResponse.token != null) {
        await _storage.write(key: 'auth_token', value: authResponse.token);
      }

      return authResponse;
    } on DioException catch (e) {
      // Handle error dari API (422/401/dll)
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return AuthResponse.fromJson(e.response!.data);
      }

      // Fallback error generic
      return AuthResponse(
        status: 'error',
        message: 'Terjadi kesalahan jaringan',
      );
    } catch (_) {
      return AuthResponse(
        status: 'error',
        message: 'Terjadi kesalahan tak terduga',
      );
    }
  }

  // PUT /auth/profile
  Future<AuthResponse> updateProfile({required String address}) async {
    try {
      final res = await _dio.put('/auth/profile', data: {'address': address});
      return AuthResponse.fromJson(res.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return AuthResponse.fromJson(e.response!.data);
      }
      return AuthResponse(
          status: 'error', message: 'Terjadi kesalahan jaringan');
    } catch (_) {
      return AuthResponse(
          status: 'error', message: 'Terjadi kesalahan tak terduga');
    }
  }

  /// POST /auth/register
  /// body: { name, email, phone, password, password_confirmation }
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String phone,
    required String address, //
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'address': address, //
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // Optional: simpan token ke storage
      // if (authResponse.isSuccess && authResponse.token != null) {
      //   await _storage.write(key: 'auth_token', value: authResponse.token);
      // }

      return authResponse;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return AuthResponse.fromJson(e.response!.data);
      }

      return AuthResponse(
        status: 'error',
        message: 'Terjadi kesalahan jaringan',
      );
    } catch (_) {
      return AuthResponse(
        status: 'error',
        message: 'Terjadi kesalahan tak terduga',
      );
    }
  }

  /// POST /auth/logout
  Future<bool> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // walau gagal di server, kita tetap hapus token lokal
    }

    await _storage.delete(key: 'auth_token');
    return true;
  }

  // Verifikasi OTP reset password
  Future<AuthResponse> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/password/verify-otp',
        data: {
          'email': email,
          'otp': otp,
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return AuthResponse.fromJson(e.response!.data);
      }
      return AuthResponse(
          status: 'error', message: 'Terjadi kesalahan jaringan');
    } catch (_) {
      return AuthResponse(
          status: 'error', message: 'Terjadi kesalahan tak terduga');
    }
  }

  // Kirim OTP reset password
  Future<AuthResponse> sendResetOtp({required String email}) async {
    try {
      final response = await _dio.post(
        '/auth/password/send-otp', // endpoint forgot password
        data: {'email': email},
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return AuthResponse.fromJson(e.response!.data);
      }
      return AuthResponse(
        status: 'error',
        message: 'Terjadi kesalahan jaringan',
      );
    } catch (_) {
      return AuthResponse(
        status: 'error',
        message: 'Terjadi kesalahan tak terduga',
      );
    }
  }

  /// POST /auth/login-partner
  Future<AuthResponse> loginPartner({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login-partner',
        data: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // kalau success → simpan token (dipakai untuk API mitra)
      if (authResponse.isSuccess && authResponse.token != null) {
        await _storage.write(key: 'auth_token', value: authResponse.token);
      }

      return authResponse;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return AuthResponse.fromJson(e.response!.data);
      }

      return AuthResponse(
        status: 'error',
        message: 'Terjadi kesalahan jaringan',
      );
    } catch (_) {
      return AuthResponse(
        status: 'error',
        message: 'Terjadi kesalahan tak terduga',
      );
    }
  }

  /// POST /auth/register-partner
  /// body: { name, email, phone, password }
  Future<AuthResponse> registerPartner({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String businessName,
    required String address,
    required double latitude,
    required double longitude,
    required Uint8List outletPhotoBytes,
    required String outletPhotoFilename,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'business_name': businessName,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'outlet_photo': MultipartFile.fromBytes(
          outletPhotoBytes,
          filename: outletPhotoFilename,
        ),
      });

      final response = await _dio.post(
        '/auth/register-partner',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return AuthResponse.fromJson(e.response!.data);
      }
      return AuthResponse(
          status: 'error', message: 'Terjadi kesalahan jaringan');
    } catch (_) {
      return AuthResponse(
          status: 'error', message: 'Terjadi kesalahan tak terduga');
    }
  }

  // Reset password dengan OTP
  Future<AuthResponse> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/password/reset', // sesuaikan dengan route Laravel
        data: {
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return AuthResponse.fromJson(e.response!.data);
      }
      return AuthResponse(
        status: 'error',
        message: 'Terjadi kesalahan jaringan',
      );
    } catch (_) {
      return AuthResponse(
        status: 'error',
        message: 'Terjadi kesalahan tak terduga',
      );
    }
  }

  /// GET /auth/me (model-based)
  Future<AuthResponse> fetchMe() async {
    try {
      final res = await _dio.get('/auth/me');

      dynamic body = res.data;
      if (body is String) body = jsonDecode(body);

      if (body is Map) {
        return AuthResponse.fromJson(Map<String, dynamic>.from(body));
      }

      return AuthResponse(status: 'error', message: 'Response tidak valid');
    } on DioException catch (e) {
      dynamic body = e.response?.data;
      if (body is String) {
        try {
          body = jsonDecode(body);
        } catch (_) {}
      }

      if (body is Map) {
        return AuthResponse.fromJson(Map<String, dynamic>.from(body));
      }

      return AuthResponse(status: 'error', message: 'Gagal memuat profil');
    } catch (_) {
      return AuthResponse(status: 'error', message: 'Terjadi kesalahan');
    }
  }

  /// kompatibilitas
  Future<User?> me() async {
    final r = await fetchMe();
    return r.user;
  }

  /// Sync FCM token ke server
  Future<void> syncFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _dio.post('/auth/fcm-token', data: {'fcm_token': token});
      }
    } catch (_) {
      // Abaikan error FCM saat setup masih berjalan / tanpa internet
    }
  }

  /// helper: bikin url public storage dari outlet_photo_path
  String buildStorageUrlFromPath(String outletPhotoPath) {
    var base =
        _dio.options.baseUrl; // contoh: https://xxxx.ngrok-free.app/api/v1
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);

    // buang /api/v1 atau /api/v2 kalau ada
    base = base.replaceFirst(RegExp(r'/api/v\d+$'), '');

    return '$base/storage/$outletPhotoPath';
  }

  Future<AuthResponse> uploadProfilePhoto({
    File? file,
    Uint8List? bytes,
    String filename = 'profile.jpg',
  }) async {
    try {
      MultipartFile mf;

      if (bytes != null) {
        mf = MultipartFile.fromBytes(bytes, filename: filename);
      } else if (file != null) {
        mf = await MultipartFile.fromFile(file.path, filename: filename);
      } else {
        return AuthResponse(
            status: 'error', message: 'File foto tidak ditemukan');
      }

      final form = FormData.fromMap({'photo': mf});
      final res = await _dio.post('/auth/profile/photo', data: form);

      return AuthResponse.fromJson(res.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        return AuthResponse.fromJson(e.response!.data);
      }
      return AuthResponse(status: 'error', message: 'Gagal upload foto profil');
    } catch (_) {
      return AuthResponse(status: 'error', message: 'Terjadi kesalahan');
    }
  }

  Future<Map<String, dynamic>> updatePartnerCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    final dio = DioClient().dio;

    final Response res = await dio.put(
      '/partner/profile',
      data: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    if (res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    // fallback kalau response bukan map
    return {
      'success': true,
      'status': 'success',
      'message': 'Koordinat diperbarui',
      'data': res.data,
    };
  }
}

import 'user.dart';
import 'partner.dart';

class AuthResponse {
  final String status; // "success" / "error"
  final String message;
  final User? user;
  final Partner? partner;
  final String? token;
  final Map<String, dynamic>? errors;

  AuthResponse({
    required this.status,
    required this.message,
    this.user,
    this.partner,
    this.token,
    this.errors,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final status = (json['status'] ?? '').toString();
    final message = (json['message'] ?? '').toString();

    final dynamic data = json['data'];
    User? user;
    Partner? partner;
    String? token;

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      // token bisa di data atau root
      token = map['token']?.toString() ?? json['token']?.toString();

      // user bisa: data.user atau data langsung user
      if (map['user'] is Map) {
        user = User.fromJson(Map<String, dynamic>.from(map['user']));
      } else if (map.containsKey('id') && map.containsKey('email')) {
        user = User.fromJson(map);
      }

      // partner object
      if (map['partner'] is Map) {
        partner = Partner.fromJson(Map<String, dynamic>.from(map['partner']));
      }
    } else {
      token = json['token']?.toString();
    }

    return AuthResponse(
      status: status,
      message: message,
      user: user,
      partner: partner,
      token: token,
      errors: json['errors'] is Map
          ? Map<String, dynamic>.from(json['errors'])
          : null,
    );
  }

  bool get isSuccess => status == 'success';
}

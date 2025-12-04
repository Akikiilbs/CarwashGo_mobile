import 'user.dart';

class AuthResponse {
  final String status; // "success" / "error"
  final String message;
  final User? user;
  final String? token;
  final Map<String, dynamic>? errors;

  AuthResponse({
    required this.status,
    required this.message,
    this.user,
    this.token,
    this.errors,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    User? user;
    String? token;

    if (data != null) {
      if (data['user'] != null) {
        user = User.fromJson(data['user']);
      }
      token = data['token'] as String?;
    }

    return AuthResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      user: user,
      token: token,
      errors: json['errors'] != null
          ? Map<String, dynamic>.from(json['errors'])
          : null,
    );
  }

  bool get isSuccess => status == 'success';
}

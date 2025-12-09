class SimpleApiResponse {
  final String status;
  final String message;
  final dynamic data;
  final Map<String, dynamic>? errors;

  SimpleApiResponse({
    required this.status,
    required this.message,
    this.data,
    this.errors,
  });

  bool get isSuccess => status == 'success';

  factory SimpleApiResponse.fromJson(Map<String, dynamic> json) {
    return SimpleApiResponse(
      status: json['status']?.toString() ?? 'error',
      message: json['message']?.toString() ?? '',
      data: json['data'],
      errors: json['errors'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['errors'])
          : null,
    );
  }
}

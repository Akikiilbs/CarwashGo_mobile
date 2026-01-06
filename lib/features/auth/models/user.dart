class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final int isActive;

  // ✅ tambahan
  final String address;
  final String profilePhotoPath;
  final String profilePhotoUrl;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    this.address = '',
    this.profilePhotoPath = '',
    this.profilePhotoUrl = '',
    this.createdAt,
    this.updatedAt,
  });

  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static int _asActive(dynamic v) {
    if (v == null) return 0;
    if (v is bool) return v ? 1 : 0;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static DateTime? _asDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _asInt(json['id']),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      isActive: _asActive(json['is_active']),

      // ✅ tambahan
      address: (json['address'] ?? '').toString(),
      profilePhotoPath: (json['profile_photo_path'] ?? '').toString(),
      profilePhotoUrl: (json['profile_photo_url'] ?? '').toString(),

      createdAt: _asDate(json['created_at']),
      updatedAt: _asDate(json['updated_at']),
    );
  }
}

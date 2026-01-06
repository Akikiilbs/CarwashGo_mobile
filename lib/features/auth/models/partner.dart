class Partner {
  final int id;
  final int userId;
  final String businessName;
  final String outletPhotoPath;
  final String outletPhotoUrl;
  final String address;
  final double? latitude;
  final double? longitude;
  final String status;

  Partner({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.outletPhotoPath,
    required this.outletPhotoUrl,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
  });

  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: _asInt(json['id']),
      userId: _asInt(json['user_id']),
      businessName: (json['business_name'] ?? '').toString(),
      outletPhotoPath: (json['outlet_photo_path'] ?? '').toString(),
      outletPhotoUrl: (json['outlet_photo_url'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      status: (json['status'] ?? '').toString(),
    );
  }
}

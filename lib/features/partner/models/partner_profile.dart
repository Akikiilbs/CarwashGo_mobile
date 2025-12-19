class PartnerServiceItem {
  final int id;
  final String? serviceName;
  final String? vehicleType;
  final double price;
  final bool isActive;

  PartnerServiceItem({
    required this.id,
    required this.serviceName,
    required this.vehicleType,
    required this.price,
    required this.isActive,
  });

  factory PartnerServiceItem.fromJson(Map<String, dynamic> json) {
    return PartnerServiceItem(
      id: json['id'] as int,
      serviceName: json['service_name'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      price: (json['price'] as num).toDouble(),
      isActive: json['is_active'] == true,
    );
  }
}

class PartnerUserInfo {
  final int id;
  final String name;
  final String email;
  final String phone;

  PartnerUserInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory PartnerUserInfo.fromJson(Map<String, dynamic> json) {
    return PartnerUserInfo(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }
}

class PartnerProfile {
  final int id;
  final String businessName;
  final String address;
  final String status;
  final double? latitude;
  final double? longitude;
  final PartnerUserInfo user;
  final List<PartnerServiceItem> services;

  PartnerProfile({
    required this.id,
    required this.businessName,
    required this.address,
    required this.status,
    this.latitude,
    this.longitude,
    required this.user,
    required this.services,
  });

  factory PartnerProfile.fromJson(Map<String, dynamic> json) {
    return PartnerProfile(
      id: json['id'] as int,
      businessName: json['business_name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      status: json['status'] as String? ?? '',
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      user: PartnerUserInfo.fromJson(json['user'] as Map<String, dynamic>),
      services: (json['services'] as List<dynamic>? ?? [])
          .map((e) => PartnerServiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

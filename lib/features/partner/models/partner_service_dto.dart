class PartnerServiceDto {
  final int id;
  final int serviceId;
  final int vehicleTypeId;
  final String? serviceName;
  final String? vehicleTypeName;
  final int price;
  final bool isActive;

  PartnerServiceDto({
    required this.id,
    required this.serviceId,
    required this.vehicleTypeId,
    required this.serviceName,
    required this.vehicleTypeName,
    required this.price,
    required this.isActive,
  });

  factory PartnerServiceDto.fromJson(Map<String, dynamic> json) {
    return PartnerServiceDto(
      id: (json['id'] as num).toInt(),
      serviceId: (json['service_id'] as num).toInt(),
      vehicleTypeId: (json['vehicle_type_id'] as num).toInt(),
      serviceName: json['service_name'] as String?,
      vehicleTypeName: json['vehicle_type'] as String?,
      price: (json['price'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] == true,
    );
  }
}

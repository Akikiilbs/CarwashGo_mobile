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
    String? sName = json['service_name'] as String?;
    if (sName == null && json['service'] is Map) {
      sName = json['service']['name']?.toString();
    }

    String? vName = json['vehicle_type_name'] as String?;
    if (vName == null && json['vehicle_type'] is Map) {
      vName = json['vehicle_type']['name']?.toString();
    } else if (vName == null && json['vehicle_type'] is String) {
      vName = json['vehicle_type'] as String;
    }

    return PartnerServiceDto(
      id: (json['id'] as num).toInt(),
      serviceId: (json['service_id'] as num).toInt(),
      vehicleTypeId: (json['vehicle_type_id'] as num).toInt(),
      serviceName: sName,
      vehicleTypeName: vName,
      price: (json['price'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] == true,
    );
  }
}

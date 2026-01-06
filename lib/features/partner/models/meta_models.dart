class MetaService {
  final int id;
  final String name;
  final String? categoryName;
  final int basePrice;
  final bool isActive;

  MetaService({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.basePrice,
    required this.isActive,
  });

  factory MetaService.fromJson(Map<String, dynamic> json) {
    return MetaService(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      categoryName: json['category_name'] as String?,
      basePrice: (json['base_price'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] == true,
    );
  }
}

class VehicleTypeDto {
  final int id;
  final String code;
  final String name;
  final String? description;

  VehicleTypeDto({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
  });

  factory VehicleTypeDto.fromJson(Map<String, dynamic> json) {
    return VehicleTypeDto(
      id: (json['id'] as num).toInt(),
      code: (json['code'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      description: json['description'] as String?,
    );
  }
}

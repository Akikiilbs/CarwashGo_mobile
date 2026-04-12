class MitraStation {
  final String id;
  final String name;
  final String location;
  final double rating;
  final String image;

  final String description;
  final String jamOperasional;
  final String hariOperasional;
  final String harga;

  final double? latitude;
  final double? longitude;
  final double? distanceKm;

  MitraStation({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.image,
    required this.description,
    required this.jamOperasional,
    required this.hariOperasional,
    required this.harga,
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  factory MitraStation.fromJson(Map<String, dynamic> json) {
    return MitraStation(
      id: (json['id'] ?? '').toString(),
      name: json['business_name'] ?? json['name'] ?? '',
      location: json['address'] ?? json['location'] ?? '',
      rating: (json['rating'] ?? 5.0).toDouble(),
      image: json['outlet_photo_url'] ?? json['image'] ?? 'assets/images/mobil1.png',
      description: json['description'] ?? '',
      jamOperasional: json['operating_hours'] ?? json['jamOperasional'] ?? '08.00 - 17.00',
      hariOperasional: json['operating_days'] ?? json['hariOperasional'] ?? 'Senin - Sabtu',
      harga: (json['harga'] ?? '50.000').toString(),
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      distanceKm: json['distance_km'] != null ? (json['distance_km'] as num).toDouble() : null,
    );
  }
}

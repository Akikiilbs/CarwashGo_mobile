// lib/models/order_model.dart

class Order {
  /// ID mitra pemilik station.
  /// Sekarang dibuat opsional karena belum selalu dikirim.
  final String? mitraId;

  final String title;
  final String date;
  final String time;
  final String status;
  final String image;
  final String location;
  final String detailAddress;
  final String plateNumber;
  final String username;
  final String phoneNumber;
  final String bookingId;
  final String carType;
  final int price;
  final int servicePrice;
  final int tax;
  final int discount;
  final int total;

  Order({
    this.mitraId,                // ✅ tidak wajib lagi
    required this.title,
    required this.date,
    required this.time,
    required this.status,
    required this.image,
    required this.location,
    required this.detailAddress,
    required this.plateNumber,
    required this.username,
    required this.phoneNumber,
    required this.bookingId,
    required this.carType,
    required this.price,
    required this.servicePrice,
    required this.tax,
    required this.discount,
    required this.total,
  });

  /// Optional: helper kalau nanti mau update sebagian field
  Order copyWith({
    String? mitraId,
    String? title,
    String? date,
    String? time,
    String? status,
    String? image,
    String? location,
    String? detailAddress,
    String? plateNumber,
    String? username,
    String? phoneNumber,
    String? bookingId,
    String? carType,
    int? price,
    int? servicePrice,
    int? tax,
    int? discount,
    int? total,
  }) {
    return Order(
      mitraId: mitraId ?? this.mitraId,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      image: image ?? this.image,
      location: location ?? this.location,
      detailAddress: detailAddress ?? this.detailAddress,
      plateNumber: plateNumber ?? this.plateNumber,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bookingId: bookingId ?? this.bookingId,
      carType: carType ?? this.carType,
      price: price ?? this.price,
      servicePrice: servicePrice ?? this.servicePrice,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
    );
  }
}

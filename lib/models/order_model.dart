// lib/models/order_model.dart

class Order {
  /// ID mitra pemilik station.
  final String? mitraId;

  // ✅ TAMBAHAN UNTUK MAP
  final int? partnerId;
  final double? latitude;
  final double? longitude;

  final String title;
  final String date;
  final String time;
  final String status;
  final String paymentStatus; // unpaid|paid|pending|failed|expired
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
    this.mitraId,
    this.partnerId,
    this.latitude,
    this.longitude,
    required this.title,
    required this.date,
    required this.time,
    required this.status,
    this.paymentStatus = 'unpaid',
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

  Order copyWith({
    String? mitraId,
    int? partnerId,
    double? latitude,
    double? longitude,
    String? title,
    String? date,
    String? time,
    String? status,
    String? paymentStatus,
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
      partnerId: partnerId ?? this.partnerId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
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

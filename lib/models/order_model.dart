class Order {
  final String title;
  final String date;
  final String time;
  final String status;
  final String image;

  // Lokasi utama (alamat dari map)
  final String location;

  // Detail alamat & plat nomor (baru)
  final String detailAddress;
  final String plateNumber;

  // Data user & booking
  final String username;
  final String phoneNumber;
  final String bookingId;
  final String carType;

  // Harga
  final int price;
  final int servicePrice;
  final int tax;
  final int discount;
  final int total;

  Order({
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
}

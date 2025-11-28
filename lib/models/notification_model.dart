class AppNotification {
  final String title;    // Judul notifikasi
  final String message;  // Pesan detail
  final String time;     // Waktu notifikasi
  bool isNew;            // Apakah notifikasi baru atau sudah dibaca

  AppNotification({
    required this.title,
    required this.message,
    required this.time,
    this.isNew = true,
  });

  // 🔹 Konversi ke Map (berguna untuk penyimpanan lokal nanti)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'time': time,
      'isNew': isNew,
    };
  }

  // 🔹 Konversi dari Map ke Model
  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      time: map['time'] ?? '',
      isNew: map['isNew'] ?? true,
    );
  }
}

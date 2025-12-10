import 'package:flutter/material.dart';

class ReviewPopup extends StatefulWidget {
  final String mitraName;

  const ReviewPopup({
    super.key,
    required this.mitraName,
  });

  @override
  State<ReviewPopup> createState() => _ReviewPopupState();
}

class _ReviewPopupState extends State<ReviewPopup> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Judul
            Text(
              "Beri Ulasan",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              widget.mitraName,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 16),

            // ✅ BINTANG RATING
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _rating = starIndex;
                    });
                  },
                  icon: Icon(
                    Icons.star,
                    size: 30,
                    color: _rating >= starIndex
                        ? Colors.amber
                        : Colors.grey.shade300,
                  ),
                );
              }),
            ),

            const SizedBox(height: 12),

            // ✅ INPUT KOMENTAR
            TextField(
              controller: _reviewController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Tulis ulasan kamu...",
                filled: true,
                fillColor: const Color(0xFFF6F8FC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E6F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ TOMBOL KIRIM
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_rating == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Silakan beri rating terlebih dahulu"),
                      ),
                    );
                    return;
                  }

                  final reviewText = _reviewController.text.trim();

                  // ✅ KIRIM BALIK DATA KE ORDERS TAB
                  Navigator.pop(context, {
                    "rating": _rating,
                    "review": reviewText,
                  });
                },
                child: const Text(
                  "Kirim Ulasan",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

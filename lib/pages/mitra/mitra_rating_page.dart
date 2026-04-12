import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/review_provider.dart';
import '../navigation/bottom_nav_mitra.dart';

class MitraRatingPage extends StatefulWidget {
  const MitraRatingPage({super.key});

  @override
  State<MitraRatingPage> createState() => _MitraRatingPageState();
}

class _MitraRatingPageState extends State<MitraRatingPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ReviewProvider>().loadPartnerReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ReviewProvider>();
    final reviews = prov.reviews;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Rating Pelanggan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : (reviews.isEmpty
              ? const Center(
                  child: Text(
                    "Belum ada ulasan",
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];

                    return Container(
                      padding: const EdgeInsets.all(18),
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.08),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                review.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "⭐ ${review.rating}",
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(review.comment),
                        ],
                      ),
                    );
                  },
                )),

      bottomNavigationBar: const BottomNavMitra(currentIndex: 2),
    );
  }
}

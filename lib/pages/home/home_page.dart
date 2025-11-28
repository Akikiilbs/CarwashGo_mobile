import 'package:flutter/material.dart';
import '../navigation/detail_station_page.dart';
import '../navigation/bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _stations = [
    {
      "name": "Pak De Station",
      "location": "Tampan, Pekanbaru",
      "rating": 5.0,
      "image": "assets/images/mobil1.png"
    },
    {
      "name": "Haji Rahmat Habsin Station",
      "location": "Tampan, Pekanbaru",
      "rating": 5.0,
      "image": "assets/images/on1.png"
    },
    {
      "name": "R CarWash Station",
      "location": "Tampan, Pekanbaru",
      "rating": 4.0,
      "image": "assets/images/carwashgo_logo.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              const Text(
                "Welcome !!!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent
                ),
              ),

              const Text(
                "Have a good day",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueAccent
                ),
              ),

              const SizedBox(height: 25),

              // SPECIAL OFFER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Special Offer !!!",
                              style: TextStyle(color: Colors.white, fontSize: 16)),
                          SizedBox(height: 5),
                          Text("50% OFF",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold)),
                          Text("On First Service",
                              style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ),
                    Expanded(child: Image.asset("assets/images/on1.png"))
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Recommend Station",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent
                ),
              ),

              const SizedBox(height: 16),

              Column(
                children: _stations.map((station) {
                  return _buildStationCard(
                    context: context,
                    image: station["image"],
                    name: station["name"],
                    location: station["location"],
                    rating: station["rating"],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  Widget _buildStationCard({
    required BuildContext context,
    required String image,
    required String name,
    required String location,
    required double rating,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(image, width: 70, height: 70),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: Colors.blueAccent, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(location,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (i) => Icon(
                        i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                        size: 18,
                        color: Colors.amber,
                      ),
                    ),
                    Text(" (${rating.toStringAsFixed(1)})",
                        style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailStationPage(
                    image: image,
                    name: name,
                    location: location,
                    rating: rating,
                  ),
                ),
              );
            },
            child: const Text("Book Now", style: TextStyle(color: Colors.blueAccent)),
          )
        ],
      ),
    );
  }
}

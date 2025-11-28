import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../navigation/detail_station_page.dart';
import '../navigation/bottom_nav.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();

  final List<Map<String, dynamic>> stations = [
    {
      "name": "Pak De Station",
      "image": "assets/images/mobil1.png",
      "rating": 5.0,
      "distance": "0.3 km",
      "location": LatLng(0.5175, 101.4475),
      "city": "Tampan, Pekanbaru"
    },
    {
      "name": "R CarWash Station",
      "image": "assets/images/on1.png",
      "rating": 5.0,
      "distance": "1.5 km",
      "location": LatLng(0.5190, 101.4580),
      "city": "Tampan, Pekanbaru"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: const MapOptions(
              initialCenter: LatLng(0.5176, 101.4477),
              initialZoom: 14.5,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  for (var station in stations)
                    Marker(
                      width: 40,
                      height: 40,
                      point: station["location"],
                      child: const Icon(Icons.location_on,
                          color: Colors.blueAccent, size: 35),
                    )
                ],
              )
            ],
          ),

          // Search bar
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search Your Location...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                ],
              ),
            ),
          ),

          // Card list
          Positioned(
            bottom: 85,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 170,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 15),
                itemCount: stations.length,
                itemBuilder: (context, index) {
                  final station = stations[index];
                  return GestureDetector(
                    onTap: () {
                      mapController.move(station["location"], 15);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailStationPage(
                            image: station["image"],
                            name: station["name"],
                            location: station["city"],
                            rating: station["rating"],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 260,
                      margin: const EdgeInsets.only(right: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.asset(
                              station["image"],
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(station["name"],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 15, color: Colors.grey),
                                          Text(station["distance"],
                                              style: const TextStyle(
                                                  color: Colors.grey, fontSize: 13)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star,
                                          size: 14, color: Colors.amber),
                                      const SizedBox(width: 3),
                                      Text(station["rating"].toString(),
                                          style: const TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNav(currentIndex: 1),
    );
  }
}

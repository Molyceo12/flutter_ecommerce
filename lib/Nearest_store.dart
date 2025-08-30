import 'package:flutter/material.dart';

class NearestStores extends StatelessWidget {
  const NearestStores({super.key});

  // Static dummy store data with local assets
  final List<Map<String, String>> stores = const [
    {
      "name": "Fresh Mart",
      "country": "Uganda",
      "image": "assets/uganda.jpeg",
    },
    {
      "name": "SuperShop",
      "country": "Nigeria",
      "image": "assets/nigeria.jpeg",
    },
    {
      "name": "City Market",
      "country": "Kenya",
      "image": "assets/kenya.jpeg",
    },
    {
      "name": "Tanzania Mart",
      "country": "Tanzania",
      "image": "assets/tanzania.jpeg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Text(
            "Nearest Stores",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
              return Card(
                margin: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: SizedBox(
                  width: 160,
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.asset(
                            store["image"]!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store["name"]!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              store["country"]!,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 6),
                            // Fake location icons row
                            Row(
                              children: const [
                                Icon(Icons.location_on,
                                    size: 14, color: Colors.redAccent),
                                SizedBox(width: 4),
                                Icon(Icons.delivery_dining,
                                    size: 14, color: Colors.green),
                                SizedBox(width: 4),
                                Icon(Icons.directions,
                                    size: 14, color: Colors.blue),
                                SizedBox(width: 4),
                                Icon(Icons.store,
                                    size: 14, color: Colors.orange),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

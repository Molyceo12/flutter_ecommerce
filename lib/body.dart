import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/Nearest_store.dart';
import 'package:flutter_ecommerce/whychoose.dart';
import 'product.dart';

class Body extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const Body({super.key, required this.products});

  // Static dummy store locations
  static const List<String> dummyStores = [
    "Main Street, NY",
    "Broadway Ave, NY",
    "5th Ave, NY",
    "Market Street, NY"
  ];

  // Group products by category using name keywords
  Map<String, List<Map<String, dynamic>>> _groupByCategory() {
    Map<String, List<Map<String, dynamic>>> categories = {
      "Food": [],
      "Clothes": [],
      "Shoes": [],
      "Coffee": [],
      "Liquor": [],
      "Groceries": [],
    };

    for (var p in products) {
      final name = p["name"].toString().toLowerCase();
      if (name.contains("pizza") ||
          name.contains("kfc") ||
          name.contains("big mac")) {
        categories["Food"]!.add(p);
      } else if (name.contains("shirt") ||
          name.contains("clothes") ||
          name.contains("jeans")) {
        categories["Clothes"]!.add(p);
      } else if (name.contains("nike") || name.contains("puma")) {
        categories["Shoes"]!.add(p);
      } else if (name.contains("coffee") ||
          name.contains("latte") ||
          name.contains("espresso") ||
          name.contains("blue bottle")) {
        categories["Coffee"]!.add(p);
      } else if (name.contains("vodka") ||
          name.contains("whisky") ||
          name.contains("heineken")) {
        categories["Liquor"]!.add(p);
      } else {
        categories["Groceries"]!.add(p);
      }
    }
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    final categories = _groupByCategory();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Welcome to",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 4),
                const Text(
                  "MarketFlow",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple),
                      onPressed: () {},
                      child: const Text("Start Shopping"),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white),
                          foregroundColor: Colors.white),
                      onPressed: () {},
                      child: const Text("Become Seller"),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Categories Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Shop by Category",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 12),

          // Display products per category
          for (var entry in categories.entries)
            if (entry.value.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: entry.value.length,
                      itemBuilder: (context, index) {
                        final product = entry.value[index];
                        final store = dummyStores[
                            index % dummyStores.length]; // static location

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      ProductPage(product: product)),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.all(8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                            child: SizedBox(
                              width: 140,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12)),
                                      child: Image.asset(product["image"],
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(product["name"],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                        Text("\$${product["price"]}",
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on,
                                                size: 14,
                                                color: Colors.redAccent),
                                            const SizedBox(width: 2),
                                            Expanded(
                                              child: Text(
                                                store,
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
          const NearestStores(),
          const WhyChoose(),
        ],
      ),
    );
  }
}

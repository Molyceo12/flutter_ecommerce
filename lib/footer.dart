import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.deepPurple.shade700,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section: Logo + About + Contact + Social/Newsletter
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 40, // horizontal spacing
                runSpacing: 20, // vertical spacing
                children: [
                  // Company Info
                  SizedBox(
                    width: constraints.maxWidth < 800
                        ? constraints.maxWidth
                        : constraints.maxWidth / 3 - 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "MarketFlow",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "MarketFlow is your ultimate online marketplace. Buy shoes, clothes, coffee, liquor, groceries, and food from top brands delivered right to your doorstep.",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  // Contact Info
                  SizedBox(
                    width: constraints.maxWidth < 800
                        ? constraints.maxWidth
                        : constraints.maxWidth / 3 - 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Contact Us",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12),
                        Text("Email: support@marketflow.com",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14)),
                        SizedBox(height: 4),
                        Text("Phone: +1 234 567 890",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14)),
                        SizedBox(height: 4),
                        Text("Address: 123 Market St, City, Country",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                  // Social + Newsletter
                  SizedBox(
                    width: constraints.maxWidth < 800
                        ? constraints.maxWidth
                        : constraints.maxWidth / 3 - 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Follow Us",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          children: [
                            _socialIcon(Icons.facebook),
                            _socialIcon(Icons.camera_alt),
                            _socialIcon(Icons.alternate_email),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Subscribe to our newsletter",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "Enter your email",
                                  hintStyle:
                                      const TextStyle(color: Colors.white54),
                                  filled: true,
                                  fillColor: Colors.deepPurple.shade500,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orangeAccent),
                              child: const Text("Subscribe"),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 30),
          const Divider(color: Colors.white38),
          const SizedBox(height: 12),
          // Bottom Section: copyright
          const Center(
            child: Text(
              "© 2024 MarketFlow. All rights reserved.",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}

Widget _socialIcon(IconData icon) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white24,
      shape: BoxShape.circle,
    ),
    child: Icon(
      icon,
      color: Colors.white,
      size: 20,
    ),
  );
}

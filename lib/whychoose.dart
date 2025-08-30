import 'package:flutter/material.dart';

class WhyChoose extends StatelessWidget {
  const WhyChoose({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Why Choose MarketFlow?",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          ListTile(
            leading: Icon(Icons.shopping_cart, color: Colors.deepPurple),
            title: Text("Wide Variety"),
            subtitle:
                Text("From food to fashion, shop everything in one place."),
          ),
          ListTile(
            leading: Icon(Icons.local_shipping, color: Colors.deepPurple),
            title: Text("Fast Delivery"),
            subtitle: Text("Get your orders delivered quickly and reliably."),
          ),
          ListTile(
            leading: Icon(Icons.security, color: Colors.deepPurple),
            title: Text("Secure Payments"),
            subtitle: Text("Pay safely with multiple payment options."),
          ),
          ListTile(
            leading: Icon(Icons.star, color: Colors.deepPurple),
            title: Text("Trusted by Thousands"),
            subtitle: Text("Join a growing community of happy shoppers."),
          ),
        ],
      ),
    );
  }
}

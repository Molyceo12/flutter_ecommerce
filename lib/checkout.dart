import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/homescreen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutPage extends StatefulWidget {
  final double subtotal;
  final double tax;
  final double shippingFee;
  final double total;

  const CheckoutPage({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.shippingFee,
    required this.total,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _paymentController = TextEditingController();

  bool _orderPlaced = false;
  List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) return;

    final dbPath = join(await getDatabasesPath(), 'ecommerce.db');
    final db = await openDatabase(dbPath);

    final cartData = await db.rawQuery('''
      SELECT cart.productId, cart.quantity, products.name, products.price
      FROM cart
      JOIN products ON cart.productId = products.id
      WHERE cart.userId = ?
    ''', [userId]);

    setState(() {
      _cartItems = cartData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Shipping & Payment Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSmallTextField(
                controller: _nameController,
                icon: Icons.person,
                label: "Full Name"),
            const SizedBox(height: 8),
            _buildSmallTextField(
                controller: _addressController,
                icon: Icons.home,
                label: "Kigali, Rwanda, Nyarugenge"),
            const SizedBox(height: 8),
            _buildSmallTextField(
                controller: _emailController,
                icon: Icons.email,
                label: "Email"),
            const SizedBox(height: 8),
            _buildSmallTextField(
                controller: _paymentController,
                icon: Icons.payment,
                label: "Payment Info"),
            const SizedBox(height: 24),
            const Text(
              "Order Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildSummaryRow("Items", "${_cartItems.length}"),
            _buildSummaryRow(
                "Subtotal", "\$${widget.subtotal.toStringAsFixed(2)}"),
            _buildSummaryRow("Tax (10%)", "\$${widget.tax.toStringAsFixed(2)}"),
            _buildSummaryRow(
                "Shipping Fee", "\$${widget.shippingFee.toStringAsFixed(2)}"),
            const Divider(),
            _buildSummaryRow(
              "Total",
              "\$${widget.total.toStringAsFixed(2)}",
              isBold: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _placeOrder(context),
              child: const Text(
                "Place Order",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    String? hintText,
  }) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 18),
          labelText: label,
          hintText: hintText,
          labelStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final email = _emailController.text.trim();
    final payment = _paymentController.text.trim();

    if (name.isEmpty || address.isEmpty || email.isEmpty || payment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final dbPath = join(await getDatabasesPath(), 'ecommerce.db');
    final db = await openDatabase(dbPath);

    final cartItems =
        await db.query('cart', where: 'userId = ?', whereArgs: [userId]);

    for (final item in cartItems) {
      await db.insert('orders', {
        "userId": userId,
        "productId": item['productId'],
        "fullName": name,
        "quantity": item['quantity'] ?? 1,
        "address": address,
        "email": email,
        "paymentInfo": payment,
      });
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Order Placed Successfully ✅"),
        content: const Text("Thank you for your purchase!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const Homescreen()),
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

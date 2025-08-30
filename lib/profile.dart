import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int? _userId;
  String _username = "User";
  late Database _db;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _initDatabaseAndLoadUser();
  }

  Future<void> _initDatabaseAndLoadUser() async {
    _db = await openDatabase(join(await getDatabasesPath(), 'ecommerce.db'));

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      setState(() {
        _userId = userId;
      });

      // Fetch username
      final userResult = await _db.query(
        'users',
        columns: ['username'],
        where: 'id = ?',
        whereArgs: [userId],
      );
      if (userResult.isNotEmpty) {
        setState(() {
          _username = userResult.first['username'] as String;
        });
      }

      // Fetch recent orders
      await _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    if (_userId == null) return;

    final results = await _db.rawQuery('''
      SELECT o.id as orderId, o.productId, o.quantity, o.fullName, o.address, o.email, o.paymentInfo, p.name as productName, p.image as productImage
      FROM orders o
      JOIN products p ON o.productId = p.id
      WHERE o.userId = ?
      ORDER BY o.orderDate DESC
    ''', [_userId]);

    setState(() {
      _orders = results;
    });
  }

  Future<void> _deleteOrder(int orderId) async {
    await _db.delete('orders', where: 'id = ?', whereArgs: [orderId]);
    await _loadOrders();
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('username');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile image and username
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple,
              child: Text(
                _username.isNotEmpty ? _username[0].toUpperCase() : "U",
                style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _username,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple),
            ),
            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent Orders",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            // Orders list
            if (_orders.isEmpty)
              const Center(
                child: Text("No orders yet"),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          order['productImage'] ?? 'assets/default.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(order['productName']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Quantity: ${order['quantity']}"),
                          Text("Address: ${order['address']}"),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteOrder(order['orderId']),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

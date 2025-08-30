import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'checkout.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Database _db;
  int? _userId;
  List<Map<String, dynamic>> _cartProducts = [];
  Map<int, int> _quantities = {}; // productId -> quantity

  @override
  void initState() {
    super.initState();
    _initCart();
  }

  Future<void> _initCart() async {
    await _openDatabase();
    await _loadUserId();
    if (_userId != null) {
      await _loadCartProducts();
    }
  }

  Future<void> _openDatabase() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), 'ecommerce.db'),
      version: 1,
    );
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    setState(() {
      _userId = userId;
    });
  }

  Future<void> _loadCartProducts() async {
    try {
      final cartItems = await _db.query(
        'cart',
        columns: ['productId'],
        where: 'userId = ?',
        whereArgs: [_userId],
      );

      if (cartItems.isEmpty) {
        setState(() {
          _cartProducts = [];
          _quantities = {};
        });
        return;
      }

      final ids = cartItems.map((e) => e['productId']).toList();
      final placeholders = List.filled(ids.length, '?').join(', ');
      final products = await _db.rawQuery(
        'SELECT * FROM products WHERE id IN ($placeholders)',
        ids,
      );

      setState(() {
        _cartProducts = products;
        _quantities = {for (var p in products) p['id'] as int: 1};
      });
    } catch (e) {
      debugPrint("❌ Error loading cart products: $e");
    }
  }

  void _incrementQuantity(int productId) {
    setState(() {
      _quantities[productId] = (_quantities[productId] ?? 1) + 1;
    });
  }

  void _decrementQuantity(int productId) {
    setState(() {
      if ((_quantities[productId] ?? 1) > 1) {
        _quantities[productId] = (_quantities[productId] ?? 1) - 1;
      }
    });
  }

  void _removeProduct(int productId) async {
    try {
      await _db.delete(
        'cart',
        where: 'userId = ? AND productId = ?',
        whereArgs: [_userId, productId],
      );
      await _loadCartProducts(); // refresh immediately after deletion
      debugPrint("🗑️ Product $productId removed from cart");
    } catch (e) {
      debugPrint("❌ Error removing product: $e");
    }
  }

  int get _totalItems => _quantities.values.fold(0, (a, b) => a + b);

  double get _totalPrice {
    double total = 0;
    for (var product in _cartProducts) {
      final id = product['id'] as int;
      final qty = _quantities[id] ?? 1;
      total += (product['price'] as num).toDouble() * qty;
    }
    return total;
  }

  double get _tax => _totalPrice * 0.1; // 10% tax
  double get _shippingFee => _totalPrice > 0 ? 5.0 : 0; // flat fee
  double get _grandTotal => _totalPrice + _tax + _shippingFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _cartProducts.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : ListView(
              padding: const EdgeInsets.only(bottom: 200),
              children: [
                ..._cartProducts.map((product) {
                  final id = product['id'] as int;
                  final qty = _quantities[id] ?? 1;

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            product['image'],
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(height: 4),
                                Text("\$${product['price']}",
                                    style: const TextStyle(
                                        color: Colors.deepPurple,
                                        fontSize: 14)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _decrementQuantity(id),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade400),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Icon(
                                          Icons.remove,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Text(qty.toString(),
                                          style: const TextStyle(fontSize: 16)),
                                    ),
                                    GestureDetector(
                                      onTap: () => _incrementQuantity(id),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade400),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Icon(
                                          Icons.add,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                onPressed: () => _removeProduct(id),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                // Order summary card
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    color: Colors.grey.shade100,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Order Summary",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Items"),
                              Text("$_totalItems"),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Subtotal"),
                              Text("\$${_totalPrice.toStringAsFixed(2)}"),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Tax (10%)"),
                              Text("\$${_tax.toStringAsFixed(2)}"),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Shipping Fee"),
                              Text("\$${_shippingFee.toStringAsFixed(2)}"),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "\$${_grandTotal.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12)),
                            onPressed: () {
                              if (_cartProducts.isEmpty) return;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckoutPage(
                                    subtotal: _totalPrice,
                                    tax: _tax,
                                    shippingFee: _shippingFee,
                                    total: _grandTotal,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Checkout",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

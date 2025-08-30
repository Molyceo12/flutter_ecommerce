import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'header.dart';
import 'body.dart';
import 'footer.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  late Database _db;
  List<Map<String, dynamic>> _products = [];
  int _cartCount = 0;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    _db = await openDatabase(join(await getDatabasesPath(), 'ecommerce.db'));
    final result = await _db.query('products');
    setState(() {
      _products = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const Header(),
                  Body(
                    products: _products,
                  ),
                  const Footer(),
                ],
              ),
            ),
    );
  }
}

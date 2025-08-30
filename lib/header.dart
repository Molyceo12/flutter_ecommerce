import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'login.dart';
import 'cart.dart';
import 'profile.dart'; // Make sure you have this file

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  String? _username;
  int? _userId;
  int _cartCount = 0;
  late Database _db;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initDatabaseAndLoadUser();

    // Refresh cart count every 0.5 seconds
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _loadCartCount();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initDatabaseAndLoadUser() async {
    await _openDatabase();
    await _loadUserData();
    await _loadCartCount();
  }

  Future<void> _openDatabase() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), 'ecommerce.db'),
      version: 1,
    );
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId != null) {
        final result = await _db.query(
          'users',
          columns: ['username'],
          where: 'id = ?',
          whereArgs: [userId],
        );

        final username =
            (result.isNotEmpty) ? result.first['username'] as String : 'User';

        setState(() {
          _userId = userId;
          _username = username;
        });
      }
    } catch (e) {
      debugPrint("❌ Error loading user data: $e");
    }
  }

  Future<void> _loadCartCount() async {
    if (_userId == null) return;

    try {
      final count = Sqflite.firstIntValue(await _db.rawQuery(
        "SELECT COUNT(*) FROM cart WHERE userId = ?",
        [_userId],
      ));

      if (_cartCount != (count ?? 0)) {
        setState(() {
          _cartCount = count ?? 0;
        });
      }
    } catch (e) {
      debugPrint("❌ Error loading cart count: $e");
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.remove('username');

      setState(() {
        _userId = null;
        _username = null;
        _cartCount = 0;
      });
    } catch (e) {
      debugPrint("❌ Logout error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 27),
      color: Colors.deepPurple,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "MarketFlow",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              if (_userId != null)
                GestureDetector(
                  onTap: () {
                    // Navigate to profile page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                  child: Text(
                    "Hello, $_username!",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              const SizedBox(width: 16),
              Container(
                width: 50,
                height: 50,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartPage()),
                    ).then((_) => _loadCartCount());
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Center(
                        child: Icon(Icons.shopping_cart,
                            size: 32, color: Colors.white),
                      ),
                      if (_cartCount > 0)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Text(
                              '$_cartCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

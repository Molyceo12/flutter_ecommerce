import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/homescreen.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Open the database
  final dbPath = join(await getDatabasesPath(), 'ecommerce.db');
  final db = await openDatabase(dbPath, version: 1);

  // Ensure users table
  await db.execute('''
    CREATE TABLE IF NOT EXISTS users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT,
      email TEXT UNIQUE,
      password TEXT
    )
  ''');
  debugPrint("✅ Users table ensured");

  // Ensure products table
  await db.execute('''
    CREATE TABLE IF NOT EXISTS products(
      id INTEGER PRIMARY KEY,
      name TEXT,
      price REAL,
      image TEXT
    )
  ''');
  debugPrint("✅ Products table ensured");

  // Ensure cart table
  await db.execute('''
    CREATE TABLE IF NOT EXISTS cart(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER,
      productId INTEGER
    )
  ''');
  debugPrint("✅ Cart table ensured");

  // Check if orders table exists
  final tableCheck = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='orders'");
  if (tableCheck.isNotEmpty) {
    debugPrint("ℹ️ Orders table already exists");
  } else {
    // Create orders table
    await db.execute('''
      CREATE TABLE orders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        fullName TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        address TEXT NOT NULL,
        email TEXT NOT NULL,
        paymentInfo TEXT NOT NULL,
        orderDate TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    debugPrint("✅ Orders table created successfully");
  }

  // Insert products only if empty
  final productCount = Sqflite.firstIntValue(
    await db.rawQuery('SELECT COUNT(*) FROM products'),
  );
  if (productCount == 0) {
    await insertProducts(db);
  }

  runApp(const MyApp());
}

Future<void> insertProducts(Database db) async {
  final products = [
    {"name": "Big Mac", "price": 5.99, "image": "assets/big-mac-food.jpeg"},
    {"name": "KFC Chicken", "price": 7.49, "image": "assets/kfc-chicken.jpeg"},
    {"name": "Pizza", "price": 9.99, "image": "assets/pizza.jpeg"},
    {"name": "Latte", "price": 3.49, "image": "assets/latte.jpeg"},
    {
      "name": "Blue Bottle Coffee",
      "price": 4.99,
      "image": "assets/bluee-bottle-coffe.jpeg"
    },
    {"name": "Espresso", "price": 2.99, "image": "assets/essperaso.jpeg"},
    {
      "name": "Organic Banana",
      "price": 1.20,
      "image": "assets/organic-banana.jpeg"
    },
    {"name": "Milk", "price": 1.50, "image": "assets/milk.jpeg"},
    {"name": "Wheat Bread", "price": 2.20, "image": "assets/wheat-bread.jpeg"},
    {"name": "Heineken", "price": 3.00, "image": "assets/heinken.jpeg"},
    {"name": "Vodka", "price": 12.00, "image": "assets/vodka.jpeg"},
    {"name": "Whisky", "price": 18.50, "image": "assets/whisky.jpeg"},
    {
      "name": "Nike Air Force",
      "price": 120.00,
      "image": "assets/nike-air-force.jpeg"
    },
    {"name": "Nike Shoes", "price": 90.00, "image": "assets/nike.jpeg"},
    {"name": "Puma Shoes", "price": 85.00, "image": "assets/puma.jpeg"},
    {"name": "Levis Jeans", "price": 60.00, "image": "assets/levis.jpeg"},
    {"name": "H&M Clothes", "price": 45.00, "image": "assets/hm-clothes.jpeg"},
    {"name": "Zara Shirt", "price": 50.00, "image": "assets/zara.jpeg"},
    {
      "name": "Uniqlo T-Shirt",
      "price": 25.00,
      "image": "assets/uniqlo-t-shirt.jpeg"
    },
  ];

  for (final p in products) {
    await db.insert("products", p);
  }
  debugPrint("✅ Products inserted successfully");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: const Homescreen(),
      ),
    );
  }
}

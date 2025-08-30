import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'login.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  String _username = '', _email = '', _password = '';
  late Database _db;

  @override
  void initState() {
    super.initState();
    _openDatabase();
  }

  // Open existing database only
  Future<void> _openDatabase() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), 'ecommerce.db'), // same as main.dart
      version: 1,
    );
    debugPrint("✅ Database opened successfully for users table");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 6)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_add, size: 64, color: Colors.deepPurple),
                const SizedBox(height: 16),
                const Text("Create an Account",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Signup to start your journey",
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: _inputDecoration("Username"),
                        onSaved: (val) => _username = val!.trim(),
                        validator: (val) =>
                            val!.isEmpty ? 'Enter username' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: _inputDecoration("Email"),
                        onSaved: (val) => _email = val!.trim(),
                        validator: (val) => val!.isEmpty ? 'Enter email' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: _inputDecoration("Password"),
                        obscureText: true,
                        onSaved: (val) => _password = val!.trim(),
                        validator: (val) =>
                            val!.isEmpty ? 'Enter password' : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _registerUser(context),
                          child: const Text("Signup",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => const Login()));
                        },
                        child: const Text("Already registered? Login",
                            style: TextStyle(color: Colors.deepPurple)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.deepPurple),
          borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.deepPurple.shade50,
    );
  }

  Future<void> _registerUser(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      final existingUsers =
          await _db.query('users', where: 'email = ?', whereArgs: [_email]);

      if (existingUsers.isNotEmpty) {
        _showMessage(context, "Email already registered");
        return;
      }

      await _db.insert('users',
          {'username': _username, 'email': _email, 'password': _password});
      _showMessage(context, "Registration successful", isError: false);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const Login()));
    } catch (e) {
      _showMessage(context, "Error: $e");
    }
  }

  void _showMessage(BuildContext context, String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg),
          backgroundColor: isError ? Colors.red : Colors.green),
    );
  }
}

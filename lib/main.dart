// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  Get.put(TokenService());
  WidgetsFlutterBinding.ensureInitialized();
  await TokenService.to.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter JWT Auth with GetX',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: TokenService.to.loadToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            if (snapshot.hasData && snapshot.data != null) {
              return HomePage();
            } else {
              return LoginPage();
            }
          }
        },
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    // final String username = _usernameController.text.trim();
    // final String password = _passwordController.text.trim();
    final String username = 'kminchelle';
    final String password = '0lelplR';

    final response = await http.post(
      Uri.parse('https://dummyjson.com/auth/login'),
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String token = responseData['token'];

      print("THIS RESPONSE DATA ${responseData}");

      // Save token locally
      TokenService.to.saveToken(token);

      // Navigate to the home page
      Get.offAll(HomePage());
    } else {
      Get.snackbar(
        'Login Failed',
        'Invalid username or password',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  void _logout() {
    TokenService.to.deleteToken();
    Get.offAll(LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          ElevatedButton(
            onPressed: _logout,
            child: Text('Logout'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
            ),
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome! You are logged in.'),
      ),
    );
  }
}

class TokenService extends GetxService {
  static TokenService get to => Get.find();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString('token', token);
  }

  Future<String?> loadToken() async {
    return _prefs.getString('token');
  }

  Future<void> deleteToken() async {
    await _prefs.remove('token');
  }
}

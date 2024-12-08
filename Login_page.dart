import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _error;

Future<void> _handleSubmit() async {
  final email = _emailController.text;
  final password = _passwordController.text;

  try {
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/users/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Store email, role, and user ID in shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', data['email']);
      await prefs.setString('role', data['role']);
      await prefs.setString('userId', data['userId'].toString()); // Convert to String if it's an int

      Fluttertoast.showToast(
        msg: "Login Successful...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      // Navigate to the next screen after a delay
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/app');
      });
    } else if (response.statusCode == 401) {
      Fluttertoast.showToast(
        msg: "Invalid email or password",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: "An error occurred. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  } catch (error) {
    print('Login error: $error');
    Fluttertoast.showToast(
      msg: "An error occurred. Please try again.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}


  void _handleSignup() {
    Navigator.pushNamed(context, '/signup');
  }

  void _handleForgotPassword() {
    Navigator.pushNamed(context, '/forgot-password');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/zu.jpeg', width: 400, height: 80),
                    SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email address',
                        errorText: _error,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      child: Text('Login'),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _handleSignup,
                      child: Text('Sign Up'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Use backgroundColor instead of primary
                      ),
                    ),
                    TextButton(
                      onPressed: _handleForgotPassword,
                      child: Text('Forgot Password?'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
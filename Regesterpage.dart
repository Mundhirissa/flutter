import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;  // Import for MediaType
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  // User request data
  Map<String, String> userRequest = {
    'username': '',
    'fullName': '',
    'phoneNumber': '',
    'email': '',
    'password': '',
    'role': 'Student',
    'status': 'Active',
  };

  // Handle input change
  void handleInputChange(String name, String value) {
    setState(() {
      userRequest[name] = value;
    });
  }

  // Handle image selection
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  // Submit the form
  Future<void> handleSubmit() async {
    // Create a FormData object
    var uri = Uri.parse('http://localhost:8080/api/users');
    var request = http.MultipartRequest('POST', uri);

    request.fields['username'] = userRequest['username']!;
    request.fields['fullName'] = userRequest['fullName']!;
    request.fields['phoneNumber'] = userRequest['phoneNumber']!;
    request.fields['email'] = userRequest['email']!;
    request.fields['password'] = userRequest['password']!;
    request.fields['role'] = userRequest['role']!;
    request.fields['status'] = userRequest['status']!;

    // If an image is selected, add it to the request
    if (_image != null) {
      var imageFile = await http.MultipartFile.fromPath('imageFile', _image!.path);
      request.files.add(imageFile);
    }

    // Send the request
    try {
      var response = await request.send();
      if (response.statusCode == 201) {
        Navigator.pushNamed(context, '/login'); // Navigate to login screen after successful registration
      } else {
        throw Exception('Failed to register user');
      }
    } catch (error) {
      print('Error during registration: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SUZA Appointment System"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                child: Column(
                  children: [
                    Text(
                      'User Information',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => handleInputChange('username', value),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => handleInputChange('fullName', value),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: phoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => handleInputChange('phoneNumber', value),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => handleInputChange('email', value),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => handleInputChange('password', value),
                    ),
                    SizedBox(height: 10),
                    // Image picker for profile image
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _image == null
                            ? Icon(Icons.add_a_photo, color: Colors.blue)
                            : Image.file(File(_image!.path), height: 100, width: 100, fit: BoxFit.cover),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: handleSubmit,
                      child: Text('Register'),
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

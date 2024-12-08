import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Map<String, dynamic>? user;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final String? userId = await getUserIdFromStorage();

    if (userId == null) {
      setState(() {
        error = "User ID not found in local storage.";
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse('http://localhost:8080/api/users/$userId'));

      if (response.statusCode != 200) {
        throw Exception("User not found.");
      }

      setState(() {
        user = jsonDecode(response.body);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<String?> getUserIdFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId'); // Fetch the user ID from SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        backgroundColor: const Color(0xFF3498DB),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Text(
                    "Error: $error",
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : user != null
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  "User Profile",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              UserProfileItem(
                                icon: FontAwesomeIcons.user,
                                label: "Username",
                                value: user!['username'] ?? 'N/A',
                              ),
                              UserProfileItem(
                                icon: FontAwesomeIcons.user,
                                label: "Full Name",
                                value: user!['fullName'] ?? 'N/A',
                              ),
                              UserProfileItem(
                                icon: FontAwesomeIcons.phone,
                                label: "Phone Number",
                                value: user!['phoneNumber'] ?? 'N/A',
                              ),
                              UserProfileItem(
                                icon: FontAwesomeIcons.envelope,
                                label: "Email",
                                value: user!['email'] ?? 'N/A',
                              ),
                              UserProfileItem(
                                // ignore: deprecated_member_use
                                icon: FontAwesomeIcons.shieldAlt,
                                label: "Role",
                                value: user!['role'] ?? 'N/A',
                              ),
                              UserProfileItem(
                                icon: FontAwesomeIcons.userCheck,
                                label: "Status",
                                value: user!['status'] ?? 'N/A',
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const Center(
                      child: Text("No user data found."),
                    ),
    );
  }
}

class UserProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const UserProfileItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          FaIcon(icon, size: 28, color: const Color(0xFF3498DB)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "$label: $value",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

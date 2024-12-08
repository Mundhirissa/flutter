import 'package:flutter/material.dart';
import 'sidebar.dart'; // Import your Sidebar widget

class MainScreen extends StatelessWidget {
  final Widget child; // Content to display in the main area

  const MainScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(), // Sidebar will always be visible
          Expanded(
            child: child, // Display the passed child widget
          ),
        ],
      ),
    );
  }
}

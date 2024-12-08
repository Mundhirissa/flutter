import 'package:flutter/material.dart';
import 'package:miadi/pages/AppointmentForm.dart';
import 'package:miadi/pages/Dashboard_page.dart';
import 'package:miadi/pages/Login_page.dart'; // Ensure this path is correct
import 'package:miadi/pages/Mainscreen.dart';
import 'package:miadi/pages/Regesterpage.dart';
import 'package:miadi/pages/StaffAppointmentList.dart';
import 'package:miadi/pages/StudentAppointmentList.dart';
import 'package:miadi/pages/UserProfile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MIADI',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(), // Login page without sidebar
        '/signup': (context) => SignUpScreen(), // Signup page without sidebar
        '/app': (context) => MainScreen(child: DashboardPage()), // Example: Dashboard
        '/studentAplist': (context) => MainScreen(child: StudentAppointmentList()),
        '/userprofile': (context) => MainScreen(child: UserProfile()),
        '/appoitmentform': (context) => MainScreen(child: AppointmentForm()),
        '/Staffappoitmentlist': (context) => MainScreen(child: StaffAppointmentList()),
      },
    );
  }
}

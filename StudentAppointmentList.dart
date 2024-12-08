import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StudentAppointmentList extends StatefulWidget {
  @override
  _StudentAppointmentListState createState() => _StudentAppointmentListState();
}

class _StudentAppointmentListState extends State<StudentAppointmentList> {
  List<dynamic> appointments = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      // Retrieve user ID from local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception("User ID not found in local storage");
      }

      // Fetch student details using the user ID
      final studentResponse = await http.get(Uri.parse('http://localhost:8080/students/user/$userId'));
      if (studentResponse.statusCode != 200) {
        throw Exception("Failed to fetch student data");
      }

      final studentData = jsonDecode(studentResponse.body);
      final studentId = studentData.isNotEmpty ? studentData[0]['studentId'] : null;

      if (studentId == null) {
        throw Exception("Student not found");
      }

      // Fetch appointments using the student ID
      final appointmentResponse = await http.get(Uri.parse('http://localhost:8080/appointments/student/$studentId'));
      if (appointmentResponse.statusCode != 200) {
        throw Exception("Failed to fetch appointments");
      }

      setState(() {
        appointments = jsonDecode(appointmentResponse.body);
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> handleCancelAppointment(int appointmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cancel Appointment"),
        content: Text("Are you sure you want to cancel this appointment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Yes"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.patch(Uri.parse('http://localhost:8080/appointments/$appointmentId/cancel'));
        if (response.statusCode == 200) {
          setState(() {
            appointments.removeWhere((appointment) => appointment['appointmentId'] == appointmentId);
          });
        } else {
          throw Exception("Failed to cancel appointment");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error canceling appointment: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text("Student Appointments")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: Text("Student Appointments")),
        body: Center(child: Text("Error: $error")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Student Appointments")),
      body: appointments.isNotEmpty
          ? ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    title: Text("Date: ${appointment['appointmentDate']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Time: ${appointment['appointmentTime']}"),
                        Text("Reason: ${appointment['appointmentReason']}"),
                        Text("Status: ${appointment['status']}"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => handleCancelAppointment(appointment['appointmentId']),
                    ),
                  ),
                );
              },
            )
          : Center(child: Text("No appointments found.")),
    );
  }
}

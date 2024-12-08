import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart'; // Import the toast package

class AppointmentForm extends StatefulWidget {
  @override
  _AppointmentFormState createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  List<dynamic> students = [];
  List<dynamic> staff = [];
  String? role;
  String? userId;
  String? selectedStudent;
  String? selectedStaff;
  String? appointmentDate;
  String? appointmentTime;
  String appointmentReason = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    role = prefs.getString('role');
    userId = prefs.getString('userId');

    String endpoint = role == 'Student'
        ? 'http://localhost:8080/students/user/$userId'
        : 'http://localhost:8080/students';

    // Fetch students
    try {
      final studentResponse = await http.get(Uri.parse(endpoint));
      if (studentResponse.statusCode == 200) {
        setState(() {
          students = json.decode(studentResponse.body);
        });
      }
    } catch (error) {
      print('Error fetching students: $error');
    }

    // Fetch staff
    try {
      final staffResponse =
          await http.get(Uri.parse('http://localhost:8080/staff'));
      if (staffResponse.statusCode == 200) {
        setState(() {
          staff = json.decode(staffResponse.body);
        });
      }
    } catch (error) {
      print('Error fetching staff: $error');
    }
  }

  Future<void> _checkAvailabilityAndSubmit() async {
    if (appointmentDate == null || appointmentTime == null || selectedStaff == null) {
      _showAlert('Please provide date, time, and select a staff member.');
      return;
    }

    try {
      // Check availability
      final availabilityResponse = await http.get(
        Uri.parse(
          'http://localhost:8080/appointments/appointments/check-availability',
        ).replace(queryParameters: {
          'appointmentDate': appointmentDate!,
          'appointmentTime': appointmentTime!,
          'staffId': selectedStaff!,
        }),
      );

      if (availabilityResponse.statusCode == 200) {
        final isAvailable = json.decode(availabilityResponse.body);
        if (!isAvailable) {
          _showAlert(
            'The selected date, time, and staff are already taken. Please choose a different slot.',
          );
          return;
        }

        // Data for creating the appointment
        final appointmentData = {
          'student': int.parse(selectedStudent ?? '0'),
          'staff': int.parse(selectedStaff ?? '0'),
          'appointmentDate': appointmentDate,
          'appointmentTime': appointmentTime,
          'appointmentReason': appointmentReason,
          'status': 'Confirmed',
        };

        // Attempt to create the appointment
        final createResponse = await http.post(
          Uri.parse('http://localhost:8080/appointments'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(appointmentData),
        );

        if (createResponse.statusCode == 200) {
          // Inspect the response body to determine success/failure
          final responseBody = json.decode(createResponse.body);

          if (responseBody['status'] == 'success') {
            // Show success toast
            Fluttertoast.showToast(
              msg: "Appointment created successfully!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );

            setState(() {
              selectedStudent = null;
              selectedStaff = null;
              appointmentDate = null;
              appointmentTime = null;
              appointmentReason = '';
            });
          } else {
            // Show failure message based on response content
            _showAlert('Failed to create appointment: ${responseBody['message'] ?? 'Unknown error.'}');
          }
        } else {
          // Handle failure when status code is not 200
          _showAlert('Failed to create appointment. Please try again later.');
        }
      } else {
        _showAlert('Failed to check availability. Please try again.');
      }
    } catch (error) {
      print('Error: $error');
      _showAlert('An error occurred. Please try again.');
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Student'),
              value: selectedStudent,
              items: students.map((student) {
                return DropdownMenuItem<String>(
                  value: student['studentId'].toString(),
                  child: Text(student['name']),
                );
              }).toList(),
              onChanged: (value) => setState(() {
                selectedStudent = value;
              }),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Staff'),
              value: selectedStaff,
              items: staff.map((member) {
                return DropdownMenuItem<String>(
                  value: member['staffId'].toString(),
                  child: Text(member['name']),
                );
              }).toList(),
              onChanged: (value) => setState(() {
                selectedStaff = value;
              }),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Appointment Date'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    appointmentDate = pickedDate.toIso8601String().split('T')[0];
                  });
                }
              },
              readOnly: true,
              controller: TextEditingController(
                  text: appointmentDate ?? 'Select Date'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Appointment Time'),
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    appointmentTime =
                        '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                  });
                }
              },
              readOnly: true,
              controller: TextEditingController(
                  text: appointmentTime ?? 'Select Time'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Reason'),
              maxLines: 3,
              onChanged: (value) => appointmentReason = value,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkAvailabilityAndSubmit,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

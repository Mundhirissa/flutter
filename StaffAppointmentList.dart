import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StaffAppointmentList extends StatefulWidget {
  @override
  _StaffAppointmentListState createState() => _StaffAppointmentListState();
}

class _StaffAppointmentListState extends State<StaffAppointmentList> {
  List<dynamic> appointments = [];

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      // Get staffId based on userId
      final staffResponse = await http.get(
        Uri.parse('http://localhost:8080/staff/user/$userId'),
      );
      final staffData = json.decode(staffResponse.body);
      final staffId = staffData['staffId'];

      // Fetch appointments for the staff
      final appointmentsResponse = await http.get(
        Uri.parse('http://localhost:8080/appointments/staff/$staffId'),
      );
      final appointmentData = json.decode(appointmentsResponse.body);

      setState(() {
        appointments = appointmentData;
      });
    } catch (error) {
      print('Error fetching appointments: $error');
    }
  }

  Future<void> confirmAppointment(String appointmentId) async {
    try {
      await http.post(
        Uri.parse('http://localhost:8080/appointments/$appointmentId/confirm'),
      );

      // Re-fetch appointments after confirming
      fetchAppointments();
    } catch (error) {
      print('Error confirming appointment: $error');
    }
  }

  Future<void> handleCancelAppointment(String appointmentId) async {
    final confirmation = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Cancellation'),
          content: Text('Are you sure you want to cancel this appointment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      try {
        await http.patch(
          Uri.parse('http://localhost:8080/appointments/$appointmentId/cancel'),
        );

        setState(() {
          appointments = appointments
              .where((appointment) =>
                  appointment['appointmentId'] != appointmentId)
              .toList();
        });
      } catch (error) {
        print('Error canceling appointment: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: appointments.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Appointment ID')),
                    DataColumn(label: Text('Student Name')),
                    DataColumn(label: Text('Appointment Date')),
                    DataColumn(label: Text('Appointment Time')),
                    DataColumn(label: Text('Reason')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: appointments.map((appointment) {
                    return DataRow(
                      cells: [
                        DataCell(Text(appointment['appointmentId'].toString())),
                        DataCell(Text(appointment['student']['name'])),
                        DataCell(Text(appointment['appointmentDate'])),
                        DataCell(Text(appointment['appointmentTime'])),
                        DataCell(Text(appointment['appointmentReason'])),
                        DataCell(Text(appointment['status'])),
                        DataCell(
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => confirmAppointment(
                                    appointment['appointmentId'].toString()),
                                child: Text('Confirm'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => handleCancelAppointment(
                                    appointment['appointmentId'].toString()),
                                child: Text('Cancel'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
      ),
    );
  }
}

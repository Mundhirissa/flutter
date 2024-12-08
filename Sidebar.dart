import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sidebar extends StatefulWidget {
  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String? _role;
  bool _isExpanded = true; // To control the width of the sidebar

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('role');
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data (including role, username, etc.)
    Navigator.pushReplacementNamed(context, "/"); // Redirect to the login page
  }

  List<Map<String, dynamic>> getMenus() {
    List<Map<String, dynamic>> menus = [
      {'title': "Dashboard", 'icon': Icons.dashboard, 'path': "/dashboard"},
    ];

    if (_role == 'Student') {
      return [
        {'title': "Appointment Form", 'icon': Icons.assignment, 'path': "/appoitmentform"},
        {'title': "Student Profile", 'icon': Icons.person, 'path': "/app/studentprofile"},
        {'title': "User Profile", 'icon': Icons.person_outline, 'path': "/userprofile"},
        {'title': "Appointments Views", 'icon': Icons.view_list, 'path': "/studentAplist"},
      ];
    } else if (_role == 'Staff') {
      return [
        {'title': "Staff Dashboard", 'icon': Icons.dashboard, 'path': "/app"},
        {'title': "User Profile", 'icon': Icons.person_outline, 'path': "/userprofile"},
        {'title': "Appointment List", 'icon': Icons.list, 'path': "/Staffappoitmentlist"},
      ];
    } else {
      return [
        {'title': "Admin Dashboard", 'icon': Icons.dashboard, 'path': "/app"},
        {'title': "Appointment List", 'icon': Icons.list, 'path': "/app/list"},
        {'title': "Add Staff", 'icon': Icons.person_add, 'path': "/app/staffAdd"},
        {'title': "Staff List", 'icon': Icons.group, 'path': "/app/staffList"},
        {'title': "Appointment Form", 'icon': Icons.assignment, 'path': "/app/formApp"},
        {'title': "Count Table", 'icon': Icons.table_chart, 'path': "/app/CountTable"},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final menus = getMenus();

    return Container(
      width: _isExpanded ? 240 : 60,
      color: Colors.black87,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Menu",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.arrow_back : Icons.arrow_forward,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: menus.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(menus[index]['icon'], color: Colors.white),
                  title: _isExpanded
                      ? Text(menus[index]['title'], style: TextStyle(color: Colors.white))
                      : null,
                  onTap: () {
                    Navigator.pushNamed(context, menus[index]['path']);
                  },
                );
              },
            ),
          ),
          Divider(color: Colors.white), // Optional: to separate the logout button
          ListTile(
            leading: Icon(Icons.logout, color: Colors.white),
            title: _isExpanded
                ? Text("Logout", style: TextStyle(color: Colors.white))
                : null,
            onTap: () {
              _logout();
            },
          ),
        ],
      ),
    );
  }
}

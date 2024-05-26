import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Drawer buildDrawer(BuildContext context, int _selectedDestination) {
  return Drawer(
    child: SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 7,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/my-profile');
                },
                child: Column(
                  children: [
                    SizedBox(height: 5),
                    Text(
                      'dtt',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 60.0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    selected: _selectedDestination == 0,
                    leading: const Icon(
                      Icons.dashboard,
                    ),
                    title: const Text(
                      'Dashboard',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                  ),
                  ListTile(
                    selected: _selectedDestination == 1,
                    leading: Icon(
                      Icons.dashboard,
                    ),
                    title: const Text(
                      'My Approval',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/home');
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    onTap: () async {
                      SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                      preferences.clear();
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (Route<dynamic> route) => false);
                    },
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Copyright @ MBM"),
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
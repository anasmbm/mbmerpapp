import 'package:flutter/material.dart';
import 'package:mbm_store/constants/global_variables.dart';
import 'package:mbm_store/services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  static const String routeName = '/profile';

  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: GlobalVariables.appBarGradient,
          ),
        ),
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => AuthService.logout(context),
            icon: const Icon(Icons.logout, color: Colors.white,),
          ),
        ],
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the color of the back icon to white
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Profile Information:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            _buildContactInfo('Email', 'contact@example.com'),
            _buildContactInfo('Phone', '+1 (123) 456-7890'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(String label, String value) {
    return Text(
      '$label: $value',
      style: const TextStyle(fontSize: 16),
    );
  }
}
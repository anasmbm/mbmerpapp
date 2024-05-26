import 'package:flutter/material.dart';

// String uri = 'http://192.168.1.5:8000';
// String uri = 'http://10.4.10.130:8000';
// String uri = 'http://10.0.2.2:8000';
String uri = 'https://erp.mbm.group';
// String uri = 'https://app.fcltdbd.com';

class GlobalVariables {
  // COLORS
  static const appBarGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 29, 201, 192),
      Color.fromARGB(255, 125, 221, 216),
    ],
    stops: [0.5, 1.0],
  );

  static const appTitle = 'MBM Store';
  static const secondaryColor = Color.fromRGBO(255, 153, 0, 1);
  static const backgroundColor = Colors.white;
  static const Color greyBackgroundColor = Color(0xffebecee);
  static var selectedNavBarColor = Colors.cyan[800]!;
  static const unselectedNavBarColor = Colors.black87;
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      backgroundColor: Colors.teal,
    ),
  );
}

String mbmDate(String dateString) {
  DateTime dateObj = DateTime.parse(dateString);
  String formattedDate = DateFormat.yMMMd().format(dateObj);
  return formattedDate;
}

String formatDate(String startDate) {
  return '${DateFormat.d().format(DateTime.parse(startDate))}/${DateFormat.M().format(DateTime.parse(startDate))}/${DateFormat.y().format(DateTime.parse(startDate))}';
}

Future<Map<String, String>> createHeaders() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('x-auth-token');
  return {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
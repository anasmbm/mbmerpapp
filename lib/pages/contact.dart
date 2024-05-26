import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ContactPage extends StatefulWidget {
  static const String routeName = '/contact';
  final reqData;

  const ContactPage({Key? key, this.reqData}) : super(key: key);

  @override
  _BillDetailsState createState() => _BillDetailsState();
}

class _BillDetailsState extends State<ContactPage> {
  var height, width;
  Map<String, dynamic>? billData; // Store the bill data here

  @override
  void initState() {
    print('Reached');
    print(widget.reqData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Requisition Details'),
      ),
      body: const Text('Contact Page'),
    );
  }

  void getBillData(billId) async {
    print(billId);
    final apiUrl = 'https://mbm.confirmtuition.com/public/api/requisitions/$billId'; // Replace with your API endpoint URL
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        setState(() {
          billData = responseData;
        });
      } else {
        // Handle error if the API request was not successful
        print("Failed to load bill details. Status code: ${response.statusCode}");
        setState(() {
          billData = null;
        });
      }
    } catch (error) {
      // Handle any network or HTTP request errors
      print("Error: $error");
      setState(() {
        billData = null;
      });
    }
  }
}
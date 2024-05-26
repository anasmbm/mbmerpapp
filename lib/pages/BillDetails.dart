import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BillDetails extends StatefulWidget {
  static const String routeName = '/billDetails';
  final billId;

  const BillDetails({Key? key, this.billId}) : super(key: key);

  @override
  _BillDetailsState createState() => _BillDetailsState();
}

class _BillDetailsState extends State<BillDetails> {
  var height, width;
  Map<String, dynamic>? billData; // Store the bill data here

  @override
  void initState() {
    getBillData(widget.billId);
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: billData == null
                ? const CircularProgressIndicator() // Display a loading indicator while fetching data
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Requisition ID: ${billData!['id']}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text('Status: ${billData!['status']}'),
                Text('User ID: ${billData!['user_id']}'),
                Text('Created At: ${billData!['created_at']}'),
                const SizedBox(height: 16),
                const Text('Items:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Column(
                  children: (billData!['items'] as List).map<Widget>((itemData) {
                    return ListTile(
                      title: Text('Item ID: ${itemData['item_id']}'),
                      subtitle: Text('Quantity: ${itemData['qty']}'),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
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


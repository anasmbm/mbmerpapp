import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mbm_store/common/widgets/appbar.dart';
import 'package:mbm_store/constants/global_variables.dart';
import 'package:mbm_store/constants/utils.dart';
import 'package:mbm_store/services/approval_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class ApprovalDetailsBill extends StatefulWidget {
  final String? approvalId;
  static const String routeName = '/approval-details-bill';

  const ApprovalDetailsBill({Key? key, required this.approvalId}) : super(key: key);

  @override
  State<ApprovalDetailsBill> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalDetailsBill> {
  Map<String, dynamic>? approvalData;
  bool loading = false;

  @override
  void initState() {
    _loadApprovalDetailsData(widget.approvalId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(pageTitle: 'Bill Details', backLink: '/approvals', approvalName: 'tt_rtgs_bill'),
      body: loading
        ? const Center(child: CircularProgressIndicator())
        : approvalData != null
    ? ApprovalCard(approvalData: approvalData!)
        : const Center(child: Text('No data available!')),
    );
  }

  Future<void> _loadApprovalDetailsData(String? approvalId) async {
    setState(() {
      loading = true;
    });

    final approvalData = await ApprovalService.fetchApprovalDetailsDataBill(approvalId);

    if (approvalData != null) {
      setState(() {
        this.approvalData = approvalData;
      });
    } else {
      print("Failed to fetch approval data");
    }

    setState(() {
      loading = false;
    });
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ActionButton({Key? key, required this.label, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        backgroundColor: const Color.fromARGB(255, 29, 201, 192),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}

class DataCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const DataCard({Key? key, required this.title, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            width: 0.5,
            color: const Color.fromARGB(255, 29, 201, 192),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.topLeft,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.5, color: Color.fromARGB(255, 29, 201, 192)),
                ),
              ),
              child: Text(title, style: const TextStyle(fontSize: 17)),
            ),
            Column(
              children: children,
            ),
          ],
        ),
      ),
    );
  }
}

// Function to download file
Future<void> downloadFile(String fileUrl) async {
  final response = await http.get(Uri.parse(fileUrl));

  if (response.statusCode == 200) {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = fileUrl.split('/').last;
    final filePath = '${appDir.path}/$fileName';
    File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    print('File downloaded to: $filePath');
  } else {
    throw Exception('Failed to download file');
  }
}

class ApprovalCard extends StatelessWidget {
  final Map<String, dynamic> approvalData;

  const ApprovalCard({Key? key, required this.approvalData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String paymentMethod = approvalData['subject']['tt_rtgs'];
    String tt = '';
    if (paymentMethod == '2') {
      tt = 'TT Payment';
    } else if(paymentMethod == '3'){
      tt = 'RTGS Payment';
    }
    String supName = 'N/A';
    if (approvalData != null && approvalData['subject'] != null && approvalData['subject']['supplier'] != null) {
      supName = approvalData['subject']['supplier']['sup_name'];
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 5, right: 5, bottom: 5),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0), // Adjust border radius as needed
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Adjust the padding
                      ),
                      onPressed: () async {
                        bool confirmAction = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Approval Confirmation"),
                              content: Text("Are you sure to approve this bill?"),
                              actions: <Widget>[
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Text("No", style: TextStyle(color: Colors.white)),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: Text("Yes", style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirmAction == true) {
                          try {
                            final response = await ApprovalService.updateBillStatus(5, "tt_rtgs_bill",  approvalData['id'].toString(), "", context);
                            if (response != null && response['type'] == 'success') {
                              showSnackBar(context, response['message']);
                            } else {
                              showSnackBar(context, 'Failed!');
                            }
                          } catch (error) {
                            showSnackBar(context, 'Error: $error');
                          }
                        }
                      },
                      child: const Text(
                        "Approve",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0), // Adjust border radius as needed
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Adjust the padding
                      ),
                      onPressed: () async {
                        bool confirmAction = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Confirmation"),
                              content: Text("Are you sure you want to reject this?"),
                              actions: <Widget>[
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Text("No", style: TextStyle(color: Colors.white)),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: Text("Yes", style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmAction == true) {
                          try {
                            final response = await ApprovalService.updateBillStatus(2, "tt_rtgs_bill",  approvalData['id'].toString(), "", context);
                            if (response != null && response['type'] == 'error') {
                              showSnackBar(context, response['message']);
                            } else {
                              showSnackBar(context, 'Failed!');
                            }
                          } catch (error) {
                            showSnackBar(context, 'Error: $error');
                          }
                        }
                      },
                      child: const Text(
                        "Reject",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          DataCard(
            title: 'Bill Information',
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bill Type: ${approvalData['subject']['bill']['bill_type']} (${tt})',
                          ),
                          Text(
                            'Supplier: ${supName}',
                          ),
                          Text(
                            'Submitted By: ${approvalData['subject']['author']['name']}',
                          ),
                          Text(
                            'Invoice No: ${approvalData['subject']['invoice_no']}',
                          ),
                          Text(
                            'Amount: ${approvalData['subject']['amount']}',
                          ),
                          Text(
                            'Bill Date: ${approvalData['subject']['bill_of_date']}',
                          ),
                          Text(
                            'Bill Date: ${approvalData['subject']['bill_of_date']}',
                          ),
                          Text(
                            'Unit: ${approvalData['subject']['unit']['hr_unit_name']}',
                          ),
                          Text(
                            'Remarks: ${approvalData['subject']['remarks']}',
                          ),
                          GestureDetector(
                            onTap: () {
                              final fileUrl = approvalData['subject']['bill_receive_file'].isNotEmpty
                                  ? approvalData['subject']['bill_receive_file'][0]['file_path']
                                  : null;
                              final fileUrlLink = uri+'/'+fileUrl;
                              if (fileUrl != null) {
                                launchUrl(Uri.parse(fileUrlLink));
                              } else {
                                showSnackBar(context, 'File not found.');
                              }
                            },
                            child: Row(
                              children: [
                                Icon(Icons.download), // Icon for download
                                SizedBox(width: 5), // Add some space between the icon and text
                                Text(
                                  'Files: ${approvalData['subject']['bill_receive_file'].isNotEmpty ? approvalData['subject']['bill_receive_file'][0]['file_name'] : 'No Files'}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
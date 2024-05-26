import 'package:flutter/material.dart';
import 'package:mbm_store/common/widgets/appbar.dart';
import 'package:mbm_store/constants/utils.dart';
import 'package:mbm_store/services/approval_service.dart';

class ApprovalDetailsPagePI extends StatefulWidget {
  final String? approvalId;

  static const String routeName = '/approval-details-pi';

  const ApprovalDetailsPagePI({Key? key, required this.approvalId}) : super(key: key);

  @override
  State<ApprovalDetailsPagePI> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalDetailsPagePI> {
  Map<String, dynamic>? approvalData;
  List<dynamic> itemDetails = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadApprovalDetailsData(widget.approvalId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(pageTitle: 'PI TT Payment Approval Details', backLink: '/approvals', approvalName: 'pi_tt_payment'),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : approvalData != null
          ? ApprovalCard(approvalData: approvalData?['master']!, itemDetails: itemDetails)
          : const Center(child: Text('No data available!')),
    );
  }

  Future<void> _loadApprovalDetailsData(String? approvalId) async {
    setState(() {
      loading = true;
    });

    final data = await ApprovalService.fetchApprovalDetailsPI(approvalId);
    print('data');
    print(data);

    if (data != null) {
      setState(() {
        approvalData = data;
        itemDetails = data['details'];
      });
    } else {
      print("Failed to fetch approval data");
    }

    setState(() {
      loading = false;
    });
  }
}

class ApprovalCard extends StatelessWidget {
  final Map<String, dynamic> approvalData;
  final List<dynamic> itemDetails;
  const ApprovalCard({Key? key, required this.approvalData, required this.itemDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                          borderRadius: BorderRadius.circular(5.0),
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
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: Text("Yes"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Text("No"),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirmAction == true) {
                          try {
                            final response = await ApprovalService.updateStatus(
                                1, 'pi_tt_payment', approvalData['subject_id'], approvalData['permission'], context);
                            if (response != null) {
                              showSnackBar(context, response['msg']);
                            } else {
                              showSnackBar(context, 'Failed!');
                            }
                          } catch (error) {
                            print(error);
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
                              title: Text("Approval Confirmation"),
                              content: Text("Are you sure to reject this bill?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: Text("Yes"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Text("No"),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirmAction == true) {
                          try {
                            final response = await ApprovalService.updateStatus(
                                2, 'pi_tt_payment', approvalData['subject_id'], approvalData['permission'], context);
                            if (response != null) {
                              showSnackBar(context, response['msg']);
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
          Card(
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
                    child: const Text('Payment Details', style: TextStyle(fontSize: 17)),
                  ),
                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Table(
                      children: [
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Text(
                              'PI No:',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              '${approvalData['pi_no']}',
                            ),
                          ),
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              'PI Date: ${mbmDate(approvalData['pi_date'])}',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              'PI Category: ${approvalData['pi_category']}',
                            ),
                          ),
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              'PI Value: ${approvalData['total_pi_value']}',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              'PI Qty: ${approvalData['total_pi_qty']}',
                            ),
                          ),
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Text(
                              'Supplier:',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              '${approvalData['supplier']}',
                            ),
                          ),
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              'Buyer: ${approvalData['buyer']}',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              'Unit: ${approvalData['unit']}',
                            ),
                          ),
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              'File: ${approvalData['file'] ?? ""}',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              'Contact: ${approvalData['contact'] ?? ""}',
                            ),
                          ),
                        ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                ],
              ),
            ),
          ),
          Card(
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
                          child: const Text('Item Details', style: TextStyle(fontSize: 17)),
                        ),
                        buildDetailsTable(itemDetails),
                      ]
                  )
              )
          )
        ],
      ),
    );
  }

  Widget buildDetailsTable(List<dynamic> detailsData) {
    return Table(
      border: TableBorder.symmetric(inside: const BorderSide(width: 0.5, color: Colors.grey)),
      children: [
        TableRow(
          children: [
            for (var headerText in ['Item', 'Qty', 'Unit Price', 'Value'])
              TableCell(
                child: Container(
                  color: Colors.grey, // Set your desired background color here
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0), // Adjust the padding as needed
                      child: Text(
                        headerText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Text color for the header
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        for (var data in detailsData)
          TableRow(
            children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0), // Adjust the padding as needed
                    child: Text(data['item']),
                  ),
                ),
              ),
              TableCell(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0), // Adjust the padding as needed
                    child: Text(data['pi_qty']),
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0), // Adjust the padding as needed
                    child: Text(data['pi_unit_price']),
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0), // Adjust the padding as needed
                    child: Text(data['pi_value']),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
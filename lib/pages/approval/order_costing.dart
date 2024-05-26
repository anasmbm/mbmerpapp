import 'package:flutter/material.dart';
import 'package:mbm_store/common/widgets/appbar.dart';
import 'package:mbm_store/constants/utils.dart';
import 'package:mbm_store/services/approval_service.dart';

class ApprovalDetailsPageOrderCosting extends StatefulWidget {
  final String? approvalId;

  static const String routeName = '/approval-details-order-costing';

  const ApprovalDetailsPageOrderCosting({Key? key, required this.approvalId}) : super(key: key);

  @override
  State<ApprovalDetailsPageOrderCosting> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalDetailsPageOrderCosting> {
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
      appBar: const CustomAppBar(pageTitle: 'Order Costing Details', backLink: '/approvals', approvalName: 'order_costing'),
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

    final approvalData = await ApprovalService.fetchApprovalDetailsData(approvalId);
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

class ApprovalCard extends StatelessWidget {
  final Map<String, dynamic> approvalData;

  const ApprovalCard({Key? key, required this.approvalData}) : super(key: key);

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
                          await ApprovalService.updateStatus(1, 'order_costing', approvalData['order_data']['order_id'], approvalData['order_data']['permission'], context)
                              .then((received) {
                            if (received != null) {
                              showSnackBar(
                                context,
                                'Approved Successfully!',
                              );
                            } else {
                              showSnackBar(
                                context,
                                'Failed!',
                              );
                            }
                          }).catchError((error) {
                            showSnackBar(
                              context,
                              'Error: $error',
                            );
                          });
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
                          await ApprovalService.updateStatus(2, 'order_costing', approvalData['order_data']['order_id'], approvalData['order_data']['permission'], context)
                              .then((received) {
                            if (received != null) {
                              showSnackBar(
                                context,
                                'Rejected Successfully!',
                              );
                            } else {
                              showSnackBar(
                                context,
                                'Failed!',
                              );
                            }
                          }).catchError((error) {
                            showSnackBar(
                              context,
                              'Error: $error',
                            );
                          });
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
            title: 'Order Information',
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
                            'Order No: ${approvalData['order_data']['order_code']}',
                          ),
                          Text(
                            'Qty: ${approvalData['order_data']['order_qty']}',
                          ),
                          Text(
                            'Buyer: ${approvalData['order_data']['b_shortname']}',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SMV: ${approvalData['order_data']['stl_smv']}',
                          ),
                          Text(
                            'Unit: ${approvalData['order_data']['hr_unit_short_name']}',
                          ),
                          Text(
                            'Delivery Date: ${mbmDate(approvalData['order_data']['order_delivery_date'])}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          DataCard(
            title: 'Summary',
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
                            'Fabric Cost: ${approvalData['summary']['fabric_bom']}',
                          ),
                          Text(
                            'Trim Cost: ${approvalData['summary']['trims_bom']}',
                          ),
                          Text(
                            'CM Cost: ${approvalData['summary']['cm']}',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var operation in approvalData['value']['operation'])
                            Text(
                              '${operation['opr_name']}: ${operation['unit_price']}',
                            ),
                          Text(
                            'Total: ${approvalData['to_summary']['total_fob']}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (approvalData['value'] != null)
            DataCard(
              title: 'Fabric',
              children: [
                Table(
                  border: TableBorder.symmetric(inside: const BorderSide(width: 0.5, color: Colors.grey)),
                  children: [
                    TableRow(
                      children: [
                        for (var headerText in ['Item', 'Qty', 'Unit Price', 'Total'])
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
                    for (var fabric in approvalData['value']['fabrics'])
                      TableRow(
                        children: [
                          TableCell(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0), // Adjust the padding as needed
                                child: Text(fabric['item_name']),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0), // Adjust the padding as needed
                                child: Text(
                                  '${(double.tryParse(fabric['qty'] ?? "0.0") ?? 0.0).toStringAsFixed(4)}${(fabric['unit_of_measurement']?['measurement_short_name'] ?? "N/A")}', // Provide default values
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0), // Adjust the padding as needed
                                child: Text(fabric['precost_unit_price']),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0), // Adjust the padding as needed
                                child: Text(fabric['total']),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          DataCard(
            title: 'Trims',
            children: [
              Table(
                border: TableBorder.symmetric(inside: const BorderSide(width: 0.5, color: Colors.grey)),
                children: [
                  TableRow(
                    children: [
                      for (var headerText in ['Item', 'Qty', 'Unit Price', 'Total'])
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
                  for (var trim in approvalData['value']['trims'])
                    TableRow(
                      children: [
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0), // Adjust the padding as needed
                              child: Text(trim['item_name']),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0), // Adjust the padding as needed
                              child: Text(
                                '${(double.tryParse(trim['qty'] ?? "0.0") ?? 0.0).toStringAsFixed(4)}${(trim['unit_of_measurement']?['measurement_short_name'] ?? "N/A")}', // Provide default values
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0), // Adjust the padding as needed
                              child: Text(trim['precost_unit_price']),
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0), // Adjust the padding as needed
                              child: Text(trim['total']),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
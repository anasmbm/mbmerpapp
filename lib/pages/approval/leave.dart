import 'package:flutter/material.dart';
import 'package:mbm_store/common/widgets/appbar.dart';
import 'package:mbm_store/constants/utils.dart';
import 'package:mbm_store/services/approval_service.dart';

class ApprovalDetailsLeave extends StatefulWidget {
  final String? approvalId;

  static const String routeName = '/approval-details-leave';

  const ApprovalDetailsLeave({Key? key, required this.approvalId}) : super(key: key);

  @override
  State<ApprovalDetailsLeave> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalDetailsLeave> {
  Map<String, dynamic>? approvalData;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadApprovalDetailsData(widget.approvalId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(pageTitle: 'Leave Approval', backLink: '/approvals', approvalName: 'employee_leave'),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : approvalData != null
          ? ApprovalCard(approvalData: approvalData)
          : const Center(child: Text('No data available!')),
    );
  }

  Future<void> _loadApprovalDetailsData(String? approvalId) async {
    setState(() {
      loading = true;
    });

    final data = await ApprovalService.fetchApprovalDetailsLeave(approvalId);
    // print('data');
    // print(data);

    if (data != null) {
      setState(() {
        approvalData = data;
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
  final Map<String, dynamic>? approvalData;
  const ApprovalCard({Key? key, this.approvalData}) : super(key: key);

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
                        try {
                          final response = await ApprovalService.updateStatus(
                              1, 'employee_leave', approvalData?['id'], "Leave Approval Management", context);
                          if (response != null) {
                            showSnackBar(context, response['msg']);
                          } else {
                            showSnackBar(context, 'Failed!');
                          }
                        } catch (error) {
                          showSnackBar(context, 'Error: $error');
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
                        try {
                          final response = await ApprovalService.updateStatus(
                              2, 'employee_leave', approvalData?['id'], "Leave Approval Management", context);
                          if (response != null) {
                            showSnackBar(context, response['msg']);
                          } else {
                            showSnackBar(context, 'Failed!');
                          }
                        } catch (error) {
                          showSnackBar(context, 'Error: $error');
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
                    child: const Text('Details', style: TextStyle(fontSize: 17)),
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
                              'Name:',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              '${approvalData?['employee']}',
                            ),
                          ),
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              'ID: ${approvalData?['associate_id'] ?? ""}',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              'Designation: ${approvalData?['designation'] ?? ""}',
                            ),
                          ),
                        ],
                        ),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              'Department: ${approvalData?['department'] ?? ""}',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              'Section: ${approvalData?['section'] ?? ""}',
                            ),
                          ),
                        ],
                        ),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Text(
                              'Date of Joining:',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              '${mbmDate(approvalData?['doj']) ?? ""}',
                            ),
                          ),
                        ],
                        ),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Text(
                              'Start Date:',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              '${mbmDate(approvalData?['start_date']) ?? ""}',
                            ),
                          ),
                        ],
                        ),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Text(
                              'End Date:',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              '${mbmDate(approvalData?['end_date']) ?? ""}',
                            ),
                          ),
                        ],
                        ),
                        TableRow(children: [
                          Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Text(
                              'Unit: ${approvalData?['unit'] ?? ""}',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              'Leave days: ${approvalData?['leave_days'] ?? ""}',
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
        ],
      ),
    );
  }
}
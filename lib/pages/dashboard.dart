import 'package:flutter/material.dart';
import 'package:mbm_store/common/widgets/appbar.dart';
import 'package:mbm_store/pages/approval/list.dart';
import 'package:mbm_store/pages/floor_attendance.dart';
import 'package:mbm_store/pages/leave_application.dart';
import 'package:mbm_store/pages/complain/complain.dart';
import 'package:mbm_store/pages/job_order/list.dart';
import 'package:mbm_store/pages/line_change.dart';
import 'package:mbm_store/services/approval_service.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/home';
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? approvalData;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchApprovalData();
  }

  Future<void> fetchApprovalData() async {
    if (!mounted) return;
    setState(() {
      loading = true;
    });
    try {
      final data = await ApprovalService.fetchApprovalDataDashboard();
      // print(data);
      if (mounted && data != null) {
        setState(() {
          approvalData = data;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, dynamic>> menuData = {
      'job_order_list': {'count': 0},
      'line_change': {'count': 0},
      'floor_attendance': {'count': 0},
      'leave_application': {'count': 0},
      'complain': {'count': 0},
    };

    return Scaffold(
      appBar: const CustomAppBar(pageTitle: 'Dashboard', showHomeIcon: true),
      body: Container(
        child: ListView(
          shrinkWrap: true,
          children: [
            Card(
              margin: const EdgeInsets.all(5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // Set the border radius to zero
              ),
              child: Container(
                decoration: BoxDecoration(
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
                      child: const Text("Approval"),
                    ),
                    const SizedBox(height: 8.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        if (loading)
                          const Center(child: Padding(
                            padding: EdgeInsets.all(30.0),
                            child: CircularProgressIndicator(),
                          ))
                        else if (approvalData != null)
                          GridView.builder(
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // Two columns
                              // crossAxisSpacing: 5.0, // Spacing between columns
                              // mainAxisSpacing: 5.0, // Spacing between rows
                              // childAspectRatio: (1),
                            ),
                            itemCount: approvalData!.length,
                            itemBuilder: (BuildContext context, int index) {
                              final entry = approvalData!.entries.elementAt(index);
                              return _buildApprovalInfo(entry.key, entry.value);
                            },
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text('No data available!'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.all(5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // Set the border radius to zero
              ),
              child: Container(
                decoration: BoxDecoration(
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
                      child: const Text("Menu"),
                    ),
                    const SizedBox(height: 8.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        GridView.builder(
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // Two columns
                          ),
                          itemCount: menuData!.length,
                          itemBuilder: (BuildContext context, int index) {
                            final entry = menuData!.entries.elementAt(index);
                            return _buildApprovalInfo(entry.key, entry.value);
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildApprovalInfo(String label, dynamic value) {
    String formattedLabel = label.replaceAll('_', ' ');
    formattedLabel = formattedLabel.replaceAllMapped(
      RegExp(r"(^| )\w"),
          (match) => match.group(0)!.toUpperCase(),
    );
    return GestureDetector(
      onTap: () {
        if(label == 'job_order_list'){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => POCashApproval(),
            ),
          );
        }else if(label == 'line_change'){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LineChange(),
            ),
          );
        }else if(label == 'floor_attendance'){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FloorAttendance(),
            ),
          );
        }else if(label == 'leave_application'){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LeaveApplication(),
            ),
          );
        }else if(label == 'complain'){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Complain(),
            ),
          );
        }else{
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ApprovalPage(
                approvalName: label,
              ),
            ),
          );
        }
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.all(5),
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Column(
              children: [
                Icon(
                  formattedLabel == 'Pi Tt Payment'
                      ? Icons.wallet_sharp
                      : formattedLabel == 'Tt Rtgs Bill'
                      ? Icons.account_balance_wallet_sharp
                      : formattedLabel == 'Job Order List'
                      ? Icons.account_balance_wallet
                      : formattedLabel == 'Line Change'
                      ? Icons.manage_accounts
                      : formattedLabel == 'Floor Attendance'
                      ? Icons.no_accounts_sharp
                      : formattedLabel == 'Leave Application'
                      ? Icons.calendar_month
                      : formattedLabel == 'Sales Contract Amend'
                      ? Icons.payment
                      : formattedLabel == 'Bill Approval'
                      ? Icons.wallet
                      : formattedLabel == 'Cf Bill'
                      ? Icons.wallet_travel_outlined
                      : formattedLabel == 'Employee Leave'
                      ? Icons.calendar_month
                      : formattedLabel == 'Order Costing'
                      ? Icons.add_card_outlined
                      : formattedLabel == 'Complain'
                      ? Icons.comment
                      : Icons.pending_actions_sharp,
                  size: 35.0,
                  color: Colors.cyan,
                ),
                SizedBox(height: 8),
                Text(
                  formattedLabel == 'Pi Tt Payment'
                      ? 'PI TT/RTGS Payment'
                      : formattedLabel == 'Tt Rtgs Bill'
                      ? 'Bill TT/RTGS Payment'
                      : formattedLabel == 'Cf Bill'
                      ? 'CnF Bill'
                      : formattedLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
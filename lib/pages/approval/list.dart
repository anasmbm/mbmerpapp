import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:mbm_store/common/widgets/appbar.dart';
import 'package:mbm_store/constants/utils.dart';
import 'package:mbm_store/pages/approval/bill_details.dart';
import 'package:mbm_store/pages/approval/pi_payment.dart';
import 'package:mbm_store/pages/approval/leave.dart';
import 'package:mbm_store/pages/approval/order_costing.dart';
import 'package:mbm_store/services/approval_service.dart';

class ApprovalPage extends StatefulWidget {
  final String? approvalName;
  static const String routeName = '/approvals';

  const ApprovalPage({Key? key, required this.approvalName}) : super(key: key);

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  List<Map<String, dynamic>> approvalDataList = [];
  bool loading = false;

  @override
  void initState() {
    _loadApprovalData(widget.approvalName);
    super.initState();
  }

  Future<void> _loadApprovalData(String? approvalName) async {
    setState(() {
      loading = true;
    });

    final data = await ApprovalService.fetchApprovalData(approvalName);
    setState(() {
      approvalDataList = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String? formattedLabel = widget.approvalName?.replaceAll('_', ' ');
    formattedLabel = formattedLabel?.replaceAllMapped(
      RegExp(r"(^| )\w"),
          (match) => match.group(0)!.toUpperCase(),
    );

    return Scaffold(
      appBar: CustomAppBar(pageTitle: '${formattedLabel ?? ""} List'),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : approvalDataList.isNotEmpty
          ? ListView.builder(
        itemCount: approvalDataList.length,
        itemBuilder: (context, index) {
              final Map<String, dynamic> approvalData = approvalDataList[index];
              // For Order costing
              final String orderId = approvalData['id']?.toString() ?? '';
              final String subjectId = approvalData['subject_id']?.toString() ?? '';
              final String approvalName = approvalData['approval_name']?.toString() ?? '';
              final String permission = approvalData['permission']?.toString() ?? '';
              final String orderCode = approvalData['order_code']?.toString() ?? '';
              final String orderQty = approvalData['order_qty']?.toString() ?? '';
              final String bShortName = approvalData['b_shortname']?.toString() ?? '';
              final String stlNo = approvalData['stl_no']?.toString() ?? '';
              // For PI TT Payment
              final String piNo = approvalData['pi_no']?.toString() ?? '';
              final String totalPiQty = approvalData['total_pi_qty']?.toString() ?? '';
              final String totalPiValue = approvalData['total_pi_value']?.toString() ?? '';
              final String buyer = approvalData['b_shortname']?.toString() ?? '';
              final String ttType = approvalData['tt_foc_type']?.toString() ?? '';
              final String employeeName = approvalData['as_name']?.toString() ?? '';
              final String designation = approvalData['designation']?.toString() ?? '';
              final String department = approvalData['department']?.toString() ?? '';
              final String startDate = approvalData['start_date']?.toString() ?? '';
              final String endDate = approvalData['end_date']?.toString() ?? '';
              final String type = approvalData['type']?.toString() ?? '';
              // For TT RTGS BILL
              final String invoiceNo = (approvalData != null &&
                  approvalData['subject'] != null &&
                  approvalData['subject']['invoice_no'] != null)
                  ? approvalData['subject']['invoice_no'].toString()
                  : '';
              final String amount = (approvalData != null && approvalData['subject'] != null && approvalData['subject']['amount'] != null)
                  ? approvalData['subject']['amount'].toString()
                  : '';
              final String paymentMethod = (approvalData != null && approvalData['subject'] != null && approvalData['subject']['tt_rtgs'] != null)
                  ? approvalData['subject']['tt_rtgs']
                  : '';
              final String supName = (approvalData != null &&
                  approvalData['subject'] != null &&
                  approvalData['subject']['supplier'] != null &&
                  approvalData['subject']['supplier']['sup_name'] != null)
                  ? approvalData['subject']['supplier']['sup_name'].toString()
                  : 'N/A';
              final String billType = (approvalData != null &&
                  approvalData['subject'] != null &&
                  approvalData['subject']['bill'] != null &&
                  approvalData['subject']['bill']['bill_type'] != null)
                  ? approvalData['subject']['bill']['bill_type'].toString()
                  : '';
              final String unit = (approvalData != null &&
                  approvalData['subject'] != null &&
                  approvalData['subject']['unit'] != null &&
                  approvalData['subject']['unit']['hr_unit_short_name'] != null)
                  ? approvalData['subject']['unit']['hr_unit_short_name'].toString()
                  : '';
              final String stageStatus = approvalData['stage_status']?? '';
              final String createdBy = (approvalData != null &&
                  approvalData['subject'] != null &&
                  approvalData['subject']['author'] != null &&
                  approvalData['subject']['author']['name'] != null)
                  ? approvalData['subject']['author']['name'].toString()
                  : '';
              final String approvedBy = (approvalData != null &&
                  approvalData['creator'] != null &&
                  approvalData['creator']['name'] != null)
                  ? approvalData['creator']['name'].toString()
                  : '';
              return ApprovalCard(
                index: index,
                orderId: orderId,
                subjectId: subjectId,
                approvalName: approvalName,
                employeeName: employeeName,
                designation: designation,
                department: department,
                startDate: startDate,
                endDate: endDate,
                type: type,
                permission: permission,
                orderCode: orderCode,
                orderQty: orderQty,
                bShortName: bShortName,
                stlNo: stlNo,
                piNo: piNo,
                totalPiQty: totalPiQty,
                totalPiValue: totalPiValue,
                buyer: buyer,
                ttType: ttType,
                invoiceNo: invoiceNo,
                billType: billType,
                amount: amount,
                supName: supName,
                paymentMethod: paymentMethod,
                unit: unit,
                stageStatus: stageStatus,
                createdBy: createdBy,
                approvedBy: approvedBy,
                onPressed: () {
                  late Widget targetPage;
                  if (widget.approvalName == 'order_costing') {
                    targetPage = ApprovalDetailsPageOrderCosting(approvalId: orderId);
                  } else if (widget.approvalName == 'pi_tt_payment') {
                    targetPage = ApprovalDetailsPagePI(approvalId: subjectId);
                  } else if (widget.approvalName == 'employee_leave') {
                    targetPage = ApprovalDetailsLeave(approvalId: orderId);
                  } else if (widget.approvalName == 'tt_rtgs_bill') {
                    targetPage = ApprovalDetailsBill(approvalId: orderId);
                  }
                  if(targetPage != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => targetPage,
                      ),
                    );
                  }
                },
                onAction: (actionIndex) {
                  setState(() {
                    approvalDataList.removeAt(actionIndex);
                  });
                },
              );
        },
      )
          : const Center(child: Text('No data available!')),
    );
  }
}

class ApprovalCard extends StatelessWidget {
  final int index;
  final String orderId;
  final String subjectId;
  final String orderCode;
  final String orderQty;
  final String bShortName;
  final String employeeName;
  final String stlNo;
  final String piNo;
  final String totalPiQty;
  final String totalPiValue;
  final String buyer;
  final String ttType;
  final String approvalName;
  final String designation;
  final String department;
  final String startDate;
  final String endDate;
  final String type;
  final String invoiceNo;
  final String billType;
  final String amount;
  final String supName;
  final String paymentMethod;
  final String unit;
  final String stageStatus;
  final String createdBy;
  final String approvedBy;
  final String permission;
  final VoidCallback onPressed;
  final Function(int) onAction;

  const ApprovalCard({
    Key? key,
    required this.index,
    required this.orderId,
    required this.subjectId,
    required this.orderCode,
    required this.orderQty,
    required this.bShortName,
    required this.employeeName,
    required this.stlNo,
    required this.onPressed,
    required this.onAction,
    required this.piNo,
    required this.totalPiQty,
    required this.totalPiValue,
    required this.buyer,
    required this.ttType,
    required this.approvalName,
    required this.permission,
    required this.designation,
    required this.department,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.invoiceNo,
    required this.billType,
    required this.amount,
    required this.supName,
    required this.paymentMethod,
    required this.unit,
    required this.stageStatus,
    required this.createdBy,
    required this.approvedBy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Card(
        elevation: 0,
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              width: 0.5,
              color: const Color.fromARGB(255, 29, 201, 192),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                            () {
                          switch (approvalName) {
                            case 'order_costing':
                              return 'Order No: $orderCode';
                            case 'employee_leave':
                              if (employeeName.length <= 15) {
                                return 'Name: $employeeName';
                              } else {
                                String truncatedName = employeeName.substring(0, 15);
                                return 'Name: $truncatedName...';
                              }
                            case 'tt_rtgs_bill':
                              return 'Inv. No: $invoiceNo';
                            default:
                              return 'PI No: $piNo';
                          }
                        }(),
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                            () {
                          switch (approvalName) {
                            case 'order_costing':
                              return 'Style: $stlNo';
                            case 'employee_leave':
                              return 'Date:${formatDate(startDate)}-${formatDate(endDate)}';
                            case 'tt_rtgs_bill':
                              return 'Amount: $amount';
                            default:
                              return 'PI Qty: $totalPiQty';
                          }
                        }(),
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                            () {
                          switch (approvalName) {
                            case 'order_costing':
                              return 'Qty: $orderQty';
                            case 'employee_leave':
                              return 'Type: $type';
                            case 'tt_rtgs_bill':
                              String tt = '';
                              if (paymentMethod == '2') {
                                tt = 'TT Payment';
                              } else if(paymentMethod == '3'){
                                tt = 'RTGS Payment';
                              }
                              return 'Type: $billType ($tt)';
                            default:
                              return 'PI Value: $totalPiValue';
                          }
                        }(),
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                            () {
                          switch (approvalName) {
                            case 'order_costing':
                              return 'Buyer: $buyer';
                            case 'employee_leave':
                              return ' Des:$designation($department)';
                            case 'tt_rtgs_bill':
                              String truncatedName = 'N/A';
                              if (supName.length > 19) {
                                truncatedName = supName.substring(0, 19) + '...';
                              } else {
                                truncatedName = supName;
                              }
                              return 'Sup: $truncatedName';
                            default:
                              return 'Buyer: $buyer';
                          }
                        }(),
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (approvalName == 'tt_rtgs_bill') ...[
                        Text(
                          'Unit: $unit',
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (approvalName == 'tt_rtgs_bill') ...[
                        Visibility(
                          visible: stageStatus == '1' ? false : true,
                          child: Text(
                            'Creator: ${createdBy.length > 18 ? createdBy.substring(0, 18) : createdBy}',
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          'Sender: ${approvedBy.length > 18 ? approvedBy.substring(0, 18) : createdBy}',
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3, // 30% of available space
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                      onPressed: onPressed,
                      child: const Text(
                        "View",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  Expanded(
                    flex: 3, // 30% of available space
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                  child: Text("No", style: TextStyle(color: Colors.white),),
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
                                  child: Text("Yes", style: TextStyle(color: Colors.white),),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirmAction == true) {
                          try {
                            if(approvalName == 'tt_rtgs_bill'){
                                final response = await ApprovalService.updateBillStatus(5, approvalName, orderId, permission, context);
                                if (response != null && response['type'] == 'success') {
                                  showSnackBar(context, response['message']);
                                  onAction(index);
                                } else {
                                  showSnackBar(context, 'Failed!');
                                }
                            } else {
                              print(orderId);
                                // final response = await ApprovalService.updateStatus(1, approvalName, orderId, permission, context);
                                // if (response != null) {
                                //   showSnackBar(context, response['msg']);
                                //   onAction(index);
                                // } else {
                                //   showSnackBar(context, 'Failed!');
                                // }
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
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  Expanded(
                    flex: 3, // 30% of available space
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                            final response = await ApprovalService.updateBillStatus(2, approvalName, orderId, permission, context);
                            if (response != null && response['type'] == 'error') {
                              showSnackBar(context, response['message']);
                              onAction(index);
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
            ],
          ),
        ),
      ),
    );
  }
}
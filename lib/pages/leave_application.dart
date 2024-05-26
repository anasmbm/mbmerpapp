import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mbm_store/common/widgets/appbar.dart';
import 'package:mbm_store/common/widgets/custom_button.dart';
import 'package:mbm_store/constants/global_variables.dart';
import 'package:mbm_store/constants/utils.dart';

import '../services/bengali_date_utils.dart';
import '../services/bengali_year_converter.dart';

class LeaveApplication extends StatefulWidget {
  const LeaveApplication({Key? key});

  @override
  LeaveApplicationState createState() => LeaveApplicationState();
}

class LeaveApplicationState extends State<LeaveApplication> {
  String? leaveTypeValue;
  String? leaveReasonValue;
  String? associateId;
  String? supervisorId;
  String? supervisorName;
  String? supervisorNameBn;
  String? supervisorDesignation;
  String? supervisorDesignationBn;
  String? supervisorDepartment;
  String? supervisorDepartmentBn;
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  bool translation = false;
  bool loading = false;
  bool submissionEnable = true;
  bool leaveStats = false;
  bool leaveLengthStats = false;
  List<String> leaveType = ["Casual","Earned","Sick","Maternity"];
  List<String> leaveReason = [];
  List<String> leaveReasonDefault = ["Others"];
  List<String> sickReason = ["Fever","Seasonal Flu", "Pain and Aches", "Diarrhea/dysentery","Injury","Others"];
  List<String> casualReason = ["Family issues","Death of family", "Child's responsibility", "Religious festival(ethnic groups)","Personal circumstance","Others"];
  Map<String, dynamic>? leaveBalance;
  Map<String, dynamic>? leaveBalanceSum;
  late int dojCount;
  final _formKey = GlobalKey<FormState>();
  XFile? _selectedFile;
  String lengthMsg = '';
  List<String> holidays = [];
  late int currentYear;
  late String bengaliYear;
  Map<String, String> leaveTypeTranslations = {
    'Casual': 'নৈমিত্তিক',
    'Earned': 'অর্জিত',
    'Sick': 'অসুস্থ',
    'Maternity': 'মাতৃত্ব',
  };
  Map<String, String> leaveReasonTranslations = {
    'Fever': 'জ্বর',
    'Seasonal Flu': 'ঋতুসংক্রান্ত ফ্লু',
    'Pain and Aches': 'ব্যাথা এবং আর্দ্রতা',
    'Diarrhea/dysentery': 'ডায়রিয়া/ব্যধি',
    'Injury': 'আঘাত',
    'Family issues': 'পরিবারের সমস্যা',
    'Death of family': 'পরিবারে মৃত্যু',
    "Child's responsibility": 'শিশুর দায়িত্ব',
    'Religious festival(ethnic groups)': 'ধর্মীয় উৎসব (জাতি সম্প্রদায়)',
    'Personal circumstance': 'ব্যক্তিগত অবস্থা',
    'Others': 'অন্যান্য',
  };

  @override
  void initState() {
    super.initState();
    currentYear = DateTime.now().year;
    bengaliYear = BengaliYearConverter.convertToBengali(currentYear);
    getData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(pageTitle: translation?'ছুটির আবেদন':'Leave Application', onPressed: translate, translateText: translation == false ? 'বাংলা' : 'English',),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    child: Text(translation ? 'আবেদন ফরম' : 'Application Form', style: const TextStyle(fontSize: 17)),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 8),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(8.0),
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 0.5,
                                color: const Color.fromARGB(255, 29, 201, 192),
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(translation ? 'ছুটির ধরন *' : 'Leave Type *'),
                                      Container(
                                        width: double.infinity,
                                        child: DropdownButtonFormField<String>(
                                          value: leaveTypeValue,
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                leaveTypeValue = newValue;
                                                leaveReasonValue = null;
                                                if(leaveTypeValue == 'Casual'){
                                                  leaveReason = casualReason;
                                                } else if(leaveTypeValue == 'Sick'){
                                                  leaveReason = sickReason;
                                                } else {
                                                  leaveReason = leaveReasonDefault;
                                                }
                                              });
                                              leaveCheck();
                                            }
                                          },
                                          hint: Text(translation ? 'ছুটির ধরন নির্বাচন' : 'Select Leave Type'),
                                          isExpanded: true,
                                          items: leaveType.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(translation ? leaveTypeTranslations[value] ?? value : value),
                                            );
                                          }).toList(),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return translation ? 'ছুটির ধরন নির্বাচন করুন':'Please select a Leave Type';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(translation ? 'কারণ' : 'Reason'),
                                      Container(
                                        width: double.infinity,
                                        child: DropdownButtonFormField<String>(
                                          value: leaveReasonValue,
                                          onChanged: (String? newValue) {
                                            if(leaveTypeValue == null){
                                              showSnackBar(context, translation ? 'প্রথমে ছুটির ধরন নির্বাচন করুন!':'Select leave type first!');
                                            }else{
                                              setState(() {
                                                leaveReasonValue = newValue;
                                              });
                                            }
                                          },
                                          hint: Text(translation ? 'কারণ নির্বাচন':'Select Reason'),
                                          isExpanded: true,
                                          items: leaveReason.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(translation ? leaveReasonTranslations[value] ?? value : value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 0.5,
                                color: const Color.fromARGB(255, 29, 201, 192),
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        readOnly: true,
                                        controller: TextEditingController(
                                          text: translation
                                              ? BengaliDateUtils.digitsToBengali(DateFormat("dd-MM-yyyy").format(fromDate))
                                              : DateFormat("dd-MM-yyyy").format(fromDate),
                                        ),
                                        decoration: InputDecoration(
                                          labelText: translation ? 'তারিখ হইতে *':'From Date *',
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return translation ? 'তারিখ নির্বাচন করুন':'Please select a date';
                                          }
                                          if (lengthMsg.isNotEmpty) {
                                            if (lengthMsg.contains('You have already taken') && translation) {
                                              return 'ইতিমধ্যে ছুটি নিয়েছেন';
                                            }
                                            return lengthMsg;
                                          }
                                          return null;
                                        },
                                        onTap: () async {
                                          if(leaveTypeValue == null){
                                            showSnackBar(context, translation?'ছুটির টাইপ নির্বাচন করুন!':'Select Leave Type First!');
                                            return;
                                          };
                                          final selectedDate = await showDatePicker(
                                            context: context,
                                            firstDate: DateTime(2005),
                                            initialDate: fromDate,
                                            lastDate: DateTime(2100),
                                          );
                                          if (selectedDate != null) {
                                            setState(() {
                                              fromDate = selectedDate;
                                              toDate = selectedDate;
                                            });
                                            leave_length_check();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        readOnly: true,
                                        controller: TextEditingController(
                                          text: translation
                                              ? BengaliDateUtils.digitsToBengali(DateFormat("dd-MM-yyyy").format(toDate))
                                              : DateFormat("dd-MM-yyyy").format(toDate),
                                        ),
                                        decoration: InputDecoration(
                                          labelText: translation?'তারিখ পর্যন্ত *':'To Date *',
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return translation?'তারিখ নির্বাচন করুন':'Please select a date';
                                          }
                                          return null;
                                        },
                                        onTap: () async {
                                          if(leaveTypeValue == null){
                                            showSnackBar(context, translation?'ছুটির টাইপ নির্বাচন করুন!':'Select Leave Type First!');
                                            return;
                                          };
                                          final selectedDate = await showDatePicker(
                                            context: context,
                                            firstDate: fromDate,
                                            initialDate: toDate,
                                            lastDate: DateTime(2100),
                                          );
                                          if (selectedDate != null) {
                                            setState(() {
                                              toDate = selectedDate;
                                            });
                                            leave_length_check();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 0.5,
                                color: const Color.fromARGB(255, 29, 201, 192),
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(translation?'সাপোর্টিং ফাইল':'Supporting File'),
                                      SizedBox(height: 6),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.teal, // Set background color to teal
                                                border: Border.all(color: Colors.grey), // Add border
                                                borderRadius: BorderRadius.circular(4), // Optional: Add border radius
                                              ),
                                              padding: EdgeInsets.all(8), // Add padding to the container
                                              child: Icon(Icons.upload, color: Colors.white), // Set icon color to white
                                            ),
                                            onTap: () async {
                                              final ImagePicker picker = ImagePicker();
                                              final sFile = await picker.pickImage(source: ImageSource.gallery);
                                              setState(() {
                                                _selectedFile = sFile;
                                              });
                                            },
                                          ),
                                          SizedBox(width: 16),
                                          GestureDetector(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.teal,
                                                border: Border.all(color: Colors.grey),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              padding: EdgeInsets.all(8),
                                              child: Icon(Icons.camera_alt, color: Colors.white),
                                            ),
                                            onTap: () async {
                                              final ImagePicker picker = ImagePicker();
                                              final sFile = await picker.pickImage(source: ImageSource.camera);
                                              setState(() {
                                                _selectedFile = sFile;
                                              });
                                            },
                                          ),
                                        ]
                                      ),
                                      SizedBox(height: 8),
                                      if (_selectedFile != null) ...[
                                        Stack(
                                          children: [
                                            Image.file(
                                              File(_selectedFile!.path),
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedFile = null;
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.red,
                                                  ),
                                                  child: Icon(Icons.close, color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: CustomButton(
                                      text: translation?'জমা দিন':'Submit',
                                      onTap: () async {
                                        if (_formKey.currentState!.validate()) {
                                          bool confirmAction = await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(translation?'নিশ্চিতকরণ':'Sure to submit:'),
                                                content: Text(translation?'নিশ্চিত করুন এবং আপনার সুপারভাইজারকে অনুমোদনের জন্য পাঠান: \nনাম: ${supervisorNameBn} \nপদবি: ${supervisorDesignationBn} \nবিভাগ: ${supervisorDepartmentBn}':'Supervisor: \nName: ${supervisorName} \nDes: ${supervisorDesignation} \nDept: ${supervisorDepartment}'),
                                                actions: <Widget>[
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop(false);
                                                      },
                                                      style: ButtonStyle(
                                                        foregroundColor: WidgetStateProperty.all<Color>(Colors.white), // Set your desired text color here
                                                      ),
                                                      child: Text(translation ? 'না' : 'No'),
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.teal,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop(true);
                                                      },
                                                      style: ButtonStyle(
                                                        foregroundColor: WidgetStateProperty.all<Color>(Colors.white), // Set your desired text color here
                                                      ),
                                                      child: Text(translation ? 'হ্যাঁ' : 'Yes'),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          if (confirmAction == true) {
                                            submitLeaveForm();
                                          }
                                        }
                                      },
                                      enabled: _formKey.currentState != null && _formKey.currentState!.validate() && leaveStats && leaveLengthStats && submissionEnable ?? false,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                    child: Text(
                      translation
                          ? 'ছুটির তালিকা - $bengaliYear'
                          : 'Leave Balance - $currentYear',
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Container(
                        padding: EdgeInsets.all(0),
                        color: Colors.white38,
                        child: loading
                            ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: CircularProgressIndicator(),
                          ), // Display circular progress indicator while loading
                        )
                            :  Table(
                          border: TableBorder.symmetric(
                            inside: const BorderSide(width: 0.5, color: Colors.grey),
                          ),
                          children: [
                            TableRow(children: [
                              for (var headerText in [
                                translation ? 'ছুটির নাম' : 'Leave',
                                translation ? 'বরাদ্দ' : 'Entitled',
                                translation ? 'গৃহীত' : 'Enjoyed',
                                translation ? 'পাওয়া যাবে' : 'Available'
                              ])
                                TableCell(
                                  child: Container(
                                    color: Colors.grey,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          headerText,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ]),
                            // Populate leave data dynamically
                            if (leaveBalance != null)
                              for (var leaveType in leaveBalance!.keys)
                                if (leaveType != 'earned') // Exclude earned leave data from the iteration
                                  TableRow(
                                    children: [
                                      TableCell(
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: (translation == true)
                                                ? (leaveType == 'sick')
                                                ? Text('অসুস্থ')
                                                : (leaveType == 'casual')
                                                ? Text('নৈমিত্তিক')
                                                : (leaveType == 'special')
                                                ? Text('বিশেষ')
                                                : Text(
                                                '${leaveType[0].toUpperCase()}${leaveType.substring(1).toLowerCase()}')
                                                : Text(
                                                '${leaveType[0].toUpperCase()}${leaveType.substring(1).toLowerCase()}'),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              translation
                                                  ? BengaliDateUtils.digitsToBengali('${leaveBalance![leaveType]['total']}')
                                                  : '${leaveBalance![leaveType]['total']}',
                                            ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              translation
                                                  ? BengaliDateUtils.digitsToBengali('${leaveBalance![leaveType]['enjoyed']}')
                                                  : '${leaveBalance![leaveType]['enjoyed']}',
                                            ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              translation
                                                  ? BengaliDateUtils.digitsToBengali('${leaveBalance![leaveType]['remaining']}')
                                                  : '${leaveBalance![leaveType]['remaining']}',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            // Add earned leave data separately
                            if (leaveBalance != null && leaveBalance!.containsKey('earned'))
                              TableRow(
                                children: [
                                  TableCell(
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: (translation == true)
                                            ? Text('অর্জিত')
                                            : Text('Earned'),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          translation
                                              ? BengaliDateUtils.digitsToBengali('${leaveBalance!['earned']['total']}')
                                              : '${leaveBalance!['earned']['total']}',
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          translation
                                              ? BengaliDateUtils.digitsToBengali('${leaveBalance!['earned']['enjoyed']}')
                                              : '${leaveBalance!['earned']['enjoyed']}',
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          translation
                                              ? BengaliDateUtils.digitsToBengali('${leaveBalance!['earned']['remaining']}')
                                              : '${leaveBalance!['earned']['remaining']}',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            TableRow(
                              children: [
                                TableCell(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        translation ? 'মোট' : 'Total',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        translation
                                            ? BengaliDateUtils.digitsToBengali(leaveBalanceSum!['entitled_total'].toString())
                                            : leaveBalanceSum!['entitled_total'].toString(),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        translation
                                            ? BengaliDateUtils.digitsToBengali(leaveBalanceSum!['enjoyed_total'].toString())
                                            : leaveBalanceSum!['enjoyed_total'].toString(),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        translation
                                            ? BengaliDateUtils.digitsToBengali(leaveBalanceSum!['remaining_total'].toString())
                                            : leaveBalanceSum!['remaining_total'].toString(),
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
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    ),
  );

  Future<void> getData() async {
    setState(() {
      loading = true;
    });
    final headers = await createHeaders();
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/leave-application'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final output = json.decode(response.body);
        print(output);
        setState(() {
          leaveBalance = Map<String, dynamic>.from(output['balance']);
          leaveBalanceSum = Map<String, dynamic>.from(output['total']);
          dojCount = output['dojCount'];
        });
      } else {
        print("1 API request failed with status code ${response.statusCode}");
      }
      setState(() {
        loading = false;
      });
    } catch (error) {
      print("Error loading data 1: $error");
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> submitLeaveForm() async {
    setState(() {
      submissionEnable = false;
    });
    List<String> leaveDays = [];
    DateTime startDate = fromDate;
    DateTime endDate = toDate;
    while (startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate)) {
      leaveDays.add(DateFormat("yyyy-MM-dd").format(startDate));
      startDate = startDate.add(Duration(days: 1));
    }
    Set<String> leaveDaysSet = Set.from(leaveDays);
    Set<String> holidaysSet = Set.from(holidays);
    Set<String> actualLeaveDaysSet = leaveDaysSet.difference(holidaysSet);
    List<String> actualLeaveDays = actualLeaveDaysSet.toList();
    // print(actualLeaveDays);
    if(actualLeaveDays.length == 0){
      showSnackBar(context, translation?'ছুটির দিন পাওয়া যায় নি!':'Leave days not available!');
      return;
    }
    Uri url = Uri.parse('$uri/api/leave-application');
    var request = http.MultipartRequest("POST", url);
    final headers = await createHeaders();
    request.headers.addAll(headers);
    // Add form fields to the request
    request.fields['leave_from'] = DateFormat("yyyy-MM-dd").format(fromDate);
    request.fields['leave_to'] = DateFormat("yyyy-MM-dd").format(toDate);
    request.fields['leave_type'] = leaveTypeValue!;
    request.fields['leave_days'] = actualLeaveDays.join(',');
    request.fields['leave_comment'] = leaveReasonValue ?? '';
    request.fields['leave_ass_id'] = associateId!;
    request.fields['send_to'] = supervisorId!;
    request.fields['leave_status'] = '0';
    request.fields['platform_app'] = '1';

    if (_selectedFile != null) {
      // print(_selectedFile);
      Uint8List? bytes = await _selectedFile?.readAsBytes();
      var myFile = http.MultipartFile(
        "leave_supporting_file",
        http.ByteStream.fromBytes(bytes as List<int>),
        bytes!.length,
        filename: _selectedFile?.name,
      );
      request.files.add(myFile);
    }
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final output = json.decode(response.body);
    print('response_received');
    print(output);
    if (output['msg'] != null) {
      if(output['type'] == 'success'){
        final successMessage = translation ? 'অনুমোদনের জন্য ছুটি প্রক্রিয়া করা হচ্ছে' : output['msg'];
        showSnackBar(context, successMessage);
      }else{
        final errorMessage = translation ? 'ফর্ম জমা দেয়া ব্যর্থ হয়েছে!' : output['msg'] ?? 'Failed to submit form!';
        showSnackBar(context, errorMessage);
      }
      setState(() {
        _selectedFile = null;
        fromDate = DateTime.now();
        toDate = DateTime.now();
        leaveTypeValue = null;
        leaveReasonValue = null;
      });
    } else {
      print('Failed to submit form. Status code: ${response.statusCode}');
      final errorMessage = translation ? 'ফর্ম জমা দেয়া ব্যর্থ হয়েছে!' : output['msg'] ?? 'Failed to submit form!';
      showSnackBar(context, errorMessage);
    }
    setState(() {
      submissionEnable = true;
    });
  }

  Future<void> leaveCheck() async {
    final headers = await createHeaders();
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/leave-check/${leaveTypeValue}'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final output = json.decode(response.body);
        if(output['stat'] == 'true'){
          setState(() {
            leaveStats = true;
          });
        } else {
          setState(() {
            leaveStats = false;
          });
        }
      } else {
        print("2 API request failed with status code ${response.statusCode}");
      }
      setState(() {
        loading = false;
      });
    } catch (error) {
      print("Error loading data 2: $error");
      setState(() {
        loading = false;
      });
    }
  }
  Future<void> leave_length_check() async {
    final from = DateFormat("yyyy-MM-dd").format(fromDate);
    final to = DateFormat("yyyy-MM-dd").format(toDate);
    final difference = toDate.difference(fromDate);
    final diffDays = difference.inDays;
    final selDays = diffDays + 1;

    final headers = await createHeaders();
    Map<String, dynamic> requestBody = {
      'from_date': from,
      'to_date': to,
      'leave_type': leaveTypeValue,
      'usertype': 'ess',
      'sel_days': selDays,
    };
    print(requestBody);
    try {
      http.Response responses = await http.post(
        Uri.parse('$uri/api/leave-length-check'),
        headers: headers,
        body: json.encode(requestBody),
      );
      if (responses.statusCode == 200) {
        final outputs = json.decode(responses.body);
        print(outputs);
        if(outputs['stat'] == 'true'){
          setState(() {
            leaveLengthStats = true;
            lengthMsg = '';
            holidays = List<String>.from(outputs['holidays']);
            associateId = outputs['leave_ass_id'];
            supervisorId = outputs['reporting_to'];
            supervisorName = outputs['reporting_name'];
            supervisorNameBn = outputs['reporting_name_bn'];
            supervisorDesignation = outputs['reporting_designation'];
            supervisorDesignationBn = outputs['reporting_designation_bn'];
            supervisorDepartment = outputs['reporting_department'];
            supervisorDepartmentBn = outputs['reporting_department_bn'];
          });
        } else {
          setState(() {
            leaveLengthStats = false;
            lengthMsg = outputs['msg'];
            holidays = List<String>.from(outputs['holidays']);
            associateId = outputs['leave_ass_id'];
            supervisorId = outputs['reporting_to'];
            supervisorName = outputs['reporting_name'];
            supervisorDesignation = outputs['reporting_designation'];
            supervisorDepartment = outputs['reporting_department'];
          });
        }
      } else {
        print("3 API request failed with status code ${responses.statusCode}");
      }
      setState(() {
        loading = false;
      });
    } catch (error) {
      print("Error loading data 3: $error");
      setState(() {
        loading = false;
      });
    }
  }

  translate() async {
    setState(() {
      translation = !translation;
    });
  }
}
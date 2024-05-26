import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mbm_store/common/widgets/appbar.dart';
import 'package:mbm_store/common/widgets/custom_button.dart';
import 'package:mbm_store/constants/global_variables.dart';
import 'package:mbm_store/constants/utils.dart';

class Complain extends StatefulWidget {
  static const String routeName = '/complain';
  const Complain({Key? key});

  @override
  ComplainState createState() => ComplainState();
}

class ComplainState extends State<Complain> {
  late Map<String, dynamic>? unitList = {};
  late Map<String, dynamic>? unitListBn = {};
  late Map<String, dynamic>? deptList = {};
  late Map<String, dynamic>? deptListBn = {};
  late Map<String, dynamic>? userList = {};
  late Map<String, dynamic>? bnNameById = {};
  bool translation = false;
  String? unitId;
  String? deptId;
  String? empIdValue;
  String? empNameValue;
  String? complainTypeValue;
  String? complainReasonValue;
  String? associateId;
  String? description;
  TextEditingController _descriptionController = TextEditingController();
  String? userName;
  String? userNameBn;
  String? userId;
  bool loading = false;
  bool submissionEnable = true;
  List<String> complainType = ["Working Condition","Workplace Safety","Harassment","Others"];
  Map<String, String> complainTypeTranslations = {
    'Working Condition': 'কাজের শর্ত',
    'Workplace Safety': 'কর্মক্ষেত্রে নিরাপত্তা',
    'Harassment': 'হয়রানি',
    'Others': 'অন্যান্য',
  };
  Map<String, String> complainReasonTranslations = {
    'Physical': 'শারীরিক',
    'Verbal': 'মৌখিক',
    'Sexual': 'যৌন',
    'Leave': 'ছুটি',
    'Overtime Issue': 'অতিরিক্ত কাজের সমস্যা',
    'Wash material': 'পরিষ্কারের সামগ্রী',
    'Insufficient fire safety': 'অপর্যাপ্ত অগ্নি নিরাপত্তা',
    'Breakage or damage': 'ভাঙা বা ক্ষতি',
    'Faulty machine': 'ত্রুটিপূর্ণ মেশিন',
    'Insufficient health safety': 'অপর্যাপ্ত স্বাস্থ্য নিরাপত্তা',
    'Others': 'অন্যান্য',
  };
  List<String> complainReason = [];
  List<String> complainReasonDefault = ["Others"];
  List<String> harassmentReason = ["Physical","Verbal", "Sexual"];
  List<String> workingConditionReason = ["Leave","Overtime Issue", "Wash material"];
  List<String> workplaceSafetyReason = ["Insufficient fire safety","Breakage or damage", "Faulty machine", "Insufficient health safety"];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(pageTitle: translation?'অভিযোগ ফর্ম':'Complain Form', onPressed: translate, translateText: translation == false ? 'বাংলা' : 'English',),
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
                    child: Text(translation?'কর্মচারীর তথ্য':'Employee Info', style: const TextStyle(fontSize: 17)),
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
                                      Text(translation?'ইউনিট':'Unit'),
                                      Container(
                                        width: double.infinity,
                                        child: DropdownButtonFormField<String>(
                                          value: unitId,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              unitId = newValue;
                                              deptId = null;
                                              empIdValue = null;
                                              empNameValue = null;
                                            });
                                            if(deptId != null) {
                                              fetchUser();
                                            }
                                            print(description);
                                          },
                                          hint: Text(translation?'ইউনিট নির্বাচন করুন':'Select Unit'),
                                          isExpanded: true,
                                          items: unitList?.isNotEmpty == true
                                              ? unitList?.keys.map((String key) {
                                            return DropdownMenuItem<String>(
                                              value: key,
                                              child: translation?Text(unitListBn?[key]):Text(unitList?[key]),
                                            );
                                          }).toList() : null,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return translation?'ইউনিট নির্বাচন করুন':'Please select a unit';
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
                                      Text(translation?'বিভাগ':'Department'),
                                      Container(
                                        width: double.infinity,
                                        child: DropdownButtonFormField<String>(
                                          value: deptId,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              deptId = newValue;
                                              empIdValue = null;
                                              empNameValue = null;
                                            });
                                            if(unitId == null){
                                              showSnackBar(context, translation?'ইউনিট নির্বাচন করুন':'Select Unit first!');
                                            }else {
                                              fetchUser();
                                            }
                                          },
                                          hint: Text(translation?'বিভাগ নির্বাচন করুন':'Select Department'),
                                          isExpanded: true,
                                          items: deptList?.isNotEmpty == true
                                              ? deptList?.keys.map((String key) {
                                            return DropdownMenuItem<String>(
                                              value: key,
                                              child: translation?Text(deptListBn?[key]):Text(deptList?[key]),
                                            );
                                          }).toList() : null,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return translation?'বিভাগ নির্বাচন করুন':'Please select a Department';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                                      Text(translation?'আইডি':'ID'),
                                      Container(
                                        width: double.infinity,
                                        child: DropdownSearch<String>(
                                          filterFn: (item, filter) {
                                            return item.toLowerCase().contains(filter.toLowerCase()) ||
                                                userList![item]!.toLowerCase().contains(filter.toLowerCase());
                                          },
                                          popupProps: PopupProps.menu(
                                            showSelectedItems: true,
                                            showSearchBox: true,
                                            searchFieldProps: TextFieldProps(
                                              decoration: InputDecoration(
                                                hintText: translation?'খোঁজার জন্য লিখুন':'Type to search',
                                                hintStyle: TextStyle(color: Colors.grey),
                                                enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                                                ),
                                                border: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                                                ),
                                              ),
                                            ),
                                            itemBuilder: (context, item, isSelected) {
                                              return ListTile(
                                                title: Text('$item - ${userList![item]}'), // Display both ID and value
                                              );
                                            },
                                          ),
                                          items: userList!.keys.toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              empIdValue = newValue;
                                              empNameValue = userList?[newValue];
                                            });
                                          },
                                          selectedItem: empIdValue,
                                          dropdownDecoratorProps: DropDownDecoratorProps(
                                            dropdownSearchDecoration: InputDecoration(
                                              hintText: translation?'আইডি নির্বাচন করুন':'Select ID',
                                              enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Colors.grey, width: 1.5),
                                              ),
                                              border: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Colors.grey, width: 1.5),
                                              ),
                                            ),
                                          ),
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
                                      Text(translation?'নাম':'Name'),
                                      Container(
                                        width: double.infinity,
                                        child: DropdownButtonFormField<String>(
                                          value: empNameValue,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              empNameValue = newValue;
                                            });
                                          },
                                          hint: Text(translation?'নাম নির্বাচন করুন':'Select Name'),
                                          isExpanded: true,
                                          items: empIdValue != null
                                              ? [
                                            DropdownMenuItem<String>(
                                              value: empNameValue ?? '',
                                              child: Text(translation ? (bnNameById?[empIdValue] ?? '') : (empNameValue ?? ''),),
                                            )
                                          ]
                                              : null,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return translation?'নাম নির্বাচন করুন':'Please select a Name';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                                      Text(translation?'অভিযোগের ধরন':'Complain Type'),
                                      Container(
                                        width: double.infinity,
                                        child: DropdownButtonFormField<String>(
                                          value: complainTypeValue,
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                complainTypeValue = newValue;
                                                complainReasonValue = null;
                                                if(complainTypeValue == 'Working Condition'){
                                                  complainReason = workingConditionReason;
                                                } else if(complainTypeValue == 'Harassment'){
                                                  complainReason = harassmentReason;
                                                } else if(complainTypeValue == 'Workplace Safety'){
                                                  complainReason = workplaceSafetyReason;
                                                } else {
                                                  complainReason = complainReasonDefault;
                                                }
                                              });
                                            }
                                          },
                                          hint: Text(translation?'অভিযোগের ধরন নির্বাচন করুন':'Select Complain Type'),
                                          isExpanded: true,
                                          items: complainType.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(translation ? complainTypeTranslations[value] ?? value : value),
                                            );
                                          }).toList(),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return translation?'অভিযোগের ধরন নির্বাচন করুন':'Please select a Complain Type';
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
                                      Text(translation?'কারণ':'Reason'),
                                      Container(
                                        width: double.infinity,
                                        child: DropdownButtonFormField<String>(
                                          value: complainReasonValue,
                                          onChanged: (String? newValue) {
                                            if(complainTypeValue == null){
                                              showSnackBar(context, translation?'অভিযোগের ধরন নির্বাচন করুন':'Select complain type first!');
                                            }else{
                                              setState(() {
                                                complainReasonValue = newValue;
                                              });
                                            }
                                          },
                                          hint: Text(translation?'কারণ নির্বাচন করুন':'Select Reason'),
                                          isExpanded: true,
                                          items: complainReason.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(translation ? complainReasonTranslations[value] ?? value : value),
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
                                      Text(translation?'বর্ণনা':'Description'),
                                      SizedBox(height: 8.0),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey, // You can customize the color here
                                              width: 1.0, // You can adjust the width here
                                            ),
                                          ),
                                        ),
                                        child: TextField(
                                          controller: _descriptionController,
                                          onChanged: (String newValue) {
                                            setState(() {
                                              description = newValue;
                                            });
                                          },
                                          maxLines: null,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: translation?'বর্ণনা লিখুন':'Enter your description here...',
                                          ),
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
                                                title: Text(translation?'নিশ্চিতকরণ':'Sure to submit?'),
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
                                                      child: Text(translation?'না':'No'),
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
                                                      child: Text(translation?'হ্যাঁ':'Yes'),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          if (confirmAction == true) {
                                            submitComplainForm(context);
                                          }
                                        }
                                      },
                                      enabled: true,
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
        Uri.parse('$uri/api/complain'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final output = json.decode(response.body);
        print(output);
        setState(() {
          unitList = Map<String, dynamic>.from(output["unitList"]);
          unitListBn = Map<String, dynamic>.from(output["unitListBn"]);
          deptList = Map<String, dynamic>.from(output["departmentList"]);
          deptListBn = Map<String, dynamic>.from(output["departmentListBn"]);
          bnNameById = Map<String, dynamic>.from(output["bnNameById"]);
          userName = output["userName"];
          userNameBn = output["userNameBn"];
          userId = output["userId"];
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

  String convertToBengaliNumerals(String input) {
    const englishToBengaliDigits = {
      '0': '০',
      '1': '১',
      '2': '২',
      '3': '৩',
      '4': '৪',
      '5': '৫',
      '6': '৬',
      '7': '৭',
      '8': '৮',
      '9': '৯',
    };

    return input.split('').map((char) => englishToBengaliDigits[char] ?? char).join('');
  }

  String translateDateToBengali(DateTime date) {
    final months = [
      'জানুয়ারী',
      'ফেব্রুয়ারী',
      'মার্চ',
      'এপ্রিল',
      'মে',
      'জুন',
      'জুলাই',
      'আগস্ট',
      'সেপ্টেম্বর',
      'অক্টোবর',
      'নভেম্বর',
      'ডিসেম্বর'
    ];
    String day = convertToBengaliNumerals(date.day.toString());
    String month = months[date.month - 1];
    String year = convertToBengaliNumerals(date.year.toString());

    return '$day $month, $year';
  }

  Future<void> submitComplainForm(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translation?'অভিযোগের আবেদন':'Complain Application', style: TextStyle(fontSize: 17)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${translation ? 'তারিখ' : 'Date'}: ${translation ? translateDateToBengali(DateTime.now()) : DateTime.now().toIso8601String().substring(0, 10)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(translation?'প্রিয় স্যার/ম্যাডাম,':'Dear Sir/Madam,'),
                SizedBox(height: 20),
                translation ? Text('আমি, ${userNameBn}, কর্মকর্তা আইডি: ${userId}, এই চিঠি লিখছি আমার অভিযোগ প্রকাশ করতে:'):
                Text('I, ${userName}, Employee ID: ${userId}, am writing this letter to express my complain for this issue:'),
                SizedBox(height: 20),
                Text('${translation ? 'আইডি' : 'ID'}: ${empIdValue}'),
                Text('${translation ? 'নাম: ${bnNameById?[empIdValue]}' : 'Name: ${empNameValue}'}'),
                Text('${translation ? 'বিভাগ: ${deptListBn?[deptId]}' : 'Department: ${deptList?[deptId]}'}'),
                Text('${translation ? 'ইউনিট: ${unitListBn?[unitId]}' : 'Unit: ${unitList?[unitId]}'}'),
                SizedBox(height: 20),
                Text('${translation ? 'অভিযোগের ধরণ' : 'Complain Type'}: ${complainTypeValue}'),
                Text('${translation ? 'অভিযোগের কারণ' : 'Complain Reason'}: ${complainReasonValue}'),
                Visibility(
                    visible: description != null,
                    child: Text(translation?'বিবরণ':'Description: ${description}')
                ),
                SizedBox(height: 20),
                Text(translation?'আমি এই বিষয়ে প্রয়োজনীয় পদক্ষেপ নিতে অনুরোধ করছি।':'I request to take necessary steps on this matter.'),
                SizedBox(height: 20),
                Text(translation?'এই সমস্যার প্রতি আপনার মনোযোগের জন্য আপনাকে ধন্যবাদ।':'Thank you for your attention to this issue.'),
                SizedBox(height: 20),
                Text(translation?'বিনম্রভাবে':'Sincerely,'),
                SizedBox(height: 0),
                Text('${translation ? userNameBn : userName}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(translation?'বাতিল করুন':'Cancel'),
            ),
            TextButton(
              onPressed: () {
                submitComplainApplicationForm();
              },
              child: Text(translation?'জমা দিন':'Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> submitComplainApplicationForm() async {
    final headers = await createHeaders();
    Map<String, dynamic> requestBody = {
      'empIdValue': empIdValue,
      'empNameValue': empNameValue,
      'deptId': deptId,
      'unitId': unitId,
      'complainTypeValue': complainTypeValue,
      'complainReasonValue': complainReasonValue,
      'description': description,
      'userName': userName,
      'userId': userId,
    };
    // print(requestBody);
    try {
      http.Response responses = await http.post(
        Uri.parse('$uri/api/complain'),
        headers: headers,
        body: json.encode(requestBody),
      );
      if (responses.statusCode == 200) {
        final output = json.decode(responses.body);
        print(output);
        if (output['msg'] != null) {
          Navigator.of(context).pop(false);
          showSnackBar(context, output['msg']);
          if(output['type'] == 'success'){
            setState((){
              empIdValue = null;
              empNameValue = null;
              deptId = null;
              unitId = null;
              complainTypeValue = null;
              complainReasonValue = null;
              description = null;
              _descriptionController.clear();
            });
          }
        }
      } else {
        print("3 API request failed with status code ${responses.statusCode}");
      }
    } catch (error) {
      print("Error loading data 3: $error");
    }
  }

  Future<void> fetchUser() async{
    final headers = await createHeaders();
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/fetchUser/${int.parse(unitId!)}/${int.parse(deptId!)}'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // print(data);
        setState(() {
          userList = Map<String, dynamic>.from(data["userList"]);
        });
      } else {
        print("API request failed with status code ${response.statusCode}");
      }
    } catch (error) {
      print("Error loading data 2: $error");
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
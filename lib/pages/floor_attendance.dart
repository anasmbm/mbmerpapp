import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mbm_store/common/widgets/appbar.dart';
import 'package:mbm_store/common/widgets/custom_button.dart';
import 'package:mbm_store/constants/global_variables.dart';
import 'package:mbm_store/constants/utils.dart';

class FloorAttendance extends StatefulWidget {
  const FloorAttendance({Key? key});

  @override
  FloorAttendanceState createState() => FloorAttendanceState();
}

class FloorAttendanceState extends State<FloorAttendance> {
  static const numberOfPostsPerRequest = 20;
  DateTime startDate = DateTime.now();
  bool noMoreData = false;
  String? unitValue;
  int total_emp = 0;
  String total_working_hour = '';
  int operator = 0;
  int ironman = 0;
  int helper = 0;
  int others = 0;
  String? floorValue;
  bool loading = false;
  late Map<String, dynamic>? unitList = {};
  late List<dynamic>? floorList = [];
  final _formKey = GlobalKey<FormState>();
  final PagingController<int, PostModel> pagingController =
  PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }

  Future<void> fetchPage(int pageKey) async {
    try {
      final headers = await createHeaders();
      String _formattedDate = DateFormat('yyyy-MM-dd').format(startDate);
      String url = '$uri/api/floor-attendance-data?unit=${unitValue}&in_date=${_formattedDate}&floor_id=${floorValue}&agent=app';
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> responseData = data['attData'];
        setState(() {
          total_emp = data['total_emp'] ?? 0;
          total_working_hour = data['totalHours'] ?? '';
          operator = data['group_emp']['OPERATOR'] ?? 0;
          ironman = data['group_emp']['IRONMAN'] ?? 0;
          helper = data['group_emp']['HELPER'] ?? 0;
          others = data['group_emp']['OTHERS'] ?? 0;
        });
        final postList = responseData.keys.map((String key) {
          final data = responseData[key];
          return PostModel(
            id: data['associate_id'],
            image: data['as_pic'],
            name: data['as_name'],
            designation: data['designation_name'] ?? 'N/A',
            inTime: data['in_time'] ?? 'N/A',
            outTime: data['out_time'] ?? '',
            gender: data['as_gender']
          );
        }).toList();

        final isLastPage = postList.length < numberOfPostsPerRequest;
        if (isLastPage) {
          pagingController.appendLastPage(postList);
          debugPrint('All pages ended. This is the last page');
        } else {
          final nextPageKey = pageKey + 1;
          pagingController.appendPage(postList, nextPageKey);
        }
      } else {
        debugPrint("API request failed with status code ${response.statusCode}");
        pagingController.error = "API request failed";
      }
    } catch (error) {
      debugPrint('error --> $error');
      pagingController.error = error.toString();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(pageTitle: 'Floor Attendance Report'),
    body: RefreshIndicator(
      onRefresh: () => Future.sync(pagingController.refresh),
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
                        Text("Unit *"),
                        Container(
                          width: double.infinity,
                          child: DropdownButtonFormField<String>(
                            value: unitValue,
                            onChanged: (String? newValue) {
                              setState(() {
                                unitValue = newValue;
                              });
                              floorByUnit(newValue);
                            },
                            hint: Text('Select Unit'),
                            isExpanded: true,
                            items: unitList?.isNotEmpty == true
                                ? unitList?.keys.map((String key) {
                              return DropdownMenuItem<String>(
                                value: key,
                                child: Text(unitList?[key]),
                              );
                            }).toList() : null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a unit';
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
                        Text("Floor"),
                        Container(
                          width: double.infinity,
                          child: DropdownButtonFormField<String>(
                            value: floorValue,
                            onChanged: (String? newValue) {
                              setState(() {
                                floorValue = newValue;
                              });
                            },
                            hint: Text('Select a floor'),
                            isExpanded: true,
                            items: floorList?.isNotEmpty == true
                                ? floorList?.map<DropdownMenuItem<String>>((dynamic item) {
                              return DropdownMenuItem<String>(
                                value: item['id'].toString(),
                                child: Text(item['name']),
                              );
                            }).toList()
                                : null,
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
                            text: DateFormat("dd-MM-yyyy").format(startDate),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Date *',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please select a date';
                            }
                            return null;
                          },
                          onTap: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              firstDate: DateTime(1900),
                              initialDate: startDate,
                              lastDate: DateTime(2100),
                            );

                            if (selectedDate != null) {
                              setState(() {
                                startDate = selectedDate;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: CustomButton(
                        text: 'Submit',
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                              fetchPage(1);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(5),
              color: Colors.blueGrey,
              child: Center(
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 8.0),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'T. W. Hour: ${total_working_hour}',
                            textAlign:TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Total Emp: ${total_emp}',
                            textAlign:TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Operator: ${operator}',
                            textAlign:TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 8.0),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Ironman: ${ironman}',
                            textAlign:TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Helper: ${helper}',
                            textAlign:TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Others: ${others}',
                            textAlign:TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            total_emp > 0 ? Expanded(
              child: PagedListView<int, PostModel>(
                pagingController: pagingController,
                builderDelegate: PagedChildBuilderDelegate<PostModel>(
                  animateTransitions: true,
                  itemBuilder: (context, item, index) {
                    return PostWidget(
                        post: item,
                        pagingController: pagingController
                    );
                  },
                ),
              ),
            ) : Center(
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Text('No Data Available!'),
              ),
            ),
          ],
        ),
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
        Uri.parse('$uri/api/floor-attendance'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          unitList = Map<String, dynamic>.from(data["unitList"]);
        });
      } else {
        print("API request failed with status code ${response.statusCode}");
      }
      setState(() {
        loading = false;
      });
    } catch (error) {
      print("Error loading data: $error");
      setState(() {
        loading = false;
      });
    }
  }

  void floorByUnit(String? newValue) async {
    setState(() {
      loading = true;
    });
    final headers = await createHeaders();
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/floorByUnit/${int.parse(newValue!)}'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          floorList = List<dynamic>.from(data["floorList"]);
        });
      } else {
        print("API request failed with status code ${response.statusCode}");
      }
    } catch (error) {
      print("Error loading data: $error");
      setState(() {
        loading = false;
      });
    }
  }

}

class PostWidget extends StatelessWidget {
  final PostModel post;

  final pagingController;

  const PostWidget({
    Key? key,
    required this.post,
    this.pagingController,
  });

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        border: Border.all(
          width: 0.5,
          color: Colors.grey,
        ),
      ),
      child: Container(
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
          },
          children: [
            TableRow(
              children: [
                TableCell(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: post.image != null || post.image.isNotEmpty
                          ? FadeInImage.assetNetwork(
                          placeholder: 'assets/user.png',
                          image: uri + post.image,
                          height: 50,
                          width: 50,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return post.gender == 'Male' ?
                              Image.asset('assets/male.jpg', height: 50, width: 50,)
                              : Image.asset('assets/female.jpg', height: 50, width: 50,);
                          }
                      )
                          : Text('N/A'),
                    ),
                  ),
                ),
                TableCell(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text('${post.name}', textAlign: TextAlign.center),
                  ),
                ),
                TableCell(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text('In Time: ${post.inTime != 'N/A' ? DateFormat('h:mm a').format(DateTime.parse(post.inTime)) : ''}'),
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                TableCell(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text('${post.id}')
                    ),
                  ),
                ),
                TableCell(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text('${post.designation}', textAlign: TextAlign.center),
                  ),
                ),
                TableCell(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text('Out Time: ${post.outTime != '' ? DateFormat('h:mm a').format(DateTime.parse(post.outTime)) : ''}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      )
  );
}

class PostModel {
  final String id;
  final String image;
  final String name;
  final String designation;
  final String inTime;
  final String outTime;
  final String gender;

  PostModel({
    required this.id,
    required this.image,
    required this.name,
    required this.designation,
    required this.inTime,
    required this.outTime,
    required this.gender,
  });
}
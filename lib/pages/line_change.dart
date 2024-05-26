import 'dart:convert';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mbm_store/common/widgets/appbar.dart';
import 'package:mbm_store/constants/global_variables.dart';
import 'package:mbm_store/constants/utils.dart';

class LineChange extends StatefulWidget {
  const LineChange({Key? key});

  @override
  LineChangeState createState() => LineChangeState();
}

class LineChangeState extends State<LineChange> {
  static const numberOfPostsPerRequest = 20;
  // DateTime startDate = DateTime.parse("2023-10-26");
  DateTime startDate = DateTime.now();
  bool saveBtnVisibility = false;
  var allData = [];

  final PagingController<int, PostModel> pagingController =
  PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
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
      String url =
          '$uri/api/line-change?page=$pageKey&limit=$numberOfPostsPerRequest&date=$_formattedDate';
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> responseData = data['data'];
        print(responseData.length);
        final postList = responseData.map((data) {
          return PostModel(
            id: int.parse(data['id']),
            image: data['image'] ?? '',
            name: data['name'] ?? '',
            line: data['line'] ?? '',
            updatedBy: data['updated_by'] ?? '',
            inTime: data['in_time'] ?? '',
            outTime: data['out_time'] ?? '',
            gender: data['gender'] ?? '',
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
        debugPrint(
            "API request failed with status code ${response.statusCode}");
        pagingController.error = "API request failed";
      }
    } catch (error) {
      debugPrint('error --> $error');
      pagingController.error = error.toString();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(pageTitle: 'Line Change'),
    body: RefreshIndicator(
      onRefresh: () => Future.sync(pagingController.refresh),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Date',),
                DateTimeField(
                  format: DateFormat("dd-MM-yyyy"),
                  initialValue: startDate,
                  keyboardType: TextInputType.datetime,
                  onShowPicker: (BuildContext context, DateTime? currentValue) {
                    return showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                  },
                  onChanged: (DateTime? newValue) {
                    if (newValue != null) {
                      setState(() {
                        startDate = newValue;
                      });
                      pagingController.refresh();
                    }
                  },
                )
              ],
            ),
          ),
          Container(
            height: 50.0,
            color: Colors.blueGrey,
            child: Row(
              children: [
                SizedBox(width: 15.0),
                Text(
                  'Image',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 20.0),
                Text(
                  'Name',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 35.0),
                Text(
                  'C. Line',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 18.0),
                Text(
                  'In Time',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 40.0),
                Text(
                  'Out Time',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PagedListView<int, PostModel>(
              pagingController: pagingController,
              builderDelegate: PagedChildBuilderDelegate<PostModel>(
                animateTransitions: true,
                itemBuilder: (context, item, index) {
                  return PostWidget(
                    post: item,
                    pagingController: pagingController,
                    allData: allData,
                    startDate: startDate,
                    onSaveVisibilityChanged: (bool isVisible) {
                      setState(() {
                        saveBtnVisibility = isVisible;
                      });
                    },
                  );
                },
              ),
            ),
          ),
          Visibility(
            visible: saveBtnVisibility,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () {
                    saveData();
                  },
                  child: Icon(Icons.save),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> saveData() async {
    try {
      final headers = await createHeaders();
      String url = '$uri/api/line-change-update';

      final Map<String, dynamic> requestData = {
        'allData': allData,
        'date': DateFormat('yyyy-MM-dd').format(startDate)
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestData),
      );
      if (response.statusCode == 200) {
        final output = json.decode(response.body);
        print(output);
        if (output == "success") {
          showSnackBar(context, "Out Time Updated!");
        } else {
          showSnackBar(context, 'Out Time Modification Failed!');
        }
      } else {
        print("API request failed with status code ${response.statusCode}");
        throw Exception("API request failed");
      }
    } catch (error) {
      print("Error: $error");
    }
  }
}

class PostWidget extends StatefulWidget {
  final PostModel post;
  final allData;
  final startDate;
  final pagingController;
  final ValueChanged<bool> onSaveVisibilityChanged;

  PostWidget({
    Key? key,
    required this.post,
    this.pagingController,
    this.allData,
    this.startDate,
    required this.onSaveVisibilityChanged,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
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
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1.2),
          2: FlexColumnWidth(0.8),
          3: FlexColumnWidth(1.3),
          4: FlexColumnWidth(2),
        },
        children: [
          TableRow(
            children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: widget.post.image != null ||
                        widget.post.image.isNotEmpty
                        ? FadeInImage.assetNetwork(
                      placeholder: 'assets/user.png',
                      image: uri + widget.post.image,
                      height: 50,
                      width: 50,
                      imageErrorBuilder:
                          (context, error, stackTrace) {
                        return widget.post.gender == 'Male'
                            ? Image.asset('assets/male.jpg',
                          height: 50, width: 50,)
                            : Image.asset('assets/female.jpg',
                          height: 50, width: 50,);
                      },
                    )
                        : Text('N/A'),
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(widget.post.name),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(widget.post.line),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    widget.post.inTime != null
                        ? DateFormat('h:mm a').format(DateTime.parse(widget.post.inTime!))
                        : '',
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Container(
                  alignment: Alignment.center,
                  child: DateTimeField(
                    initialValue: widget.post.outTime != ''
                        ? DateTime.parse(widget.post.outTime!)
                        : null,
                    format: DateFormat("h:mm a"),
                    onShowPicker: (context, currentValue) async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                          currentValue ?? DateTime.now(),
                        ),
                      );
                      return DateTimeField.convert(time);
                    },
                    onChanged: (DateTime? newValue) {
                      setState(() {
                        if (newValue != null) {
                          print(widget.post.inTime);
                          String formattedOutTime = DateFormat('HH:mm:ss').format(newValue);
                          DateTime outDate = widget.startDate;
                          DateTime combinedDateTime = DateTime(
                            outDate.year,
                            outDate.month,
                            outDate.day,
                            int.parse(formattedOutTime.split(':')[0]),
                            int.parse(formattedOutTime.split(':')[1]),
                            int.parse(formattedOutTime.split(':')[2]),
                          );
                          String formattedCombinedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(combinedDateTime);
                          var inTime;
                          if(widget.post.inTime != null){
                            inTime = widget.post.inTime;
                          }else{
                            inTime = widget.startDate;
                          }
                          DateTime dt1 = DateTime.parse(inTime);
                          DateTime dt2 = DateTime.parse(formattedCombinedDateTime);
                          if(dt1.isAfter(dt2)){
                            dt2 = dt2.add(Duration(days: 1));
                          }
                          int existingIndex = widget.allData.indexWhere((entry) => entry['update_id'] == widget.post.id);
                          if (existingIndex != -1) {
                            widget.allData[existingIndex]['out_time'] = dt2.toString();
                            widget.allData[existingIndex]['in_time'] = widget.post.inTime;
                          } else {
                            widget.allData.add({
                              'update_id': widget.post.id,
                              'out_time': dt2.toString(),
                              'in_time': widget.post.inTime,
                            });
                          }
                        } else {
                          widget.allData.removeWhere((entry) => entry['update_id'] == widget.post.id);
                        }
                        bool isSaveBtnVisible = widget.allData.length > 0;
                        widget.onSaveVisibilityChanged(isSaveBtnVisible);
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Time',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
  class PostModel {
  final int id;
  final String image;
  final String name;
  final String line;
  final String? updatedBy;
  final String? inTime;
  final String? outTime;
  final String gender;

  PostModel({
  required this.id,
  required this.image,
  required this.name,
  required this.line,
  this.updatedBy,
  this.inTime,
  this.outTime,
  required this.gender,
});
}
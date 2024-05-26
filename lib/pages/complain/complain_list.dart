import 'package:flutter/material.dart';
import 'package:mbm_store/constants/utils.dart';
import 'package:mbm_store/services/complain_service.dart';
import 'package:mbm_store/common/widgets/appbar.dart';

class ComplainList extends StatefulWidget {
  static const String routeName = '/complain-list';

  const ComplainList({Key? key}) : super(key: key);

  @override
  State<ComplainList> createState() => _ComplainListState();
}

class _ComplainListState extends State<ComplainList> {
  late List<Map<String, dynamic>> approvalData = [];
  late List<Map<String, dynamic>> filteredData = [];
  bool loading = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(pageTitle: 'Complain List', backLink: '/complain'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    filterData('');
                  },
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // Add your desired border color here
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // Border color after focus
                ),
              ),
              onChanged: (value) {
                filterData(value);
              },
            ),
          ),
          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : filteredData.isNotEmpty
                ? ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final item = filteredData[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.all(5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        width: 0.5,
                        color: const Color.fromARGB(255, 29, 201, 192),
                      ),
                    ),
                    child: ListTile(
                      title: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Unit: ${item['hr_unit_short_name']}'),
                              Text('Name: ${item['as_name']}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('ID: ${item['associate_id']}'),
                              Text('Department: ${item['hr_department_name']}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('C. Type: ${item['complain_type']}'),
                              TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0), // Adjust border radius as needed
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Adjust the padding
                                  ),
                                  onPressed: () async {
                                    // print(item);
                                    submitComplainForm(context, item);
                                  },
                                  child: const Text(
                                    "View",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14, // Adjust the text size
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      onTap: (){
                        // print('object');
                        submitComplainForm(context, item);
                      },
                    ),
                  ),
                );
              },
            )
                : Center(child: Text('No data available!')),
          ),
        ],
      ),
    );
  }

  Future<void> loadData() async {
    setState(() {
      loading = true;
    });
    try {
      List<Map<String, dynamic>> data = await ComplainService.getData();
      setState(() {
        approvalData = data;
        filteredData = data; // Initialize filteredData with all data initially
        loading = false;
      });
    } catch (error) {
      print("Error loading data: $error");
      setState(() {
        loading = false;
      });
    }
  }

  void filterData(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredData = approvalData;
      } else {
        filteredData = approvalData.where((item) {
          return item['as_name'].toLowerCase().contains(query.toLowerCase()) ||
              item['associate_id'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> submitComplainForm(BuildContext context, Map<String, dynamic> item) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Complain Application', style: TextStyle(fontSize: 17)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date: ${mbmDate(item['created_at'])}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text('Dear Sir/Madam,'),
                SizedBox(height: 20),
                Text('I, ${item['cb_name']}, Employee ID: ${item['cb_as_id']}, am writing this letter to express my complain for this issue:',),
                SizedBox(height: 20),
                Text('ID: ${item['associate_id']}'),
                Text('Name: ${item['as_name']}'),
                Text('Department: ${item['hr_department_name']}'),
                Text('Unit: ${item['hr_unit_short_name']}'),
                SizedBox(height: 20),
                Text('Complain Type: ${item['complain_type']}'),
                Text('Complain Reason: ${item['complain_reason']}'),
                Visibility(
                    visible: item['description'] != '',
                    child: Text('Description: ${item['description']}')
                ),
                SizedBox(height: 20),
                Text('I request to take necessary steps on this matter.'),
                SizedBox(height: 20),
                Text('Thank you for your attention to this issue.'),
                SizedBox(height: 20),
                Text('Sincerely,'),
                SizedBox(height: 0),
                Text('${item['cb_name']}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
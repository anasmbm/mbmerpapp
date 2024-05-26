import 'package:flutter/material.dart';
import 'package:mbm_store/constants/utils.dart';
import 'package:mbm_store/pages/job_order/edit.dart';
import 'package:mbm_store/services/job_order_service.dart';
import 'package:mbm_store/common/widgets/appbar.dart';

class POCashApproval extends StatefulWidget {
  static const String routeName = '/job-order-list';

  const POCashApproval({Key? key}) : super(key: key);

  @override
  State<POCashApproval> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<POCashApproval> {
  late List<Map<String, dynamic>> approvalData = []; // Initialize with an empty list
  late List<Map<String, dynamic>> filteredData = []; // Initialize with an empty list for filtered data
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
      appBar: const CustomAppBar(pageTitle: 'Job Order List'),
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
                final is_service = item['is_service'];
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
                              Text('Reference No: '),
                              Text(item['reference_no']),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('ID: ${item['id']}'),
                              Text('PO Date: ${mbmDate(item['po_date'])}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total: ${item['total_price']} + VAT: ${item['vat']}'),
                              Text('Gross: ${double.parse(item['gross_price']).toStringAsFixed(2)}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    print(item);
                                    showDialog(
                                      context: context, // You need to provide the context here
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5.0), // You can adjust the radius to change the corner curvature
                                          ),
                                          title: Text("Purchase Order Details", style: TextStyle(fontSize: 14)),
                                          content: IntrinsicHeight(
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text("Reference:", textAlign: TextAlign.left,),
                                                    Text("${item['reference_no']}"),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text("Date:"),
                                                    Text("${mbmDate(item['po_date'])}"),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text("Total:"),
                                                    Text("${item['total_price']}"),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text("VAT:"),
                                                    Text("${item['vat']}"),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text("Gross:"),
                                                    Text("${item['gross_price'].toStringAsFixed(2)}"),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Close"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
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
                              ),
                              SizedBox(width: 10),
                              Visibility(
                                visible: int.tryParse(is_service) != 1,
                                child: Expanded(
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.indigoAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5.0), // Adjust border radius as needed
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Adjust the padding
                                    ),
                                    onPressed: () {
                                      print(item['id']);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => JobOrderEdit(
                                            poId: item['id'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Edit",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14, // Adjust the text size
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: (){
                        print('object');
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
      List<Map<String, dynamic>> data = await JobOrderService.getJobOrderData();
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
        // If the query is empty, show all data
        filteredData = approvalData;
      } else {
        // Filter data based on the search query
        filteredData = approvalData.where((item) {
          // You can adjust the conditions for filtering based on your requirements
          return item['reference_no'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }
}
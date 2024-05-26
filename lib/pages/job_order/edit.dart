import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:mbm_store/common/widgets/appbar.dart';
import 'package:mbm_store/common/widgets/custom_button.dart';
import 'package:mbm_store/common/widgets/custom_textfield.dart';
import 'package:mbm_store/constants/global_variables.dart';
import 'package:http/http.dart' as http;
import 'package:mbm_store/constants/utils.dart';
import 'package:mbm_store/models/IJOModel.dart';
import 'package:mbm_store/services/job_order_service.dart';

class JobOrderEdit extends StatefulWidget {
  static const String routeName = '/job-order-edit';
  final poId;

  const JobOrderEdit({Key? key, this.poId}) : super(key: key);

  @override
  State<JobOrderEdit> createState() => _JobOrderEditState();
}

class _JobOrderEditState extends State<JobOrderEdit> {
  final _discountFormKey = GlobalKey<FormState>();
  List<TextEditingController> unitPriceControllers = [];
  List<TextEditingController> qtyControllers = [];
  List<Map<String, dynamic>> poItems = [];
  bool isLoading = true;
  Map<String, dynamic> poData = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(pageTitle: 'Internal Job Order Edit', backLink: '/job-order-list'),
      body: Stack(
        children: [
          if (!isLoading)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _discountFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
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
                                child: Text('Reference: ${poData['reference_no']}'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Expanded(
                        child: ListView.builder(
                          itemCount: poData["rel_purchase_order_items"].length,
                          itemBuilder: (context, index) {
                            final unitPrice = poData["rel_purchase_order_items"][index]["unit_price"]?? 0;
                            if (unitPriceControllers.length <= index) {
                              unitPriceControllers.add(TextEditingController(text: unitPrice));
                            }
                            final qty = poData["rel_purchase_order_items"][index]["qty"] ?? 0;
                            if (qtyControllers.length <= index) {
                              qtyControllers.add(TextEditingController(text: qty));
                            }
                            final product = poData["rel_purchase_order_items"][index]["rel_product"];
                            final productName = product?["name"] ?? 'N/A';

                            final unit = product?["product_unit"]["unit_name"] ?? 'N/A';

                            var subTotalPrice = poData["rel_purchase_order_items"][index]["sub_total_price"] ?? 0;
                            final vatPercentage = poData["rel_purchase_order_items"][index]["vat_percentage"] ?? 0;
                            final vat = poData["rel_purchase_order_items"][index]["vat"] ?? 0;
                            var totalPrice = poData["rel_purchase_order_items"][index]["total_price"] ?? 0;
                            return Card(
                              margin: EdgeInsets.only(top: 8, bottom: 8, left: 5, right: 5),
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
                                      child: Text('${index + 1}. $productName (${qty} ${unit})'),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Table(
                                            children: [
                                              TableRow(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 20.0),
                                                    child: Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Text('Unit Price:'),
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 50,
                                                    padding: EdgeInsets.symmetric(vertical: 6.0),
                                                    child: CustomTextField(
                                                      controller: unitPriceControllers[index],
                                                      hintText: 'Unit Price',
                                                      rightAligned: true,
                                                      onChanged: (newUnitPrice) {
                                                        var newPrice = newUnitPrice.isNotEmpty ? int.parse(newUnitPrice) : 0;
                                                        calculateTotalPrice(index, newPrice);
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              TableRow(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 20.0),
                                                    child: Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Text('Qty:'),
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Container(
                                                      height: 50,
                                                      padding: EdgeInsets.symmetric(vertical: 6.0),
                                                      child: CustomTextField(
                                                        controller: qtyControllers[index],
                                                        hintText: 'Qty',
                                                        rightAligned: true,
                                                        onChanged: (newValue) {
                                                          var newQty = newValue.isNotEmpty ? int.parse(newValue) : 0;
                                                          calculateQty(index, newQty);
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              TableRow(
                                                children: [
                                                  Text(
                                                    'Sub Total: ',
                                                  ),
                                                  Align(
                                                      alignment: Alignment.topRight,
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(right: 15.0),
                                                        child: Text('$subTotalPrice'),
                                                      )
                                                  ),
                                                ],
                                              ),
                                              TableRow(
                                                children: [
                                                  Text(
                                                    'VAT ($vatPercentage%):',
                                                  ),
                                                  Align(
                                                      alignment: Alignment.topRight,
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(right: 15.0),
                                                        child: Text('$vat'),
                                                      )
                                                  ),
                                                ],
                                              ),
                                              TableRow(
                                                children: [
                                                  Text(
                                                    'Grand Total: ',
                                                  ),
                                                  Align(
                                                    alignment: Alignment.topRight,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(right: 15.0),
                                                      child: Text('$totalPrice'),
                                                    )
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.5,
                          child: CustomButton(
                            text: 'Save',
                            onTap: () {
                              if (_discountFormKey.currentState!.validate()) {
                                saveFormData();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Future<void> saveFormData() async {
    double sumOfSubtotal = 0;
    double sumOfVat = 0;
    if (!_discountFormKey.currentState!.validate()) {
      return;
    }

    final List<PoItem> poItemsList = [];

    for (int index = 0; index < poData["rel_purchase_order_items"].length; index++) {
      final product = poData["rel_purchase_order_items"][index]["rel_product"] ?? 0;
      final int unitPrice = int.parse(unitPriceControllers[index].text);
      final subTotalPrice = poData["rel_purchase_order_items"][index]["sub_total_price"];
      final productVat = poData["rel_purchase_order_items"][index]["vat_percentage"];
      double subTotalVatPrice = (double.parse(productVat) / 100) * double.parse(subTotalPrice.toString());
      final qty = poData["rel_purchase_order_items"][index]["qty"];
      final poItem = PoItem(
        id: poData["rel_purchase_order_items"][index]["id"],
        productId: product!["id"],
        unitPrice: unitPrice,
        qty: int.parse(qty.toString()),
        requestQty: int.parse(qty.toString()),
        subTotalPrice: int.parse(subTotalPrice.toString()),
        subTotalVatPrice: double.parse(subTotalVatPrice.toStringAsFixed(2)),
        itemDiscountPercent: 0,
        itemDiscountAmount: 0,
        productVat: double.parse(productVat),
      );

      poItemsList.add(poItem);
    }

    for (int index = 0; index < poData["rel_purchase_order_items"].length; index++) {
      final String productVat = poData["rel_purchase_order_items"][index]["vat_percentage"];
      final subTotalPrice = poData["rel_purchase_order_items"][index]["sub_total_price"] ?? 0.0;
      double subTotalVatPrice = (double.parse(productVat) / 100) * double.parse(subTotalPrice.toString());
      sumOfVat += subTotalVatPrice;
      sumOfSubtotal += double.parse(subTotalPrice.toString());
    }

    final jobOrderData = JobOrderData(
      updateId: int.parse(widget.poId),
      sumOfSubtotal: sumOfSubtotal,
      discount: 0,
      subTotalWithDiscount: sumOfSubtotal + 0,
      vat: sumOfVat,
      grossPrice: sumOfSubtotal + sumOfVat,
      discountPercent: 0,
      poItems: poItemsList,
    );

    final jsonData = jobOrderData.toJson();

    final headers = await createHeaders();
    try {
      final response = await http.post(
        Uri.parse('$uri/api/internal-job-order-update'),
        headers: headers,
        body: jsonEncode(jsonData),
      );
      final output = jsonDecode(response.body);
      print('output');
      print(output);
      if (output["status"] == 'success') {
        showSnackBar(context, output["message"]);
      } else {
        print('Failed to save form data, ${output["message"]}');
      }
    } catch (error) {
      print('Error saving form data: $error');
    }
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    try {
      Map<String, dynamic> data = await JobOrderService.getPOData(widget.poId);
      // print(data);
      setState(() {
        poData = data;
        isLoading = false;
      });
    } catch (error) {
      print("Error loading data: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  void calculateTotalPrice(int index, int newPrice) {
    final qty = poData["rel_purchase_order_items"][index]["qty"] ?? 0;
    final String productVat = poData["rel_purchase_order_items"][index]["vat_percentage"];
    final int subTotalPrice = int.parse(qty.toString()) * newPrice;
    double subTotalVatPrice = (double.parse(productVat) / 100) * double.parse(subTotalPrice.toString());
    final num totalPrice = subTotalPrice + subTotalVatPrice;
    setState(() {
      poData["rel_purchase_order_items"][index]["unit_price"] = newPrice;
      poData["rel_purchase_order_items"][index]["vat"] = subTotalVatPrice;
      poData["rel_purchase_order_items"][index]["sub_total_price"] = subTotalPrice;
      poData["rel_purchase_order_items"][index]["total_price"] = totalPrice;
    });
  }

  void calculateQty(int index, int newQty) {
    final unitPrice = poData["rel_purchase_order_items"][index]["unit_price"] ?? 0;
    final String productVat = poData["rel_purchase_order_items"][index]["vat_percentage"];
    final int subTotalPrice = int.parse(unitPrice.toString()) * newQty;
    double subTotalVatPrice = (double.parse(productVat) / 100) * double.parse(subTotalPrice.toString());
    final num totalPrice = subTotalPrice + subTotalVatPrice;
    setState(() {
      poData["rel_purchase_order_items"][index]["qty"] = newQty;
      poData["rel_purchase_order_items"][index]["vat"] = subTotalVatPrice;
      poData["rel_purchase_order_items"][index]["sub_total_price"] = subTotalPrice;
      poData["rel_purchase_order_items"][index]["total_price"] = totalPrice;
    });
  }
}
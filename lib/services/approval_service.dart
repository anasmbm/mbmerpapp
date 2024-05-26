import 'package:http/http.dart' as http;
import 'package:mbm_store/constants/global_variables.dart';
import 'package:mbm_store/constants/utils.dart';
import 'dart:convert';

class ApprovalService {
  static Future<Map<String, dynamic>?> fetchApprovalDataDashboard() async {
    final headers = await createHeaders();
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/approvals/app'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        print("Failed to fetch approval data. Status code: ${response.statusCode}");
        return null;
      }
    } catch (error) {
      print("Error: $error");
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchApprovalData(String? approvalName) async {
    final headers = await createHeaders();
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/approvals/app/$approvalName'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map<String, dynamic>) {
          return [data];
        }
      } else {
        print("Failed to fetch approval data. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }

    // Return an empty list in case of failure or error.
    return <Map<String, dynamic>>[];
  }

  static Future<Map<String, dynamic>?> fetchApprovalDetailsData(String? approvalId) async {
    final headers = await createHeaders();
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/order_costing_approval/$approvalId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Failed to fetch approval data. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }

    return null;
  }

  static Future<Map<String, dynamic>?> fetchApprovalDetailsDataBill(String? approvalId) async {
    final headers = await createHeaders();
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/tt_rtgs_bill_approval/$approvalId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Failed to fetch approval data. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }

    return null;
  }

  static Future<Map<String, dynamic>?> fetchApprovalDetailsPI(String? approvalId) async {
    final headers = await createHeaders();
    try {
      print(approvalId);
      http.Response response = await http.get(
        Uri.parse('$uri/api/pi_tt_payment_approval/$approvalId'),
        headers: headers,
      );
      print(response);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Failed to fetch approval data. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }

    return null;
  }

  static Future<Map<String, dynamic>?> fetchApprovalDetailsLeave(String? approvalId) async {
    final headers = await createHeaders();
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/leave_approval/$approvalId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Failed to fetch approval data. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }

    return null;
  }

  static Future<dynamic> updateBillStatus(int type, String approvalName, String orderId, String permission, context) async {
    final headers = await createHeaders();
    Map<String, dynamic> data = {
      "status": type,
      "mca_id": orderId,
      "approval_name": approvalName,
      "process_name" : permission
    };

    try {
      http.Response response = await http.patch(
        Uri.parse('$uri/api/update_approval_status/$orderId'),
        body: json.encode(data),
        headers: headers,
      );
      // print(response.body);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        showSnackBar(
          context,
          'Failed!',
        );
        print("Failed to fetch approval data. Status code: ${response.statusCode}");
        return null; // Return null in case of failure
      }
    } catch (error) {
      print("Error: $error");
      return null; // Return null in case of an error
    }
  }

  static Future<dynamic> updateStatus(int type, String approvalName, String orderId, String permission, context) async {
    final headers = await createHeaders();
    Map<String, dynamic> data = {
      "status": type,
      "mca_id": orderId,
      "approval_name": approvalName,
      "process_name" : permission
    };

    try {
      http.Response response = await http.post(
        Uri.parse('$uri/api/update_approval_status'),
        body: json.encode(data),
        headers: headers,
      );
      // print(response.body);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        showSnackBar(
          context,
          'Failed!',
        );
        print("Failed to fetch approval data. Status code: ${response.statusCode}");
        return null; // Return null in case of failure
      }
    } catch (error) {
      print("Error: $error");
      return null; // Return null in case of an error
    }
  }

}
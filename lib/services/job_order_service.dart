import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mbm_store/constants/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mbm_store/constants/global_variables.dart';

class JobOrderService {
  static Future<List<Map<String, dynamic>>> getJobOrderData() async {
    final headers = await createHeaders();
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/internal-job-order'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print("Failed to fetch approval data. Status code: ${response.statusCode}");
        return [];
      }
    } catch (error) {
      print("Error: $error");
      return [];
    }
  }

  static Future<Map<String, dynamic>> getPOData(String poId) async {
    final headers = await createHeaders();
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/internal-job-order/$poId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        print("Failed to fetch approval data. Status code: ${response.statusCode}");
        return {};
      }
    } catch (error) {
      print("Error: $error");
      return {};
    }
  }
}
import 'dart:convert';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:mbm_store/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/error_handling.dart';
import '../constants/global_variables.dart';
import '../constants/utils.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;

class AuthService {
  bool isSignInLoading = false;
  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      User user = User(
        id: '',
        name: name,
        password: password,
        email: email,
        address: '',
        type: '',
        token: '',
      );

      http.Response res = await http.post(
        Uri.parse('$uri/api/signup'),
        body: user.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(
            context,
            'Account created! Login with the same credentials!',
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<Map<String, dynamic>?> signInUser({
    required BuildContext context,
    required String email,
    required String password,
    required String? deviceToken,
  }) async {
    print(uri);
    try {
      final response = await http.post(
        Uri.parse('$uri/api/login'),
        body: jsonEncode({
          'email': email,
          'password': password,
          'device_token': deviceToken,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Failed to log in. Status code: ${response.statusCode}");
        return null;
      }
    } catch (error) {
      print("Error: $error");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> profile() async {
    final headers = await createHeaders();
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Failed to fetch profile data. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error: $error");
    }

    return null;
  }

  void getUserData(
    BuildContext context,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');
      if(token == null) {
        prefs.setString('x-auth-token', '');
      }

      var tokenRes = await http.post(
        Uri.parse('$uri/tokenIsValid'),
        headers: <String, String> {
          'Content-Type': 'application/json: charset=UTF-8',
          'x-auth-token': token!
        },
      );

      var response = jsonDecode(tokenRes.body);

      if(response == true){
        http.Response userRes = await http.get(
          Uri.parse('$uri/'),
          headers: <String, String>{
            'Content-Type': 'application/json: charset=UTF-8',
            'x-auth-token': token!
          },
        );

        var userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(userRes.body);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  static Future<void> logout(BuildContext context) async {
    CoolAlert.show(
      title: 'Sure to logout?',
      context: context,
      type: CoolAlertType.confirm,
      onConfirmBtnTap: () async {
        final preferences = await SharedPreferences.getInstance();
        preferences.clear();
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/auth-screen',
              (Route<dynamic> route) => false,
        );
      },
    );
  }
}
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:mbm_store/common/widgets/custom_button.dart';
import 'package:mbm_store/common/widgets/custom_textfield.dart';
import 'package:mbm_store/constants/global_variables.dart';
import 'package:mbm_store/constants/utils.dart';
import 'package:mbm_store/pages/dashboard.dart';
import 'package:mbm_store/providers/user_provider.dart';
import 'package:mbm_store/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  static const String routeName = '/auth-screen';

  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _signInFormKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  late String? xAuthToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    xAuthToken = prefs.getString('x-auth-token');
    if (xAuthToken != null) {
      // send api request to check user profile data
      final response = await AuthService.profile();
      if (response != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print("Invalid Token!");
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: GlobalVariables.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Image.asset('assets/logo.png', height: 70),
                ),
              ),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
                  side: BorderSide(
                    color: Colors.grey, // Set the border color
                    width: 0.6, // Set the border width
                  ),
                ),
                child: Container(
                  color: GlobalVariables.backgroundColor,
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _signInFormKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Email',
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                        ),
                        const SizedBox(height: 20),
                        FractionallySizedBox(
                          widthFactor: 0.5,
                          child: CustomButton(
                            text: isLoading ? 'Loading ...' : 'Sign In',
                            onTap: () {
                              if (_signInFormKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });
                                signInUser();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> signInUser() async {
    setState(() {
      isLoading = true;
    });

    final email = _emailController.text;
    final password = _passwordController.text;
    final String? token = await FirebaseMessaging.instance.getToken();

    try {
      final response = await authService.signInUser(
        context: context,
        email: email,
        password: password,
        deviceToken: token,
      );

      if (response != null) {
        Map<String, dynamic> responseJson = response;

        String message = responseJson['message'];

        if (message == 'Success') {
          showSnackBar(context, 'Login Successful!');
          SharedPreferences prefs = await SharedPreferences.getInstance();
          Provider.of<UserProvider>(context, listen: false).setUser(jsonEncode(responseJson));
          await prefs.setString('x-auth-token', responseJson['access_token']);
          Navigator.pushNamed(context, '/home');
        } else {
          showSnackBar(context, 'Email or Password is Incorrect!');
        }
      } else {
        showSnackBar(context, 'Response is null');
      }
    } catch (error) {
      print(error);
      showSnackBar(context, 'Error: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
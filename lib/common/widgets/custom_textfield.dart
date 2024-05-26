import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  final bool rightAligned;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.enabled = true,
    this.rightAligned = false,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: hintText == 'Password' ? true : false,
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black38,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black38,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      ),
      textAlign: rightAligned ? TextAlign.right : TextAlign.left,
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Enter your $hintText';
        }
        return null;
      },
      onChanged: onChanged
    );
  }
}
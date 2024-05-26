import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool enabled;
  const CustomButton({super.key, required this.text, required this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
          ),
        ),
        child: Text(text, style: TextStyle(color: Colors.white)),
    );
  }
}

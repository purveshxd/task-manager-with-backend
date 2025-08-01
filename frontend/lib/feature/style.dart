import 'package:flutter/material.dart';

class AppStyle {
  static Text subheadingTextStyle(String text) {
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, height: 0),
    );
  }

  static Text secondaryHeading(String text) {
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, height: 0),
    );
  }

  static ButtonStyle primaryButtonColor() {
    return FilledButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 0, 38, 255),
      foregroundColor: Colors.white,
    );
  }

  static ButtonStyle secondaryButtonColor() {
    return OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    );
  }

  static InputDecoration textFieldDecoration({required String label}) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      fillColor: Colors.white,
      filled: true,
    );
  }

  static Color appBackground() {
    return Colors.grey.shade100;
  }

  static Color primaryColor() {
    return Color.fromARGB(255, 230, 235, 255);
  }
}

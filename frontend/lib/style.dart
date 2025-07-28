import 'package:flutter/material.dart';

class AppStyle {
  static Text subheadingTextStyle(String text) {
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
    );
  }
}

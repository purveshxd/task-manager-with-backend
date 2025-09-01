import 'package:flutter/material.dart';
import 'package:tasks_frontend/models/tasks.model.dart';

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
      backgroundColor: Color(0xFF0026FF),
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
    // return const Color.fromARGB(255, 20, 20, 20);
  }

  static Color primaryColor() {
    return Color.fromARGB(255, 230, 235, 255);
  }

  static Color givePriorityColor(TaskPriority? taskPriority) {
    final priority = taskPriority ?? TaskPriority.low;
    switch (priority) {
      case TaskPriority.low:
        return Colors.lightGreen.shade400;
      case TaskPriority.medium:
        return Colors.amberAccent.shade200;
      case TaskPriority.high:
        return Colors.redAccent.shade200;
      // default:
      //   return Colors.lightGreen.shade400;
    }
  }
}

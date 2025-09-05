// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class AppDataModel {
  final ThemeMode themeMode;
  final Color accentColor;
  AppDataModel({required this.themeMode, required this.accentColor});

  AppDataModel copyWith({ThemeMode? themeMode, Color? accentColor}) {
    return AppDataModel(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}

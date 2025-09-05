import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:tasks_frontend/bloc/app_cubit/app_data_model.dart';
import 'package:tasks_frontend/localstorage/shared_prefs.dart';

class AppCubit extends Cubit<AppDataModel> {
  AppCubit()
    : super(
        AppDataModel(
          themeMode: ThemeMode.system,
          accentColor: Color(0xFF0026FF),
        ),
      );

  void loadTheme() {
    loadThemeMode();
    loadAccentColor();
  }

  void loadThemeMode() async {
    int savedThemeIndex = await SharedPrefs.getTheme();
    var newState = state.copyWith(themeMode: ThemeMode.values[savedThemeIndex]);
    emit(newState);
    log(ThemeMode.values[savedThemeIndex].toString());
  }

  void switchThemeMode(ThemeMode newTheme) async {
    final isSet = await SharedPrefs.setTheme(newTheme);
    if (isSet) {
      var newState = state.copyWith(themeMode: newTheme);
      emit(newState);
    } else {
      emit(state);
    }
  }

  void loadAccentColor() async {
    final accentColorIndex = await SharedPrefs.getAccentColor();
    var newState = state.copyWith(
      accentColor: Colors.primaries[accentColorIndex],
    );
    // Color(0xFF0026FF)
    emit(newState);
    log(Colors.primaries[accentColorIndex].toString());
  }

  void switchAccentColor(int accentColorIndex) async {
    final isSet = await SharedPrefs.setAccentColor(accentColorIndex);
    if (isSet) {
      var newState = state.copyWith(
        accentColor: Colors.primaries[accentColorIndex],
      );
      emit(newState);
    } else {
      emit(state);
    }
  }
}

import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

class AppCubit extends Cubit<ThemeMode> {
  AppCubit() : super(ThemeMode.dark);

  void toggleTheme() {
    log("Toggle");
    log(state.name);
    if (state == ThemeMode.light) {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.light);
    }
  }
}

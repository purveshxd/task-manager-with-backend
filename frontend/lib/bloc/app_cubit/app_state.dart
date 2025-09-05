import 'package:flutter/widgets.dart';
import 'package:tasks_frontend/bloc/app_cubit/app_data_model.dart';

@immutable
sealed class AppState {}

final class AppSuccess extends AppState {
  final AppDataModel appDataModel;

  AppSuccess({required this.appDataModel});
}

final class AppLoading extends AppState {}

final class AppError extends AppState {
  final String error;

  AppError({required this.error});
}

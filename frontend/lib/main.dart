import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks_frontend/bloc/app_cubit/app_cubit.dart';
import 'package:tasks_frontend/bloc/task_bloc/tasks_bloc.dart';
import 'package:tasks_frontend/localstorage/local_storage.dart';
import 'package:tasks_frontend/notification_handler.dart';
import 'package:tasks_frontend/style/app_theme.dart';
import 'package:tasks_frontend/views/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageRepo.init();

  // Initialize Awesome Notifications
  await NotificationProvider.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TasksBloc(LocalStorageRepo())..add(LoadTasks()),
        ),
        BlocProvider(create: (context) => AppCubit()),
      ],
      child: MyApp(),
    ),
  );
}

/*
  TODO [1] Add dark theme
  TODO [2] Add task marking in database
*/

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: Homepage(),
        );
      },
    );
  }
}

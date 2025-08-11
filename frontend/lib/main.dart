import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks_frontend/bloc/task_bloc/tasks_bloc.dart';
import 'package:tasks_frontend/localstorage/local_storage.dart';
import 'package:tasks_frontend/notification_handler.dart';
import 'package:tasks_frontend/views/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageRepo.init();

  // Initialize Awesome Notifications
  await NotificationProvider.init();

  runApp(
    BlocProvider(
      create: (context) => TasksBloc(LocalStorageRepo())..add(LoadTasks()),
      child: MyApp(),
    ),
  );
}

/*
  // TODO 1. check how the notification works [is scheduled or does it work when the app is closed]
  TODO - 
*/

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: Color(0xFF0026FF),
          dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
          // dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
        ),
      ),
      home: Home(),
    );
  }
}

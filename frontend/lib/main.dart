import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks_frontend/bloc/tasks_bloc.dart';
import 'package:tasks_frontend/feature/homepage.dart';
import 'package:tasks_frontend/localstorage/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageRepo.init();

  // Initialize Awesome Notifications
  AwesomeNotifications().initialize(debug: true, null, [
    NotificationChannel(
      criticalAlerts: true,
      channelKey: 'task_channel',
      channelName: 'Task Notifications',
      channelDescription: 'Notification channel for task reminders',
      defaultColor: Colors.blue,
      locked: true,
      ledColor: Colors.white,
      importance: NotificationImportance.High,
    ),
  ]);

  runApp(
    BlocProvider(
      create: (context) => TasksBloc(LocalStorageRepo())..add(LoadTasks()),

      child: MyApp(),
    ),
  );
}

/*

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF0026FF),
          dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        ),
      ),
      home: Home(),
    );
  }
}

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
  // TODO: Work on the edit task page [Remove it OR merge it with Add task page] 
  // TODO: Work on the backend as well
  TODO: Add date selection in the app
  /// 1. Add it to the object [Tasks] model
  /// 2. To the backend as well
  TODO: Add reminder options for the tasks
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
        primarySwatch: Colors.indigo,
      ),
      home: Home(),
    );
  }
}

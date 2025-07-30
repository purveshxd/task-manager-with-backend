import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks_frontend/bloc/tasks_bloc.dart';
import 'package:tasks_frontend/views/home.dart';
import 'package:tasks_frontend/views/tasks_provider.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => TasksBloc(TasksProvider())..add(LoadTasks()),
      child: MyApp(),
    ),
  );
}

/*
  TODO: Work on the edit task page [Remove it OR merge it with Add task page]
  TODO: Work on the backend as well
*/
class MyApp extends StatelessWidget {
  final TasksProvider tasksProvider = TasksProvider();

  MyApp({super.key});

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

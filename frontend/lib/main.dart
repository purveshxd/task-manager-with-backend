import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks_frontend/bloc/tasks_bloc.dart';
import 'package:tasks_frontend/homepage.dart';
import 'package:tasks_frontend/tasks_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final TasksProvider tasksProvider = TasksProvider();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
      ),
      home: BlocProvider(
        create: (context) => TasksBloc(tasksProvider)..add(LoadTasks()),
        child: Homepage(),
      ),
      darkTheme: ThemeData.dark(),
    );
  }
}

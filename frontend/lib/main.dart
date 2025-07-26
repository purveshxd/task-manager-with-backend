import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks_frontend/bloc/tasks_bloc.dart';
import 'package:tasks_frontend/home.dart';
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
      theme: ThemeData(useMaterial3: false, primarySwatch: Colors.indigo),
      home: BlocProvider(
        create: (context) => TasksBloc(tasksProvider)..add(LoadTasks()),
        child: Home(),
      ),
    );
  }
}

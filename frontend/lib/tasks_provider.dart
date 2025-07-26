import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:tasks_frontend/tasks.model.dart';

class TasksProvider {
  // final String url = "http://127.0.0.1:8000";
  final String url = "http://192.168.1.4:8000";

  // ! Get Tasks
  Future<List<Tasks>> getTasks() async {
    log("Called");
    try {
      final resp = await http.get(Uri.parse("$url/get-task"));
      if (resp.statusCode == 200) {
        var data = jsonDecode(resp.body) as List;
        final tasks = data.map((e) => Tasks.fromMap(e)).toList();
        return tasks;
      } else {
        log("No Data");
        return [];
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  //! add tasks
  Future<bool> addTask(Tasks task) async {
    try {
      final resp = await http.post(
        Uri.parse("$url/add-task"),
        headers: {"Content-type": "application/json"},
        body: task.toJson(),
      );
      if (resp.statusCode == 201) {
        return true;
      } else {
        log("No Data");
        return false;
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  // ! tasks toggle
  Future<bool> toggleTask(String taskID) async {
    try {
      final resp = await http.put(Uri.parse("$url/toggleComplete/$taskID"));
      if (resp.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  // ! Delete Task
  Future<bool> deleteTask(String taskID) async {
    try {
      final resp = await http.delete(Uri.parse("$url/delete-task/$taskID"));
      log(taskID);
      log(resp.body.toString());
      if (resp.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }
}

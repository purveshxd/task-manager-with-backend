import 'dart:developer';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tasks_frontend/models/tasks.model.dart';
import 'package:tasks_frontend/models/taskslog.model.dart';

class LocalStorageRepo {
  static Isar? _isar;

  static Future<void> init() async {
    if (_isar == null) {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open([
        TasksSchema,
        TaskLogModelSchema,
      ], directory: dir.path);
    }
  }

  //! Watch tasks
  Stream<List<Tasks>> watchAllTasks() {
    return _isar!.tasks.where().watch(fireImmediately: true);
  }

  Future<List<Tasks>> getTasks() async {
    return await _isar?.tasks.where().findAll() ?? [];
  }

  Future<bool> addTask(Tasks task) async {
    try {
      await _isar!.writeTxn(() async => _isar!.tasks.put(task));

      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<bool> updateTask(Tasks task) async {
    try {
      await _isar!.writeTxn(() async => await _isar!.tasks.put(task));

      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<bool> toggleTask(int id) async {
    try {
      final task = await _isar!.tasks.get(id);

      if (task != null) {
        task.isComplete = !task.isComplete;

        await _isar!.writeTxn(() async {
          await _isar!.tasks.put(task);
        });

        return true;
      } else {
        log("Task not found with ID: $id");
        return false;
      }
    } catch (e) {
      log("Toggle Task Error: $e");
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      await _isar!.writeTxn(() async => await _isar!.tasks.delete(id));

      return true;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }
}

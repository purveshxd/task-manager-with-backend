import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tasks_frontend/feature/tasks.model.dart';

class LocalStorageRepo {
  static Isar? _isar;

  static Future<void> init() async {
    if (_isar == null) {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open([TasksSchema], directory: dir.path);
    }
  }

  Future<List<Tasks>> getTasks() async {
    return await _isar?.tasks.where().findAll() ?? [];
  }

  Future<bool> addTask(Tasks task) async {
    try {
      await _isar!.writeTxn(() async => await _isar!.tasks.put(task));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateTask(Tasks task) async {
    try {
      await _isar!.writeTxn(() async => await _isar!.tasks.put(task));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> toggleTask(int id) async {
    try {
      await _isar!.writeTxn(() async {
        final task = await _isar!.tasks.get(id);
        if (task != null) {
          task.isComplete = !task.isComplete;
          await _isar!.tasks.put(task);
        }
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      await _isar!.writeTxn(() async => await _isar!.tasks.delete(id));
      return true;
    } catch (_) {
      return false;
    }
  }
}

import 'package:isar/isar.dart';

part 'taskslog.model.g.dart';

@collection
class TaskLogModel {
  Id id = Isar.autoIncrement; // Auto-managed by Isar
  late int taskId; // Reference to Tasks.id
  late DateTime date;
  late bool isCompleted;

  TaskLogModel({
    required this.taskId,
    required this.date,
    required this.isCompleted,
  });

  TaskLogModel copyWith({int? taskId, DateTime? date, bool? isCompleted}) {
    return TaskLogModel(
      taskId: taskId ?? this.taskId,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
    )..id = id; // Keep original id
  }
}

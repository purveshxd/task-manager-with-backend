import 'dart:convert';

import 'package:isar/isar.dart';

part 'tasks.model.g.dart';

enum RepeatOption { once, daily, weekly, monthly }

enum TaskPriority { low, medium, high }

@collection
class Tasks {
  Id id = Isar.autoIncrement;
  late String name;
  @enumerated
  late TaskPriority taskPriority;
  late bool isComplete;
  late String desc;
  late bool addNotification;
  DateTime? notificationDateTime;
  @enumerated
  late RepeatOption repeatOption; // ✅ Added

  Tasks({
    required this.name,
    this.taskPriority = TaskPriority.low,
    this.isComplete = false,
    this.desc = '',
    this.addNotification = false,
    this.notificationDateTime,
    this.repeatOption = RepeatOption.once,
  });

  Tasks copyWith({
    Id? id,
    TaskPriority? taskPriority,
    String? name,
    bool? isComplete,
    String? desc,
    bool? addNotification,
    DateTime? notificationDateTime,
    RepeatOption? repeatOption,
  }) {
    return Tasks(
      name: name ?? this.name,
      taskPriority: taskPriority ?? this.taskPriority,
      isComplete: isComplete ?? this.isComplete,
      desc: desc ?? this.desc,
      addNotification: addNotification ?? this.addNotification,
      notificationDateTime: notificationDateTime ?? this.notificationDateTime,
      repeatOption: repeatOption ?? this.repeatOption,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'taskPriority': taskPriority,
      'isComplete': isComplete,
      'desc': desc,
      'addNotification': addNotification,
      'notificationDateTime': notificationDateTime?.millisecondsSinceEpoch,
      'repeatOption': repeatOption,
    };
  }

  factory Tasks.fromMap(Map<String, dynamic> map) {
    return Tasks(
      // id: map['id'] as int,
      name: map['name'] as String,
      taskPriority: map['taskPriority'] as TaskPriority,
      isComplete: map['isComplete'] as bool,
      desc: map['desc'] as String,
      addNotification: map['addNotification'],
      notificationDateTime: map['notificationDateTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['notificationDateTime'] as int,
            )
          : null,
      repeatOption: map['repeatOption'] as RepeatOption,
    );
  }

  String toJson() => json.encode(toMap());

  factory Tasks.fromJson(String source) =>
      Tasks.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Task{id: $id, title: $name, desc: $desc, repeatOption: $repeatOption, isCompleted: $isComplete, notificationDateTime: $notificationDateTime, taskPriority: $taskPriority}';
  }
}

import 'package:isar/isar.dart';

part 'tasks.model.g.dart';

@collection
class Tasks {
  Id id = Isar.autoIncrement; // Managed by Isar
  late String name;
  late bool isComplete;
  late String desc;
  late bool addNotification;
  DateTime? notificationDateTime;

  Tasks({
    required this.name,
    this.isComplete = false,
    this.desc = '',
    this.addNotification = false,
    this.notificationDateTime,
  });

  Tasks copyWith({
    String? name,
    bool? isComplete,
    String? desc,
    bool? addNotification,
    DateTime? notificationDateTime,
  }) {
    return Tasks(
      name: name ?? this.name,
      isComplete: isComplete ?? this.isComplete,
      desc: desc ?? this.desc,
      addNotification: addNotification ?? this.addNotification,
      notificationDateTime: notificationDateTime ?? this.notificationDateTime,
    )..id = id; // Keep original ID
  }
}

part of 'tasks_bloc.dart';

@immutable
sealed class TasksEvent {}

// Event: Load all tasks
class LoadTasks extends TasksEvent {}

// Event: Add a task
class AddTask extends TasksEvent {
  final Tasks task;
  AddTask(this.task);
}

// Event: Update a task
class UpdateTask extends TasksEvent {
  final Tasks updatedTask;
  UpdateTask(this.updatedTask);
}

// Event: Toggle completion of a task
class ToggleTask extends TasksEvent {
  final int id;
  ToggleTask(this.id);
}

// Event: Delete a task
class DeleteTask extends TasksEvent {
  final int id;
  DeleteTask(this.id);
}

class GroupTasks extends TasksEvent {
  final List<Tasks> tasks;

  GroupTasks({required this.tasks});
}

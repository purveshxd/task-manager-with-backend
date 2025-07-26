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

// Event: Toggle completion of a task
class ToggleTask extends TasksEvent {
  final String id;
  ToggleTask(this.id);
}

// Event: Delete a task
class DeleteTask extends TasksEvent {
  final String id;
  DeleteTask(this.id);
}



part of 'tasks_bloc.dart';

@immutable
sealed class TasksState {}

final class TasksInitial extends TasksState {}

final class TasksLoading extends TasksState {}

final class TasksLoaded extends TasksState {
  final List<Tasks> tasks;

  TasksLoaded({required this.tasks});
}

final class TasksError extends TasksState {
  final String message;
  TasksError(this.message);
}

// final class TaskActionFailed extends TasksState {
//   final String message;
//   TaskActionFailed({required this.message});
// }

final class TaskActionMessage extends TasksState {
  final String message;

  TaskActionMessage({required this.message});
}

import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:tasks_frontend/localstorage/local_storage.dart';
import 'package:tasks_frontend/models/tasks.model.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final LocalStorageRepo tasksProvider;

  TasksBloc(this.tasksProvider) : super(TasksInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<ToggleTask>(_onToggleTask);
    on<DeleteTask>(_onDeleteTask);
    on<GroupTasks>(_groupTasks);
    on<UpdateTask>(_onUpdateTask);
  }

  // Future<void> _onLoadTasks(LoadTasks event, Emitter<TasksState> emit) async {
  //   emit(TasksLoading());
  // }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TasksState> emit) async {
    emit(TasksLoading());
    try {
      final tasks = await tasksProvider.getTasks();
      emit(TasksLoaded(tasks: tasks));
      for (var element in tasks) {
        log(element.toString());
      }
    } catch (e) {
      log(e.toString());
      emit(TasksError(e.toString()));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TasksState> emit) async {
    if (state is TasksLoaded) {
      final currentTasks = List<Tasks>.from((state as TasksLoaded).tasks);
      final isAdded = await tasksProvider.addTask(event.task);
      if (isAdded) {
        currentTasks.add(event.task);
        emit(TasksLoaded(tasks: currentTasks));
      } else {
        emit(TaskActionMessage(message: "Can't add the task right now"));
        emit(TasksLoaded(tasks: currentTasks));
      }
    }
  }

  Future<void> _onToggleTask(ToggleTask event, Emitter<TasksState> emit) async {
    if (state is TasksLoaded) {
      final currentTasksList = List<Tasks>.from((state as TasksLoaded).tasks);

      // Find index of the task to update
      final task = currentTasksList.firstWhere(
        (task) => task.id == event.taskID,
      );
      final index = currentTasksList.indexOf(task);

      task.isComplete = !task.isComplete;

      if (index != -1) {
        // replace the task from list
        currentTasksList[index] = task;

        log("UpdatedTask-${currentTasksList.toString()}");
        // Optionally call API to persist the update
        final isUpdated = await tasksProvider.updateTask(task);

        if (isUpdated == true) {
          emit(TasksLoaded(tasks: currentTasksList));
        } else {
          // Show error message and revert state if needed
          emit(TaskActionMessage(message: "Error: Can't update the task"));
          emit(TasksLoaded(tasks: currentTasksList)); // Restore old state
        }
      }
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TasksState> emit) async {
    if (state is TasksLoaded) {
      final currentTasks = List<Tasks>.from((state as TasksLoaded).tasks);
      final isDeleted = await tasksProvider.deleteTask(event.id);
      if (isDeleted) {
        final updatedTasks = (state as TasksLoaded).tasks
            .where((task) => task.id != event.id)
            .toList();
        emit(TasksLoading());
        emit(TaskActionMessage(message: "Task deleted!"));
        emit(TasksLoaded(tasks: updatedTasks));
      } else {
        emit(TaskActionMessage(message: "Error: Can't delete the task"));
        emit(TasksLoaded(tasks: currentTasks));
      }
    }
  }

  Future<void> _groupTasks(GroupTasks event, Emitter<TasksState> emit) async {
    if (state is TasksLoaded) {
      // final currentTasks = List<Tasks>.from((state as TasksLoaded).tasks);
      final completedTasks = event.tasks
          .where((task) => task.isComplete == true)
          .toList();
      final onGoingTasks = event.tasks
          .where((task) => task.isComplete == false)
          .toList();

      emit(
        GroupedTasksState(
          completedTasks: completedTasks,
          ongoingTasks: onGoingTasks,
        ),
      );
      emit(TasksLoaded(tasks: completedTasks + onGoingTasks));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TasksState> emit) async {
    if (state is TasksLoaded) {
      final currentTasksList = List<Tasks>.from((state as TasksLoaded).tasks);

      // Find index of the task to update
      final index = currentTasksList.indexWhere(
        (task) => task.id == event.updatedTask.id,
      );

      if (index != -1) {
        // Replace old task with the updated one
        currentTasksList[index] = event.updatedTask;
        log("UpdatedTask-${event.updatedTask}");
        // Optionally call API to persist the update
        final isUpdated = await tasksProvider.updateTask(event.updatedTask);

        if (isUpdated == true) {
          emit(TasksLoaded(tasks: currentTasksList));
        } else {
          // Show error message and revert state if needed
          emit(TaskActionMessage(message: "Error: Can't update the task"));
          emit(TasksLoaded(tasks: currentTasksList)); // Restore old state
        }
      }
    }
  }
}

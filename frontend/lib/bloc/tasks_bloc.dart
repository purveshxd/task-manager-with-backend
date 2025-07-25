import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:tasks_frontend/tasks.model.dart';
import 'package:tasks_frontend/tasks_provider.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TasksProvider tasksProvider;

  TasksBloc(this.tasksProvider) : super(TasksInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<ToggleTask>(_onToggleTask);
    on<DeleteTask>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TasksState> emit) async {
    emit(TasksLoading());
    try {
      final tasks = await tasksProvider.getTasks();
      emit(TasksLoaded(tasks: tasks));
    } catch (e) {
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
        emit(TaskActionFailed(message: "Can't add the task right now"));
        emit(TasksLoaded(tasks: currentTasks));
      }
    }
  }

  Future<void> _onToggleTask(ToggleTask event, Emitter<TasksState> emit) async {
    if (state is TasksLoaded) {
      await tasksProvider.toggleTask(event.id);

      final updatedTasks = (state as TasksLoaded).tasks.map((task) {
        if (task.id == event.id) {
          return task.copyWith(isComplete: !task.isComplete);
        }
        return task;
      }).toList();

      emit(TasksLoaded(tasks: updatedTasks));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TasksState> emit) async {
    if (state is TasksLoaded) {
      await tasksProvider.deleteTask(event.id);
      final updatedTasks = (state as TasksLoaded).tasks
          .where((task) => task.id != event.id)
          .toList();
      emit(TasksLoaded(tasks: updatedTasks));
    }
  }
}

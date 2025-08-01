import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks_frontend/bloc/tasks_bloc.dart';
import 'package:tasks_frontend/feature/add_task.view.dart';
import 'package:tasks_frontend/feature/tasks.model.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task});
  final Tasks task;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (context, state) {
        TimeOfDay timeOfDay = TimeOfDay.fromDateTime(
          task.notificationDateTime ?? DateTime.now(),
        );
        return Container(
          padding: EdgeInsets.all(12).copyWith(bottom: 0, top: 4),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 7,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTaskView(task: task),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.name[0].toUpperCase() + task.name.substring(1),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      task.desc.isNotEmpty
                          ? Text(
                              task.desc[0].toUpperCase() +
                                  task.desc.substring(1),
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : SizedBox.shrink(),
                      SizedBox(height: 1),

                      task.notificationDateTime != null
                          ? Text(
                              "${task.notificationDateTime!.day}.${task.notificationDateTime!.month}.${task.notificationDateTime!.year} | ${timeOfDay.hourOfPeriod}:${timeOfDay.minute} ${timeOfDay.period.name.toUpperCase()}",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: InkWell(
                  onTap: () {
                    context.read<TasksBloc>().add(ToggleTask(task.id));
                  },
                  child: Container(
                    padding: EdgeInsets.all(0.5),
                    decoration: BoxDecoration(
                      border: BoxBorder.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),

                      borderRadius: BorderRadiusDirectional.circular(8),
                    ),
                    child: Icon(task.isComplete ? Icons.check_rounded : null),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

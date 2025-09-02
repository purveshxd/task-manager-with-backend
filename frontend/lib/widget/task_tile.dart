import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks_frontend/style/app_theme.dart';
import 'package:tasks_frontend/style/custom_style.dart';

import '../bloc/task_bloc/tasks_bloc.dart';
import '../models/tasks.model.dart';
import '../views/add_task.view.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task});
  final Tasks task;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (context, state) {
        // notification timer
        final timeOfDay = TimeOfDay.fromDateTime(
          task.notificationDateTime ?? DateTime.now(),
        );

        return Container(
          padding: const EdgeInsets.all(12).copyWith(bottom: 10, top: 10),
          margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
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
                    unawaited(
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTaskView(task: task),
                        ),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 4,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            task.name[0].toUpperCase() + task.name.substring(1),
                            style: TextStyle(
                              fontSize: 16,
                              color: context.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          RotatedBox(
                            quarterTurns: 3,
                            child: Icon(
                              Icons.bookmark_rounded,
                              color: AppStyle.givePriorityColor(
                                task.taskPriority,
                              ),
                            ),
                          ),
                          // Chip(
                          //   label: Text(
                          //     task.taskPriority.name[0].toUpperCase() +
                          //         task.taskPriority.name.substring(1),
                          //     style: TextStyle(height: 0, fontSize: 10),
                          //   ),
                          //   visualDensity: VisualDensity.compact,
                          //   padding: EdgeInsets.all(0),
                          //   side: BorderSide.none,
                          //   backgroundColor: givePriorityColor(),
                          //   shape: RoundedRectangleBorder(
                          //     borderRadius: BorderRadiusGeometry.circular(6),
                          //   ),
                          // ),
                        ],
                      ),

                      if (task.desc.isNotEmpty)
                        Text(
                          task.desc[0].toUpperCase() + task.desc.substring(1),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      const SizedBox(height: 1),
                      if (task.addNotification)
                        Text(
                          '${task.notificationDateTime!.day}.${task.notificationDateTime!.month}.${task.notificationDateTime!.year} | ${timeOfDay.hourOfPeriod}:${timeOfDay.minute} ${timeOfDay.period.name.toUpperCase()}',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: InkWell(
                  onTap: () {
                    log('Tick Widget ${task.id}');
                    context.read<TasksBloc>().add(ToggleTask(task.id));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(0.5),
                    decoration: BoxDecoration(
                      color: context.onBackground,
                      border: BoxBorder.all(
                        color: context.onBackground,
                        style: BorderStyle.solid,
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

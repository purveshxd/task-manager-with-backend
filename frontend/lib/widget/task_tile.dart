import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks_frontend/bloc/tasks_bloc.dart';
import 'package:tasks_frontend/views/tasks.model.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task});

  final Tasks task;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        context.read<TasksBloc>().add(ToggleTask(task.id));
      },
      child: Container(
        padding: EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          spacing: 8,

          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(0.5),
              decoration: BoxDecoration(
                border: BoxBorder.all(color: Colors.grey.shade300, width: 1.5),

                borderRadius: BorderRadiusDirectional.circular(8),
              ),
              child: Icon(task.isComplete ? Icons.check_rounded : null),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.name[0].toUpperCase() + task.name.substring(1),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  task.desc.isNotEmpty
                      ? Text(
                          task.desc[0].toUpperCase() + task.desc.substring(1),
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

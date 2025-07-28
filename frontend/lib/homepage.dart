import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks_frontend/bloc/tasks_bloc.dart';
import 'package:tasks_frontend/tasks.model.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController taskTitleController = TextEditingController();
    final focusNode = FocusNode();

    void onSubmit() {
      String taskTitle = "";
      String desc = "";

      if (!taskTitleController.text.contains("#")) {
        taskTitle = taskTitleController.text.trim();
      } else {
        taskTitle = taskTitleController.text.trim().split("#")[0].trim();
        desc = taskTitleController.text.trim().split("#")[1].isEmpty
            ? ""
            : taskTitleController.text.trim().split("#")[1];
      }
      if (taskTitle.isNotEmpty) {
        context.read<TasksBloc>().add(
          AddTask(
            Tasks(name: taskTitle, id: '0', isComplete: false, desc: desc),
          ),
        );
        taskTitleController.clear();
        focusNode.unfocus();
      }
    }

    return BlocListener<TasksBloc, TasksState>(
      listener: (context, state) {
        if (state is TaskActionMessage) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        body: BlocBuilder<TasksBloc, TasksState>(
          builder: (context, state) {
            if (state is TasksError) {
              return Center(child: Text("Error: ${state.message}"));
            } else if (state is TasksLoaded) {
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: state.tasks.length,
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 2.0,
                      horizontal: 8,
                    ),
                    child: Dismissible(
                      onDismissed: (direction) {
                        context.read<TasksBloc>().add(DeleteTask(task.id));
                      },
                      confirmDismiss: (direction) {
                        return showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Delete Task"),
                              content: Text("Confirm to delete the task"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: Text("Delete"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      background: Container(color: Colors.red),

                      key: UniqueKey(),
                      child: CheckboxListTile(
                        tileColor: Theme.of(context).colorScheme.onSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(8),
                        ),
                        title: Text(
                          task.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        value: task.isComplete,
                        onChanged: (value) {
                          context.read<TasksBloc>().add(ToggleTask(task.id));
                        },

                        enableFeedback: true,
                        subtitle: task.desc.isNotEmpty
                            ? Container( 
                                margin: EdgeInsets.all(0),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceDim,
                                ),
                                child: Text(
                                  task.desc,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : null,
                        dense: false,
                        isThreeLine: false,
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.task_alt_rounded),
              label: "Tasks",
            ),
            NavigationDestination(
              icon: Icon(Icons.notes_rounded),
              label: "Notes",
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Add Task"),
                  content: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      TextField(
                        controller: taskTitleController,

                        onTapOutside: (event) {
                          focusNode.unfocus();
                        },
                        onSubmitted: (value) {
                          onSubmit();
                        },
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          // hintText: "Enter task & Use # for description",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      Text("Enter task & Use # for description"),
                    ],
                  ),
                  actions: [
                    FilledButton.tonalIcon(
                      icon: Icon(Icons.cancel_rounded),
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      label: Text("Cancel"),
                    ),
                    FilledButton.tonalIcon(
                      icon: Icon(Icons.check_circle_rounded),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      label: Text("Add"),
                    ),
                  ],
                );
              },
            );
          },
          child: Icon(Icons.add_rounded),
        ),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // bottomSheet: BottomSheet(
        //   enableDrag: false,
        //   onClosing: () {},
        //   builder: (context) => Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: TextField(
        //       controller: taskTitleController,

        //       onTapOutside: (event) {
        //         focusNode.unfocus();
        //       },
        //       onSubmitted: (value) {
        //         onSubmit();
        //       },
        //       focusNode: focusNode,
        //       decoration: InputDecoration(
        //         hintText: "Enter task & Use # for description",
        //         border: OutlineInputBorder(borderSide: BorderSide.none),
        //       ),
        //     ),
        //   ),
        // ),
      ),
    );
  }
}

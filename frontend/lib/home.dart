import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks_frontend/bloc/tasks_bloc.dart';
import 'package:tasks_frontend/tasks.model.dart';
import 'package:tasks_frontend/widget/icon_button_filled.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
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
        AddTask(Tasks(name: taskTitle, id: '0', isComplete: false, desc: desc)),
      );
      taskTitleController.clear();
      focusNode.unfocus();
    }
  }

  final ScrollController scrollController = ScrollController();
  final ValueNotifier<double> height = ValueNotifier(200);
  final double minHeight = 80;
  final double maxHeight = 200;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      double offset = scrollController.offset;
      double newHeight = (maxHeight - offset).clamp(minHeight, maxHeight);
      height.value = newHeight;
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    height.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TasksBloc, TasksState>(
      listener: (context, state) {
        if (state is TaskActionMessage) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: BlocBuilder<TasksBloc, TasksState>(
              builder: (context, tasksState) {
                if (tasksState is TasksError) {
                  return Center(child: Text("Error: ${tasksState.message}"));
                } else if (tasksState is TasksLoaded) {
                  return Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // List below
                      ValueListenableBuilder(
                        valueListenable: height,
                        builder: (context, value, child) {
                          return Padding(
                            padding: EdgeInsets.only(
                              top: value + 90,
                            ), // header + title
                            child: ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.all(8),
                              itemCount: tasksState.tasks.length,
                              itemBuilder: (context, index) {
                                final task = tasksState.tasks[index];
                                return Container(
                                  padding: EdgeInsets.all(12),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        spacing: 8,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor:
                                                Colors.grey.shade400,
                                            child: Text(index.toString()),
                                          ),
                                          Text(
                                            task.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      InkWell(
                                        onTap: () {
                                          context.read<TasksBloc>().add(
                                            ToggleTask(task.id),
                                          );
                                        },
                                        child: CircleAvatar(
                                          backgroundColor: task.isComplete
                                              ? Colors.green.shade400
                                              : Colors.grey.shade400,
                                          child: Icon(
                                            task.isComplete
                                                ? Icons.check_rounded
                                                : Icons.close_rounded,
                                            color: task.isComplete
                                                ? Colors.green.shade50
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),

                      // Header on top
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Good",
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      "Morning",
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButtonFilled(
                                      onPressed: () {},
                                      icon: Icon(Icons.notifications_outlined),
                                    ),
                                    IconButtonFilled(
                                      icon: Icon(Icons.person_outline_rounded),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: height,
                            builder: (context, value, child) {
                              return AnimatedContainer(
                                duration: Durations.short1,
                                height: value,
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      Positioned(
                        bottom: 30,
                        child: FilledButton.tonalIcon(
                          icon: Icon(Icons.add_rounded),
                          onPressed: () {
                            
                          },
                          label: Text("Add"),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

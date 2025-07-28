import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tasks_frontend/bloc/tasks_bloc.dart';
import 'package:tasks_frontend/style.dart';
import 'package:tasks_frontend/tasks.model.dart';
import 'package:tasks_frontend/widget/icon_button_filled.dart';
import 'package:tasks_frontend/widget/task_tile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  final TextEditingController taskTitleController = TextEditingController();
  final focusNode = FocusNode();

  String dateFormat() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('d MMMM, E').format(now);
    return formattedDate;
  }

  List getProgress(List<Tasks> tasks) {
    final done = tasks
        .where((element) => element.isComplete == true)
        .toList()
        .length;

    final total = tasks.length;
    final String stringFormat = "$done/$total";
    final per = ((done / total) * 100).floor();

    return [stringFormat, per];
  }

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
  final ValueNotifier<double> height = ValueNotifier(250);
  final double minHeight = 100;
  final double maxHeight = 250;

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
    final double width = MediaQuery.of(context).size.width;
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
                  final completedTasks = tasksState.tasks
                      .where((task) => task.isComplete == true)
                      .toList();
                  final onGoingTasks = tasksState.tasks
                      .where((task) => task.isComplete == false)
                      .toList();
                  return Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // List below
                      ValueListenableBuilder(
                        valueListenable: height,
                        builder: (context, value, child) {
                          return Padding(
                            padding: EdgeInsets.only(top: value + 90),
                            child: SingleChildScrollView(
                              controller: scrollController,

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,

                                      children: [
                                        AppStyle.subheadingTextStyle("Ongoing"),
                                        Chip(
                                          backgroundColor: Colors.grey.shade300,
                                          padding: EdgeInsets.all(0),
                                          side: BorderSide.none,
                                          label: Text(
                                            onGoingTasks.length.toString(),
                                            style: TextStyle(height: 0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        Divider(
                                          endIndent: 10,
                                          indent: 10,
                                          color: Colors.grey.shade300,
                                        ),
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    // controller: scrollController,
                                    padding: const EdgeInsets.all(8),
                                    itemCount: onGoingTasks.length,
                                    itemBuilder: (context, index) {
                                      return TaskTile(
                                        task: onGoingTasks[index],
                                      );
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,

                                      children: [
                                        AppStyle.subheadingTextStyle(
                                          "Completed",
                                        ),
                                        Chip(
                                          backgroundColor: Colors.grey.shade300,
                                          padding: EdgeInsets.all(0),
                                          side: BorderSide.none,
                                          label: Text(
                                            completedTasks.length.toString(),
                                            style: TextStyle(height: 0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        Divider(
                                          endIndent: 10,
                                          indent: 10,
                                          color: Colors.grey.shade300,
                                        ),
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    // controller: scrollController,
                                    padding: const EdgeInsets.all(8),
                                    itemCount: completedTasks.length,
                                    itemBuilder: (context, index) {
                                      return TaskTile(
                                        task: completedTasks[index],
                                      );
                                    },
                                  ),
                                ],
                              ),
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
                                  spacing: 0,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Good",
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        height: 0,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      "Morning",
                                      style: TextStyle(
                                        fontSize: 28,
                                        height: 0,
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
                                clipBehavior: Clip.hardEdge,
                                width: double.maxFinite,
                                duration: Durations.short1,
                                height: value,
                                padding: EdgeInsets.all(14),
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    value > 200
                                        ? Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                dateFormat(),
                                                style: TextStyle(
                                                  color: Colors.grey.shade400,
                                                  fontSize: value * 0.045,
                                                  height: 1,
                                                ),
                                              ),
                                              Text(
                                                "Today's Progress",
                                                style: TextStyle(
                                                  fontSize: value * 0.1,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  height: 1,
                                                ),
                                              ),
                                            ],
                                          )
                                        : SizedBox(),
                                    Column(
                                      spacing: 4,
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        value > 200
                                            ? AnimatedDefaultTextStyle(
                                                duration: Durations.medium1,
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                  fontSize:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.height *
                                                      0.025,
                                                  height: 1,
                                                ),
                                                child: Text(
                                                  getProgress(
                                                    tasksState.tasks,
                                                  )[0],
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                        AnimatedDefaultTextStyle(
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                MediaQuery.of(
                                                  context,
                                                ).size.height *
                                                0.05,
                                            height: 1,
                                          ),
                                          duration: Durations.medium4,
                                          curve: Curves.easeInOut,
                                          child: Text(
                                            '${getProgress(tasksState.tasks)[1]}%',
                                          ),
                                        ),
                                        Container(
                                          width: double.maxFinite,
                                          height: (minHeight + value) * 0.05,
                                          // margin: const EdgeInsets.all(
                                          //   8,
                                          // ).copyWith(top: 0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.white,
                                            ),
                                          ),
                                          child: AnimatedFractionallySizedBox(
                                            duration: Durations.medium4,
                                            curve: Curves.easeOut,
                                            alignment: Alignment.centerLeft,

                                            widthFactor:
                                                getProgress(
                                                  tasksState.tasks,
                                                )[1] /
                                                100,
                                            child: FractionallySizedBox(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade400,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      Positioned(
                        bottom: 30,
                        child: FloatingActionButton.extended(
                          foregroundColor: Colors.white,
                          isExtended: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(50),
                          ),
                          backgroundColor: const Color.fromARGB(
                            255,
                            0,
                            38,
                            255,
                          ),
                          label: Text(
                            "Add Task",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            showBottomSheet(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.3,
                              ),
                              showDragHandle: true,
                              enableDrag: true,
                              backgroundColor: Colors.indigo.shade50,
                              elevation: 10,

                              context: context,
                              builder: (context) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 8,
                                    children: [
                                      TextField(
                                        controller: taskTitleController,
                                        onTapOutside: (event) {
                                          focusNode.unfocus();
                                        },
                                        // onSubmitted: (value) {
                                        //   onSubmit();
                                        // },
                                        focusNode: focusNode,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      const Text(
                                        "Enter task & Use # for description",
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FilledButton.tonalIcon(
                                            icon: const Icon(
                                              Icons.cancel_rounded,
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context, false);
                                            },
                                            label: const Text("Cancel"),
                                          ),
                                          const SizedBox(width: 10),
                                          FilledButton.tonalIcon(
                                            icon: const Icon(
                                              Icons.check_circle_rounded,
                                            ),
                                            onPressed: () {
                                              onSubmit();
                                              Navigator.pop(context);
                                            },
                                            label: const Text("Add"),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.add_rounded),
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

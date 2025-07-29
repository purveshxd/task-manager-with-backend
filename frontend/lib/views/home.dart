import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tasks_frontend/bloc/tasks_bloc.dart';
import 'package:tasks_frontend/views/add_task.view.dart';
import 'package:tasks_frontend/views/style.dart';
import 'package:tasks_frontend/views/tasks.model.dart';
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
          : taskTitleController.text.trim().split("#")[1].trim();
    }
    if (taskTitle.isNotEmpty) {
      context.read<TasksBloc>().add(
        AddTask(Tasks(name: taskTitle, id: '0', isComplete: false, desc: desc)),
      );
      taskTitleController.clear();
      focusNode.unfocus();
    }
  }

  final double headerHeight = 200;
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
          backgroundColor: Colors.grey.shade100,
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
                      Padding(
                        padding: EdgeInsets.only(top: headerHeight + 70),
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
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
                                      padding: EdgeInsets.all(1),
                                      side: BorderSide.none,
                                      label: Text(
                                        onGoingTasks.length.toString(),
                                        style: TextStyle(height: 1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ListView.separated(
                                separatorBuilder: (context, index) => Divider(
                                  endIndent: 10,
                                  indent: 10,
                                  color: Colors.grey.shade300,
                                ),
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,

                                itemCount: onGoingTasks.length,
                                itemBuilder: (context, index) {
                                  return TaskTile(task: onGoingTasks[index]);
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,

                                  children: [
                                    AppStyle.subheadingTextStyle("Completed"),
                                    Chip(
                                      backgroundColor: Colors.grey.shade300,
                                      padding: EdgeInsets.all(1),
                                      side: BorderSide.none,
                                      label: Text(
                                        completedTasks.length.toString(),
                                        style: TextStyle(height: 1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ListView.separated(
                                separatorBuilder: (context, index) => Divider(
                                  endIndent: 10,
                                  indent: 10,
                                  color: Colors.grey.shade300,
                                ),
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,

                                itemCount: completedTasks.length,
                                itemBuilder: (context, index) {
                                  return TaskTile(task: completedTasks[index]);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Header on top
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          appbarWidget(),
                          headerWidget(context, tasksState, headerHeight),
                        ],
                      ),

                      Positioned(
                        bottom: 10,
                        // right: 35,
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddTaskView(
                                  taskTitleController: taskTitleController,
                                  onSubmit: () => onSubmit(),
                                ),
                              ),
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

  Padding appbarWidget() {
    return Padding(
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
                  height: 1,
                  color: Colors.black,
                ),
              ),
              Text(
                "morning",
                style: TextStyle(
                  fontSize: 28,
                  height: 1,
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
    );
  }

  Widget headerWidget(
    BuildContext context,
    TasksLoaded tasksState,
    double headerHeight,
  ) {
    return Container(
      clipBehavior: Clip.hardEdge,
      width: double.maxFinite,
      height: headerHeight,
      padding: EdgeInsets.all(14).copyWith(bottom: 16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            spacing: 4,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                dateFormat(),
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: headerHeight * 0.080,
                  height: 0,
                ),
              ),

              Text(
                "Today's Progress",
                style: TextStyle(
                  fontSize: headerHeight * 0.1,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ],
          ),

          Column(
            spacing: 4,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedDefaultTextStyle(
                duration: Durations.medium1,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: headerHeight * 0.08,
                  height: 1,
                ),
                child: Text(getProgress(tasksState.tasks)[0]),
              ),
              AnimatedDefaultTextStyle(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: headerHeight * 0.18,
                  height: 1,
                ),
                duration: Durations.medium4,
                curve: Curves.easeInOut,
                child: Text('${getProgress(tasksState.tasks)[1]}%'),
              ),
              Container(
                width: double.maxFinite,
                height: headerHeight * 0.15,
                // margin: const EdgeInsets.all(
                //   8,
                // ).copyWith(top: 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white),
                ),
                child: AnimatedFractionallySizedBox(
                  duration: Durations.medium4,
                  curve: Curves.easeOut,
                  alignment: Alignment.centerLeft,

                  widthFactor: getProgress(tasksState.tasks)[1] / 100,
                  child: FractionallySizedBox(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(8),
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
  }
}

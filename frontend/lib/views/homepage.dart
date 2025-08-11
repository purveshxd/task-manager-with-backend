import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:tasks_frontend/views/profile_view.dart';

import '../bloc/task_bloc/tasks_bloc.dart';
import '../models/tasks.model.dart';
import '../notification_handler.dart';
import '../style/style.dart';
import '../widget/icon_button_filled.dart';
import '../widget/task_tile.dart';
import 'add_task.view.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  final focusNode = FocusNode();

  String dateFormat() {
    final now = DateTime.now();
    final formattedDate = DateFormat('d MMMM, E').format(now);
    return formattedDate;
  }

  List getProgress(List<Tasks> tasks) {
    final done = tasks.where((element) => element.isComplete).toList().length;
    final total = tasks.length;
    final stringFormat = '$done/$total';
    final per = ((done / total) * 100).floor();
    return [stringFormat, per];
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
          backgroundColor: AppStyle.appBackground(),
          body: SafeArea(
            child: BlocBuilder<TasksBloc, TasksState>(
              builder: (context, tasksState) {
                if (tasksState is TasksError) {
                  return Center(child: Text('Error: ${tasksState.message}'));
                } else if (tasksState is TasksLoaded) {
                  final completedTasks = tasksState.tasks
                      .where((task) => task.isComplete)
                      .toList();
                  final onGoingTasks = tasksState.tasks
                      .where((task) => !task.isComplete)
                      .toList();

                  if (tasksState.tasks.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        appbarWidget(),
                        const Spacer(),
                        Text(
                          'No tasks to work on right now',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),
                        addTaskButtonFloating(context),
                        const SizedBox(height: 10),
                      ],
                    );
                  } else {
                    return Stack(
                      fit: StackFit.expand,
                      alignment: Alignment.topCenter,
                      children: [
                        // List below
                        Padding(
                          padding: EdgeInsets.only(top: headerHeight + 75),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AppStyle.subheadingTextStyle('Ongoing'),
                                      Chip(
                                        backgroundColor: Colors.grey.shade300,
                                        padding: const EdgeInsets.all(1),
                                        side: BorderSide.none,
                                        label: Text(
                                          onGoingTasks.length.toString(),
                                          style: const TextStyle(height: 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (onGoingTasks.isNotEmpty)
                                  ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        Divider(
                                          endIndent: 10,
                                          indent: 10,
                                          color: Colors.grey.shade300,
                                        ),
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,

                                    itemCount: onGoingTasks.length,
                                    itemBuilder: (context, index) {
                                      return TaskTile(
                                        task: onGoingTasks[index],
                                      );
                                    },
                                  )
                                else
                                  Center(
                                    child: AppStyle.secondaryHeading(
                                      'All tasks done!',
                                    ),
                                  ),
                                if (completedTasks.isEmpty)
                                  const SizedBox()
                                else
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,

                                      children: [
                                        AppStyle.subheadingTextStyle(
                                          'Completed',
                                        ),
                                        Chip(
                                          backgroundColor: Colors.grey.shade300,
                                          padding: const EdgeInsets.all(1),
                                          side: BorderSide.none,
                                          label: Text(
                                            completedTasks.length.toString(),
                                            style: const TextStyle(height: 1),
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
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,

                                  itemCount: completedTasks.length,
                                  itemBuilder: (context, index) {
                                    return TaskTile(
                                      task: completedTasks[index],
                                    );
                                  },
                                ),
                                // SizedBox(height: 60),
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
                          child: addTaskButtonFloating(context),
                        ),
                      ],
                    );
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget addTaskButtonFloating(BuildContext context) {
    return FloatingActionButton.extended(
      foregroundColor: Colors.white,
      isExtended: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(50),
      ),
      // backgroundColor: const Color.fromARGB(255, 0, 38, 255),
      label: const Text('Add Task', style: TextStyle(color: Colors.white)),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddTaskView()),
        );
      },
      icon: const Icon(Icons.add_rounded),
    );
  }

  Padding appbarWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 0,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Good',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1,
                  // color: Theme.of(context).colorScheme.primary,
                  color: Colors.black,
                ),
              ),
              Text(
                'morning',
                style: TextStyle(
                  fontSize: 28,
                  height: 1,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                  // color: Theme.of(context).colorScheme.secondaryContainer,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButtonFilled(
                onPressed: () async {
                  // temp notification
                  await FlutterLocalNotificationsPlugin().show(
                    Random().nextInt(100),
                    'title',
                    'body',
                    const NotificationDetails(
                      android: AndroidNotificationDetails(
                        'task_channel', // channel id
                        'Task Notifications',
                        importance: Importance.high,
                        enableVibration: true,
                        autoCancel: false,
                        category: AndroidNotificationCategory.reminder,
                        priority: Priority.high,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_outlined),
              ),
              IconButtonFilled(
                icon: const Icon(Icons.circle),
                onPressed: () async {
                  await NotificationProvider().debugScheduledNotifications();
                },
              ),
              IconButtonFilled(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const ProfileView();
                      },
                    ),
                  );
                },
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
      padding: const EdgeInsets.all(14).copyWith(bottom: 16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        // color: Theme.of(context).colorScheme.onSurface,
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
              Text(
                getProgress(tasksState.tasks)[0],
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500,
                  fontSize: headerHeight * 0.08,
                  height: 1,
                ),
              ),
              Text(
                '${getProgress(tasksState.tasks)[1]}%',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: headerHeight * 0.18,
                  height: 1,
                ),
              ),
              Container(
                width: double.maxFinite,
                height: headerHeight * 0.15,

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
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(7),
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

import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tasks_frontend/bloc/app_cubit/app_cubit.dart';
import 'package:tasks_frontend/bloc/task_bloc/tasks_bloc.dart';
import 'package:tasks_frontend/models/tasks.model.dart';
import 'package:tasks_frontend/notification_handler.dart';
import 'package:tasks_frontend/style/app_theme.dart';
import 'package:tasks_frontend/style/custom_style.dart';
import 'package:tasks_frontend/widget/icon_button_filled.dart';

class RepeatOptionModel {
  final RepeatOption option;
  final bool isSelected;

  RepeatOptionModel({required this.option, required this.isSelected});

  RepeatOptionModel copyWith({RepeatOption? option, bool? isSelected}) {
    return RepeatOptionModel(
      option: option ?? this.option,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class AddTaskView extends StatefulWidget {
  const AddTaskView({super.key, this.task});
  final Tasks? task;

  @override
  State<AddTaskView> createState() => _AddTaskViewState();
}

class _AddTaskViewState extends State<AddTaskView> {
  late TextEditingController titleController;
  late TextEditingController descController;
  TimeOfDay timeOfDay = TimeOfDay.now();
  DateTime dateTime = DateTime.now();

  late List<RepeatOptionModel> repeatOptions;
  late int repeatIndex;
  late String repeatName;
  late RepeatOption repeatOption;
  late TaskPriority taskPriority;

  final notificationHandler = NotificationProvider();

  bool isEdit = false;
  bool addNotification = false;

  FocusNode focusNode = FocusNode();

  final List<Color> priorityColorList = [
    Colors.greenAccent.shade700,
    Colors.yellowAccent.shade700,
    Colors.redAccent.shade700,
  ];

  @override
  void initState() {
    super.initState();

    isEdit = widget.task != null;
    taskPriority = widget.task?.taskPriority ?? TaskPriority.low;
    repeatOption = widget.task?.repeatOption ?? RepeatOption.once;

    // Initialize controllers
    titleController = TextEditingController(text: widget.task?.name ?? "");
    descController = TextEditingController(text: widget.task?.desc ?? "");

    // Initialize notification settings
    addNotification = widget.task?.addNotification ?? false;

    // Initialize date and time from existing task if editing
    if (isEdit && widget.task!.notificationDateTime != null) {
      final notifDateTime = widget.task!.notificationDateTime!;
      dateTime = DateTime(
        notifDateTime.year,
        notifDateTime.month,
        notifDateTime.day,
      );
      timeOfDay = TimeOfDay(
        hour: notifDateTime.hour,
        minute: notifDateTime.minute,
      );
    }

    // Initialize repeat options
    final currentRepeat = widget.task?.repeatOption ?? RepeatOption.once;
    repeatIndex = currentRepeat.index;
    repeatName = currentRepeat.name;

    repeatOptions = [
      RepeatOptionModel(
        option: RepeatOption.once,
        isSelected: currentRepeat == RepeatOption.once,
      ),
      RepeatOptionModel(
        option: RepeatOption.daily,
        isSelected: currentRepeat == RepeatOption.daily,
      ),
      RepeatOptionModel(
        option: RepeatOption.weekly,
        isSelected: currentRepeat == RepeatOption.weekly,
      ),
      RepeatOptionModel(
        option: RepeatOption.monthly,
        isSelected: currentRepeat == RepeatOption.monthly,
      ),
    ];
  }

  // Helper method to get the current notification DateTime
  DateTime get currentNotificationTime {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      timeOfDay.hour, // Use timeOfDay.hour instead of hourOfPeriod
      timeOfDay.minute,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? timer = await showDatePicker(
      confirmText: "Set Time",
      currentDate: dateTime,
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: 10000)),
    );
    if (timer != null && timer != dateTime) {
      setState(() {
        dateTime = timer;
      });
    }
    if (context.mounted) {
      await _selectTime(context);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    if (context.mounted) {
      final TimeOfDay? timerPick = await showTimePicker(
        context: context,
        initialTime: timeOfDay,
        initialEntryMode: TimePickerEntryMode.dial,
      );
      if (timerPick != null && timerPick != timeOfDay) {
        setState(() {
          timeOfDay = timerPick;
        });
      }
    }
  }

  Future<void> addNotificationButton() async {
    await notificationHandler.scheduleNotification(
      repeatType: repeatOptions[repeatIndex].option.name,
      id: isEdit ? widget.task!.id.hashCode : Random().nextInt(100),
      title: titleController.text.trim(),
      body: descController.text.trim(),
      dateTime: currentNotificationTime,
    );
  }

  void onSubmit() {
    if (titleController.text.trim().isNotEmpty) {
      if (addNotification) {
        addNotificationButton();
      }

      context.read<TasksBloc>().add(
        AddTask(
          Tasks(
            repeatOption: repeatOption,
            notificationDateTime: addNotification
                ? currentNotificationTime
                : null,
            addNotification: addNotification,
            name: titleController.text.trim(),
            isComplete: false,
            desc: descController.text.trim().isEmpty
                ? ""
                : descController.text.trim(),
            taskPriority: taskPriority,
          ),
        ),
      );

      titleController.clear();
      descController.clear();
      focusNode.unfocus();
    }
  }

  Future<void> handleSubmit() async {
    if (isEdit) {
      // Cancel existing notification if it exists
      if (widget.task!.addNotification) {
        notificationHandler.cancelNotification(widget.task!.id.hashCode);
      }

      // Create updated task - need to handle notificationDateTime properly
      // because copyWith doesn't handle null values correctly
      Tasks editTask = Tasks(
        name: titleController.text.trim(),
        isComplete: widget.task!.isComplete,
        desc: descController.text.trim(),
        addNotification: addNotification,
        notificationDateTime: addNotification ? currentNotificationTime : null,
        repeatOption: repeatOption,
        taskPriority: taskPriority,
      );
      // Preserve the original ID
      editTask.id = widget.task!.id;

      // Schedule new notification if needed
      if (addNotification) {
        await addNotificationButton();
      }

      // Update the task in bloc
      mounted ? context.read<TasksBloc>().add(UpdateTask(editTask)) : null;
    } else {
      onSubmit();
    }

    mounted ? Navigator.pop(context) : null;
  }

  // request notification permission
  Future<void> requestPermission() async {
    final permission = await Permission.notification.status;

    final isGranted = permission.isGranted;
    if (!isGranted) {
      await Permission.notification.request();
    }
  }

  void toggleChip(int index) {
    setState(() {
      for (int i = 0; i < repeatOptions.length; i++) {
        repeatOptions[i] = repeatOptions[i].copyWith(isSelected: i == index);
      }
      repeatIndex = index;
      repeatName = repeatOptions[index].option.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,

      appBar: AppBar(
        leading: CloseButton(color: context.secondaryColor),
        title: Text(
          isEdit ? "Edit Task" : "Add Task",
          style: TextStyle(
            color: context.secondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: context.backgroundColor,
        actionsPadding: EdgeInsets.symmetric(horizontal: 10),
        actions: [
          widget.task != null
              ? IconButtonFilled(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<TasksBloc>().add(DeleteTask(widget.task!.id));
                  },
                  icon: Icon(
                    Icons.delete_sweep_rounded,
                    color: context.secondaryColor,
                  ),
                )
              : SizedBox.shrink(),

          IconButton.filled(
            onPressed: () {
              context.read<AppCubit>().toggleTheme();
            },
            icon: Icon(Icons.dark_mode),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0).copyWith(bottom: 8),
          child: ListView(
            // mainAxisSize: MainAxisSize.min,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Task",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    textInputAction: TextInputAction.next,
                    controller: titleController,
                    style: TextStyle(color: context.secondaryColor),
                    decoration: AppStyle.textFieldDecoration(
                      context,
                      label: "",
                    ),
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      const Text(
                        "Description",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: 3,
                          width: double.maxFinite,
                          color: context.onBackground,
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    textInputAction: TextInputAction.done,
                    controller: descController,
                    style: TextStyle(color: context.secondaryColor),
                    minLines: null,
                    maxLines: null,
                    decoration: AppStyle.textFieldDecoration(
                      context,
                      label: "",
                    ),
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      const Text(
                        "Priority",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: 3,
                          width: double.maxFinite,
                          color: context.onBackground,
                        ),
                      ),
                    ],
                  ),
                  Flexible(
                    child: SegmentedButton<int>(
                      onSelectionChanged: (Set<int> newSelection) {
                        setState(() {
                          taskPriority =
                              TaskPriority.values[newSelection.first];
                        });
                      },
                      segments: List.generate(
                        TaskPriority.values.length,
                        (index) => ButtonSegment(
                          value: index,
                          icon: RotatedBox(
                            quarterTurns: 3,
                            child: Icon(
                              Icons.bookmark_rounded,
                              color: AppStyle.givePriorityColor(
                                TaskPriority.values[index],
                              ),
                            ),
                          ),
                          label: Text(
                            TaskPriority.values[index].name[0].toUpperCase() +
                                TaskPriority.values[index].name.substring(1),
                          ),
                        ),
                      ),
                      selected: {TaskPriority.values.indexOf(taskPriority)},
                      showSelectedIcon: false,
                      emptySelectionAllowed: false,
                      expandedInsets: EdgeInsets.all(0),
                      multiSelectionEnabled: false,
                      style: SegmentedButton.styleFrom(
                        foregroundColor: context.secondaryColor,
                        selectedForegroundColor: Colors.black,
                        animationDuration: Durations.medium4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(10),
                        ),
                        side: BorderSide.none,
                        backgroundColor: context.onBackground.withAlpha(200),
                        selectedBackgroundColor: context.secondaryColor
                            .withAlpha(180),
                      ),
                    ),
                  ),

                  Row(
                    spacing: 8,
                    children: [
                      const Text(
                        "Notification",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Flexible(
                        child: Container(
                          height: 3,
                          width: double.maxFinite,
                          color: context.onBackground,
                        ),
                      ),
                      IconButton(
                        splashColor: Colors.grey.shade50,
                        style: IconButton.styleFrom(
                          backgroundColor: context.onBackground,
                          foregroundColor: addNotification
                              ? Colors.black
                              : Colors.grey.shade400,
                        ),
                        onPressed: () async {
                          setState(() {
                            addNotification = !addNotification;
                          });
                        },
                        icon: AnimatedRotation(
                          duration: Durations.medium4,
                          turns: addNotification ? .375 : 0,
                          child: Icon(Icons.add_rounded),
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.all(0),
                      ),
                    ],
                  ),

                  AnimatedScale(
                    scale: !addNotification ? 0 : 1,
                    duration: Durations.medium4,
                    curve: Curves.easeInOutBack,
                    alignment: Alignment.topRight,
                    child: Column(
                      spacing: 8,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: context.onBackground.withAlpha(200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                spacing: 5,
                                children: [
                                  SizedBox(width: 5),
                                  Text(
                                    "Date | Time",

                                    style: TextStyle(
                                      color: context.secondaryColor,

                                      // fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  ActionChip(
                                    onPressed: () => _selectDate(context),
                                    label: Text(
                                      "${dateTime.day}/${dateTime.month}/${dateTime.year}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: addNotification
                                            ? Colors.black
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                                    backgroundColor: context.onBackground
                                        .withAlpha(130),
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  ActionChip(
                                    onPressed: () => _selectTime(context),
                                    label: Text(
                                      "${timeOfDay.hourOfPeriod}:${timeOfDay.minute.toString().padLeft(2, '0')} ${timeOfDay.period.name.toUpperCase()}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: addNotification
                                            ? Colors.black
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                                    backgroundColor: context.onBackground
                                        .withAlpha(130),
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          spacing: 8,
                          children: [
                            const Text(
                              "Repeat",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: 3,
                                width: double.maxFinite,
                                color: context.onBackground,
                              ),
                            ),
                          ],
                        ),

                        // ! =================
                        SegmentedButton<int>(
                          onSelectionChanged: (Set<int> newSelection) {
                            setState(() {
                              repeatOption =
                                  RepeatOption.values[newSelection.first];
                            });
                          },
                          segments: List.generate(
                            RepeatOption.values.length,
                            (index) => ButtonSegment(
                              value: index,
                              label: Text(
                                RepeatOption.values[index].name[0]
                                        .toUpperCase() +
                                    RepeatOption.values[index].name.substring(
                                      1,
                                    ),
                              ),
                            ),
                          ),
                          selected: {RepeatOption.values.indexOf(repeatOption)},
                          showSelectedIcon: false,
                          emptySelectionAllowed: false,
                          expandedInsets: EdgeInsets.all(0),
                          multiSelectionEnabled: false,
                          style: SegmentedButton.styleFrom(
                            foregroundColor: context.secondaryColor,
                            selectedForegroundColor: Colors.black,
                            animationDuration: Durations.medium4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(10),
                            ),
                            side: BorderSide.none,
                            backgroundColor: context.onBackground.withAlpha(
                              200,
                            ),
                            selectedBackgroundColor: context.secondaryColor
                                .withAlpha(180),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,

      floatingActionButton: FilledButton.tonalIcon(
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.check_circle_rounded),
        onPressed: handleSubmit,
        label: Text(isEdit ? "Update" : "Add"),
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks_frontend/bloc/task_bloc/tasks_bloc.dart';
import 'package:tasks_frontend/models/tasks.model.dart';
import 'package:tasks_frontend/notification_handler.dart';
import 'package:tasks_frontend/style/style.dart';
import 'package:tasks_frontend/widget/custom_action_chip.dart';
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

  final notificationHandler = NotificationProvider();

  bool isEdit = false;
  bool addNotification = false;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    isEdit = widget.task != null;

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
            repeatOption: RepeatOption.values[repeatIndex],
            notificationDateTime: addNotification
                ? currentNotificationTime
                : null,
            addNotification: addNotification,
            name: titleController.text.trim(),
            isComplete: false,
            desc: descController.text.trim().isEmpty
                ? ""
                : descController.text.trim(),
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
        repeatOption: RepeatOption.values[repeatIndex],
      );
      // Preserve the original ID
      editTask.id = widget.task!.id;

      // Schedule new notification if needed
      if (addNotification) {
        await addNotificationButton();
      }

      // Update the task in bloc
      context.read<TasksBloc>().add(UpdateTask(editTask));
    } else {
      onSubmit();
    }

    Navigator.pop(context);
  }

  // request notification permission
  Future<void> requestPermission() async {
    // bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    // if (!isAllowed) {
    //   await AwesomeNotifications().requestPermissionToSendNotifications();
    // }
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
      backgroundColor: AppStyle.appBackground(),
      appBar: AppBar(
        title: Text(isEdit ? "Edit Task" : "Add Task"),
        backgroundColor: AppStyle.appBackground(),
        actionsPadding: EdgeInsets.symmetric(horizontal: 10),
        actions: [
          widget.task != null
              ? IconButtonFilled(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<TasksBloc>().add(DeleteTask(widget.task!.id));
                  },
                  icon: Icon(Icons.delete_outline_sharp),
                )
              : SizedBox.shrink(),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0).copyWith(bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    decoration: AppStyle.textFieldDecoration(label: ""),
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
                          height: 2,
                          width: double.maxFinite,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    textInputAction: TextInputAction.done,
                    controller: descController,
                    minLines: null,
                    maxLines: null,
                    decoration: AppStyle.textFieldDecoration(label: ""),
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
                          height: 2,
                          width: double.maxFinite,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      IconButton(
                        splashColor: Colors.grey.shade50,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: addNotification
                              ? Colors.black
                              : Colors.grey.shade400,
                        ),
                        onPressed: () async {
                          await requestPermission();
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
                            color: Colors.white,
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
                                      fontWeight: FontWeight.bold,
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
                                    backgroundColor: Colors.grey.shade200,
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
                                    backgroundColor: Colors.grey.shade200,
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
                                height: 2,
                                width: double.maxFinite,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: double.maxFinite,
                          padding: EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            runSpacing: 0,
                            spacing: 8,
                            children: List.generate(repeatOptions.length, (
                              index,
                            ) {
                              final option = repeatOptions[index];
                              return CustomActionChip(
                                label: option.option.name,
                                isSelected: option.isSelected,
                                onPressed: (value) => toggleChip(index),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // ! Bottom Buttons -------------------
              Spacer(),
              Row(
                spacing: 16,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                  ),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 38, 255),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check_circle_rounded),
                      onPressed: handleSubmit,
                      label: Text(isEdit ? "Update" : "Add"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

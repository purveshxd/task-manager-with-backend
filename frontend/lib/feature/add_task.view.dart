import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks_frontend/bloc/tasks_bloc.dart';
import 'package:tasks_frontend/feature/style.dart';
import 'package:tasks_frontend/feature/tasks.model.dart';
import 'package:tasks_frontend/notification_handler.dart';
import 'package:tasks_frontend/widget/icon_button_filled.dart';

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

  final notificationHandler = NotificationProvider();

  bool isEdit = false;
  bool addNotification = false;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    isEdit = widget.task != null;
    addNotification = widget.task?.addNotification ?? false;

    titleController = TextEditingController(text: widget.task?.name ?? "");
    descController = TextEditingController(text: widget.task?.desc ?? "");
  }

  Future<void> _selectTime(BuildContext context) async {
    final DateTime? timer = await showDatePicker(
      confirmText: "Set Time",
      currentDate: DateTime.now(),
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: 10000)),
    );
    if (timer != null && timer != dateTime) {
      setState(() {
        dateTime = timer;
      });
    }

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

    if (addNotification) {
      log(
        "Add Timer Noti-$addNotification | ${dateTime.day}/${dateTime.month}/${dateTime.year} | ${timeOfDay.hourOfPeriod}:${timeOfDay.minute} ${timeOfDay.period.name.toUpperCase()}",
      );
      await notificationHandler.scheduleMinuteNotification(
        title: titleController.text.trim(),
        body: descController.text.trim(),
        scheduledDate: DateTime(
          dateTime.year,
          dateTime.month,
          dateTime.day,
          timeOfDay.hour,
          timeOfDay.minute,
        ),
      );
    }
  }

  void onSubmit() {
    if (titleController.text.trim().isNotEmpty) {
      context.read<TasksBloc>().add(
        AddTask(
          Tasks(
            notificationDateTime: DateTime(
              dateTime.year,
              dateTime.month,
              dateTime.day,
              timeOfDay.hour,
              timeOfDay.minute,
            ),
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

  void handleSubmit() {
    if (isEdit) {
      Tasks editTask = widget.task!.copyWith(
        notificationDateTime: DateTime(
          dateTime.year,
          dateTime.month,
          dateTime.day,
          timeOfDay.hour,
          timeOfDay.minute,
        ),
        addNotification: addNotification,
        name: titleController.text.trim(),
        desc: descController.text.trim(),
      );
      context.read<TasksBloc>().add(UpdateTask(editTask));
    } else {
      onSubmit();
    }
    Navigator.pop(context);
  }

  // request notification permission
  Future<void> requestPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(isEdit ? "Edit Task" : "Add Task"),
        backgroundColor: Colors.grey.shade100,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Task",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
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
                  ListTile(
                    enabled: addNotification,
                    contentPadding: EdgeInsets.all(0),

                    onTap: () => _selectTime(context),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4,
                      children: [
                        Chip(
                          label: Text(
                            "${dateTime.day}/${dateTime.month}/${dateTime.year}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: addNotification
                                  ? Colors.black
                                  : Colors.grey.shade400,
                            ),
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        Chip(
                          label: Text(
                            "${timeOfDay.hourOfPeriod}:${timeOfDay.minute} ${timeOfDay.period.name.toUpperCase()}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: addNotification
                                  ? Colors.black
                                  : Colors.grey.shade400,
                            ),
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () async {
                            await requestPermission();
                            setState(() {
                              addNotification = !addNotification;
                            });
                          },
                          icon: Icon(
                            addNotification
                                ? Icons.close_rounded
                                : Icons.add_rounded,
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      "Notification",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: addNotification
                            ? Colors.black
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],
              ),
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

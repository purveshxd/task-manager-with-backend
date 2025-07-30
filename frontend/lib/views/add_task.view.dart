import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks_frontend/bloc/tasks_bloc.dart';
import 'package:tasks_frontend/views/style.dart';
import 'package:tasks_frontend/views/tasks.model.dart';

class AddTaskView extends StatefulWidget {
  const AddTaskView({super.key, this.task});

  final Tasks? task;

  @override
  State<AddTaskView> createState() => _AddTaskViewState();
}

class _AddTaskViewState extends State<AddTaskView> {
  late TextEditingController titleController;
  late TextEditingController descController;
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isEdit = false;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    isEdit = widget.task != null;

    titleController = TextEditingController(text: widget.task?.name ?? "");
    descController = TextEditingController(text: widget.task?.desc ?? "");
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? timer = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timer != null && timer != selectedTime) {
      setState(() {
        selectedTime = timer;
      });
    }
  }

  void onSubmit() {
    if (titleController.text.trim().isNotEmpty) {
      context.read<TasksBloc>().add(
        AddTask(
          Tasks(
            name: titleController.text.trim(),
            id: '0',
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
        name: titleController.text.trim(),
        desc: descController.text.trim(),
      );
      context.read<TasksBloc>().add(UpdateTask(editTask));
    } else {
      onSubmit();
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(isEdit ? "Edit Task" : "Add Task"),
        backgroundColor: Colors.grey.shade100,
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
                spacing: 8,
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
                    controller: descController,
                    minLines: null,
                    maxLines: null,
                    decoration: AppStyle.textFieldDecoration(label: ""),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.all(0),
                    leading: const Icon(Icons.notifications_rounded),
                    onTap: () => _selectTime(context),
                    trailing: Chip(
                      label: Text(
                        selectedTime.format(context),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    title: const Text(
                      "Add Reminder",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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

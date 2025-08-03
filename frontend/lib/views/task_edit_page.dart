import 'package:flutter/material.dart';
import 'package:tasks_frontend/style/style.dart';
import 'package:tasks_frontend/models/tasks.model.dart';

class TaskEditPage extends StatelessWidget {
  final Tasks task;
  const TaskEditPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    TextEditingController titleController = TextEditingController(
      text: task.name,
    );
    TextEditingController descController = TextEditingController(
      text: task.desc,
    );
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close_rounded),
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16),
        actions: [
          FilledButton.tonal(
            onPressed: () {},
            style: AppStyle.primaryButtonColor(),
            child: Text("Save"),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          spacing: 12,
          children: [
            SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: AppStyle.textFieldDecoration(label: ""),
            ),
            Row(
              spacing: 6,
              children: [
                Text("Description", style: TextStyle(fontSize: 11)),
                Flexible(
                  child: Container(
                    height: 1,
                    color: Colors.grey.shade400,
                    width: double.maxFinite,
                  ),
                ),
              ],
            ),
            TextField(
              controller: descController,
              maxLines: null,
              minLines: null,
              decoration: AppStyle.textFieldDecoration(label: ""),
            ),
          ],
        ),
      ),
    );
  }
}

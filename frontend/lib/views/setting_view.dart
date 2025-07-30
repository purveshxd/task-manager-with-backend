import 'package:flutter/material.dart';
import 'package:tasks_frontend/views/style.dart';

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    const List<String> listSettings = [
      
    ];
    return Scaffold(
      backgroundColor: AppStyle.appBackground(),
      appBar: AppBar(
        backgroundColor: AppStyle.appBackground(),
        title: Text("Settings"),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(8),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: Text("$index"),
              tileColor: AppStyle.primaryColor(),
              subtitle: Text("Another $index"),
            ),
          );
        },
        itemCount: 8,
      ),
    );
  }
}

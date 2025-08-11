import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool switchButton = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            spacing: 18,
            children: [
              CircleAvatar(
                radius: MediaQuery.of(context).size.width * .15,
                child: Icon(Icons.person_rounded),
              ),
              Text(
                "Purvesh Dongarwar",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
              ),
              SwitchListTile(
                value: switchButton,
                onChanged: (value) {
                  setState(() {
                    switchButton = !switchButton;
                  });
                },
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                ).copyWith(left: 18),
                title: Text(
                  "Settings",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                tileColor: Theme.of(context).colorScheme.secondaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:tasks_frontend/style/app_theme.dart';

class IconButtonFilled extends StatelessWidget {
  final void Function()? onPressed;
  final Icon icon;
  const IconButtonFilled({super.key, this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: icon,

      style: IconButton.styleFrom(
        // backgroundColor: context.onBackground,
        backgroundColor: context.backgroundColor,
      ),
    );
  }
}

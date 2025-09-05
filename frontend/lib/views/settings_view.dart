import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasks_frontend/bloc/app_cubit/app_cubit.dart';
import 'package:tasks_frontend/style/app_theme.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  Color darkOrLight(Color color) {
    Color textColor = Colors.white;
    final luminance = color.computeLuminance();
    if (luminance > 0.5) {
      textColor = Colors.black;
    } else {
      textColor = Colors.white;
    }

    return textColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: context.secondaryColor),
        title: Text(
          "Settings",
          style: TextStyle(
            color: context.secondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleText('Theme Mode'),
              Row(
                children: [
                  Expanded(
                    child: CupertinoSlidingSegmentedControl(
                      padding: EdgeInsetsGeometry.all(6),
                      proportionalWidth: false,
                      thumbColor: context.secondaryColor.withAlpha(50),
                      groupValue: context.read<AppCubit>().state.themeMode,
                      children: {
                        for (var element in ThemeMode.values)
                          element: Text(
                            element.name[0].toUpperCase() +
                                element.name.substring(1),
                            style: TextStyle(color: context.secondaryColor),
                          ),
                      },
                      onValueChanged: (value) {
                        context.read<AppCubit>().switchThemeMode(value!);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              titleText('Accent Color'),
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    crossAxisCount: 8,
                  ),
                  itemCount: 16,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      context.read<AppCubit>().switchAccentColor(index);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.primaries[index],
                        shape: BoxShape.circle,
                        border:
                            context.read<AppCubit>().state.accentColor ==
                                Colors.primaries[index]
                            ? Border.all(width: 2, color: Colors.black)
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Text titleText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: context.secondaryColor,
        fontWeight: FontWeight.w500,
        fontSize: MediaQuery.sizeOf(context).width * 0.05,
      ),
    );
  }
}

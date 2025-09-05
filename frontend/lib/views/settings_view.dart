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
              _builContainer(
                Column(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleText('Theme Mode'),
                    // ThemeModeSegmentedControl(),
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoSlidingSegmentedControl(
                            padding: EdgeInsetsGeometry.all(6),
                            proportionalWidth: false,
                            thumbColor: context.secondaryColor.withAlpha(30),
                            groupValue: context
                                .read<AppCubit>()
                                .state
                                .themeMode,
                            children: {
                              for (var element in ThemeMode.values)
                                element: Text(
                                  element.name[0].toUpperCase() +
                                      element.name.substring(1),
                                  style: TextStyle(
                                    color: context.secondaryColor,
                                  ),
                                ),
                            },
                            onValueChanged: (value) {
                              context.read<AppCubit>().switchThemeMode(value!);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              _builContainer(
                Center(
                  child: Column(
                    spacing: 8,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleText('Accent Color'),
                      Wrap(
                        spacing: 10,

                        // mainAxisSize: MainAxisSize.min,
                        children: List.generate(primaryColors.length, (index) {
                          return FilledButton(
                            onPressed: () {
                              context.read<AppCubit>().switchAccentColor(index);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: primaryColors[index],
                            ),

                            child:
                                context.read<AppCubit>().state.accentColor ==
                                    primaryColors[index]
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: darkOrLight(primaryColors[index]),
                                  )
                                : null,
                          );
                        }, growable: false),
                      ),
                    ],
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
        fontSize: MediaQuery.sizeOf(context).width * 0.04,
      ),
    );
  }

  Container _builContainer(Widget child) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.onBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class ThemeModeSegmentedControl extends StatefulWidget {
  const ThemeModeSegmentedControl({super.key});

  @override
  State<ThemeModeSegmentedControl> createState() =>
      _ThemeModeSegmentedControlState();
}

class _ThemeModeSegmentedControlState extends State<ThemeModeSegmentedControl>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Animate the slider
    _controller.animateTo(index / (ThemeMode.values.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final themeModes = ThemeMode.values;

    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth = constraints.maxWidth / themeModes.length;

        return SizedBox(
          child: Stack(
            children: [
              // Slider background
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                left: _selectedIndex * segmentWidth,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),

              // Buttons
              Row(
                spacing: 8,
                children: List.generate(themeModes.length, (index) {
                  return Expanded(
                    child: InkWell(
                      onTap: () => _onTap(index),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: _selectedIndex == index
                              ? context.surfaceContainer
                              : context.secondaryColor,
                        ),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        child: Text(
                          themeModes[index].name[0].toUpperCase() +
                              themeModes[index].name.substring(1),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: context.backgroundColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

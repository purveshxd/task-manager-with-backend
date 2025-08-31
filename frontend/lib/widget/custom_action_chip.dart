import 'package:flutter/material.dart';

class CustomActionChip extends StatelessWidget {
  const CustomActionChip({
    super.key,
    required this.label,
    this.onPressed,
    required this.isSelected,
    this.backgroundColor,
    this.selectedColor,
  });
  final String label;
  final bool isSelected;
  final void Function(bool)? onPressed;
  final Color? backgroundColor;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      chipAnimationStyle: ChipAnimationStyle(
        enableAnimation: AnimationStyle(
          duration: Durations.medium4,
          reverseDuration: Durations.medium4,
          curve: Curves.easeInOut,
          reverseCurve: Curves.easeInOut,
        ),
        selectAnimation: AnimationStyle(
          reverseDuration: Durations.medium4,
          duration: Durations.medium4,
          reverseCurve: Curves.easeInOut,
          curve: Curves.easeInOut,
        ),
      ),
      visualDensity: VisualDensity.compact,
      selected: isSelected,
      onSelected: onPressed,
      label: Text(
        label[0].toUpperCase() + label.substring(1),
        style: TextStyle(color: Colors.black),
      ),
      // padding: EdgeInsets.all(0),
      side: BorderSide.none,
      backgroundColor: backgroundColor ?? Colors.grey.shade200,
      selectedColor: selectedColor ?? Colors.grey.shade400,
      showCheckmark: false,
      // labelPadding: EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

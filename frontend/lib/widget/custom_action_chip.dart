import 'package:flutter/material.dart';

class CustomActionChip extends StatelessWidget {
  const CustomActionChip({
    super.key,
    required this.label,
    this.onPressed,
    required this.isSelected,
  });
  final String label;
  final bool isSelected;
  final void Function(bool)? onPressed;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: isSelected,
      onSelected: onPressed,
      label: Text(label, style: TextStyle(color: Colors.black)),
      // padding: EdgeInsets.all(0),
      side: BorderSide.none,
      backgroundColor: Colors.grey.shade200,
      selectedColor: Colors.grey.shade400,
      showCheckmark: false,
      // labelPadding: EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

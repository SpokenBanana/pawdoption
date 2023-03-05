import 'package:flutter/material.dart';

class PetButton extends StatelessWidget {
  PetButton(
      {required this.child,
      required this.color,
      required this.padding,
      required this.onPressed});

  final Widget child;
  final VoidCallback onPressed;
  final Color color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: this.onPressed,
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: color,
            padding: padding,
            elevation: 5.0),
        child: child,
      ),
    );
  }
}

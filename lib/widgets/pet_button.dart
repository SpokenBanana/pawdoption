import 'package:flutter/material.dart';

class PetButton extends StatelessWidget {
  PetButton(
      {this.key, this.child, this.lightMode, this.padding, this.onPressed})
      : super(key: key);
  final Key key;

  final Widget child;
  final bool lightMode;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: this.lightMode ? Colors.white : Colors.black,
      elevation: 5.0,
      onPressed: this.onPressed,
      shape: CircleBorder(),
      padding: padding,
      child: child,
    );
  }
}

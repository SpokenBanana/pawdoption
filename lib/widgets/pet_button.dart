import 'package:flutter/material.dart';

import '../api.dart';

class PetButton extends StatelessWidget {
  PetButton({this.key, this.child, this.feed, this.padding, this.onPressed})
      : super(key: key);
  final Key key;

  final Widget child;
  final AnimalFeed feed;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: Colors.white,
      elevation: 5.0,
      onPressed: this.onPressed,
      shape: CircleBorder(),
      padding: padding,
      child: child,
    );
  }
}

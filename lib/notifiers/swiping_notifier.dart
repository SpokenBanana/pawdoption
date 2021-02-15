import 'package:flutter/widgets.dart';

enum Swiped { left, right, undo, none }

/// Lets the swiping page know when something was swiped on. Helpful for
/// allowing buttons to mimick a swiping action.
class SwipeNotifier extends ChangeNotifier {
  Swiped swiped = Swiped.none;

  likeCurrent() {
    swiped = Swiped.right;
    notifyListeners();
  }

  skipCurrent() {
    swiped = Swiped.left;
    notifyListeners();
  }

  undo() {
    swiped = Swiped.undo;
    notifyListeners();
  }
}

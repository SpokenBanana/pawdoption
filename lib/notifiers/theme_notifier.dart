import 'package:flutter/widgets.dart';

/// Lets the app know when the theme was updated.
/// Listeners:
/// * Main app
/// * PetButtons
/// * Swiping cards
/// * Details
class ThemeNotifier extends ChangeNotifier {
  bool lightModeEnabled;

  ThemeNotifier() {
    lightModeEnabled = false;
  }

  setTheme(bool toLight) {
    this.lightModeEnabled = toLight;
    notifyListeners();
  }
}

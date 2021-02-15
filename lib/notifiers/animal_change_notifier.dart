import 'package:flutter/widgets.dart';

/// Lets the settings page know when the user has changed the animal type they
/// want to search for. Useful to let the breed search widget start searching
/// through the correct breed list for the new animal type.
class AnimalChangeNotifier extends ChangeNotifier {
  String animalType;
  AnimalChangeNotifier({this.animalType});

  changeAnimal(String animal) {
    this.animalType = animal;
    notifyListeners();
  }
}

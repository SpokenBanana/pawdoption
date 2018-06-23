import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'animals.dart';
import 'petfinder_lib/petfinder.dart';

/// The main interface the app uses to get pet information.
/// Made this extra layer so we can switch APIs and keep the same
/// expected functionality.
class AnimalFeed {
  List<Animal> currentList;
  List<Animal> liked;
  Queue<Animal> skipped;
  String zip, animalType;
  int miles, _undoMax = 20;
  SwipeNotifier notifier;

  int fetchMoreAt, serveLimit, storeLimit;
  bool done, reloadFeed;

  PetAPI petApi;

  Animal get currentPet => currentList.last;
  Animal get nextPet {
    if (currentList.length < 2) return null;
    return currentList[currentList.length - 2];
  }

  AnimalFeed() {
    this.zip = '';
    this.miles = -1;
    notifier = SwipeNotifier();

    petApi = PetFinderApi();

    this.fetchMoreAt = 5;
    this.reloadFeed = false;

    // Amount to store in this class (reduce number of calls to website at the
    // sacrafice of mememory).
    this.storeLimit = 50;

    this.skipped = Queue<Animal>();
    this.currentList = List<Animal>();
    this.done = false;
    this.reloadFeed = false;
  }

  List<Animal> _toAnimalList(List<String> reprs) {
    return reprs.map((repr) => Animal.fromString(repr)).toList();
  }

  Future<bool> reInitialize() async {
    return await this.initialize(this.zip, this.miles);
  }

  removeCurrentPet() {
    currentList.removeLast();
  }

  Future<bool> initialize(String zip, int miles, {String animalType}) async {
    this.zip = zip;
    this.miles = miles;
    this.animalType = animalType;

    this.currentList = List<Animal>();
    this.skipped = Queue<Animal>();

    var prefs = await SharedPreferences.getInstance();
    this.liked = _toAnimalList(prefs.getStringList('liked') ?? List<String>());

    await petApi.setLocation(zip, miles, animalType: animalType);
    this.currentList = await petApi.getAnimals(this.storeLimit, this.liked);
    this.currentList.shuffle();
    this.done = true;
    return true;
  }

  void updateList() {
    print('running this: ${this.currentList.length}');
    if (this.currentList.length <= this.fetchMoreAt) {
      petApi.getAnimals(25, this.liked).then((list) {
        list.shuffle();
        this.currentList.insertAll(0, list);
      });
    }
  }

  void skip(Animal pet) {
    if (this.skipped.length == _undoMax) this.skipped.removeFirst();
    this.skipped.addLast(pet);
  }

  void getRecentlySkipped() {
    if (this.skipped.isNotEmpty)
      this.currentList.add(this.skipped.removeLast());
  }
}

Future<List<String>> getDetailsAbout(Animal animal) async {
  List<String> info = await PetFinderApi.getAnimalDetails(animal);
  return info;
}

Future<ShelterInformation> getShelterInformation(String location) async {
  ShelterInformation info = await PetFinderApi.getShelterInformation(location);
  return info;
}

enum Swiped { left, right, undo, none }

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

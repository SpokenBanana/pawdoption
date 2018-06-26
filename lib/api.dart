import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'animals.dart';
import 'petfinder_lib/petfinder.dart';
import 'protos/pet_search_options.pb.dart';

final kDefaultOptions = PetSearchOptions()
  ..fixedOnly = false
  ..includeBreeds = true
  ..animalType = "dog";

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
  PetSearchOptions searchOptions;

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
    searchOptions = kDefaultOptions;

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
    var searchString = prefs.getString('searchOptions');
    this.searchOptions = searchString != null
        ? PetSearchOptions.fromJson(searchString)
        : kDefaultOptions;

    await petApi.setLocation(zip, miles, animalType: animalType);
    var amount = searchOptions == kDefaultOptions ? this.storeLimit : 25;
    this.currentList = await petApi.getAnimals(amount, this.liked,
        searchOptions: this.searchOptions);
    this.currentList.shuffle();
    this.done = true;
    return true;
  }

  void updateList() {
    print('running this: ${this.currentList.length}');
    if (this.currentList.length <= this.fetchMoreAt) {
      petApi
          .getAnimals(25, this.liked, searchOptions: this.searchOptions)
          .then((list) {
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

Future<List<String>> getBreedList(String animal) async {
  return await PetFinderApi.getBreeds(animal);
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

// TODO: This is probably overkill for our purposes so maybe find a better
//       way to do this.
class AnimalChangeNotifier extends ChangeNotifier {
  String animalType;
  AnimalChangeNotifier({this.animalType});

  changeAnimal(String animal) {
    this.animalType = animal;
    notifyListeners();
  }
}

import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'animals.dart';
import 'petfinder_lib/petfinder.dart';

/// The main interface the app uses to get pet information.
/// Made this extra layer so we can switch APIs and keep the same
/// expected functionality.
class AnimalFeed {
  List<Animal> currentList, storeList;
  List<Animal> liked;
  Queue<Animal> skipped;
  String zip, animalType;
  int miles, _undoMax = 20;

  int fetchMoreAt, serveLimit, storeLimit;
  bool done;

  PetAPI petApi;

  AnimalFeed() {
    this.zip = '';
    this.miles = -1;

    petApi = PetFinderApi();

    this.fetchMoreAt = 3;

    // Amount to send to front-end.
    this.serveLimit = 5;

    // Amount to store in this class (reduce number of calls to website at the
    // sacrafice of mememory).
    this.storeLimit = 50;

    this.skipped = Queue<Animal>();
    this.currentList = List<Animal>();
    this.storeList = List<Animal>();
    this.done = false;
  }

  List<Animal> _toAnimalList(List<String> reprs) {
    return reprs.map((repr) => Animal.fromString(repr)).toList();
  }

  Future<bool> initialize(String zip, int miles, {String animalType}) async {
    this.zip = zip;
    this.miles = miles;
    this.animalType = animalType;
    this.currentList = List<Animal>();
    this.storeList = List<Animal>();
    var prefs = await SharedPreferences.getInstance();
    this.liked = _toAnimalList(prefs.getStringList('liked') ?? List<String>());
    await petApi.setLocation(zip, miles, animalType: animalType);
    this.storeList = await petApi.getAnimals(this.storeLimit, this.liked);
    this.storeList.shuffle();
    this.currentList.addAll(this.storeList.sublist(0, this.serveLimit));
    this.storeList = this.storeList.sublist(this.serveLimit);
    this.done = true;
    return true;
  }

  void updateList() {
    print('running this: ${this.currentList.length}');
    if (this.currentList.length <= this.fetchMoreAt &&
        this.storeList.isNotEmpty) {
      num currentSize =
          min(this.serveLimit - this.currentList.length, this.storeList.length);
      this.currentList.insertAll(0, this.storeList.sublist(0, currentSize));
      this.storeList = this.storeList.sublist(currentSize);
      if (this.storeList.length <= this.serveLimit) {
        petApi
            .getAnimals(this.storeLimit - this.storeList.length, this.liked)
            .then((list) {
          list.shuffle();
          this.storeList.addAll(list);
        });
      }
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

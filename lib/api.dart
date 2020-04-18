import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'animals.dart';
import 'petfinder_lib/petfinder.dart';
import 'protos/pet_search_options.pb.dart';

final kDefaultOptions = PetSearchOptions()
  ..fixedOnly = false
  ..includeBreeds = true
  ..maxDistance = 50
  ..animalType = "dog";

/// The main interface the app uses to get pet information.
/// Made this extra layer so we can switch APIs and keep the same
/// expected functionality.
class AnimalFeed {
  List<Animal> currentList;
  List<Animal> liked;
  Queue<Animal> skipped;
  String zip, animalType;
  int miles;
  SwipeNotifier notifier;

  final int fetchMoreAt = 5, storeLimit = 25, _undoMax = 20;
  bool done, reloadFeed, geoLocationEnabled = false;
  double userLat, userLng;

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

    this.skipped = Queue<Animal>();
    this.liked = List<Animal>();
    this.currentList = List<Animal>();
    this.done = false;
    this.reloadFeed = false;
  }

  Future<bool> reInitialize() async {
    return await this.initialize(this.zip,
        animalType: this.animalType, options: this.searchOptions);
  }

  removeCurrentPet() {
    currentList.removeLast();
  }

  Future<bool> initialize(String zip,
      {String animalType, PetSearchOptions options}) async {
    this.reloadFeed = false;
    this.done = false;
    this.zip = zip;
    this.animalType = animalType;

    this.currentList = List<Animal>();
    this.skipped = Queue<Animal>();

    this.searchOptions = options ?? kDefaultOptions;
    miles = this.searchOptions.maxDistance;

    await petApi.setLocation(zip, miles,
        animalType: animalType, lat: userLat, lng: userLng);
    var amount = searchOptions == kDefaultOptions ? this.storeLimit : 25;
    this.currentList = await petApi.getAnimals(amount, this.liked,
        searchOptions: this.searchOptions,
        usrLat: this.userLat,
        userLng: this.userLng);
    this.currentList.shuffle();
    this.done = true;
    return true;
  }

  void updateList() {
    if (this.currentList.length <= this.fetchMoreAt) {
      petApi
          .getAnimals(25, this.liked,
              searchOptions: this.searchOptions,
              usrLat: this.userLat,
              userLng: this.userLng)
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

  void storeCurrentlyLikedList() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList("liked", liked.map((pet) => pet.toString()).toList());
    });
  }

  void loadLiked() async {
    var prefs = await SharedPreferences.getInstance();
    this.liked = prefs
            .getStringList('liked')
            ?.map((str) => Animal.fromString(str))
            ?.toList() ??
        [];
  }
}

Future<String> getZipFromGeo() async {
  var location = Location();
  try {
    var currentLocation = await location.getLocation();
    final userLat = currentLocation['latitude'];
    final userLng = currentLocation['longitude'];
    final coords = Coordinates(userLat, userLng);
    var address = await Geocoder.local.findAddressesFromCoordinates(coords);
    return address.first.postalCode;
  } on Exception {
    return null;
  }
}

Future<String> getDetailsAbout(Animal animal) async =>
    await PetFinderApi.getAnimalDetails(animal);

Future<ShelterInformation> getShelterInformation(String location) async =>
    await PetFinderApi.getShelterInformation(location);

Future<List<String>> getBreedList(String animal) async =>
    await PetFinderApi.getBreeds(animal);

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

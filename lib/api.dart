import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:petadopt/sql_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

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
  LikedDb likedDb;
  Set<String> liked;
  Queue<Animal> skipped;

  String zip;
  SwipeNotifier notifier;

  final int fetchMoreAt = 5, storeLimit = 25, _undoMax = 20;
  bool reloadFeed;

  PetFinderApi petApi;
  PetSearchOptions searchOptions;

  List<Animal> currentList;
  Animal get currentPet => currentList.last;
  Animal get nextPet {
    if (currentList.length < 2) return null;
    return currentList[currentList.length - 2];
  }

  AnimalFeed() {
    this.zip = '';
    notifier = SwipeNotifier();

    petApi = PetFinderApi();
    searchOptions = kDefaultOptions;

    this.skipped = Queue<Animal>();
    this.liked = Set<String>();
    this.currentList = List<Animal>();
    this.reloadFeed = false;
    this.likedDb = new LikedDb();
  }

  Future<bool> reInitialize() async {
    return await this.initialize(this.zip, options: this.searchOptions);
  }

  removeCurrentPet() {
    currentList.removeLast();
  }

  Future<bool> initialize(String zip,
      {String animalType, PetSearchOptions options}) async {
    this.reloadFeed = false;
    this.zip = zip;

    this.currentList = List<Animal>();
    this.skipped = Queue<Animal>();

    this.searchOptions = options ?? kDefaultOptions;

    await petApi.setLocation(zip, this.searchOptions.maxDistance,
        animalType: animalType);
    var amount = searchOptions == kDefaultOptions ? this.storeLimit : 25;
    this.currentList = await petApi.getAnimals(amount, this.liked,
        searchOptions: this.searchOptions);
    this.currentList.shuffle();
    return true;
  }

  void maybeFetchMoreAnimals() {
    if (this.currentList.length <= this.fetchMoreAt) {
      petApi
          .getAnimals(25, this.liked, searchOptions: this.searchOptions)
          .then((result) {
        result.shuffle();
        this.currentList.insertAll(0, result);
      });
    }
  }

  void skip() {
    Animal pet = currentList.removeLast();
    if (this.skipped.length == _undoMax) this.skipped.removeFirst();
    this.skipped.addLast(pet);
    this.maybeFetchMoreAnimals();
  }

  void getRecentlySkipped() {
    if (this.skipped.isNotEmpty)
      this.currentList.add(this.skipped.removeLast());
  }

  Future removeFromLiked(Animal dog) async {
    liked.remove(dog.info.apiId);
    await likedDb.delete(dog);
  }

  void like() {
    Animal current = currentList.removeLast();
    if (!liked.contains(current.info.apiId)) {
      liked.add(current.info.apiId);
      likedDb.insert(current);
    }
    this.maybeFetchMoreAnimals();
  }

  void updatePet(Animal pet) {
    this.likedDb.update(pet);
  }

  Future loadLiked() async {
    var databasesPath = await getDatabasesPath();
    String path = '$databasesPath/demo.db';
    await this.likedDb.open(path);

    // Check if we have previously saved pets in SharedPreferences.
    // This is because I used to store the saved pets list in SharedPreferences,
    // but I moved it to a SQL database to allow for more pets stored.
    var prefs = await SharedPreferences.getInstance();
    var fromPrefs = prefs.getStringList('liked');
    if (fromPrefs != null) {
      this.syncSharedPreferences(fromPrefs);
      prefs.remove('liked');
    }

    this.liked = (await this.likedDb.getAll())
            ?.map((animal) => animal.info.apiId)
            ?.toSet() ??
        Set<String>();
  }

  // Just in case some users still have some saved pets, here migrate them to
  // the new database and delete it. Once metrics show no apps installed before
  // update 1.5, then we can remove this.
  void syncSharedPreferences(List<String> fromShared) {
    for (String repr in fromShared) {
      this.likedDb.insert(Animal.fromString(repr));
    }
  }
}

Future<String> getZipFromGeo() async {
  var location = Location();
  try {
    var currentLocation = await location.getLocation();
    final userLat = currentLocation.latitude;
    final userLng = currentLocation.longitude;
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

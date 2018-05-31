import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import 'animals.dart';
import 'petharbor_lib/petharbor.dart';
import 'petfinder_lib/petfinder.dart';
import 'constants.dart';

/// The main interface the app uses to get pet information.
/// Made this extra layer so we can switch APIs and keep the same
/// expected functionality.
class AnimalFeed {
  List<Animal> currentList, storeList;
  List<String> liked, skipped;
  String zip, animalType;
  int miles;

  int fetchMoreAt, serveLimit, storeLimit;
  bool done;

  PetAPI petApi;

  AnimalFeed() {
    this.zip = '';
    this.miles = -1;

    // Not needed anymore, used to be used to decide which one is best.
    if (kUsePetHarbor)
      petApi = PetHarborApi();
    else
      petApi = PetFinderApi();

    this.fetchMoreAt = 3;

    // Amount to send to front-end.
    this.serveLimit = 10;

    // Amount to store in this class (reduce number of calls to website at the
    // sacrafice of mememory).
    this.storeLimit = 40;

    this.currentList = List<Animal>();
    this.storeList = List<Animal>();
    this.done = false;
  }

  Future<bool> initialize(String zip, int miles, {String animalType}) async {
    this.zip = zip;
    this.miles = miles;
    this.animalType = animalType;
    this.currentList = List<Animal>();
    this.storeList = List<Animal>();
    var prefs = await SharedPreferences.getInstance();
    var liked = prefs.getStringList('liked') ?? List<String>();
    if (liked.isNotEmpty) {
      var parts = liked[0].split('|');
      if (kUsePetHarbor) {
        if (parts[8] != '') {
          print('reseting list');
          liked = List<String>();
          prefs.setStringList('liked', liked);
        }
      } else {
        if (parts[8] == '') {
          print('reseting list');
          liked = List<String>();
          prefs.setStringList('liked', liked);
        }
      }
    }
    this.liked = liked == null ? List<String>() : liked;
    await petApi.setLocation(zip, miles, animalType: animalType);
    this.storeList =
        await petApi.getAnimals(this.storeLimit, this.liked.toList());
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
}

Future<List<String>> getDetailsAbout(Animal animal) async {
  List<String> info = kUsePetHarbor
      ? await PetHarborApi.getAnimalDetails(animal)
      : await PetFinderApi.getAnimalDetails(animal);
  return info;
}

Future<ShelterInformation> getShelterInformation(String location) async {
  ShelterInformation info = kUsePetHarbor
      ? await PetHarborApi.getShelterInformation(location)
      : await PetFinderApi.getShelterInformation(location);
  return info;
}

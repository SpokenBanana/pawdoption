import 'dart:async';
import 'dart:math';

import 'package:quiver/core.dart';
import 'package:vector_math/vector_math.dart';

import 'protos/animals.pb.dart';
import 'protos/pet_search_options.pb.dart';

/// Used as sort of an abstract class. Probably a better way of doing this.
/// This is so that if another API is found to be better or the current
/// API stops working, then we can switch APIs without being so dependent
/// on how one API works.
class PetAPI {
  void setLocation(String zip, int miles,
      {String animalType, double lat, double lng}) {}
  // ignore: missing_return
  Future<List<Animal>> getAnimals(int amount, List<Animal> toSkip,
      {PetSearchOptions searchOptions, double usrLat, double userLng}) {}
  // ignore: missing_return
  static Future<List<String>> getAnimalDetails(Animal animal) {}
  // ignore: missing_return
  static Future<ShelterInformation> getShelterInformation(String location) {}
}

class Animal {
  AnimalData info;
  String description;
  DateTime lastUpdated;
  bool spayedNeutered = false,
      hasShots = false,
      specialNeeds = false,
      noKids = false;

  Animal({AnimalData info, String description}) {
    if (info != null)
      this.info = info;
    else
      this.info = AnimalData.create();
    this.description = description;
  }

  factory Animal.fromString(String animalStr) {
    try {
      Animal pet = Animal(info: AnimalData.fromJson(animalStr));
      return pet;
    } catch (Exception) {}

    // Support old way of serializing, which was a very bad idea.
    List<String> parts = animalStr.split('|');
    Animal pet = Animal();
    pet.info.name = parts[0];
    pet.info.gender = parts[1];
    pet.info.color = parts[2];
    pet.info.breed = parts[3];
    pet.info.age = parts[4];
    pet.info.lastUpdated = parts[5];
    pet.info.imgUrl.add(parts[7]);
    pet.info.apiId = parts[8];
    pet.info.shelterId = parts[9];
    pet.info.id = parts[10];
    if (parts.length > 11 && parts[11] != '') {
      pet.info.options.addAll(parts[11].split(','));
    }
    return pet;
  }

  String toString() {
    return info.writeToJson();
  }

  void readAttributes(dynamic attributes) {
    specialNeeds = attributes['special_needs'] == 'true';
    hasShots = attributes['shots_current'] == 'true';
    spayedNeutered = attributes['spayed_neutered'] == 'true';
  }

  bool operator ==(other) {
    return other is Animal && other.info.apiId == this.info.apiId;
  }

  int get hashCode => this.info.apiId.hashCode;
}

class ShelterInformation {
  String name, phone, location, id, email;
  double lat, lng;
  int distance = -1;

  ShelterInformation(name, phone, location, {this.lat, this.lng}) {
    this.name = name;
    this.phone = phone;
    this.location = location;
  }

  ShelterInformation.fromApi(dynamic response) {
    var address = response['address']['address1'] ?? '';
    var city = response['address']['city'];
    var zip = response['address']['postcode'];
    var state = response['address']['state'];
    this.location = '$address $city, $state. $zip';
    this.phone = response['phone'] ?? '';
    this.name = response['name'];
    this.id = response['id'];
    if (response['distance'] != null) {
      this.distance = response['distance'].round();
    }
    if (response['email'] != null) {
      this.email = response['email'];
    }
  }

  computeDistanceFrom(lat1, lng1) {
    lat1 = radians(lat1);
    lng1 = radians(lng1);
    lat = radians(lat);
    lng = radians(lng);
    const R = 3959;
    final x = (lng1 - lng) * cos(0.5 * (lat1 + lat));
    final y = lat1 - lat;
    distance = (R * sqrt((x * x) + (y * y))).round();
  }
}

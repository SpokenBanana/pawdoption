import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../animals.dart';
import 'credentials.dart';
import 'utils.dart';

/// We want this class to serve as the communication between the PetFinder API
/// and the front-end. Some things it has to do.
///
///   * Get pets of a certain type(s) sorted by this criteria
///
/// Types:
///   * Animals (one or more)
///   * Breed (Can select for each animal type)
///   * Age restriction?
///   * Shelter
///
/// Sorting criteria
///   * Last updated
///   * Age
///

PetSearchOptions kDefaultSearchOptions = PetSearchOptions(
    animalType: 'dog',
    breed: '',
    ages: <String>[],
    sizes: <String>[],
    sex: '',
    zip: '',
    shelters: Set.from(<String>[]));

class PetSearchOptions {
  String animalType;
  String breed;
  String sex;
  String zip;
  List<String> ages;
  List<String> sizes;
  // This could be pretty big, so we want to optimize searches in this field.
  Set<String> shelters;

  PetSearchOptions(
      {this.animalType,
      this.breed,
      this.ages,
      this.sizes,
      this.sex,
      this.zip,
      this.shelters});

  String toString() {
    return '$animalType|$breed|${ages.join(',')}|${sizes.join(',')}';
  }
}

class PetFinderSearch {
  int _offset;

  PetFinderSearch() {
    _offset = 0;
  }

  void resetSearch() {
    _offset = 0;
  }

  Future<List<Animal>> searchFor(PetSearchOptions options,
      {int amount = 25}) async {
    List<Animal> animals = List<Animal>();
    // TODO: Remove this, just here in case there is a bug and this loop runs
    //       infinitely.
    int x = 0;
    while (animals.length < amount && x < 5) {
      x++;
      var params = _buildParams(options, _offset, amount);
      var response = await http.get(buildUrl('/pet.find', params));
      var petList = json.decode(utf8.decode(response.bodyBytes));
      for (Map pet in petList['petfinder']['pets']['pet']) {
        animals.add(toAnimal(pet));
      }
      _offset += amount;

      // Manually filter now.
      animals = animals.where((animal) {
        if (options.ages.isNotEmpty && !options.ages.contains(animal.age))
          return false;
        if (options.sizes.isNotEmpty && !options.sizes.contains(animal.size))
          return false;
        if (options.shelters.isNotEmpty &&
            !options.shelters.contains(animal.shelter)) return false;
        return true;
      }).toList();
    }
    return animals;
  }

  Future<List<String>> getBreedList(String animal) async {
    var response = await http.get(buildUrl('/breed.list',
        {'key': kPetFinderToken, 'animal': animal, 'format': 'json'}));
    var breedMap = json.decode(response.body);
    List<String> breeds = List<String>();
    for (Map breed in breedMap['petfinder']['breeds']['breed']) {
      breeds.add(breed['\$t']);
    }
    return breeds;
  }

  // Can probably get this from the PetFinderAPI class?
  Future<List<ShelterInformation>> getShelterList(String zip) async {
    Map<String, String> params = {
      'key': kPetFinderToken,
      'location': zip,
      'output': 'full',
      'format': 'json'
    };
    var response = await http.get(buildUrl('/shelter.find', params));
    Map data = json.decode(response.body);
    List<ShelterInformation> shelters = List<ShelterInformation>();
    for (Map shelter in data['petfinder']['shelters']['shelter']) {
      shelters.add(toShelterInformation(shelter));
    }
    return shelters;
  }

  Map<String, String> _buildParams(
      PetSearchOptions options, int offset, int amount) {
    Map<String, String> params = {
      'key': kPetFinderToken,
      'animal': options.animalType,
      'location': options.zip,
      'output': 'full',
      'format': 'json'
    };

    if (options.breed != '') params['breed'] = options.breed;
    if (options.sex != '') params['sex'] = options.sex;

    return params;
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../animals.dart';
import '../protos/pet_search_options.pb.dart';
import 'credentials.dart';
import 'utils.dart';

const String kUrlRegex = r'(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]'
    r'{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)';

ApiClient kClient = new ApiClient();

/// Uses PetFinder API to get animals using the standard API interface defined
/// in 'animals.dart'.
class PetFinderApi implements PetAPI {
  String _zip, _animalType;

  // We want to limit the API calls for this one, so caching is key.
  // TODO: Making this static is a bit of bad practice, try to find an
  //       alternative solution
  static Map<String, ShelterInformation> _shelterCache;

  int _currentOffset = 1;

  void setLocation(String zip, int miles,
      {String animalType, double lat, double lng}) async {
    _currentOffset = 1;
    _shelterCache = Map<String, ShelterInformation>();
    _animalType = animalType;
    Map<String, String> params = {
      'location': zip,
      'distance': '$miles',
      'limit': '50',
    };
    print('$zip');
    print('$miles');
    _zip = zip;
    var data = await kClient.fetch('organizations', params);
    for (Map shelter in data['organizations']) {
      String id = shelter['id'];
      if (!_shelterCache.containsKey(id))
        _shelterCache[id] =
            toShelterInformation(shelter, usrlat: lat, usrlng: lng);
    }
  }

  Future<List<Animal>> getAnimals(int amount, List<Animal> toSkip,
      {PetSearchOptions searchOptions, double usrLat, double userLng}) async {
    List<Animal> animals = List<Animal>();
    Map<String, String> params = {
      'type': _animalType != null ? _animalType : 'dog',
      'location': _zip,
      'limit': '$amount',
      'status': 'adoptable',
      'page': _currentOffset.toString(),
    };
    if (searchOptions != null)
      params.addAll(_buildParamsFromOptions(searchOptions));

    _currentOffset++;

    var jsonResponse = await kClient.fetch('animals', params);
    var petList = jsonResponse['animals'];

    for (Map pet in petList) {
      Animal animal = toAnimal(pet);
      if (!toSkip.contains(animal)) {
        animals.add(animal);
      }
    }
    return animals;
  }

  _buildParamsFromOptions(PetSearchOptions options) {
    Map<String, String> params = Map<String, String>();
    if (options.includeBreeds && options.breeds.isNotEmpty) {
      params['breed'] = options.breeds.join(',');
    }
    params['distance'] = options.maxDistance.toString();
    if (options.hasSex()) params['gender'] = options.sex;
    if (options.ages.isNotEmpty) params['age'] = options.ages.join(',');
    if (options.sizes.isNotEmpty) params['size'] = options.sizes.join(',');
    return params;
  }

  static Future<List<String>> getBreeds(String animalType) async {
    Map<String, String> params = {
      'key': kPetFinderToken,
    };
    var response = await kClient.fetch('types/$animalType/breeds', params);
    var breeds = response['breeds'];
    List<String> list = List<String>();
    for (String name in breeds.map((breed) => breed['name'])) {
      list.add(name);
    }
    return list;
  }

  static Future<ShelterInformation> getShelterInformation(String location,
      {double lat, double lng}) async {
    print('$location');
    print(_shelterCache.keys.toString());
    if (_shelterCache.containsKey(location)) return _shelterCache[location];
    var response = await kClient.fetch('organizations/$location', {});
    var shelterMap = response['organization'];
    // Cache it to not make this API call again.
    ShelterInformation shelter =
        toShelterInformation(shelterMap, usrlat: lat, usrlng: lng);
    _shelterCache[location] = shelter;
    return shelter;
  }

  static Future<String> getAnimalDetails(Animal animal) async {
    if (animal.description == null) {
      // Re-fetch the data.
      var response = await kClient.fetch('animals/${animal.info.apiId}', {});
      var petDoc = response['animal'];
      var description = petDoc['description'];
      if (description.isEmpty) {
        description = 'No comments.';
      } else {
        // Try to resolve some encoding issues.
        // Somethings this fails, if it does then we just have to deal with it.
        try {
          description = utf8.decode(Latin1Codec().encode(description));
        } catch (Exception) {}
      }

      // Cache it so that we don't have to make this API call multiple times.
      animal.description = description;

      // Update the rest of the pet information
      var lastUpdated = petDoc['published_at'];
      if (lastUpdated != animal.info.lastUpdated) {
        animal.info.options.clear();
        for (String item in petDoc['tags']) {
          animal.info.options.add(item);
        }
        animal.info.lastUpdated = lastUpdated;
        animal.info.age = petDoc['age'];
      }
      return animal.description;
    }
    return animal.description;
  }
}

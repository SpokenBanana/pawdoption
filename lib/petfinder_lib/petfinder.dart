import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../animals.dart';
import 'credentials.dart';
import 'utils.dart';

const String kUrlRegex = r'(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]'
    r'{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)';

/// Uses PetFinder API to get animals using the standard API interface defined
/// in 'animals.dart'.
class PetFinderApi implements PetAPI {
  List<String> _shelterIds;
  Map<String, String> _baseParams;
  String _zip, _animalType;

  // We want to limit the API calls for this one, so caching is key.
  // TODO: Making this static is a bit of bad practice, try to find an
  //       alternative solution
  static Map<String, ShelterInformation> _shelterCache;

  int _currentOffset;

  PetFinderApi() {
    _currentOffset = 0;
    _baseParams = {'key': kPetFinderToken, 'output': 'full', 'format': 'json'};
  }

  void setLocation(String zip, int miles, {String animalType}) async {
    _shelterIds = List<String>();
    _currentOffset = 0;
    _shelterCache = Map<String, ShelterInformation>();
    _animalType = animalType;
    Map<String, String> params = {
      'location': zip,
    };
    _zip = zip;
    params.addAll(_baseParams);
    var response = await http.get(buildUrl('/shelter.find', params));
    Map data = json.decode(response.body);
    for (Map shelter in data['petfinder']['shelters']['shelter']) {
      String id = shelter['id']['\$t'];
      _shelterIds.add(id);
      _shelterCache[id] = toShelterInformation(shelter);
    }
  }

  Future<List<Animal>> getAnimals(int amount, List<String> toSkip) async {
    List<Animal> animals = List<Animal>();
    while (animals.length < amount) {
      Map<String, String> params = {
        'animal': _animalType != null ? _animalType : 'dog',
        'location': _zip,
        'output': 'full',
        'offset': _currentOffset.toString(),
      };
      params.addAll(_baseParams);
      _currentOffset += 25; // The default count for the API.

      var response = await http.get(buildUrl('/pet.find', params));
      var petList = json.decode(utf8.decode(response.bodyBytes))['petfinder']
          ['pets']['pet'];

      if (petList == null) break;
      for (Map pet in petList) {
        Animal animal = toAnimal(pet);
        if (!toSkip.contains(animal.toString())) animals.add(animal);
      }
    }

    return animals;
  }

  static Future<ShelterInformation> getShelterInformation(
      String location) async {
    if (_shelterCache.containsKey(location)) return _shelterCache[location];
    Map<String, String> params = {
      'key': kPetFinderToken,
      'id': location,
      'format': 'json'
    };
    var response = await http.get(buildUrl('/shelter.get', params));
    var shelterMap = json.decode(response.body)['petfinder']['shelter'];
    // Cache it to not make this API call again.
    ShelterInformation shelter = toShelterInformation(shelterMap);
    _shelterCache[location] = shelter;
    return shelter;
  }

  static Future<List<String>> getAnimalDetails(Animal animal) async {
    List<String> results = List<String>();
    if (animal.description == '' || animal.description == null) {
      // Re-fetch the data.
      Map<String, String> params = {
        'key': kPetFinderToken,
        'id': animal.apiId,
        'format': 'json',
      };
      var response = await http.get(buildUrl('/pet.get', params));
      var petDoc = json.decode(utf8.decode(response.bodyBytes));
      Map descMap = petDoc['petfinder']['pet']['description'];
      if (descMap.isEmpty) {
        results.add('No comments.');
      } else {
        results.add(descMap['\$t']);
        // Try to resolve some encoding issues.
        // Somethings this fails, if it does then we just have to deal with it.
        try {
          results[0] = utf8.decode(Latin1Codec().encode(results[0]));
        } catch (Exception) {}
      }

      // Cache it so that we don't have to make this API call multiple times.
      animal.description = results[0];
      // TODO: Maybe fill in the options tag while we're here? It isn't saved
      //       yet.
    } else {
      results.add(animal.description);
    }

    // Find urls since Flutter won't let us select/copy text from Text widgets.
    var urlMatches = RegExp(kUrlRegex).allMatches(results[0]);
    for (Match m in urlMatches) {
      results.add(m.group(0));
    }
    return results;
  }
}

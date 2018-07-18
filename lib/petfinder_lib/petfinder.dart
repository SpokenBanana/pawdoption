import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../animals.dart';
import '../protos/pet_search_options.pb.dart';
import 'credentials.dart';
import 'utils.dart';

const String kUrlRegex = r'(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]'
    r'{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)';

/// Uses PetFinder API to get animals using the standard API interface defined
/// in 'animals.dart'.
class PetFinderApi implements PetAPI {
  final Map<String, String> _baseParams = {
    'key': kPetFinderToken,
    'output': 'full',
    'format': 'json'
  };
  // If we have to keep fetching, then the query matces too few animals to keep
  // looking.
  final maxIterations = 5;
  String _zip, _animalType;

  // We want to limit the API calls for this one, so caching is key.
  // TODO: Making this static is a bit of bad practice, try to find an
  //       alternative solution
  static Map<String, ShelterInformation> _shelterCache;

  int _currentOffset = 0;

  void setLocation(String zip, int miles,
      {String animalType, double lat, double lng}) async {
    _currentOffset = 0;
    _shelterCache = Map<String, ShelterInformation>();
    _animalType = animalType;
    Map<String, String> params = {
      'location': zip,
      'count': '50',
    };
    _zip = zip;
    params.addAll(_baseParams);
    var response = await http.get(buildUrl('/shelter.find', params));
    Map data = json.decode(response.body);
    for (Map shelter in data['petfinder']['shelters']['shelter']) {
      String id = shelter['id']['\$t'];
      if (!_shelterCache.containsKey(id))
        _shelterCache[id] =
            toShelterInformation(shelter, usrlat: lat, usrlng: lng);
    }
  }

  /// Because of the way the API works, this method will always return the list
  /// with size that is a multiple of 25. So if amount == 15, you'll get back
  /// 25. Otherwise, we would get duplicate results.
  /// TODO: Passing the user lat, lng this way looks ugly, there is probably
  /// a better way to do this.
  Future<List<Animal>> getAnimals(int amount, List<Animal> toSkip,
      {PetSearchOptions searchOptions, double usrLat, double userLng}) async {
    List<Animal> animals = List<Animal>();
    int iterations = 0;
    const defaultCount = 25;
    while (animals.length < amount) {
      Map<String, String> params = {
        'animal': _animalType != null ? _animalType : 'dog',
        'location': _zip,
        'offset': _currentOffset.toString(),
      };
      if (searchOptions != null)
        params.addAll(_buildParamsFromOptions(searchOptions));

      params.addAll(_baseParams);
      _currentOffset += defaultCount;

      var response = await http.get(buildUrl('/pet.find', params));
      var petList = json.decode(utf8.decode(response.bodyBytes))['petfinder']
          ['pets']['pet'];

      if (petList == null) break;
      for (Map pet in petList) {
        Animal animal = toAnimal(pet);
        if (!toSkip.contains(animal) &&
            (searchOptions == null ||
                await _shouldKeep(searchOptions, animal,
                    lat: usrLat, lng: userLng))) {
          animals.add(animal);
        }
      }

      iterations++;
      // This means we reached the end of the search query.
      if (petList.length < defaultCount) break;
      if (iterations >= maxIterations) break;
    }
    return animals;
  }

  Future<bool> _shouldKeep(PetSearchOptions options, Animal pet,
      {double lat, double lng}) async {
    if (options.ages.length > 1 && !options.ages.contains(pet.info.age))
      return false;
    if (options.sizes.length > 1 && !options.sizes.contains(pet.info.size))
      return false;
    if (options.fixedOnly && !pet.info.options.contains("altered"))
      return false;
    if (!options.includeBreeds || options.breeds.length > 1) {
      var found = !options.includeBreeds;
      for (String breed in options.breeds) {
        if (pet.breeds.contains(breed)) {
          if (options.includeBreeds) {
            found = true;
            break;
          } else {
            return false;
          }
        }
      }
      if (!found) return false;
    }
    ShelterInformation shelter = await PetFinderApi
        .getShelterInformation(pet.info.shelterId, lat: lat, lng: lng);
    // Shelter opted out to give informaiton if it is null.
    if (shelter != null) {
      int distance = shelter.distance;
      if (distance != -1 && distance > options.maxDistance) {
        return false;
      }
    } else {
      // TODO: Only return false if the geoLocation is enabled, otherwise
      // just include the pet.
      return false;
    }

    if (options.selectedShelters.isNotEmpty &&
        !options.selectedShelters.contains(pet.info.shelterId)) return false;
    return true;
  }

  _buildParamsFromOptions(PetSearchOptions options) {
    Map<String, String> params = Map<String, String>();
    if (options.includeBreeds && options.breeds.length == 1) {
      params['breed'] = options.breeds[0];
    }
    if (options.hasSex()) params['sex'] = options.sex;
    if (options.ages.length == 1) params['age'] = options.ages[0];
    if (options.sizes.length == 1) params['size'] = options.sizes[0];
    return params;
  }

  static Future<List<String>> getBreeds(String animalType) async {
    Map<String, String> params = {
      'key': kPetFinderToken,
      'animal': animalType,
      'format': 'json',
    };
    var response = await http.get(buildUrl('/breed.list', params));
    var breeds = json.decode(response.body)['petfinder']['breeds']['breed'];
    List<String> list = List<String>();
    for (String item in breeds.map((breed) => breed['\$t'])) {
      list.add(item);
    }
    return list;
  }

  static Future<ShelterInformation> getShelterInformation(String location,
      {double lat, double lng}) async {
    if (_shelterCache.containsKey(location)) return _shelterCache[location];
    Map<String, String> params = {
      'key': kPetFinderToken,
      'id': location,
      'format': 'json'
    };
    var response = await http.get(buildUrl('/shelter.get', params));
    var shelterMap = json.decode(response.body)['petfinder']['shelter'];
    // Cache it to not make this API call again.
    ShelterInformation shelter =
        toShelterInformation(shelterMap, usrlat: lat, usrlng: lng);
    _shelterCache[location] = shelter;
    return shelter;
  }

  static Future<String> getAnimalDetails(Animal animal) async {
    if (animal.description == null) {
      // Re-fetch the data.
      Map<String, String> params = {
        'key': kPetFinderToken,
        'id': animal.info.apiId,
        'format': 'json',
      };
      var response = await http.get(buildUrl('/pet.get', params));
      var petDoc = json.decode(utf8.decode(response.bodyBytes));
      Map descMap = petDoc['petfinder']['pet']['description'];
      var description;
      if (descMap.isEmpty) {
        description = 'No comments.';
      } else {
        description = descMap['\$t'];
        // Try to resolve some encoding issues.
        // Somethings this fails, if it does then we just have to deal with it.
        try {
          description = utf8.decode(Latin1Codec().encode(description));
        } catch (Exception) {}
      }

      // Cache it so that we don't have to make this API call multiple times.
      animal.description = description;

      // Update the rest of the pet information
      var lastUpdated = petDoc['petfinder']['pet']['lastUpdate']['\$t'];
      if (lastUpdated != animal.info.lastUpdated) {
        animal.info.options
            .addAll(Animal.parseOptions(petDoc['petfinder']['pet']['options']));
        animal.info.lastUpdated = lastUpdated;
        animal.info.age = petDoc['petfinder']['pet']['age']['\$t'];
      }
      return animal.description;
    }
    return animal.description;
  }
}

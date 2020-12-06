import 'dart:async';

import '../animals.dart';
import '../protos/pet_search_options.pb.dart';
import 'credentials.dart';
import 'utils.dart';

const String kUrlRegex =
    r'(https?|ftp)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?';

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
    _zip = zip;
    var data = await kClient.fetch('organizations', params);
    for (Map shelter in data['organizations']) {
      String id = shelter['id'];
      if (!_shelterCache.containsKey(id))
        _shelterCache[id] =
            toShelterInformation(shelter, usrlat: lat, usrlng: lng);
    }
  }

  Future<List<Animal>> getAnimals(int amount, Set<String> toSkip,
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
      if (!toSkip.contains(animal.info.apiId)) {
        animals.add(animal);
      }
    }
    return animals;
  }

  _buildParamsFromOptions(PetSearchOptions options) {
    Map<String, String> params = Map<String, String>();
    if (options.includeBreeds && options.breeds.isNotEmpty) {
      params['breed'] = listToParamValue(options.breeds);
    }

    if (options.goodWithCats) {
      params['good_with_cats'] = 'true';
    }
    if (options.goodWithChildren) {
      params['good_with_children'] = 'true';
    }
    if (options.goodWithDogs) {
      params['good_with_dogs'] = 'true';
    }
    if (options.coat.length > 0) {
      params['coat'] = listToParamValue(options.coat);
    }
    if (options.color.length > 0) {
      params['color'] = listToParamValue(options.color);
    }
    params['distance'] = options.maxDistance.toString();
    if (options.hasSex()) params['gender'] = options.sex;
    if (options.ages.isNotEmpty) params['age'] = listToParamValue(options.ages);
    if (options.sizes.isNotEmpty)
      params['size'] = listToParamValue(options.sizes);
    return params;
  }

  static Future<List<String>> getBreeds(String animalType) async {
    Map<String, String> params = {
      'key': kPetFinderToken,
    };
    var response = await kClient.fetch('types/$animalType/breeds', params);
    var breeds = response['breeds'];
    List<String> list = List<String>();
    list.addAll(breeds.map((breed) => breed['name']));
    return list;
  }

  static Future<ShelterInformation> getShelterInformation(String location,
      {double lat, double lng}) async {
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
    animal.info.description = await getAnimalDescriptionV1(animal.info.apiId);

    // Update the rest of the pet information if needed.
    var response = await kClient.fetch('animals/${animal.info.apiId}', {});
    var petDoc = response['animal'];
    if (animal.info.description == null) {
      animal.info.description = petDoc['description'];
    }
    animal.info.options.clear();
    for (String item in petDoc['tags']) {
      animal.info.options.add(item);
    }

    animal.info.imgUrl.clear();
    for (var img in petDoc['photos']) {
      animal.info.imgUrl.add(img['large']);
    }
    if (animal.info.imgUrl.isEmpty) {
      // TODO: Add an actual placeholder image.
      animal.info.imgUrl.add('');
    }

    // TODO: update pictures, check adoption status.
    animal.status = petDoc['status'];

    animal.info.age = petDoc['age'];
    return animal.info.description;
  }
}

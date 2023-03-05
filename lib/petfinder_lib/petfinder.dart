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
class PetFinderApi {
  String _zip = '', _animalType = '';

  // We want to limit the API calls for this one, so we'll hold on to results.
  // TODO: Making this static is a bit of bad practice, try to find an
  //       alternative solution
  static Map<String, ShelterInformation> _shelterMap = Map();

  int _currentPage = 1;

  Future setLocation(String zip, int miles, {String? animalType}) async {
    _currentPage = 1;
    _shelterMap = Map<String, ShelterInformation>();
    _animalType = animalType!;
    Map<String, String> params = {
      'location': zip,
      'distance': '$miles',
      'limit': '50',
    };
    _zip = zip;
    var data = await kClient.call('organizations', params);
    for (Map shelter in data['organizations']) {
      String id = shelter['id'];
      if (!_shelterMap.containsKey(id))
        _shelterMap[id] = toShelterInformation(shelter)!;
    }
  }

  Future<List<Animal>> getAnimals(int amount, Set<String> toSkip,
      {PetSearchOptions? searchOptions,
      double? usrLat,
      double? userLng}) async {
    List<Animal> animals = [];
    Map<String, String> params = {
      'type': _animalType.isNotEmpty ? _animalType : 'dog',
      'location': _zip,
      'limit': '$amount',
      'status': 'adoptable',
      'page': '$_currentPage',
    };
    if (searchOptions != null)
      params.addAll(_buildParamsFromOptions(searchOptions));

    _currentPage++;

    var jsonResponse = await kClient.call('animals', params);
    var petList = jsonResponse['animals'];

    for (Map pet in petList) {
      Animal animal = Animal.fromApi(pet);
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
    var response = await kClient.call('types/$animalType/breeds', params);
    var breeds = response['breeds'];
    List<String> list = [];
    for (dynamic b in breeds) {
      list.add(b['name']);
    }
    return list;
  }

  static Future<ShelterInformation> getShelterInformation(
      String location) async {
    if (_shelterMap.containsKey(location)) return _shelterMap[location]!;
    var response = await kClient.call('organizations/$location', {});
    var shelterMap = response['organization'];
    // Save it to not make this API call again.
    ShelterInformation shelter = toShelterInformation(shelterMap)!;
    _shelterMap[location] = shelter;
    return shelter;
  }

  // Returns the description of the Animal. While we make this request, we'll
  // also fetch some additional information on the pet incase something was
  // updated.
  // TODO: Refreshing information is only really necessary for saved Animals.
  static Future<String> fetchAnimalDesciption(Animal animal) async {
    // NOTE: The new API of PetFinder does not return the full description for
    // some reason. They only return a portion and then elipses. I emailed them
    // about this and they said this was intentional and would consider
    // returning the full desciption in the future, so for now just fall back
    // to the old API for the full description
    animal.info.description = await getAnimalDescriptionV1(animal.info.apiId);

    // Update the rest of the pet information if needed.
    var response = await kClient.call('animals/${animal.info.apiId}', {});

    var petDoc = response['animal'];
    // If the V1 API doesn't return anything, then we have no choice than to use
    // the short description returned in V2.
    if (animal.info.description.isEmpty) {
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

    // TODO: Update pictures, check adoption status.
    animal.status = petDoc['status'];

    animal.info.age = petDoc['age'];
    return animal.info.description;
  }
}

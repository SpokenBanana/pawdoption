import 'dart:async';
import 'package:http/http.dart' as http;
import '../animals.dart';
import 'credentials.dart';
import 'dart:convert';

const String kBaseUrl = 'api.petfinder.com';
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
    var response = await http.get(_buildUrl('/shelter.find', params));
    Map data = json.decode(response.body);
    for (Map shelter in data['petfinder']['shelters']['shelter']) {
      String id = shelter['id']['\$t'];
      _shelterIds.add(id);
      _shelterCache[id] = _toShelterInformation(shelter);
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

      var response = await http.get(_buildUrl('/pet.find', params));
      var petList = json.decode(utf8.decode(response.bodyBytes))['petfinder']
          ['pets']['pet'];

      if (petList == null) break;
      for (Map pet in petList) {
        Animal animal = _toAnimal(pet);
        if (!toSkip.contains(animal.toString())) animals.add(_toAnimal(pet));
      }
    }

    return animals;
  }

  static Future<ShelterInformation> getShelterInformation(
      String location) async {
    if (_shelterCache.containsKey(location)) {
      return _shelterCache[location];
    }
    Map<String, String> params = {
      'key': kPetFinderToken,
      'id': location,
      'format': 'json'
    };
    var response = await http.get(_buildUrl('/shelter.get', params));
    var shelterMap = json.decode(response.body)['petfinder']['shelter'];
    return _toShelterInformation(shelterMap);
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
      var response = await http.get(_buildUrl('/pet.get', params));
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

  Animal _toAnimal(Map animalData) {
    var imgUrl;
    var photoMap = animalData['media']['photos'];
    var images;
    if (photoMap != null) {
      images = animalData['media']['photos']['photo']
          .map((urlMap) => urlMap['\$t'])
          .toList();
    } else {
      images = [''];
    }
    for (var img in images) {
      // Use the biggest image, usually the one with width=500.
      if (img.contains('500')) {
        imgUrl = img;
        break;
      }
    }
    if (imgUrl == null) imgUrl = images[0];
    Map descriptionMap = animalData['description'];
    String description = descriptionMap.isEmpty
        ? "No comments available"
        : descriptionMap['\$t'];
    try {
      description = utf8.decode(Latin1Codec().encode(description));
    } catch (Exception) {}
    var breeds = animalData['breeds']['breed'];
    var breed;
    var city = animalData['contact']['city'];
    var state = animalData['contact']['state'];
    var cityState = '${city.isEmpty ? 'Unknown' : city['\$t']}, '
        '${state.isEmpty? 'Unknown' : state['\$t']}';
    if (breeds is List) {
      breed = breeds.map((breedstr) => breedstr['\$t']).join(' ');
    } else {
      breed = breeds['\$t'];
    }
    return Animal.fromPetFinder(
        animalData['name']['\$t'],
        animalData['sex']['\$t'],
        breed,
        animalData['age']['\$t'],
        imgUrl,
        animalData['shelterPetId']['\$t'],
        animalData['shelterId']['\$t'],
        animalData['id']['\$t'],
        description,
        cityState,
        animalData['lastUpdate']['\$t']);
  }
}

String _buildUrl(String method, Map<String, String> params) {
  return Uri.http(kBaseUrl, method, params).toString();
}

ShelterInformation _toShelterInformation(Map shelter) {
  if (shelter == null) {
    return null;
  }
  var address = shelter['address1'].isEmpty ? '' : shelter['address1']['\$t'];
  var city = shelter['city']['\$t'];
  var zip = shelter['zip']['\$t'];
  var state = shelter['state']['\$t'];
  var location = '$address $city, $state. $zip';
  return ShelterInformation(
    shelter['name']['\$t'],
    shelter['phone']['\$t'] ?? '',
    location,
  );
}

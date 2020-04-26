import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:petadopt/petfinder_lib/credentials.dart';

import '../animals.dart';
import '../protos/animals.pb.dart';

String buildUrl(String method, Map<String, String> params) {
  return Uri.https('api.petfinder.com', '/v2/$method', params).toString();
}

// Will make sure we make authorized requests.
class ApiClient {
  DateTime tokenExperiation;
  String token;
  ApiClient() {
    tokenExperiation = new DateTime.now();
  }

  void checkToken() async {
    if (tokenExperiation.isBefore(DateTime.now())) {
      var response = await http.post(buildUrl('oauth2/token', {}), body: {
        'grant_type': 'client_credentials',
        'client_id': '$kPetFinderToken',
        'client_secret': '$kPetFinderSecret',
      });
      var parsed = json.decode(response.body);
      tokenExperiation =
          new DateTime.now().add(new Duration(seconds: parsed['expires_in']));
      token = parsed['access_token'];
    }
  }

  dynamic fetch(String method, Map<String, String> params) async {
    await checkToken();
    var response = await http.get(buildUrl(method, params),
        headers: {'Authorization': 'Bearer $token'});
    return json.decode(utf8.decode(response.bodyBytes));
  }
}

/// For some reason, V2 isn't returning full descriptions. So, let's just
/// use the V1 API since it looks like it is still working and does return full
/// descriptions. We'll save this information once we fetch it.
Future<String> getAnimalDescriptionV1(String petId) async {
  String url = Uri.https('api.petfinder.com', 'pet.get', {
    'format': 'json',
    'output': 'full',
    'key': kV1Token,
    'id': petId,
  }).toString();
  var response = await http.get(url);
  var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
  // In case PetFinder actually shuts down this API.
  try {
    return utf8.decode(Latin1Codec()
        .encode(jsonResponse['petfinder']['pet']['description']['\$t']));
  } catch (Exception) {
    return null;
  }
}

ShelterInformation toShelterInformation(Map shelter,
    {double usrlat, double usrlng}) {
  if (shelter == null) {
    return null;
  }
  return ShelterInformation.fromApi(shelter);
}

Animal toAnimal(Map animalMap) {
  AnimalData data = AnimalData.create();

  for (var img in animalMap['photos']) {
    data.imgUrl.add(img['large']);
  }
  if (data.imgUrl.isEmpty) {
    // TODO: Add an actual placeholder image.
    data.imgUrl.add('');
  }

  // Get city state.
  var city = animalMap['contact']['address']['city'];
  var state = animalMap['contact']['address']['state'];
  data.cityState = '${city.isEmpty ? 'Unknown' : city}, '
      '${state.isEmpty ? 'Unknown' : state}';

  // Get breed.
  var breeds = animalMap['breeds'];
  List<String> breedList = List<String>();
  if (breeds['primary'] != null) {
    breedList.add(breeds['primary'].toString());
  }
  if (breeds['secondary'] != null) {
    breedList.add(breeds['secondary'].toString());
  }
  data.breed = breedList.join(' / ');
  if (breeds['unknown'] == 'true') {
    data.breed = 'Unknown';
  }

  data.name = animalMap['name'];
  data.name =
      '${data.name[0].toUpperCase()}${data.name.substring(1).toLowerCase()}';
  data.gender = animalMap['gender'];
  data.age = animalMap['age'];
  data.shelterId = animalMap['organization_id'];
  data.apiId = animalMap['id'].toString();
  data.lastUpdated = animalMap['published_at'];
  for (String item in animalMap['tags']) {
    data.options.add(item);
  }
  data.size = animalMap['size'];

  Animal pet = Animal(info: data);
  // TODO: These fields are now in AnimalData, fill it out there.
  pet.readAttributes(animalMap['attributes']);
  return pet;
}

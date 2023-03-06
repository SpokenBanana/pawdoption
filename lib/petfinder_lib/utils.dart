import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:petadopt/petfinder_lib/credentials.dart';

import '../animals.dart';

Uri buildUrl(String method, Map<String, String> params) {
  return Uri.https('api.petfinder.com', '/v2/$method', params);
}

// Will make sure we make authorized requests.
class ApiClient {
  DateTime _tokenExperiation = DateTime.now();
  String _token = '';

  Future<String> checkToken() async {
    if (_tokenExperiation.isBefore(DateTime.now())) {
      var response = await http.post(buildUrl('oauth2/token', {}), body: {
        'grant_type': 'client_credentials',
        'client_id': '$kPetFinderToken',
        'client_secret': '$kPetFinderSecret',
      });
      var parsed = json.decode(response.body);
      _tokenExperiation =
          new DateTime.now().add(new Duration(seconds: parsed['expires_in']));
      _token = parsed['access_token'];
      return _token;
    }
    return _token;
  }

  dynamic call(String method, Map<String, String> params) async {
    String token = await checkToken();
    var response = await http.get(buildUrl(method, params),
        headers: {'Authorization': 'Bearer $token'});
    return json.decode(utf8.decode(response.bodyBytes));
  }
}

/// For some reason, V2 isn't returning full descriptions. So, let's just
/// use the V1 API since it looks like it is still working and does return full
/// descriptions. We'll save this information once we fetch it.
Future<String> getAnimalDescriptionV1(String petId) async {
  Uri url = Uri.https('api.petfinder.com', 'pet.get', {
    'format': 'json',
    'output': 'full',
    'key': kV1Token,
    'id': petId,
  });
  var response = await http.get(url);
  var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
  // In case PetFinder actually shuts down this API.
  try {
    return utf8.decode(Latin1Codec()
        .encode(jsonResponse['petfinder']['pet']['description']['\$t']));
  } catch (exception) {
    return '';
  }
}

ShelterInformation? toShelterInformation(Map? shelter) {
  if (shelter == null) {
    return null;
  }
  return ShelterInformation.fromApi(shelter);
}

String listToParamValue(List<String> list) {
  return list.map((l) => l.toLowerCase()).join(',');
}

import 'dart:convert';

import '../animals.dart';

const String kBaseUrl = 'api.petfinder.com';

String buildUrl(String method, Map<String, String> params) {
  return Uri.http('api.petfinder.com', method, params).toString();
}

ShelterInformation toShelterInformation(Map shelter) {
  if (shelter == null) {
    return null;
  }
  var address = shelter['address1'].isEmpty ? '' : shelter['address1']['\$t'];
  var city = shelter['city']['\$t'];
  var zip = shelter['zip']['\$t'];
  var state = shelter['state']['\$t'];
  var location = '$address $city, $state. $zip';
  var lat = double.parse(shelter['latitude']['\$t']);
  var lng = double.parse(shelter['longitude']['\$t']);
  ShelterInformation info = ShelterInformation(
      shelter['name']['\$t'], shelter['phone']['\$t'] ?? '', location)
    ..id = shelter['id']['\$t']
    ..lat = lat
    ..lng = lng;
  return info;
}

Animal toAnimal(Map animalData) {
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
  String description =
      descriptionMap.isEmpty ? "No comments available" : descriptionMap['\$t'];
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
      animalData['lastUpdate']['\$t'],
      animalData['options'],
      animalData['size']['\$t']);
}

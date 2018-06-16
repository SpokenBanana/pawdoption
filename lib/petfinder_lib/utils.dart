import 'dart:convert';

import '../animals.dart';
import '../protos/animals.pb.dart';

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

Animal toAnimal(Map animalMap) {
  AnimalData data = AnimalData.create();

  // Photos.
  var photoMap = animalMap['media']['photos'];
  if (photoMap != null) {
    var images = animalMap['media']['photos']['photo'];
    for (var img in images) {
      if (img['@size'] == 'x') data.imgUrl.add(img['\$t']);
    }
  } else {
    data.imgUrl.add('');
  }

  // Set description.
  Map descriptionMap = animalMap['description'];
  String description =
      descriptionMap.isEmpty ? "No comments available" : descriptionMap['\$t'];
  try {
    description = utf8.decode(Latin1Codec().encode(description));
  } catch (Exception) {}

  // Get city state.
  var city = animalMap['contact']['city'];
  var state = animalMap['contact']['state'];
  data.cityState = '${city.isEmpty ? 'Unknown' : city['\$t']}, '
      '${state.isEmpty? 'Unknown' : state['\$t']}';

  // Get breed.
  var breeds = animalMap['breeds']['breed'];
  if (breeds is List) {
    data.breed = breeds.map((breedstr) => breedstr['\$t']).join(' ');
  } else {
    data.breed = breeds['\$t'];
  }

  data.name = animalMap['name']['\$t'];
  data.name =
      '${data.name[0].toUpperCase()}${data.name.substring(1).toLowerCase()}';
  data.gender = animalMap['sex']['\$t'] == 'M' ? 'Male' : 'Female';
  data.age = animalMap['age']['\$t'];
  data.shelterId = animalMap['shelterId']['\$t'];
  // Not all animals have a shelter Id.
  if (animalMap['shelterPetId']['\$t'] != null)
    data.id = animalMap['shelterPetId']['\$t'];
  data.apiId = animalMap['id']['\$t'];
  data.lastUpdated = animalMap['lastUpdate']['\$t'];
  data.options.addAll(Animal.parseOptions(animalMap['options']));
  data.size = animalMap['size']['\$t'];

  Animal pet = Animal(info: data, description: description);
  return pet;
}

import 'protos/animals.pb.dart';

// Wrapper class for the AnimalData proto. Provides some read/write serialize
// methods for convenience.
class Animal {
  AnimalData info;
  DateTime lastViewed;
  String status;
  // Only populated if the Animal was liked and has an id in our db.
  int dbId;

  Animal({AnimalData info}) {
    if (info != null) {
      this.info = info;
      this.lastViewed = DateTime.parse(info.lastUpdated);
      // Assume adoptable since that is the default search filter we apply.
      this.status = "adoptable";
    } else
      this.info = AnimalData.create();
  }

  factory Animal.fromString(String animalStr) {
    try {
      Animal pet = Animal(info: AnimalData.fromJson(animalStr));
      return pet;
    } catch (Exception) {}

    // Support old way of serializing, which was a very bad idea.
    List<String> parts = animalStr.split('|');
    Animal pet = Animal();
    pet.info.name = parts[0];
    pet.info.gender = parts[1];
    pet.info.color = parts[2];
    pet.info.breed = parts[3];
    pet.info.age = parts[4];
    pet.info.lastUpdated = parts[5];
    pet.info.imgUrl.add(parts[7]);
    pet.info.apiId = parts[8];
    pet.info.shelterId = parts[9];
    pet.info.id = parts[10];
    if (parts.length > 11 && parts[11] != '') {
      pet.info.options.addAll(parts[11].split(','));
    }
    return pet;
  }

  String toString() {
    return info.writeToJson();
  }

  void readAttributes(dynamic attributes) {
    this.info.specialNeeds = attributes['special_needs'] == 'true';
    this.info.shotsCurrent = attributes['shots_current'] == 'true';
    this.info.spayedNeutered = attributes['spayed_neutered'] == 'true';
  }

  bool operator ==(other) {
    return other is Animal && other.info.apiId == this.info.apiId;
  }

  int get hashCode => this.info.apiId.hashCode;

  // For now, we'll check on pets if it has been more than 3 days since the last
  // recorded lastUpdated date.
  bool shouldCheckOn() {
    bool result = DateTime.now().difference(this.lastViewed).inHours > 12 ||
        info.description == null ||
        info.description.isEmpty;
    this.lastViewed = DateTime.now();
    info.lastUpdated = this.lastViewed.toIso8601String();
    return result;
  }

  // For DB operations.

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'protoString': info.writeToJson(),
    };
    if (dbId != null) {
      map['id'] = dbId;
    }
    return map;
  }

  factory Animal.fromMap(Map<String, dynamic> map) {
    Animal pet = Animal.fromString(map['protoString']);
    pet.dbId = map['id'];
    return pet;
  }
}

class ShelterInformation {
  String name,
      phone,
      location,
      id,
      email,
      missionStatement,
      policy,
      policyUrl,
      photo;
  int distance = -1;

  ShelterInformation(name, phone, location) {
    this.name = name;
    this.phone = phone;
    this.location = location;
  }

  ShelterInformation.fromApi(dynamic response) {
    var address = response['address']['address1'] ?? '';
    var city = response['address']['city'];
    var zip = response['address']['postcode'];
    var state = response['address']['state'];
    this.location = '$address $city, $state. $zip';
    this.phone = response['phone'] ?? '';
    this.name = response['name'];
    this.id = response['id'];
    this.missionStatement = response['mission_statement'];
    this.policy = response['adoption']['policy'];
    this.policyUrl = response['adoption']['url'];
    if (response['photos'] != null && response['photos'].isNotEmpty) {
      this.photo = response['photos'][0]['medium'];
    }
    if (response['distance'] != null) {
      this.distance = response['distance'].round();
    }
    if (response['email'] != null) {
      this.email = response['email'];
    }
  }
}

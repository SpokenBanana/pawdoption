import 'dart:async';

RegExp _animalIdExp = RegExp(r"ID=(\w+)&LOCATION=(\w+)");

/// Used as sort of an abstract class. Probably a better way of doing this.
/// This is so that if another API is found to be better or the current
/// API stops working, then we can switch APIs without being so dependent
/// on how one API works.
class PetAPI {
  void setLocation(String zip, int miles, {String animalType}) {}
  // ignore: missing_return
  Future<List<Animal>> getAnimals(int amount, List<String> toSkip) {}
  // ignore: missing_return
  static Future<List<String>> getAnimalDetails(Animal animal) {}
  // ignore: missing_return
  static Future<ShelterInformation> getShelterInformation(String location) {}
}

class Animal {
  String name, gender, color, breed, shelter, age, since, imgUrl, id;

  // PetFinder specific.
  String apiId, description, location, cityState;

  DateTime lastUpdated;

  List<String> options;
  bool spayedNeutered, hasShots, specialNeeds, noKids;

  /// Was used when the project scraped information from petharbor but now
  /// used.
  Animal(name, gender, color, breed, age, since, shelter, imgUrl) {
    if (name.indexOf('(') != -1) {
      this.name = name.substring(0, name.indexOf("(") - 1).toLowerCase();
    } else {
      this.name = name.toLowerCase();
    }
    this.name = "${this.name[0].toUpperCase()}${this.name.substring(1)}";
    this.gender = gender;
    this.color = color;
    this.breed = breed;

    try {
      var ageSegments = age.split(' ');
      int years = int.parse(ageSegments[0]);
      int months =
          int.parse(ageSegments[1].substring(ageSegments[1].length - 2));
      this.age = "$years year${years == 1 ? '' : 's'} and $months "
          "month${months == 1 ? '' : 's'} old";
    } catch (Exception) {
      this.age = age;
    }

    this.since = since;
    this.shelter = shelter;
    this.imgUrl = imgUrl;
    this.apiId = '';

    var matches = _animalIdExp.allMatches(this.imgUrl).toList();
    if (matches.isNotEmpty) {
      this.id = matches[0].group(1);
      this.location = matches[0].group(2);
    }
  }

  Animal.fromPetFinder(
      String name,
      this.gender,
      this.breed,
      this.age,
      this.imgUrl,
      this.id,
      this.location,
      this.apiId,
      this.description,
      this.cityState,
      this.since) {
    name = name.toLowerCase();
    this.name = '${name[0].toUpperCase()}${name.substring(1)}';
    if (this.gender == 'F')
      this.gender = 'Female';
    else if (this.gender == 'M') this.gender = 'Male';
    lastUpdated = DateTime.parse(this.since);
  }

  Animal.fromBasicParams(
      this.name,
      this.gender,
      this.color,
      this.breed,
      this.age,
      this.since,
      this.shelter,
      this.imgUrl,
      this.apiId,
      this.location,
      this.id) {}

  factory Animal.fromString(String animalStr) {
    List<String> parts = animalStr.split('|');
    return Animal.fromBasicParams(parts[0], parts[1], parts[2], parts[3],
        parts[4], parts[5], parts[6], parts[7], parts[8], parts[9], parts[10]);
  }

  /// Used to reconstruct saved Animal objects. Can't be too big since we
  /// store the information locally which is limited, so we don't
  /// save description since that is usually a large string.
  String toString() {
    // TODO: Incorporate the options into this format.
    return "${this.name}|${this.gender}|${this.color}|${this.breed}|"
        "${this.age}|${this.since}|${this.shelter}|${this.imgUrl}|"
        "${this.apiId}|${this.location}|${this.id}";
  }

  void readOptions() {
    for (String option in options) {
      switch (option) {
        case 'specialNeeds':
          specialNeeds = true;
          break;
        case 'hasShots':
          hasShots = true;
          break;
        case 'altered':
          spayedNeutered = true;
          break;
        case 'noKids':
          noKids = true;
          break;
        default:
          continue;
      }
    }
  }

  static List<String> parseOptions(Map options) {
    if (options == null) return List<String>();
    if (options['option'] is List) {
      List<String> strOptions = List<String>();
      for (var option in options['option']) strOptions.add(option['\$t']);
      return strOptions;
    }
    return <String>[options['option']['\$t']];
  }
}

class ShelterInformation {
  String name, phone, location;
  ShelterInformation(name, phone, location) {
    this.name = name;
    this.phone = phone;
    this.location = location;
  }
}

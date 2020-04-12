import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../animals.dart';
import 'credentials.dart';
import 'utils.dart';

/// We want this class to serve as the communication between the PetFinder API
/// and the front-end. Some things it has to do.
///
///   * Get pets of a certain type(s) sorted by this criteria
///
/// Types:
///   * Animals (one or more)
///   * Breed (Can select for each animal type)
///   * Age restriction?
///   * Shelter
///
/// Sorting criteria
///   * Last updated
///   * Age
///

PetSearchOptions kDefaultSearchOptions = PetSearchOptions(
    animalType: 'dog',
    breed: '',
    ages: <String>[],
    sizes: <String>[],
    sex: '',
    zip: '',
    shelters: Set.from(<String>[]));

class PetSearchOptions {
  String animalType;
  String breed;
  String sex;
  String zip;
  List<String> ages;
  List<String> sizes;
  // This could be pretty big, so we want to optimize searches in this field.
  Set<String> shelters;

  PetSearchOptions(
      {this.animalType,
      this.breed,
      this.ages,
      this.sizes,
      this.sex,
      this.zip,
      this.shelters});

  String toString() {
    return '$animalType|$breed|${ages.join(',')}|${sizes.join(',')}';
  }
}

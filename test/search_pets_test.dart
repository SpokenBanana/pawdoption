import 'package:test/test.dart';

import '../lib/animals.dart';
import '../lib/petfinder_lib/search_pets.dart';

void main() {
  PetFinderSearch searcher;
  PetSearchOptions options;

  setUp(() {
    searcher = PetFinderSearch();
    options = kDefaultSearchOptions..zip = '94016';
  });

  test('Can make full requests', () async {
    var animals = await searcher.searchFor(options);
    expect(animals.length, 25);
  });

  test('Does filter correctly', () async {
    options.ages = <String>['Young'];
    options.sizes = <String>['M'];
    options.sex = 'F';
    List<Animal> animals = await searcher.searchFor(options);

    for (Animal animal in animals) {
      expect(animal.age, 'Young');
      expect(animal.size, 'M');
      expect(animal.gender, 'Female');
    }
  });

  test('Does get breeds', () async {
    var breeds = await searcher.getBreedList('dog');
    expect(breeds.length >= 1, true);
  });

  test('Does get shelters', () async {
    var shelters = await searcher.getShelterList(options.zip);
    expect(shelters.length >= 1, true);
  });
}

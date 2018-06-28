import 'dart:async';
import 'dart:math';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

import '../animals.dart';
import '../protos/pet_search_options.pb.dart';

const String kBaseUrl = 'http://petharbor.com/';
const String kSearchUrl = kBaseUrl + 'results.asp?';
const String kShelterUrl = kBaseUrl + 'pick_shelter.asp?';

const String kUrlRegex = r'(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]'
    r'{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)';

const String kSearchParams = 'searchtype=ADOPT&stylesheet=include/default.css&'
    'frontdoor=1&grid=1&friends=1&samaritans=1&nosuccess=0'
    '&rows=24&imght=120&imgres=thumb&tWidth=200&'
    'view=sysadm.v_animal&fontface=arial&fontsize=10&'
    '&ADDR=undefined&nav=1&start=4'
    '&nomax=1';
const String kShelterParams = 'searchtype=PRE&stylesheet=include/default.css&'
    'frontdoor=1&friends=1&samaritans=1&nosuccess=0&'
    'rows=10&imght=120&imgres=thumb&tWidth=200'
    '&view=sysadm.v_animal_short&fontface=arial&'
    'fontsize=10&atype=';

Future<Document> _fetchShelterSearchPage(String zip, int miles) async {
  var response = await http.get('$kShelterUrl$kShelterParams&zip=$zip'
      '&miles=$miles');
  return parser.parse(response.body);
}

Future<Document> _fetchAnimalSearchPage(
    String type, int page, List<String> shelters) async {
  var response = await http.get('$kSearchUrl$kSearchParams'
      '&where=type_${type.toUpperCase()}&shelterlist=${shelters.join(",")}'
      '&atype=$type&page=$page');
  return parser.parse(response.body);
}

Animal _scrapeAnimalData(Element e) {
  var text = e.getElementsByClassName('gridText');
  var img = e.getElementsByTagName('img')[0];
  var url = "http://petharbor.com/${img.attributes['src']}";
  url = url.replaceFirst("thumb", "Detail");
  // Depreciated, so information isnt't filled.
  return Animal();
}

// TODO: Since this really shouldn't be used anymore maybe it's time to remove
//       this?
class PetHarborApi implements PetAPI {
  int _currentPage, _totalPages, _lastElement, _pageOffset;
  List<String> _shelters;

  PetHarborApi() {
    this._lastElement = 0;
  }

  void setLocation(String zip, int miles,
      {String animalType, double lat, double lng}) async {
    print('Setting location');
    Document doc = await _fetchShelterSearchPage(zip, miles);
    _shelters = List<String>();
    for (Element e in doc.getElementsByTagName('input[type="CHECKBOX"]'))
      _shelters.add('%27${e.attributes['name'].substring(3)}%27');
    print('shelters found ${_shelters.length}');

    Document searchPage = await _fetchAnimalSearchPage('dog', 1, _shelters);
    _getTotalPages(searchPage);
    this._currentPage = 1;
  }

  Future<List<Animal>> getAnimals(int amount, List<Animal> toSkip,
      {PetSearchOptions searchOptions, double lat, double lng}) async {
    // TODO: Maybe send an error message?
    if (this._totalPages != -1 && this._currentPage > this._totalPages)
      return List<Animal>();

    List<Animal> animals = List<Animal>();
    while (animals.length < amount) {
      Document doc = await _fetchAnimalSearchPage(
          'dog',
          (this._currentPage + this._pageOffset) % this._totalPages,
          this._shelters);

      var results = doc.getElementsByClassName('gridResult');
      int i = this._lastElement;
      int length =
          min(this._lastElement + (amount - animals.length), results.length);
      print('Going for $length starting at $i out of ${results.length}');
      for (; i < length; i++) {
        Animal animal = _scrapeAnimalData(results[i]);
        if (!toSkip.contains(animal)) animals.add(animal);
      }

      if (i >= results.length) {
        this._currentPage += 1;
        // Wrap back around.
        if (this._currentPage > this._totalPages) {
          this._currentPage = 1;
        }
        print('Now at page ${this._currentPage}');
        this._lastElement = 0;
      } else
        this._lastElement = i;
    }
    print('Finished at element ${this._lastElement}');
    return animals;
  }

  static Future<ShelterInformation> getShelterInformation(
      String location) async {
    String url = '${kBaseUrl}site.asp?ID=${location}';
    var response = await http.get(url);
    var doc = parser.parse(response.body);

    RegExp phoneReg = RegExp(r'(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]'
        r'\d{3}[\s.-]\d{4}');

    String name = doc.getElementsByTagName('h1')[0].text;
    var locationInfo = doc.getElementsByClassName('contact');
    var address = locationInfo[0].text.trim().split(RegExp(r'\s+')).join(" ");
    var phoneMatches = phoneReg.allMatches(locationInfo[1].text).toList();
    if (phoneMatches.isEmpty) {
      return ShelterInformation(name, "", address);
    }
    var phone = phoneMatches[0].group(0);
    return ShelterInformation(name, phone, address);
  }

  static Future<List<String>> getAnimalDetails(Animal animal) async {
    // Doesn't work, removed constructor for this.
    String url = '${kBaseUrl}pet.asp?uaid=${animal.info.shelterId}.'
        '${animal.info.id}';
    var respone = await http.get(url);
    var details = parser
        .parse(respone.body)
        .getElementsByClassName('DetailTable')[1]
        .getElementsByTagName('td')[1];

    var results = new List<String>();
    results.add(details.text);

    var urlMatches = RegExp(kUrlRegex).allMatches(results[0]);
    for (Match m in urlMatches) {
      results.add(m.group(0));
    }

    return results;
  }

  void _getTotalPages(Document searchDoc) {
    var pageParts = searchDoc.getElementsByTagName('center')[1].text.split(' ');
    this._totalPages = int.parse(pageParts[pageParts.length - 1]);
    this._pageOffset = Random().nextInt(this._totalPages);
    print('Offset: $_pageOffset');
    print('Pages ${this._totalPages}');
  }
}

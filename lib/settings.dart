import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'api.dart';
import 'colors.dart';
import 'protos/pet_search_options.pb.dart';
import 'widgets/search_bar.dart';

/// Handles the settings of the application as well as providiing general
/// information ahout the app.
class SettingsPage extends StatefulWidget {
  SettingsPage({required Key key, required this.feed}) : super(key: key);

  final AnimalFeed feed;

  @override
  _SettingsPage createState() => new _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  String _zip = '';
  PetSearchOptions searchOptions = kDefaultOptions;
  AnimalChangeNotifier animalNotifier = AnimalChangeNotifier(animalType: 'dog');
  List<String> breeds = [];
  bool _selectedCats = false;
  String _errorMessage = '';

  TextEditingController _textController = TextEditingController();

  _SettingsPage() {
    SharedPreferences.getInstance().then((prefs) {
      // TODO: Zip and animal type should go in SearchOptions.
      var zip = prefs.getString('zip');
      var selectedCat = prefs.getBool('animalType') ?? false;
      setState(() {
        if (widget.feed.zip.isNotEmpty) {
          _zip = widget.feed.zip;
          _textController.text = _zip;
        } else if (zip != null) {
          _zip = zip;
          _textController.text = zip;
        }

        var searchJson = prefs.getString('searchOptions');
        if (searchJson != null) {
          searchOptions = PetSearchOptions.fromJson(searchJson);
        } else {
          searchOptions = widget.feed.searchOptions.deepCopy();
        }

        _selectedCats = selectedCat;
        if (_selectedCats == true) animalNotifier.changeAnimal('cat');
      });
    });
    var animalType = _selectedCats ? 'cat' : 'dog';
    getBreedList(animalType).then((breeds) {
      setState(() {
        this.breeds = breeds;
      });
    });
  }
  @override
  void initState() {
    super.initState();
    searchOptions = widget.feed.searchOptions.deepCopy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: buildWholePage(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.3),
              spreadRadius: 1.0,
              blurRadius: 3.0,
            )
          ],
        ),
        child: Container(
          height: 80.0,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _errorMessage != '' ? Text(_errorMessage) : SizedBox(),
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: kPetThemecolor,
                    padding: EdgeInsets.all(4.0),
                    textStyle: TextStyle(color: Colors.white),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4.0)))),
                onPressed: () => updateInfo(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    Text(
                      "Done",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // TODO: This has become a very long mess, should try to break this up.
  Widget buildWholePage() {
    final titleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20.0,
      fontFamily: 'Open Sans',
    );
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: ListView(
          children: <Widget>[
            Text(
              'Where do you want to search?',
              style: titleStyle,
            ),
            buildZipTextField(),
            TextButton(
              onPressed: () async {
                var zip = await getZipFromGeo();
                if (zip.isNotEmpty)
                  setState(() {
                    _textController.text = zip;
                    _zip = zip;
                  });
              },
              child: Row(
                children: <Widget>[
                  Icon(Icons.my_location),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Auto set my location'),
                  ),
                ],
              ),
            ),
            Divider(),
            Text(
              "What do you want to search for?",
              style: titleStyle,
            ),
            // TOOO: Make this use the GroupedOptions.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Dogs"),
                      Checkbox(
                        value: !_selectedCats,
                        activeColor: kPetThemecolor,
                        onChanged: (value) {
                          setState(() {
                            if (value != null) {
                              searchOptions.breeds.clear();
                              animalNotifier.changeAnimal('dog');
                            }
                            _selectedCats = false;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Cats"),
                      Checkbox(
                        value: _selectedCats,
                        activeColor: kPetThemecolor,
                        onChanged: (value) {
                          setState(() {
                            if (value != null) {
                              searchOptions.breeds.clear();
                              animalNotifier.changeAnimal('cat');
                            }
                            _selectedCats = true;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            Text("Gender", style: titleStyle),
            GroupedOptions(
              key: ValueKey('gender'),
              options: <Option>[
                Option(
                  text: "Both",
                  value: !searchOptions.hasSex(),
                  onChange: (change) {
                    if (change) {
                      setState(() {
                        searchOptions.clearSex();
                      });
                    }
                  },
                ),
                Option(
                  text: "Male",
                  value: searchOptions.sex == 'male',
                  onChange: (change) {
                    if (change) {
                      setState(() {
                        searchOptions.sex = 'male';
                      });
                    }
                  },
                ),
                Option(
                  text: "Female",
                  value: searchOptions.sex == 'female',
                  onChange: (change) {
                    if (change) {
                      setState(() {
                        searchOptions.sex = 'female';
                      });
                    }
                  },
                ),
              ],
            ),
            Divider(),
            Text('Size', style: titleStyle),
            GroupedOptions(
              key: ValueKey('sizes'),
              options: generateOptions("All sizes",
                  ['small', 'medium', 'large', 'xlarge'], searchOptions.sizes),
            ),
            Divider(),
            Text('Age', style: titleStyle),
            GroupedOptions(
              key: ValueKey('ages'),
              options: generateOptions("All ages",
                  ['Baby', 'Young', 'Adult', 'Senior'], searchOptions.ages),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Spayed/Neutered only",
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 17.0,
                    )),
                Switch(
                  activeColor: kPetThemecolor,
                  value: searchOptions.fixedOnly,
                  onChanged: (value) {
                    setState(() {
                      searchOptions.fixedOnly = value;
                    });
                  },
                ),
              ],
            ),
            createDistanceSlider(titleStyle),
            Divider(),
            Text('Breeds', style: titleStyle),
            Text('Leave empty to use all breeds',
                style: TextStyle(color: Colors.grey)),
            SizedBox(height: 10.0),
            SelectableInput(
              key: ValueKey('input'),
              refetchNotifier: animalNotifier,
              hintText: 'Search breeds',
              listFetcher: fetchBreedList,
              selectedMatches: searchOptions.breeds,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buidInfoSection(),
            )
          ],
        ),
      ),
    );
  }

  Widget createDistanceSlider(titleStyle) {
    return Column(
      children: <Widget>[
        Divider(),
        Text('Max distance', style: titleStyle),
        // TODO: There is currently a bug that doesn't let the label render
        //       so use the label field once it is fixed.
        Center(child: Text('${searchOptions.maxDistance} miles')),
        Slider(
          value: searchOptions.maxDistance.toDouble(),
          min: 1.0,
          max: 100.0,
          divisions: 100,
          onChanged: (value) {
            setState(() {
              searchOptions.maxDistance = value.round();
            });
          },
          activeColor: kPetThemecolor,
        ),
      ],
    );
  }

  Future<List<String>> fetchBreedList() async =>
      await getBreedList(animalNotifier.animalType);

  List<Option> generateOptions(
      String allText, List<String> options, List<String> container) {
    List<Option> result = <Option>[
      Option(
        text: allText,
        value: container.isEmpty,
        onChange: (value) {
          if (value)
            setState(() {
              container.clear();
            });
        },
      ),
    ];

    for (String option in options) {
      result.add(Option(
        text: option,
        value: container.contains(option),
        onChange: (value) {
          setState(() {
            if (value)
              container.add(option);
            else
              container.remove(option);
            if (container.length == options.length) container.clear();
          });
        },
      ));
    }
    return result;
  }

  Widget buidInfoSection() {
    const infoStyle = const TextStyle(
      color: Colors.grey,
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Divider(),
        Icon(Icons.info, color: Colors.grey),
        Text(
          "All information was provided by PetFinder",
          textAlign: TextAlign.center,
          style: infoStyle,
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'Head over to ',
            style: infoStyle,
            children: <TextSpan>[
              TextSpan(
                  text: 'petfinder.com',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      await launchUrlString('https://www.petfinder.com/');
                    }),
              TextSpan(
                text: ' to search directly for the pets found here!',
                style: infoStyle,
              ),
            ],
          ),
        ),
        Text(
          "(then come back)",
          textAlign: TextAlign.center,
          style: infoStyle,
        ),
      ],
    );
  }

  void updateInfo() {
    var message = 'Location set!';
    if (_zip.length < 5) {
      message = 'Please set a valid zip code';
      setState(() {
        _errorMessage = message;
      });
    } else {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('zip', _zip);
        prefs.setBool('animalType', _selectedCats);
        prefs.setString('searchOptions', searchOptions.writeToJson());
      });
      if (searchOptions != widget.feed.searchOptions ||
          searchOptions.breeds.length !=
              widget.feed.searchOptions.breeds.length) {
        // TODO: ApiFeed needs its own updateSetting() call.
        widget.feed.reloadFeed = true;
        widget.feed.searchOptions = searchOptions;
        widget.feed.zip = _zip;
      }
      Navigator.pop(context, widget.feed.reloadFeed);
    }
  }

  Widget buildZipTextField() {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: Theme.of(context).secondaryHeaderColor,
      ),
      child: TextField(
        style: TextStyle(
            fontFamily: 'OpenSans',
            color: Theme.of(context).secondaryHeaderColor,
            fontSize: 20.0),
        controller: _textController,
        keyboardType: TextInputType.number,
        maxLength: 5,
        onChanged: (text) {
          _errorMessage = '';
          _zip = text;
        },
        decoration: InputDecoration(
          labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
          fillColor: Theme.of(context).secondaryHeaderColor,
          labelText: "Zip Code",
          suffixIcon: Icon(Icons.location_on),
        ),
      ),
    );
  }
}

/// Let user select from what can possibily be a large list of items.
class SelectableInput extends StatefulWidget {
  SelectableInput(
      {required this.key,
      required this.listFetcher,
      required this.selectedMatches,
      required this.hintText,
      required this.refetchNotifier})
      : super(key: key);
  final Key key;
  final ItemCallback listFetcher;
  final List<String> selectedMatches;
  final ChangeNotifier refetchNotifier;
  final String hintText;
  @override
  _SelectableInputState createState() => _SelectableInputState();
}

class _SelectableInputState extends State<SelectableInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        buildSelectedItems(),
        SearchBar(
          items: [],
          refetchNotifier: widget.refetchNotifier,
          hintText: widget.hintText,
          onSelectedItem: (item) {
            if (!widget.selectedMatches.contains(item))
              setState(() {
                widget.selectedMatches.add(item);
              });
          },
          listFetcher: widget.listFetcher,
        ),
      ],
    );
  }

  Widget buildSelectedItems() {
    return Column(
      children: widget.selectedMatches.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 30,
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: CircleBorder(),
                    backgroundColor: kPetThemecolor,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.selectedMatches.remove(item);
                    });
                  },
                  child: Center(
                      child: Icon(Icons.close, size: 10, color: Colors.white)),
                ),
              ),
              SizedBox(width: 10),
              Text(item),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Used to list options that the user can select from.
class GroupedOptions extends StatefulWidget {
  GroupedOptions({required Key key, required this.options}) : super(key: key);
  final List<Option> options;
  @override
  _GroupedOptionsState createState() => _GroupedOptionsState();
}

class _GroupedOptionsState extends State<GroupedOptions> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: widget.options.map((option) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(option.text,
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 17.0,
                    )),
                Checkbox(
                  value: option.value,
                  onChanged: (val) {
                    option.onChange(val!);
                  },
                  activeColor: kPetThemecolor,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Basically a wrapper for checkbox inputs. We may want to use a different
/// widget so we want at least have a uniform way to define an option.
class Option {
  final String text;
  final bool value;
  final Function(bool change) onChange;
  Option({required this.text, required this.onChange, required this.value});
}

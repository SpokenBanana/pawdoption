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
  PetSearchOptions _searchOptions = kDefaultOptions;
  AnimalChangeNotifier _animalNotifier =
      AnimalChangeNotifier(animalType: 'dog');
  String _errorMessage = '';

  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchOptions = widget.feed.searchOptions.deepCopy();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        var searchJson = prefs.getString('searchOptions');
        if (searchJson != null) {
          _searchOptions = PetSearchOptions.fromJson(searchJson);
        } else {
          _searchOptions = widget.feed.searchOptions.deepCopy();
        }
        _textController.text = _searchOptions.zip;
        if (_searchOptions.animalType == 'cat')
          _animalNotifier.changeAnimal('cat');
      });
    });
    getBreedList(_searchOptions.animalType).then((breeds) {
      setState(() {});
    });
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
      // fontWeight: FontWeight.bold,
      fontSize: 17.0,
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
                    _searchOptions.zip = zip;
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
            Text("Pet type", style: titleStyle),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Center(
                child: ToggleButtons(
                  isSelected: [
                    _searchOptions.animalType == 'dog',
                    _searchOptions.animalType == 'cat'
                  ],
                  borderRadius: BorderRadius.circular(8),
                  fillColor: kPetThemecolor,
                  color: Colors.white,
                  selectedColor: Colors.white,
                  onPressed: (index) {
                    setState(() {
                      if (index == 0) {
                        _searchOptions.breeds.clear();
                        _animalNotifier.changeAnimal('dog');
                        _searchOptions.animalType = 'dog';
                      } else {
                        _searchOptions.breeds.clear();
                        _animalNotifier.changeAnimal('cat');
                        _searchOptions.animalType = 'cat';
                      }
                    });
                  },
                  children: [Text('Dogs'), Text('Cats')],
                ),
              ),
            ),
            Divider(),
            Text("Gender", style: titleStyle),
            GroupedOptions(
              key: UniqueKey(),
              options: <Option>[
                Option(
                  text: "Both",
                  value: () => !_searchOptions.hasSex(),
                  onChange: (change) {
                    setState(() {
                      _searchOptions.clearSex();
                    });
                  },
                ),
                Option(
                  text: "Male",
                  value: () => _searchOptions.sex == 'male',
                  onChange: (change) {
                    setState(() {
                      _searchOptions.sex = 'male';
                    });
                  },
                ),
                Option(
                  text: "Female",
                  value: () => _searchOptions.sex == 'female',
                  onChange: (change) {
                    setState(() {
                      _searchOptions.sex = 'female';
                    });
                  },
                ),
              ],
            ),
            Divider(),
            Text('Size', style: titleStyle),
            GroupedOptions(
              key: UniqueKey(),
              options: generateOptions("All",
                  ['small', 'medium', 'large', 'xlarge'], _searchOptions.sizes),
            ),
            Divider(),
            Text('Age', style: titleStyle),
            GroupedOptions(
              key: ValueKey('ages'),
              options: generateOptions("All",
                  ['Baby', 'Young', 'Adult', 'Senior'], _searchOptions.ages),
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
                  value: _searchOptions.fixedOnly,
                  onChanged: (value) {
                    setState(() {
                      _searchOptions.fixedOnly = value;
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
              refetchNotifier: _animalNotifier,
              hintText: 'Search breeds',
              listFetcher: fetchBreedList,
              selectedMatches: _searchOptions.breeds,
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
        Center(child: Text('${_searchOptions.maxDistance} miles')),
        Slider(
          value: _searchOptions.maxDistance.toDouble(),
          min: 1.0,
          max: 100.0,
          divisions: 100,
          onChanged: (value) {
            setState(() {
              _searchOptions.maxDistance = value.round();
            });
          },
          activeColor: kPetThemecolor,
        ),
      ],
    );
  }

  Future<List<String>> fetchBreedList() async =>
      await getBreedList(_animalNotifier.animalType);

  List<Option> generateOptions(
      String allText, List<String> options, List<String> container) {
    List<Option> result = <Option>[
      Option(
        text: allText,
        value: () => container.isEmpty,
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
        value: () => container.contains(option),
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
    if (_searchOptions.zip.length < 5) {
      message = 'Please set a valid zip code';
      setState(() {
        _errorMessage = message;
      });
    } else {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('searchOptions', _searchOptions.writeToJson());
      });
      if (_searchOptions != widget.feed.searchOptions ||
          _searchOptions.breeds.length !=
              widget.feed.searchOptions.breeds.length) {
        // TODO: ApiFeed needs its own updateSetting() call.
        widget.feed.reloadFeed = true;
        widget.feed.searchOptions = _searchOptions;
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
        style: TextStyle(fontFamily: 'OpenSans', fontSize: 20.0),
        controller: _textController,
        keyboardType: TextInputType.number,
        maxLength: 5,
        onChanged: (text) {
          _errorMessage = '';
          _searchOptions.zip = text;
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
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: asToggles(),
        ),
      ),
    );
  }

  List<bool> _selected = [];
  @override
  void initState() {
    super.initState();
    _selected = widget.options.map((e) => e.value()).toList();
  }

  Widget asToggles() {
    return Container(
      child: ToggleButtons(
        isSelected: _selected,
        borderRadius: BorderRadius.circular(8),
        fillColor: kPetThemecolor,
        color: Colors.white,
        selectedColor: Colors.white,
        onPressed: (index) {
          setState(() {
            widget.options[index].onChange(!_selected[index]);
            for (var i = 0; i < _selected.length; i++) {
              _selected[i] = widget.options[i].value();
            }
          });
        },
        children: widget.options.map((option) {
          return Text(option.text);
        }).toList(),
      ),
    );
  }
}

/// Basically a wrapper for checkbox inputs. We may want to use a different
/// widget so we want at least have a uniform way to define an option.
class Option {
  final String text;
  final bool Function() value;
  final Function(bool change) onChange;
  Option({required this.text, required this.onChange, required this.value});
}

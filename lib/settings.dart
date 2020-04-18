import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api.dart';
import 'colors.dart';
import 'protos/pet_search_options.pb.dart';
import 'widgets/search_bar.dart';

/// Handles the settings of the application as well as providiing general
/// information ahout the app.
class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.feed}) : super(key: key);

  final AnimalFeed feed;

  @override
  _SettingsPage createState() => new _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  String _zip;
  PetSearchOptions searchOptions;
  AnimalChangeNotifier animalNotifier = AnimalChangeNotifier(animalType: 'dog');
  List<String> breeds;
  int _miles;
  bool _selectedCats;
  String _errorMessage;

  TextEditingController _textController = TextEditingController();

  _SettingsPage() {
    _errorMessage = '';
    _zip = '';
    _miles = 10;
    _selectedCats = false;
    breeds = List<String>();
    SharedPreferences.getInstance().then((prefs) {
      var zip = prefs.getString('zip');
      var miles = prefs.getInt('miles');
      var selectedCat = prefs.getBool('animalType') ?? false;
      if (zip != null) {
        setState(() {
          _zip = zip;
          _textController.text = zip;
        });
      }
      if (miles != null) {
        setState(() {
          _miles = miles;
          _selectedCats = selectedCat;
          if (_selectedCats == true) animalNotifier.changeAnimal('cat');
        });
      }
    });
    getBreedList('dog').then((breeds) {
      setState(() {
        this.breeds = breeds;
      });
    });
  }
  @override
  void initState() {
    super.initState();
    searchOptions = widget.feed.searchOptions.clone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: _buildWholePage(),
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
              FlatButton(
                padding: const EdgeInsets.all(4.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                ),
                color: kPetThemecolor,
                textColor: Colors.white,
                onPressed: () => _updateInfo(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.check),
                    Text("Done"),
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
  Widget _buildWholePage() {
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
            _buildZipTextField(),
            FlatButton(
              onPressed: () async {
                var zip = await getZipFromGeo();
                if (zip != null)
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
                            if (value) {
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
                            if (value) {
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
            Text("Sex", style: titleStyle),
            GroupedOptions(
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
              options: _generateOptions("All sizes",
                  ['small', 'medium', 'large', 'xlarge'], searchOptions.sizes),
            ),
            Divider(),
            Text('Age', style: titleStyle),
            GroupedOptions(
              options: _generateOptions("All ages",
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
            widget.feed.geoLocationEnabled
                ? _createDistanceSlider(titleStyle)
                : SizedBox(),
            Divider(),
            Text('Breeds', style: titleStyle),
            Text('Leave empty to use all breeds',
                style: TextStyle(color: Colors.grey)),
            SizedBox(height: 10.0),
            SelectableInput(
              refetchNotifier: animalNotifier,
              hintText: 'Type the breeds you want here',
              listFetcher: _fetchBreedList,
              selectedMatches: searchOptions.breeds,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buidInfoSection(),
            )
          ],
        ),
      ),
    );
  }

  Widget _createDistanceSlider(titleStyle) {
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

  Future<List<String>> _fetchBreedList() async =>
      await getBreedList(animalNotifier.animalType);

  List<Option> _generateOptions(
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

  Widget _buidInfoSection() {
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
                      await launch('https://www.petfinder.com/');
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

  void _updateInfo() {
    var message = 'Location set!';
    if (_zip.length < 5) {
      message = 'Please set a valid zip code';
      setState(() {
        _errorMessage = message;
      });
    } else {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setInt('miles', _miles);
        prefs.setString('zip', _zip);
        prefs.setBool('animalType', _selectedCats);
        prefs.setString('searchOptions', searchOptions.writeToJson());
      });
      if (searchOptions != widget.feed.searchOptions) {
        widget.feed.reloadFeed = true;
        widget.feed.searchOptions = searchOptions;
      }
      Navigator.pop(context, true);
    }
  }

  Widget _buildZipTextField() {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: Theme.of(context).accentColor,
      ),
      child: TextField(
        style: TextStyle(
            fontFamily: 'OpenSans',
            color: Theme.of(context).accentColor,
            fontSize: 20.0),
        controller: _textController,
        keyboardType: TextInputType.number,
        maxLength: 5,
        onChanged: (text) {
          _errorMessage = '';
          _zip = text;
        },
        decoration: InputDecoration(
          labelStyle: TextStyle(color: Theme.of(context).accentColor),
          fillColor: Theme.of(context).accentColor,
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
      {this.key,
      this.listFetcher,
      this.selectedMatches,
      this.hintText,
      this.refetchNotifier})
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
        _buildSelectedItems(),
        SearchBar(
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

  Widget _buildSelectedItems() {
    return Column(
      children: widget.selectedMatches.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: <Widget>[
              ButtonTheme(
                height: 14.0,
                child: FlatButton(
                  shape: CircleBorder(),
                  color: kPetThemecolor,
                  onPressed: () {
                    setState(() {
                      widget.selectedMatches.remove(item);
                    });
                  },
                  child: Icon(Icons.remove, color: Colors.white),
                ),
              ),
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
  GroupedOptions({Key key, this.options}) : super(key: key);
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
                  onChanged: option.onChange,
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
  Option({this.text, this.onChange, this.value});
}

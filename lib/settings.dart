import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';
import 'api.dart';

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
  int _miles;
  bool _selectedCats;
  String _errorMessage;

  TextEditingController _textController = TextEditingController();

  _SettingsPage() {
    _errorMessage = '';
    _zip = '';
    _miles = 10;
    _selectedCats = false;
    SharedPreferences.getInstance().then((prefs) {
      var zip = prefs.getString('zip');
      var miles = prefs.getInt('miles');
      var selectedCat = prefs.getBool('animalType') ?? false;
      if (zip != null && miles != null) {
        setState(() {
          _zip = zip;
          _miles = miles;
          _selectedCats = selectedCat;
          _textController.text = zip;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: _buildWholePage(),
    );
  }

  Widget _buildWholePage() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: ListView(
          children: <Widget>[
            Text(
              'Where do you want to search?',
            ),
            _buildZipTextField(),
            Text("What do you want to search for?"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Dogs"),
                Switch(
                  inactiveTrackColor: Colors.green,
                  activeTrackColor: Colors.blue,
                  activeColor: Colors.white,
                  value: _selectedCats,
                  onChanged: (change) {
                    setState(() {
                      _selectedCats = change;
                      print(change ? 'cats selected' : 'dogs selected');
                    });
                  },
                ),
                Text('Cats'),
              ],
            ),
            _errorMessage != '' ? Text(_errorMessage) : SizedBox(),
            ButtonBar(
              children: [
                FlatButton(
                  padding: const EdgeInsets.all(4.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                  color: Colors.blue[400],
                  textColor: Colors.white,
                  onPressed: () => _updateInfo(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Icon(Icons.check),
                      Text("Done"),
                    ],
                  ),
                )
              ],
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
      });
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

  // TODO: Remove this.
  Widget _buildRadiusDropdown() {
    return DropdownButton<int>(
      iconSize: 0.1,
      value: _miles,
      onChanged: (value) {
        setState(() {
          _miles = value;
        });
      },
      elevation: 1,
      items: <int>[10, 20, 50, 100, 200].map((value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text('$value miles'),
        );
      }).toList(),
    );
  }
}

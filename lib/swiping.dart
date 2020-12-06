import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';
import 'protos/pet_search_options.pb.dart';
import 'settings.dart';
import 'widgets/pet_button.dart';
import 'widgets/swiping_cards.dart';

/// The swiping page of the application.
class SwipingPage extends StatefulWidget {
  SwipingPage({Key key, this.feed}) : super(key: key);

  final AnimalFeed feed;

  @override
  _SwipingPageState createState() => new _SwipingPageState(this.feed);
}

class _SwipingPageState extends State<SwipingPage>
    with SingleTickerProviderStateMixin {
  _SwipingPageState(AnimalFeed feed);

  Future<bool> initializeAnimalList() async {
    var prefs = await SharedPreferences.getInstance();

    final animalType = prefs.getBool('animalType') ?? false;
    final optionsStr = prefs.getString('searchOptions') ?? '';
    String zip = await getZip(prefs);
    if (zip == null) return false;

    var options;
    if (optionsStr.isNotEmpty) {
      options = PetSearchOptions.fromJson(optionsStr);
    }

    if (zip != widget.feed.zip ||
        widget.feed.reloadFeed ||
        animalType != (widget.feed.searchOptions.animalType == 'cat')) {
      return await widget.feed.initialize(zip,
          animalType: animalType ? 'cat' : 'dog', options: options);
    }
    return true;
  }

  Future<String> getZip(SharedPreferences prefs) async {
    if (widget.feed.zip != '') {
      return widget.feed.zip;
    }
    var zipFromUser = await getLocationFromUser();
    if (zipFromUser != null) {
      return zipFromUser;
    }
    String zip = prefs.getString('zip');
    return zip;
  }

  Future<String> getLocationFromUser() async {
    String zip;
    var location = Location();
    // We only need to get the zip code from the location, don't need
    // high accuracy for now.
    location.changeSettings(accuracy: LocationAccuracy.low);
    try {
      var currentLocation = await location.getLocation();
      double userLat = currentLocation.latitude;
      double userLng = currentLocation.longitude;
      final coords = Coordinates(userLat, userLng);
      var address = await Geocoder.local.findAddressesFromCoordinates(coords);
      return address.first.postalCode;
    } on Exception {}
    return zip;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        centerTitle: true,
        title: Text("Pawdoption",
            style: TextStyle(
              fontFamily: 'LobsterTwo',
            )),
      ),
      body: Center(
        child: FutureBuilder(
          future: initializeAnimalList(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return CircularProgressIndicator(
                  strokeWidth: 1.0,
                );
              default:
                if (snapshot.hasError) return buildErrorPage();

                if (snapshot.data == false) return buildNoInfoPage();
                return Column(
                  children: [
                    SizedBox(height: 8.0),
                    SwipingCards(
                      feed: widget.feed,
                    ),
                    SizedBox(height: 15.0),
                    buildButtonRow(),
                  ],
                );
            }
          },
        ),
      ),
    );
  }

  Widget buildErrorPage() {
    return Column(
      children: <Widget>[
        Text('Error occurred :( Try again?'),
        PetButton(
          child: Icon(Icons.refresh),
          onPressed: () {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget buildNoInfoPage() {
    const infoStyle = TextStyle(fontSize: 15.0);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("You haven't set your location!", style: infoStyle),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Go to the ', style: infoStyle),
              RaisedButton(
                elevation: 5.0,
                onPressed: () {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          maintainState: false,
                          pageBuilder: (context, _, __) =>
                              SettingsPage(feed: widget.feed)));
                },
                color: Colors.white,
                shape: CircleBorder(),
                padding: const EdgeInsets.all(10.0),
                child: Icon(
                  Icons.settings,
                  size: 15.0,
                  color: Colors.grey,
                ),
              ),
              Text("page and set your location", style: infoStyle),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildButtonRow() {
    const num size = 35.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        PetButton(
          padding: const EdgeInsets.all(10.0),
          onPressed: () {
            if (widget.feed.skipped.isNotEmpty) widget.feed.notifier.undo();
          },
          child: Icon(
            Icons.replay,
            size: size / 2,
            color: Colors.yellow[700],
          ),
        ),
        PetButton(
          padding: const EdgeInsets.all(12.0),
          onPressed: () => widget.feed.notifier.skipCurrent(),
          child: Icon(
            Icons.close,
            size: size,
            color: Colors.red,
          ),
        ),
        PetButton(
          padding: const EdgeInsets.all(12.0),
          onPressed: () => widget.feed.notifier.likeCurrent(),
          child: Icon(
            Icons.favorite,
            size: size,
            color: Colors.green[400],
          ),
        ),
        PetButton(
          padding: const EdgeInsets.all(10.0),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SettingsPage(feed: widget.feed))),
          child: Icon(
            Icons.settings,
            size: size / 2,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';
import 'protos/pet_search_options.pb.dart';
import 'settings.dart';
import 'widgets/pet_button.dart';
import 'widgets/swiping_cards.dart';

/// The swiping page of the application.
class SwipingPage extends StatefulWidget {
  SwipingPage({required Key key, required this.feed}) : super(key: key);

  final AnimalFeed feed;

  @override
  _SwipingPageState createState() => new _SwipingPageState(this.feed);
}

class _SwipingPageState extends State<SwipingPage>
    with SingleTickerProviderStateMixin {
  _SwipingPageState(AnimalFeed feed);

  Future<bool> initializeAnimalList() async {
    var prefs = await SharedPreferences.getInstance();
    String zip = await getZip(prefs);

    PetSearchOptions? options;
    final optionsStr = prefs.getString('searchOptions') ?? '';
    if (optionsStr.isNotEmpty) {
      options = PetSearchOptions.fromJson(optionsStr);
      zip = options.zip;
    }
    // If we can't get a zip, we can't search. Have user go and enter their zip
    // in the settings page.
    if (zip.isEmpty) return false;

    bool animalType = prefs.getBool('animalType') ?? false;
    if (needsRefresh(zip, animalType)) {
      return await widget.feed.initialize(zip,
          animalType: animalType ? 'cat' : 'dog', options: options);
    }
    return true;
  }

  bool needsRefresh(String zip, bool animalType) {
    return zip != widget.feed.searchOptions.zip ||
        widget.feed.reloadFeed ||
        animalType != (widget.feed.searchOptions.animalType == 'cat');
  }

  Future<String> getZip(SharedPreferences prefs) async {
    if (widget.feed.searchOptions.zip.isNotEmpty) {
      return widget.feed.searchOptions.zip;
    }
    var zipFromUser = await getLocationFromUser();
    if (zipFromUser.isEmpty) {
      return zipFromUser;
    }
    return prefs.getString('zip') ?? '';
  }

  Future<String> getLocationFromUser() async {
    try {
      var location = Location();
      // We only need to get the zip code from the location, don't need
      // high accuracy for now.
      if (await location.hasPermission() != PermissionStatus.granted) {
        var service = await location.requestService();
        if (!service) return '';
        var permission = await location.requestPermission();
        if (permission == PermissionStatus.denied ||
            permission == PermissionStatus.deniedForever) return '';
        location.changeSettings(accuracy: LocationAccuracy.low);
      }
      var currentLocation = await location.getLocation();
      var address = await Geocoder.local.findAddressesFromCoordinates(
          Coordinates(currentLocation.latitude!, currentLocation.longitude!));
      return address.first.postalCode!;
    } on Exception {}
    return '';
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
          color: Colors.white,
          padding: const EdgeInsets.all(12.0),
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
              ElevatedButton(
                onPressed: () async {
                  if (await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SettingsPage(
                              key: UniqueKey(), feed: widget.feed)))) {
                    setState(() {
                      // Options changed so we should re-fresh the feed.
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  elevation: 5.0,
                  backgroundColor: Colors.grey.shade900,
                  shape: CircleBorder(),
                  padding: const EdgeInsets.all(10.0),
                ),
                child: Icon(
                  Icons.settings,
                  size: 15.0,
                  color: Colors.grey,
                ),
              ),
              Text(" page and set your location", style: infoStyle),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildButtonRow() {
    const double baseSize = 35.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            left: 3,
            right: 3,
            bottom: 12,
          ),
          width: 60,
          child: PetButton(
              padding: const EdgeInsets.all(10.0),
              onPressed: () {
                if (widget.feed.skipped.isNotEmpty) widget.feed.notifier.undo();
              },
              child: Icon(
                Icons.replay,
                size: baseSize / 2,
              ),
              color: Colors.yellow.shade800),
        ),
        PetButton(
          padding: const EdgeInsets.all(12.0),
          onPressed: () => widget.feed.notifier.skipCurrent(),
          color: Color.fromARGB(255, 42, 107, 168),
          child: Transform(
            transform: Matrix4.rotationY(pi),
            alignment: Alignment.center,
            child: Icon(
              Icons.next_plan,
              size: baseSize,
            ),
          ),
        ),
        PetButton(
          padding: const EdgeInsets.all(12.0),
          onPressed: () => widget.feed.notifier.likeCurrent(),
          color: Colors.green.shade500,
          child: Icon(
            Icons.favorite,
            size: baseSize,
          ),
        ),
        Container(
          width: 60,
          padding: EdgeInsets.only(
            left: 3,
            right: 3,
            top: 17,
          ),
          child: PetButton(
            padding: const EdgeInsets.all(10.0),
            onPressed: () async {
              if (await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SettingsPage(key: UniqueKey(), feed: widget.feed)))) {
                setState(() {
                  // Options changed so we should re-fresh the feed.
                });
              }
            },
            color: Colors.grey.shade700,
            child: Icon(
              Icons.settings,
              size: baseSize / 2,
            ),
          ),
        ),
      ],
    );
  }
}

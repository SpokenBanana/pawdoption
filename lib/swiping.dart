import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'animals.dart';
import 'api.dart';
import 'settings.dart';
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
  _SwipingPageState(AnimalFeed feed) {
    _updateLikedList();
  }

  _updateLikedList() {
    SharedPreferences.getInstance().then((prefs) {
      var liked = prefs.getStringList('liked') ?? List<String>();
      if (liked.isNotEmpty)
        widget.feed.liked =
            liked.map((repr) => Animal.fromString(repr)).toList();
    });
  }

  Future<bool> _initializeAnimalList() async {
    var prefs = await SharedPreferences.getInstance();
    String zip = prefs.getString('zip');
    var animalType = prefs.getBool('animalType') ?? false;
    if (zip == null) return false;
    if (zip != widget.feed.zip ||
        animalType != (widget.feed.animalType == 'cat')) {
      widget.feed.done = false;
      return await widget.feed
          .initialize(zip, 0, animalType: animalType ? 'cat' : 'dog');
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4.0,
        centerTitle: true,
        title: Text("Pawdoption",
            style: TextStyle(
              fontFamily: 'LobsterTwo',
            )),
      ),
      body: Center(
        child: FutureBuilder(
          future: _initializeAnimalList(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return CircularProgressIndicator(
                  strokeWidth: 1.0,
                );
              default:
                if (snapshot.hasError)
                  return Text('Couldn\'t fetch the feed :( Try again later? ');
                if (snapshot.data == false) return _buildNoInfoPage();
                return Column(
                  children: [
                    SizedBox(height: 20.0),
                    SwipingCards(
                      feed: widget.feed,
                    ),
                    SizedBox(height: 10.0),
                    _buildButtonRow(),
                  ],
                );
            }
          },
        ),
      ),
    );
  }

  Widget _buildNoInfoPage() {
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

  Widget _buildButtonRow() {
    const EdgeInsets edge = EdgeInsets.all(12.0);
    const num elevation = 5.0;
    const num size = 35.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          elevation: 5.0,
          onPressed: () {
            if (widget.feed.skipped.isNotEmpty) {
              widget.feed.notifier.undo();
            }
          },
          shape: CircleBorder(),
          padding: const EdgeInsets.all(10.0),
          child: Icon(
            Icons.replay,
            size: size / 2,
            color: Colors.yellow[700],
          ),
        ),
        RaisedButton(
          elevation: elevation,
          onPressed: () => widget.feed.notifier.skipCurrent(),
          padding: edge,
          shape: CircleBorder(),
          child: Icon(
            Icons.close,
            size: size,
            color: Colors.red,
          ),
        ),
        RaisedButton(
          elevation: elevation,
          onPressed: () => widget.feed.notifier.likeCurrent(),
          padding: edge,
          shape: CircleBorder(),
          child: Icon(
            Icons.favorite,
            size: size,
            color: Colors.green,
          ),
        ),
        RaisedButton(
          elevation: 5.0,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsPage(feed: widget.feed)));
          },
          shape: CircleBorder(),
          padding: const EdgeInsets.all(10.0),
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

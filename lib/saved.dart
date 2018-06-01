import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'details.dart';
import 'api.dart';
import 'animals.dart';
import 'constants.dart';

/// Handles displaying the saved animals to later view.
class SavedPage extends StatefulWidget {
  @override
  _SavedPage createState() => _SavedPage();
}

class _SavedPage extends State<SavedPage> {
  List<String> liked;

  _SavedPage() {
    liked = List<String>();
    _getLiked();
  }

  Future<List<String>> _getLiked() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    liked = prefs.getStringList('liked') ?? List<String>();
    if (this.mounted) setState(() {});
    return liked;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3.0,
        title: Text("Saved Pets"),
      ),
      body: Container(
        color: Theme.of(context).canvasColor,
        alignment: Alignment.center,
        child: liked.isEmpty
            ? _buildNoSavedPage()
            : ListView(
                physics: const BouncingScrollPhysics(),
                children: liked
                    .map<Widget>((String repr) =>
                        _buildDogPreview(Animal.fromString(repr)))
                    .toList(),
              ),
      ),
    );
  }

  void _removeDog(Animal dog) {
    setState(() {
      liked.remove(dog.toString());
      SharedPreferences.getInstance().then((prefs) {
        prefs.setStringList("liked", liked);
      });
    });
  }

  Widget _buildDogPreview(Animal dog) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => DetailsPage(pet: dog))),
      child: Dismissible(
        dismissThresholds: {
          DismissDirection.endToStart: .4,
        },
        onDismissed: (direction) => _removeDog(dog),
        direction: DismissDirection.endToStart,
        key: ObjectKey(dog),
        child: _buildDogInfo(dog),
        background: Container(
            alignment: Alignment.centerRight,
            color: Colors.red,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(Icons.delete, size: 30.0, color: Colors.white),
            )),
      ),
    );
  }

  Widget _buildDogInfo(Animal dog) {
    return Container(
      height: 80.0,
      child: Row(children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: CircleAvatar(
            radius: 35.0,
            backgroundImage: NetworkImage(dog.imgUrl),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child:
                  Text(dog.name, style: Theme.of(context).textTheme.headline),
            ),
            Flexible(
              child: Text(
                dog.breed,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildNoSavedPage() {
    const infoStyle = TextStyle(
      color: Colors.grey,
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.sentiment_dissatisfied,
          size: 60.0,
          color: Colors.grey,
        ),
        Text("You have no saved animals.", style: infoStyle),
        Text(
            'Go to the search page and swipe right on some pups! (or kittens!)',
            textAlign: TextAlign.center,
            style: infoStyle),
      ],
    );
  }
}

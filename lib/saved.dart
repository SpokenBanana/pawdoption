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
      backgroundColor: Colors.white,
      body: Container(
        alignment: Alignment.center,
        child: liked.isEmpty
            ? _buildNoSavedPage()
            : ListView(
                physics: const BouncingScrollPhysics(),
                children: liked.map<Widget>((String repr) {
                  var info = repr.split('|');
                  Animal dog = Animal(info[0], info[1], info[2], info[3],
                      info[4], info[5], info[6], info[7]);
                  dog.apiId = info[8];
                  dog.location = info[9];
                  dog.id = info[10];
                  return _buildDogPreview(dog);
                }).toList(),
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
              child: Text(dog.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Raleway',
                      color: Color(0xFF555555),
                      fontSize: 20.0)),
            ),
            Flexible(
              child: Text(
                dog.breed,
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 14.0,
                ),
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

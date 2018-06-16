import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'animals.dart';
import 'details.dart';
import 'protos/animals.pb.dart';

/// Handles displaying the saved animals to later view.
class SavedPage extends StatefulWidget {
  @override
  _SavedPage createState() => _SavedPage();
}

class _SavedPage extends State<SavedPage> {
  List<Animal> liked;

  _SavedPage() {
    liked = List<Animal>();
    _getLiked();
  }

  Future<Null> _getLiked() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var likedrepr = prefs.getStringList('liked') ?? List<String>();
    this.liked = likedrepr.map((animal) => Animal.fromString(animal)).toList();
    if (this.mounted) setState(() {});
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
            : ListView.builder(
                itemCount: liked.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return _buildPetPreview(liked[index]);
                }),
      ),
    );
  }

  void _removeDog(Animal dog) {
    setState(() {
      liked.remove(dog);
      SharedPreferences.getInstance().then((prefs) {
        prefs.setStringList(
            "liked", liked.map((pet) => pet.toString()).toList());
      });
    });
  }

  Widget _buildPetPreview(Animal pet) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => DetailsPage(pet: pet))),
      child: Dismissible(
        dismissThresholds: {
          DismissDirection.endToStart: .4,
        },
        onDismissed: (direction) => _removeDog(pet),
        direction: DismissDirection.endToStart,
        key: ObjectKey(pet),
        child: _buildDogInfo(pet.info),
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

  Widget _buildDogInfo(AnimalData dog) {
    return Container(
      height: 80.0,
      child: Row(children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: CircleAvatar(
            radius: 30.0,
            backgroundImage: NetworkImage(dog.imgUrl[0]),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: Text(dog.name,
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline
                      .copyWith(fontSize: 18.0)),
            ),
            Flexible(
              child: Text(
                dog.breed,
                style: Theme.of(context).textTheme.caption.copyWith(
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

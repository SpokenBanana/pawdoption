import 'package:flutter/material.dart';
import 'package:petadopt/api.dart';

import 'animals.dart';
import 'details.dart';
import 'protos/animals.pb.dart';

enum SavedSort {
  liked,
  name,
  breed,
}

/// Handles displaying the saved animals to later view.
class SavedPage extends StatefulWidget {
  SavedPage({required this.feed});
  final AnimalFeed feed;
  @override
  _SavedPage createState() => _SavedPage();
}

class _SavedPage extends State<SavedPage> {
  List<Animal> saved = [];
  SavedSort sortCriteria = SavedSort.liked;
  bool reversed = false;

  @override
  void initState() {
    super.initState();
    widget.feed.likedDb.getAll().then((animals) {
      // TODO: Add sorting and sort them here.
      setState(() {
        this.saved = animals;
      });
    });
  }

  List<Animal> sortList(List<Animal> list) {
    switch (this.sortCriteria) {
      case SavedSort.name:
        list.sort((a, b) {
          return a.info.name.compareTo(b.info.name);
        });
        break;
      case SavedSort.liked:
        list.sort((a, b) {
          if (a.dbId == null || b.dbId == null) return -1;
          return a.dbId!.compareTo(b.dbId!);
        });
        break;
      case SavedSort.breed:
        list.sort((a, b) {
          return a.info.breed.compareTo(b.info.breed);
        });
        break;
    }

    if (this.reversed) {
      return list.reversed.toList();
    }
    return list;
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
        child: widget.feed.liked.isEmpty
            ? buildNoSavedPage()
            : buildPetList(this.saved),
      ),
    );
  }

  Widget buildPetList(List<Animal> animals) {
    return ListView.builder(
        itemCount: animals.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return buildPetPreview(animals[index]);
        });
  }

  void removeDog(Animal dog) async {
    await widget.feed.removeFromLiked(dog);
    var newSaved = await widget.feed.likedDb.getAll();
    setState(() {
      this.saved = newSaved;
    });
  }

  Widget buildPetPreview(Animal pet) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetailsPage(pet: pet, feed: widget.feed))),
      child: Dismissible(
        dismissThresholds: {
          DismissDirection.endToStart: .4,
        },
        onDismissed: (direction) => removeDog(pet),
        direction: DismissDirection.endToStart,
        key: ObjectKey(pet),
        child: buildDogInfo(pet.info),
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

  Widget buildDogInfo(AnimalData dog) {
    return Container(
      height: 80.0,
      child: Row(children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: CircleAvatar(
            radius: 35.0,
            backgroundImage:
                dog.imgUrl[0].isEmpty ? null : NetworkImage(dog.imgUrl[0]),
          ),
        ),
        Expanded(
          child: Container(
            height: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: Text(dog.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 18.0)),
                ),
                Expanded(
                  child: Text(
                    dog.breed,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14.0,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget buildNoSavedPage() {
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

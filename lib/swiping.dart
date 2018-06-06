import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'animals.dart';
import 'api.dart';
import 'details.dart';
import 'settings.dart';

/// The swiping page of the application.
class SwipingPage extends StatefulWidget {
  SwipingPage({Key key, this.title}) : super(key: key) {
    feed = new AnimalFeed();
  }

  AnimalFeed feed;
  final String title;

  @override
  _SwipingPageState createState() => new _SwipingPageState(this.feed);
}

class _SwipingPageState extends State<SwipingPage>
    with SingleTickerProviderStateMixin {
  AnimalFeed feed;
  bool _hasInfo, _swipingRight;
  AnimationController _controller;
  Animation<double> _right;
  Animation<double> _bottom;
  Animation<double> _rotate;
  double _screenWidth;
  double _screenHeight;

  _SwipingPageState(AnimalFeed feed) {
    this.feed = feed;
  }

  _updateLikedList() {
    SharedPreferences.getInstance().then((prefs) {
      var liked = prefs.getStringList('liked') ?? List<String>();
      if (liked.isNotEmpty) feed.liked = liked;
    });
  }

  _initializeAnimalList() {
    SharedPreferences.getInstance().then((prefs) {
      String zip = prefs.getString('zip');
      int miles = prefs.getInt('miles');
      var animalType = prefs.getBool('animalType') ?? false;
      if (zip == null || miles == null) {
        _hasInfo = false;
      } else {
        if (this.mounted)
          setState(() {
            _hasInfo = true;
            if (zip != feed.zip ||
                miles != feed.miles ||
                animalType != (feed.animalType == 'cat')) {
              feed.done = false;
              _initializeFeed(zip, miles,
                  animalType: animalType ? 'cat' : 'dog');
            }
          });
      }
    });
  }

  void initState() {
    super.initState();
    _hasInfo = false;
    _initializeAnimalList();
    _updateLikedList();
    _swipingRight = true;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    Animation curve = CurvedAnimation(parent: _controller, curve: Curves.ease);

    _rotate = new Tween<double>(
      begin: -0.0,
      end: -40.0,
    ).animate(curve);
    _rotate.addListener(() {
      setState(() {
        if (_rotate.isCompleted) {
          _controller.reset();
        }
      });
    });
    _right = new Tween<double>(
      begin: 0.0,
      end: 400.0,
    ).animate(curve);
    _bottom = new Tween<double>(
      begin: 15.0,
      end: 100.0,
    ).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    _screenWidth = screenSize.width;
    _screenHeight = screenSize.height;

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
        child: this._hasInfo
            ? this.feed.done
                ? Column(
                    children: [
                      SizedBox(height: 20.0),
                      Stack(
                          alignment: Alignment.center,
                          children: _buildCardsForPets(this.feed.currentList)),
                      SizedBox(height: 10.0),
                      _buildButtonRow(),
                    ],
                  )
                : CircularProgressIndicator()
            : _buildNoInfoPage(),
      ),
    );
  }

  void _initializeFeed(String zip, int miles, {String animalType}) {
    if (!this.feed.done)
      this.feed.initialize(zip, miles, animalType: animalType).then((done) {
        if (this.mounted) setState(() {});
      });
  }

  Future<Null> _runAnimation() async {
    try {
      await _controller.forward();
    } on TickerCanceled {}
  }

  void _dogSwiped(DismissDirection direction, Animal pet) {
    if (direction == DismissDirection.startToEnd)
      _savePet(pet);
    else
      feed.skip(pet);
    _removePet(pet);
  }

  _savePet(Animal pet) {
    String repr = pet.toString();
    if (!feed.liked.contains(repr)) {
      feed.liked.add(repr);
      SharedPreferences.getInstance().then((prefs) {
        prefs.setStringList('liked', feed.liked);
      });
    }
  }

  _removePet(Animal pet) {
    setState(() {
      widget.feed.currentList.remove(pet);
      widget.feed.updateList();
    });
  }

  _buildPetCardContainer(Widget child, Animal pet, {double elevation = 0.1}) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => DetailsPage(pet: pet))),
      child: Card(
        margin: const EdgeInsets.all(0.0),
        elevation: elevation,
        child: Container(
          height: _screenHeight / 1.65,
          width: _screenWidth / 1.2,
          child: child,
        ),
      ),
    );
  }

  Widget _buildCardPositioning(Widget child, bool isActive) {
    return Positioned(
      right: !_swipingRight && isActive
          ? _right.value != 0 ? _right.value : null
          : null,
      left: _swipingRight && isActive
          ? _right.value != 0 ? _right.value : null
          : null,
      child: child,
    );
  }

  Widget _buildActiveCard(Animal pet) {
    return RotationTransition(
      turns: AlwaysStoppedAnimation(
          _swipingRight ? -_rotate.value / 360.0 : _rotate.value / 360),
      child: _buildPetCardContainer(_buildPetInfo(pet), pet),
    );
  }

  List<Widget> _buildCardsForPets(List<Animal> pets) {
    int index = -1;
    return pets.map((Animal pet) {
      index += 1;
      return _buildCardPositioning(
          Dismissible(
            // background: _buildDismissBackground(true),
            // secondaryBackground:_buildDismissBackground(false),
            movementDuration: Duration(milliseconds: 500),
            key: UniqueKey(),
            crossAxisEndOffset: -.2,
            onDismissed: (direction) => _dogSwiped(direction, pet),
            child: index == pets.length - 1
                ? _buildActiveCard(pet)
                : _buildPetCardContainer(_buildPetInfo(pet), pet),
          ),
          index == pets.length - 1);
    }).toList();
  }

  Widget _buildDismissBackground(bool toRight) {
    // Creates a background for dismissibles to tell user what swiping
    // left/right does.
    // Still deciding whether or not to do this.
    var color = toRight
        ? const Color.fromRGBO(140, 230, 140, .7)
        : const Color(0x88ff0000);
    var text = toRight ? 'SAVE' : 'SKIP';
    var rotation = toRight ? -.25 : .25;
    return Container(
      color: color,
      child: RotationTransition(
        turns: AlwaysStoppedAnimation(rotation),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Raleway',
                  color: Colors.white,
                  fontSize: 120.0)),
        ),
      ),
    );
  }

  Widget _buildPetInfo(Animal pet) {
    var sideInfo = TextStyle(
      color: Colors.grey[600],
    );
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: _screenHeight / 1.65 - 110,
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(pet.imgUrl),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text(
                  '${pet.name},',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.headline,
                ),
                SizedBox(width: 5.0),
                Expanded(
                  child: Text(
                    pet.age,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.subhead,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(pet.gender, style: sideInfo),
                Text(pet.cityState, style: sideInfo),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(pet.breed, style: sideInfo),
            ),
          ),
        ]);
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
                  Navigator
                      .push(
                          context,
                          PageRouteBuilder(
                              maintainState: false,
                              pageBuilder: (context, _, __) =>
                                  SettingsPage(feed: this.feed)))
                      .then((result) {
                    if (result == true) {
                      setState(() {
                        _hasInfo = true;
                        this.feed.done = false;
                        _initializeAnimalList();
                      });
                    }
                  });
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
            setState(() {
              feed.getRecentlySkipped();
            });
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
          onPressed: () {
            Animal pet = feed.currentList[feed.currentList.length - 1];
            if (_swipingRight) setState(() => _swipingRight = false);
            _runAnimation().then((_) {
              _removePet(pet);
            });
          },
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
          onPressed: () {
            Animal pet = feed.currentList[feed.currentList.length - 1];
            _savePet(pet);
            if (!_swipingRight) setState(() => _swipingRight = true);
            _runAnimation().then((_) {
              _removePet(pet);
            });
          },
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
            Navigator
                .push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SettingsPage(feed: this.feed)))
                .then((result) {
              if (result == true) {
                this.feed.done = false;
                _initializeAnimalList();
              }
            });
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

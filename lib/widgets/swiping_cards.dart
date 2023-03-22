import 'package:flutter/material.dart';
import 'package:petadopt/notifiers/swiping_notifier.dart';

import '../animals.dart';
import '../api.dart';
import '../colors.dart';
import '../details.dart';
import 'draggable_card.dart';

class SwipingCards extends StatefulWidget {
  SwipingCards({required this.feed});
  final AnimalFeed feed;
  @override
  _SwipingCardsState createState() => _SwipingCardsState();
}

class _SwipingCardsState extends State<SwipingCards>
    with AutomaticKeepAliveClientMixin<SwipingCards> {
  @override
  bool get wantKeepAlive => true;

  bool _loading = false;

  double _backCardScale = 0.9;

  @override
  void initState() {
    super.initState();
    widget.feed.notifier.addListener(onSwipeChange);
    widget.feed.themeNotifier.addListener(onThemeChanged);
  }

  onSwipeChange() {
    if (widget.feed.notifier.swiped == Swiped.undo) {
      setState(() {
        widget.feed.getRecentlySkipped();
      });
    }
  }

  onThemeChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.feed.notifier.removeListener(onSwipeChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) {
      Size screenSize = MediaQuery.of(context).size;
      double _screenWidth = screenSize.width;
      double _screenHeight = screenSize.height;
      return Container(
          height: _screenHeight / 1.65,
          width: _screenWidth / 1.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(strokeWidth: 1.0),
            ],
          ));
    }
    if (widget.feed.currentList.isEmpty) return buildNoPetsLeftPage();
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        widget.feed.nextPet == null
            ? SizedBox()
            : Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scale(_backCardScale, _backCardScale),
                child: PetCard(widget.feed.nextPet!),
              ),
        DraggableCard(
          onLeftSwipe: () {
            setState(() {
              widget.feed.skip();
            });
          },
          onSlideBack: () {},
          onRightSwipe: () {
            setState(() {
              widget.feed.like();
            });
          },
          onSwipe: (Offset offset) {
            setState(() {
              _backCardScale =
                  0.9 + (0.1 * (offset.distance / 150)).clamp(0.0, 0.1);
            });
          },
          notifier: widget.feed.notifier,
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailsPage(
                      pet: widget.feed.currentPet, feed: widget.feed))),
          child: PetCard(widget.feed.currentPet,
              widget.feed.themeNotifier.lightModeEnabled),
        ),
      ],
    );
  }

  buildNoPetsLeftPage() {
    Size screenSize = MediaQuery.of(context).size;
    double _screenWidth = screenSize.width;
    double _screenHeight = screenSize.height;
    return Container(
      height: _screenHeight / 1.65,
      width: _screenWidth / 1.2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Icon(Icons.sentiment_dissatisfied, size: 90.0),
          Text("No more pets"),
          TextButton(
            onPressed: () {
              setState(() {
                _loading = true;
                widget.feed.reInitialize().then((result) {
                  if (result)
                    setState(() {
                      _loading = false;
                    });
                });
              });
            },
            child: Text("Start over"),
          ),
        ],
      ),
    );
  }
}

/// Widget to allow for better handling of pet cards and swiping them.
class PetCard extends StatelessWidget {
  final Animal pet;
  final bool lightModeEnabled;
  PetCard(this.pet, this.lightModeEnabled);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double _screenWidth = screenSize.width;
    double _screenHeight = screenSize.height;

    var sideInfo = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 15,
        );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade900,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0.0, 2.0),
            spreadRadius: 0.5,
            blurRadius: 4.0,
            color: Colors.black.withOpacity(.1),
          )
        ],
      ),
      height: _screenHeight / 1.53,
      width: _screenWidth / 1.05,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: _screenHeight / 1.56 - 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  color: Colors.black,
                  image: pet.info.imgUrl[0].isEmpty
                      ? null
                      : DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(pet.info.imgUrl[0]),
                        ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: pet.info.imgUrl.map((_) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    width: 6.0,
                    height: 6.0,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Flexible(
                  child: Container(
                    child: Text(
                      '${pet.info.name},',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: 26),
                    ),
                  ),
                ),
                SizedBox(width: 6.0),
                Expanded(
                  child: Text(
                    pet.info.age,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontSize: 22),
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
                Text(pet.info.gender, style: sideInfo),
                Row(
                  children: <Widget>[
                    Icon(Icons.location_on, size: 15.0, color: Colors.grey),
                    Text(pet.info.cityState, style: sideInfo),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                pet.info.breed,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: sideInfo,
              ),
            ),
          ),
          _buildTags(pet),
        ],
      ),
    );
  }

  Widget _buildTags(Animal pet) {
    if (pet.info.options.isEmpty) return SizedBox();
    return Container(
      padding: const EdgeInsets.only(left: 8.0),
      height: 30.0,
      child: Row(
        children: <Widget>[
          pet.info.spayedNeutered
              ? Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Text(pet.info.gender == 'Male' ? "Neutered" : "Spayed",
                      style: const TextStyle(
                          color: kPetThemecolor, fontWeight: FontWeight.bold)),
                )
              : SizedBox(),
          pet.info.options.length > 1
              ? Icon(
                  Icons.more,
                  color: kPetThemecolor,
                )
              : SizedBox(),
        ],
      ),
    );
  }
}

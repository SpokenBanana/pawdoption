import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'animals.dart';
import 'api.dart';
import 'colors.dart';
import 'petfinder_lib/petfinder.dart';
import 'protos/animals.pb.dart';
import 'widgets/pet_image_gallery.dart';

/// Shows detailed profile for the animal.
class DetailsPage extends StatefulWidget {
  DetailsPage({Key key, this.pet}) : super(key: key);

  final Animal pet;

  @override
  _DetailsPage createState() => _DetailsPage();
}

class _DetailsPage extends State<DetailsPage> {
  List<String> urls;
  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: key,
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        title: Text(widget.pet.info.name,
            style: const TextStyle(fontFamily: 'Raleway')),
      ),
      body: ListView(
        children: <Widget>[
          PetImageGallery(
            widget.pet.info.imgUrl,
            tag: widget.pet.info.apiId,
          ),
          _buildDogInfo(widget.pet.info),
          Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text("Comments about ${widget.pet.info.name}:",
                style: const TextStyle(fontFamily: 'Raleway', fontSize: 20.0)),
          ),
          _fetchAndBuildComments(key),
          Divider(),
          _buildOptionTagSection(widget.pet.info),
          _buildAdoptInfo(),
          !widget.pet.info.hasId()
              ? SizedBox()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Tell them you want to adopt ${widget.pet.info.name}"
                        " whose ID is ${widget.pet.info.id}.",
                    textAlign: TextAlign.center,
                  ),
                ),
        ],
      ),
    );
  }

  _getUrls(String description) {
    urls = List<String>();
    var urlMatches = RegExp(kUrlRegex).allMatches(description);
    for (Match m in urlMatches) {
      urls.add(m.group(0));
    }
  }

  Widget _fetchAndBuildComments(GlobalKey<ScaffoldState> key) {
    if (widget.pet.description != null) {
      _getUrls(widget.pet.description);
      return _buildComments(widget.pet.description, urls, key);
    }
    return FutureBuilder(
      future: getDetailsAbout(widget.pet),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('Wait..');
          case ConnectionState.waiting:
            return Text('Loading...');
          default:
            if (snapshot.hasError)
              return new Text('Couldn\'t get the comments :( ');
            else {
              urls = snapshot.data.sublist(1);
              return _buildComments(snapshot.data[0], urls, key);
            }
        }
      },
    );
  }

  Widget _buildComments(
      String comments, List<String> urls, GlobalKey<ScaffoldState> key) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: RichText(
            text: TextSpan(
              text: comments,
              style: Theme.of(context).textTheme.body1,
            ),
          ),
        ),
        _buildLinkSection(urls, key),
      ],
    );
  }

  Widget _createInfoRow(String title, String item) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Text(
            title,
            style: const TextStyle(
                fontFamily: 'Raleway',
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
            child: Text(item,
                style: const TextStyle(fontFamily: 'Raleway', fontSize: 20.0))),
      ],
    );
  }

  Widget _buildDogInfo(AnimalData pet) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _createInfoRow("Breed:", pet.breed),
            _createInfoRow("Gender:", pet.gender),
            _createInfoRow("Age:", pet.age),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTagSection(AnimalData pet) {
    if (pet.options == null || pet.options.isEmpty) return SizedBox();
    return Column(
      children: <Widget>[
        Text("Pet Tags"),
        _buildOptionTags(),
        Divider(),
      ],
    );
  }

  Widget _buildOptionTags() {
    return Container(
      height: 30.0,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: widget.pet.info.options.map((option) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              Animal.parseOption(option, widget.pet.info),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: kPetThemecolor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUrlTags(List<String> urls, GlobalKey<ScaffoldState> key) {
    return Container(
      height: 50.0,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: urls.map((String url) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () async {
                if (await canLaunch(url)) {
                  await launch(url);
                }
              },
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: url));
                key.currentState.showSnackBar(SnackBar(
                  content: Text("Copied!"),
                ));
              },
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    url,
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      color: Theme.of(context).indicatorColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShelterDescription(ShelterInformation shelter) {
    if (shelter == null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Shelter opted out of giving information :("),
      );
    }
    var linkStyle = TextStyle(
      fontFamily: "OpenSans",
      color: Theme.of(context).indicatorColor,
    );
    var normalStyle = Theme.of(context).textTheme.body1;
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
              child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "I am at ",
              style: normalStyle,
              children: <TextSpan>[
                TextSpan(
                  text: "${shelter.name}, "
                      "${shelter.location}",
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      String search = Uri.encodeComponent("${shelter.name}, "
                          "${shelter.location}");
                      String url = "geo:0,0?q=$search";
                      if (await canLaunch(url)) launch(url);
                    },
                ),
              ],
            ),
          )),
          shelter.phone == ""
              ? Text("No phone number available, go visit!")
              : RichText(
                  text: TextSpan(
                    text: "Go visit or call ",
                    children: <TextSpan>[
                      TextSpan(
                        text: shelter.phone,
                        style: linkStyle,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            String url = "tel://${shelter.phone}";
                            if (await canLaunch(url)) launch(url);
                          },
                      ),
                    ],
                    style: normalStyle,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildAdoptInfo() {
    return Column(
      children: <Widget>[
        Text(
          "Adopt ${widget.pet.info.name}!",
          style: const TextStyle(
              fontFamily: "Raleway",
              fontSize: 23.0,
              fontWeight: FontWeight.bold),
        ),
        FutureBuilder(
          future: getShelterInformation(widget.pet.info.shelterId),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text('Wait..');
              case ConnectionState.waiting:
                return Text('Loading shleter information...');
              default:
                if (snapshot.hasError)
                  return new Text(
                      'Couldn\'t get the information :( ${snapshot.error}');
                else
                  return _buildShelterDescription(snapshot.data);
            }
          },
        ),
      ],
    );
  }

  Widget _buildLinkSection(List<String> urls, key) {
    if (urls.isEmpty) return SizedBox();
    return Column(
      children: <Widget>[
        Divider(),
        Text("Links found:"),
        _buildUrlTags(urls, key),
        Text("Long press link to copy",
            style: const TextStyle(color: Colors.grey, fontSize: 12.0))
      ],
    );
  }
}

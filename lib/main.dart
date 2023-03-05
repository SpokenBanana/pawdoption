import 'package:flutter/material.dart';

import 'api.dart';
import 'colors.dart';
import 'saved.dart';
import 'swiping.dart';

void main() => runApp(new MyApp());

final AnimalFeed feed = AnimalFeed();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    feed.loadLiked();
    return MaterialApp(
        title: 'Pawdoption',
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            bottomNavigationBar: _buildTabBar(),
            body: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  SwipingPage(key: UniqueKey(), feed: feed),
                  SavedPage(feed: feed),
                ]),
          ),
        ));
  }

  Widget _buildTabBar() {
    return Container(
      height: 60.0,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.4), blurRadius: 5.0)
        ],
      ),
      child: TabBar(
        indicatorWeight: 0.1,
        labelColor: kPetThemecolor,
        unselectedLabelColor: Colors.grey,
        tabs: <Widget>[
          Tab(icon: ImageIcon(AssetImage('assets/app_black_icon.png'))),
          Tab(icon: Icon(Icons.favorite)),
        ],
      ),
    );
  }
}

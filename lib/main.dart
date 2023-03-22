import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';
import 'colors.dart';
import 'saved.dart';
import 'swiping.dart';
import 'protos/pet_search_options.pb.dart';

void main() => runApp(new MyApp());

final AnimalFeed feed = AnimalFeed();
ThemeData mainTheme;

class MyApp extends StatefulWidget {
  bool darkMode = true;
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  _MyAppState() {
    SharedPreferences.getInstance().then((prefs) {
      final optionsStr = prefs.getString('searchOptions') ?? '';
      PetSearchOptions options = kDefaultOptions;
      if (optionsStr.isNotEmpty)
        options = PetSearchOptions.fromJson(optionsStr);
      if (options.lightModeEnable != feed.themeNotifier.lightModeEnabled)
        feed.themeNotifier.setTheme(options.lightModeEnable);
    });
  }
  @override
  Widget build(BuildContext context) {
    feed.loadLiked();
    feed.themeNotifier.addListener(whenThemeChanged);
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

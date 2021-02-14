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
    ThemeData mainTheme =
        this.widget.darkMode ? _buildDarkTheme() : _buildTheme();
    feed.loadLiked();
    feed.themeNotifier.addListener(whenThemeChanged);
    return MaterialApp(
        title: 'Pawdoption',
        theme: mainTheme,
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            bottomNavigationBar: _buildTabBar(mainTheme),
            body: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  SwipingPage(feed: feed),
                  SavedPage(feed: feed),
                ]),
          ),
        ));
  }

  void whenThemeChanged() {
    setState(() {
      this.widget.darkMode = !feed.themeNotifier.lightModeEnabled;
    });
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      height: 60.0,
      decoration: BoxDecoration(
        color: theme.bottomAppBarColor,
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
          Tab(icon: Icon(Icons.favorite_border)),
        ],
      ),
    );
  }

  ThemeData _buildTheme() {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      brightness: Brightness.light,
      primaryColor: Colors.white,
      primaryColorDark: kPetPrimaryText,
      accentColor: Colors.black,
      canvasColor: Colors.white,
      scaffoldBackgroundColor: kPetGray,
      buttonColor: Colors.white,
      primaryIconTheme: base.iconTheme.copyWith(
        color: Colors.grey,
      ),
      primaryTextTheme: base.textTheme.copyWith(),
      textTheme: base.textTheme.copyWith(),
    );
  }

  ThemeData _buildDarkTheme() {
    final ThemeData base = ThemeData.dark();
    return base.copyWith(
      indicatorColor: Colors.blue[600],
      brightness: Brightness.dark,
      accentColor: Colors.white,
      primaryTextTheme: base.primaryTextTheme.copyWith(),
      textTheme: base.textTheme.copyWith().apply(),
      buttonColor: Colors.grey[700],
      buttonTheme: base.buttonTheme.copyWith(),
    );
  }
}

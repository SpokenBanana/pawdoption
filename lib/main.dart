import 'package:flutter/material.dart';

import 'colors.dart';
import 'saved.dart';
import 'swiping.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData mainTheme = _buildTheme();
    return MaterialApp(
        title: 'Pawdoption',
        theme: mainTheme,
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
          length: 3,
          child: Scaffold(
            bottomNavigationBar: _buildTabBar(mainTheme),
            body: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  SwipingPage(title: 'Petdoption'),
                  SavedPage(),
                ]),
          ),
        ));
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
          Tab(
              icon: ImageIcon(
            AssetImage('assets/app_black_icon.png'),
          )),
          Tab(icon: Icon(Icons.favorite_border)),
        ],
      ),
    );
  }

  ThemeData _buildTheme() {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      primaryColor: Colors.white,
      primaryColorDark: kPetPrimaryText,
      accentColor: Colors.black,
      canvasColor: Colors.white,
      scaffoldBackgroundColor: kPetGray,
      buttonColor: Colors.white,
      primaryIconTheme: base.iconTheme.copyWith(
        color: Color(0xFF555555),
      ),
      primaryTextTheme: base.textTheme.copyWith(
        title: TextStyle(
          color: kPetPrimaryText,
          fontFamily: "Raleway",
          fontSize: 25.0,
        ),
        subhead: TextStyle(
          color: Colors.grey[600],
          fontFamily: 'Raleway',
          fontSize: 22.0,
        ),
      ),
      textTheme: base.textTheme.copyWith(
        title: TextStyle(
          color: kPetPrimaryText,
          fontFamily: "LobsterTwo",
          fontSize: 25.0,
        ),
        headline: TextStyle(
          color: kPetPrimaryText,
          fontFamily: 'Raleway',
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
        ),
        subhead: TextStyle(
          color: Colors.grey[600],
          fontFamily: 'Raleway',
          fontSize: 22.0,
        ),
        caption: TextStyle(
          color: Colors.grey,
          fontFamily: 'OpenSans',
          fontSize: 14.0,
        ),
        body1: TextStyle(
          color: kPetPrimaryText,
          fontFamily: 'OpenSans',
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final ThemeData base = ThemeData.dark();
    return base.copyWith(
      indicatorColor: Colors.blue[600],
      accentColor: Colors.white,
      primaryTextTheme: base.primaryTextTheme.copyWith(
        title: TextStyle(
          color: Colors.grey[200],
          fontFamily: "Raleway",
          fontSize: 25.0,
        ),
      ),
      textTheme: base.textTheme
          .copyWith(
              title: TextStyle(
                color: Colors.grey[200],
                fontFamily: "LobsterTwo",
                fontSize: 25.0,
              ),
              headline: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey[300],
              ),
              subhead: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 22.0,
                color: Colors.grey[400],
              ),
              caption: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14.0,
                color: Colors.grey,
              ),
              body1: TextStyle(
                fontFamily: 'OpenSans',
                color: Colors.grey[300],
              ))
          .apply(),
      buttonColor: Colors.grey[700],
      buttonTheme: base.buttonTheme.copyWith(),
    );
  }
}

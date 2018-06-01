import 'package:flutter/material.dart';
import 'colors.dart';
import 'saved.dart';
import 'swiping.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Pawdoption',
        theme: _buildTheme(),
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
          length: 3,
          child: Scaffold(
            bottomNavigationBar: _buildTabBar(),
            body: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  SwipingPage(title: 'Petdoption'),
                  SavedPage(),
                ]),
          ),
        ));
  }

  Widget _buildTabBar() {
    return Container(
      height: 60.0,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5.0)],
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
      primaryColor: kPetPrimary,
      scaffoldBackgroundColor: kPetGray,
      primaryIconTheme: base.iconTheme.copyWith(
        color: Color(0xFF555555),
      ),
      primaryTextTheme: base.textTheme.copyWith().apply(
            fontFamily: 'OpenSans',
            displayColor: kPetPrimaryText,
            bodyColor: kPetPrimaryText,
          ),
      textTheme: base.textTheme.copyWith().apply(
            fontFamily: 'OpenSans',
            displayColor: kPetPrimaryText,
            bodyColor: kPetPrimaryText,
          ),
    );
  }
}

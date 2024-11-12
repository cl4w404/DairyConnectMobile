import 'dart:developer';

import 'package:dairy_connect/controller/account.dart';
import 'package:dairy_connect/controller/landing_page.dart';
import 'package:dairy_connect/controller/services.dart';
import 'package:dairy_connect/controller/withdrawals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class Landin extends StatefulWidget {
  Landin({Key? key}) : super(key: key);

  @override
  _LandinState createState() => _LandinState();
}

class _LandinState extends State<Landin> {
  var _currentIndex = 0;
  List<Widget> screen = [
    LandingPage(),
    Services(),
    Account(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SalomonBottomBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange.shade50,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          /// Home
          SalomonBottomBarItem(
              icon: Icon(Icons.home),
              title: Text("Home"),
              selectedColor: Colors.green.shade900,
              activeIcon: Icon(CupertinoIcons.home),
              unselectedColor: Colors.blue.shade900),

          /// Likes
          /*SalomonBottomBarItem(
              icon: Icon(Icons.home_repair_service),
              title: Text("Services"),
              unselectedColor: Colors.green.shade900,
              activeIcon: Icon(Icons.home_repair_service_outlined),
              selectedColor: Colors.blue.shade900
          ),*/

          /// Search
          SalomonBottomBarItem(
            icon: Icon(CupertinoIcons.money_dollar_circle),
            title: Text("Services"),
            activeIcon: Icon(CupertinoIcons.money_dollar),
            unselectedColor: Colors.blue.shade900,
            selectedColor: Colors.green.shade900,
          ),

          /// Profile
          SalomonBottomBarItem(
              icon: Icon(CupertinoIcons.person),
              title: Text("Account"),
              unselectedColor: Colors.blue.shade900,
              selectedColor: Colors.green.shade900),
        ],
      ),
      body:
          Container(color: Colors.green.shade50, child: screen[_currentIndex]),
    );
  }
}

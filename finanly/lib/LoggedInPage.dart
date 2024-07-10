import 'package:finanly/MainHomePage.dart';
import 'package:finanly/user_interface.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'FileUploadScreen.dart';
import 'User_List.dart';
import 'main.dart';



late String name;

class LoggedInPage extends StatefulWidget {
  LoggedInPage({required String name1}) {
    name = name1;
  }

  @override
  _LoggedInPageState createState() => _LoggedInPageState();
}

class _LoggedInPageState extends State<LoggedInPage> {
  int _selectedIndex = 0;
  late String name3;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    name3 = name;
    _widgetOptions = <Widget>[
      MainHomePage(name: name3),
      ImageUploadScreen(name: name3),
      sbsun(),
      UserInterface(UserName: name3),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'stats.dart';
import 'questions.dart';

class Dash extends StatefulWidget {
  const Dash({Key? key}) : super(key: key);
  static List<double> lastList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  static List<String> yListe = [];

  @override
  _DashState createState() => _DashState();
}

class _DashState extends State<Dash> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const Stats(),
    const Questions(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222831),
      //resizeToAvoidBottomInset: false,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.query_stats,
              color: Colors.white,
            ),
            label: "Charts",
            backgroundColor: Color(0xFF1ABAB0),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat,
              color: Colors.white,
            ),
            label: "Discussions",
            backgroundColor: Color(0xFF0082AB),
          )
        ],
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.shifting,
        onTap: _onItemTapped,
        fixedColor: Colors.black,
        elevation: 10,
        iconSize: 30,
        showUnselectedLabels: true,
        unselectedItemColor: Colors.black,
      ),
    );
  }
}

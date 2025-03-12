import 'package:flutter/material.dart';
import 'home-page.dart';
import 'user-page.dart';
import '../components/bottom-bar.dart';

class HomeWithBottomBar extends StatefulWidget {
  @override
  _HomeWithBottomBarState createState() => _HomeWithBottomBarState();
}

class _HomeWithBottomBarState extends State<HomeWithBottomBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    UserPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Exibe a página selecionada
      bottomNavigationBar: BottomBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}

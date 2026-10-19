import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/searchPage.dart';
import 'package:flutter_application_1/pages/library_screen.dart';
import 'package:flutter_application_1/pages/videoLibPage.dart';
import 'package:flutter_application_1/pages/homePage.dart';
class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}
class _StartPageState extends State<StartPage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = const [
    HomePage(),
    SearchPage(), // Index 0: Deine Suchseite
    LibraryPage(),
    VideoLibPage()
  ];

  // (Optional) Titel für die AppBar passend zum Tab
  final List<String> _titles = const [
    "Startseite",
    "Suchen",
    "Bibliothek",
    "VideoLib",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem( 
            icon: Icon(Icons.library_add),
            label: "Bibliothek",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: "VideoOrdner",
          ),
        ]
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPaageState();
}

class _SearchPaageState extends State<SearchPage> {

  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _searchResults =  [];
  bool _isLaoding = false;

  void _performSearch(String query) async  {
    if (query.isEmpty) return;
    
    setState(() {
      _isLaoding = true;
    });

    // api call
  } 
 @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.shade100, // Blauer Hintergrund
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              "Hier kommt die YouTube-Suche hin!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
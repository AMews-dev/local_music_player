import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/media_service.dart';
import 'package:flutter_application_1/widgets/song_list_view.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final MediaService _mediaService = MediaService();

  List<SongModel> _allSongs = [];
  List<SongModel> _favoriteSongs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Daten einmalig beim Start laden
  Future<void> _loadData() async {
    // 1. Berechtigung prüfen & Alle Songs laden (inkl. deiner Duplikat-Filterung)
    final songs = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
    );

    // Echte Dateipfad-Duplikate filtern
    final seenPaths = <String>{};
    final uniqueSongs = songs.where((song) => seenPaths.add(song.data)).toList();

    // 2. Favoriten-IDs laden
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorite_songs') ?? [];

    // 3. Favoriten-Liste filtern
    final favorites = uniqueSongs
        .where((song) => favoriteIds.contains(song.id.toString()))
        .toList();

    setState(() {
      _allSongs = uniqueSongs;
      _favoriteSongs = favorites;
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mediathek"),
       bottom: const TabBar(
            isScrollable: true, // Erlaubt das seitliche Scrollen, wenn es zu viele Tabs sind
            indicatorColor: Colors.green, // Farbe des aktiven Unterstrichs
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Ordner"),
              Tab(text: "Playlists"),
              Tab(text: "Alle Songs"),
              Tab(text: "Künstler"),
              Tab(text: "Titel"),
            ],
          ),
        ),
        // Hier definierst du, welcher Inhalt bei welchem Tab angezeigt werden soll
        body:  TabBarView(
          children: [
            Center(child: Text("Hier kommen deine Ordner hin")),
            Center(child: Text("Hier kommen deine Playlists hin")),
            Center(child: Text("Hier kommt die Liste aller Songs hin")),
            Center(child: Text("Hier kommen die Künstler hin")),
            SongListView(songs: _allSongs)
          ],
        ),
      ),
    );
  }
}
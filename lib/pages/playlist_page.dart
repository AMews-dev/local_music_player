

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/category_list_page.dart';
import 'package:flutter_application_1/pages/folder_detail_page.dart';
import 'package:flutter_application_1/services/music_controller.dart';
import 'package:flutter_application_1/widgets/song_list_view.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key,});
  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  Map<String, List<SongModel>> categories = {};

  
  final MusicController controller = MusicController();
  final OnAudioQuery _audioQuery = OnAudioQuery();
  bool _isLoading = false; // Oder je nach Ladezustand

  @override
  Widget build(BuildContext context) {

  final Map<String, List<SongModel>> categories = {
      "Favoriten": controller.favoriteSongs, // Falls es eine Methode ist, ansonsten controller.favoriteSongs ohne Klammern
      ...controller.customPlaylists,             // Fügt alle Custom Playlists hinzu
    };
    if(_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (categories.isEmpty) {
      return const Center(
        child: Text("Keine Songs auf dem Gerät gefunden."),
      );
    }
   return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        // Korrigiert: Nutze 'categories' statt '_ordner'
        final categoryName = categories.keys.elementAt(index);
        final songsInCategory = categories[categoryName]!;

        // Bestimme das Icon (Favoriten bekommen ein Herz, Playlists eine Note)
        final isFavorite = categoryName == "Favoriten";
        final firstSong = songsInCategory.isNotEmpty ? songsInCategory.first : null;
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: SizedBox(
      width: 50,
      height: 50,
      child: firstSong != null
          ? QueryArtworkWidget(
              controller: _audioQuery, // Dein AudioQuery-Objekt (oder _mediaService)
              id: firstSong.id,
              type: ArtworkType.AUDIO,
              nullArtworkWidget: Container(
                color: Colors.grey[800],
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.folder,
                  color: Colors.white,
                ),
              ),
            )
          : Container(
              color: Colors.grey[800],
              child: const Icon(Icons.music_note, color: Colors.white),
            ),
            ),
          ),
          
          title: Text(categoryName),
          subtitle: Text('${songsInCategory.length} Songs'),
          onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FolderDetailPage(
                folderName: categoryName, songs: 
                songsInCategory)));

           
          },
        );
      },
    );
  }
}
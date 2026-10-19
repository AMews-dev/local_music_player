import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/song_list_view.dart';
import "package:on_audio_query/on_audio_query.dart";
class FolderDetailPage extends StatefulWidget {
  final String folderName;
  final List<SongModel> songs;

  const FolderDetailPage({
    super.key,
    required this.folderName,
    required this.songs,
  });
  
  

  @override
  State<FolderDetailPage> createState() => _FolderDetailPageState();
}

class _FolderDetailPageState extends State<FolderDetailPage> {
  @override
  Widget build(BuildContext context) {
    // Hier kommt gleich dein Scaffold und ListView rein!
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName), // Zeigt den Ordnernamen oben an
      ),
      body:  SongListView(songs: widget.songs)// Platzhalter für die Song-Liste
    );
  }
}
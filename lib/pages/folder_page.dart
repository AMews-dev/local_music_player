import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/folder_detail_page.dart';
import 'package:flutter_application_1/services/media_service.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FolderPage extends StatefulWidget {
  const FolderPage({super.key});

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  final MediaService _mediaService = MediaService();
  List<SongModel> _songs = [];
  Map<String, List<SongModel>> _ordner = {}; 
  bool _isLoading = true;

  @override 
  void initState() {
    super.initState();
    _loadOrdner();
  }

  Future<void> _loadOrdner() async {
    final ordner = await _mediaService.getAllOrdner();
    setState(() {
      _ordner = ordner;
      _isLoading = false;
    });
  }

  Future<void> _loadSongs() async {
    final songs = await _mediaService.getAllSongs();
    setState(() {   
        _songs = songs;
        _isLoading = false;
      });
  }

  


  @override
  Widget build(BuildContext context) {
    if(_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_ordner.isEmpty) {
      return const Center(
        child: Text("Keine Songs auf dem Gerät gefunden."),
      );
    }
    return ListView.builder(
      itemCount: _ordner.length,
      itemBuilder: (context, index) {
        // 1. folderpath 
      final folderPath = _ordner.keys.elementAt(index);
      
      // 2. list of song in folder
      final songsInFolder = _ordner[folderPath]!;
      
      // 3. 
      final folderName = folderPath.split('/').last;
        return ListTile(
          leading: const Icon(Icons.music_note, color: Colors.blue),
          title: Text(folderName),
          subtitle: Text('${songsInFolder.length} Songs'), // Zeigt an, wie viele Songs drin sind
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FolderDetailPage(folderName: folderName, songs: songsInFolder)));
          },
        );
      },
    );
  }
}
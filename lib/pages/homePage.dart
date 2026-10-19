import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/media_service.dart';
import 'package:flutter_application_1/widgets/song_list_view.dart';
import 'package:on_audio_query/on_audio_query.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final MediaService _mediaService = MediaService();
  List<SongModel> _songs = [];
  bool _isLoading = true;

  @override 
  void initState() {
    super.initState();
    _loadSongs();
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
    return Scaffold(
      appBar: AppBar(
        title: Text("My Home")
      ),
      body: SongListView(songs: _songs)
    );
   
  }
}
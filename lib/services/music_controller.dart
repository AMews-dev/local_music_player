import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MusicController {
  // 1. Singleton-Muster mit Factory
  static final MusicController _instance = MusicController._internal();
  factory MusicController() => _instance;
  MusicController._internal();

  final List<SongModel> favoriteSongs = [];
   
  bool isFavoriteSong(SongModel song) {
    return favoriteSongs.any((s) => s.id == song.id);
  }

 void toggleFavorite(SongModel song) {
    if (isFavoriteSong(song)) {
      favoriteSongs.removeWhere((s) => s.id == song.id);
      print("❌ AUS FAVORITEN ENTFERNT: ${song.title}");
    } else {
      favoriteSongs.add(song);
      print("❤️ ZU FAVORITEN HINZUGEFÜGT: ${song.title}");
    }
  }


  final Map<String, List<SongModel>> customPlaylists = {};
  void createPlaylist(String playlistName, SongModel initalSong) {
    customPlaylists[playlistName] = [initalSong];
  }

  void addSongToPlaylist(String playlistName, SongModel song) {
    if(customPlaylists.containsKey(playlistName)) {
      customPlaylists[playlistName]!.add(song);
    }
  }

  // 2. Der globale AudioPlayer und die klassische ConcatenatingAudioSource
  final AudioPlayer audioPlayer = AudioPlayer();
  List<SongModel> currentPlaylist = [];
  
  //globale lock against fast klicking 
  bool _isChangingTrack = false;
  bool _isQueuing = false;
  // Playlist starten

  Future<void> playPlaylist(List<SongModel> playlist, int initialIndex) async {
    if (_isChangingTrack) return;
    _isChangingTrack = true;
   try {
    currentPlaylist = playlist;
    await audioPlayer.stop();
    // Songs in AudioSources umwandeln
    final List<AudioSource> sources = playlist.map<AudioSource>((song) {
        return AudioSource.uri(Uri.parse(song.data));
      }).toList();

      // Playlist setzen in 0.10.x
      await audioPlayer.setAudioSources(
        sources,
        initialIndex: initialIndex,
      );
      
      audioPlayer.play();
      audioPlayer.setLoopMode(LoopMode.all); // allow  endless loop
    } catch (e) {
      print("Fehler beim Abspielen der Playlist: $e");
    } finally {
      await Future.delayed(const Duration(milliseconds: 300));
      _isChangingTrack = false;
    }
  }

  // "Als Nächstes spielen" – absolut unkompliziert mit der klassischen API!
 Future<void> playNext(SongModel newSong) async {
  if(_isQueuing) return;
  _isQueuing = true;
    try {
      if (currentPlaylist.isEmpty) {
        playPlaylist([newSong], 0);
        return;
      }

      final currentIndex = audioPlayer.currentIndex ?? 0;
      final insertIndex = currentIndex + 1;

      // 1. In die lokale Liste einfügen
      currentPlaylist.insert(insertIndex, newSong);

      // 2. Playlist neu aufbauen mit Typ-Erzwingung <AudioSource>
      final List<AudioSource> sources = currentPlaylist.map<AudioSource>((song) {
        return AudioSource.uri(Uri.parse(song.data));
      }).toList();

      await audioPlayer.setAudioSources(
        sources,
        initialIndex: currentIndex, // Hält den aktuellen Song exakt an seiner Position
      );

      print("Song '${newSong.title}' wurde erfolgreich als Nächstes eingereiht!");
    } catch (e) {
      print("Fehler beim 'Als Nächstes spielen': $e");
    } finally {
      await Future.delayed(const Duration(milliseconds: 200));
      _isQueuing = false;
    }
  }

  Future<void> skipNext() async {
    if (_isChangingTrack) return;
    _isChangingTrack = true;

    try {
      final currentIndex = audioPlayer.currentIndex ?? 0;
      if (currentIndex < currentPlaylist.length - 1) {
        await audioPlayer.seekToNext();
      } else {
        // Wrap-Around zum Anfang (optional)
        await audioPlayer.seek(Duration.zero, index: 0);
      }
    } finally {
      await Future.delayed(const Duration(milliseconds: 300));
      _isChangingTrack = false;
    }
  }

  // 4. Optional: Vorherigen Song überspringen direkt im Controller steuern
  Future<void> skipPrevious() async {
    if (_isChangingTrack) return;
    _isChangingTrack = true;

    try {
      final currentIndex = audioPlayer.currentIndex ?? 0;
      if (currentIndex > 0) {
        await audioPlayer.seekToPrevious();
      } else {
        // Wrap-Around zum Ende (optional)
        final lastIndex = currentPlaylist.length - 1;
        await audioPlayer.seek(Duration.zero, index: lastIndex);
      }
    } finally {
      await Future.delayed(const Duration(milliseconds: 300));
      _isChangingTrack = false;
    }
  }


}
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MusicController {
  // 1. Singleton-Muster mit Factory
  static final MusicController _instance = MusicController._internal();
  factory MusicController() => _instance;
  MusicController._internal();

  // 2. Der globale AudioPlayer und die klassische ConcatenatingAudioSource
  final AudioPlayer audioPlayer = AudioPlayer();
  List<SongModel> currentPlaylist = [];
  

  // Playlist starten
  Future<void> playPlaylist(List<SongModel> playlist, int initialIndex) async {
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
    }
  }

  // "Als Nächstes spielen" – absolut unkompliziert mit der klassischen API!
 Future<void> playNext(SongModel newSong) async {
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
    }
  }
}
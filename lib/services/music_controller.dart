import 'dart:convert';

import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicController {
  // 1. Singleton-Muster mit Factory
  static final MusicController _instance = MusicController._internal();
  factory MusicController() => _instance;
  MusicController._internal();

  List<SongModel> favoriteSongs = [];
  Map<String, List<SongModel>> customPlaylists = {};


  // run once at start
  Future<void> initPrefs() async {
    print("🚀 initPrefs gestartet...");
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Favoriten laden
      final String? favsJson = prefs.getString('saved_favorites');
      if (favsJson != null) {
        final List decoded = jsonDecode(favsJson);
        favoriteSongs = decoded.map((map) {
          final rawMap = map as Map<String, dynamic>;
          
          // Vollständiges Mapping mit allen möglichen Feldern und Fallbacks
          final Map<String, dynamic> convertedMap = {
            '_id': rawMap['id'] ?? rawMap['_id'] ?? 0,
            '_data': rawMap['data'] ?? rawMap['_data'] ?? '',
            '_title': rawMap['title'] ?? rawMap['_title'] ?? 'Unbekannter Titel',
            '_artist': rawMap['artist'] ?? rawMap['_artist'] ?? 'Unbekannter Interpret',
            '_album': rawMap['album'] ?? rawMap['_album'] ?? '',
            '_duration': rawMap['duration'] ?? rawMap['_duration'] ?? 0,
            '_size': rawMap['size'] ?? rawMap['_size'] ?? 0,
            '_display_name': rawMap['display_name'] ?? rawMap['_display_name'] ?? '',
            'track': rawMap['track'] ?? 0,
            'year': rawMap['year'] ?? 0,
          };
          
          return SongModel(convertedMap);
        }).toList();
        print("❤️ Favoriten geladen: ${favoriteSongs.length}");
      }

      // 2. Playlists laden
      final String? playlistsJson = prefs.getString('saved_playlists');
      if (playlistsJson != null) {
        final Map<String, dynamic> decodedMap = jsonDecode(playlistsJson);
        customPlaylists = decodedMap.map((key, value) {
          final List songList = value;
          final songs = songList.map((map) {
            final rawMap = map as Map<String, dynamic>;
            
            final Map<String, dynamic> convertedMap = {
              '_id': rawMap['id'] ?? rawMap['_id'] ?? 0,
              '_data': rawMap['data'] ?? rawMap['_data'] ?? '',
              '_title': rawMap['title'] ?? rawMap['_title'] ?? 'Unbekannter Titel',
              '_artist': rawMap['artist'] ?? rawMap['_artist'] ?? 'Unbekannter Interpret',
              '_album': rawMap['album'] ?? rawMap['_album'] ?? '',
              '_duration': rawMap['duration'] ?? rawMap['_duration'] ?? 0,
              '_size': rawMap['size'] ?? rawMap['_size'] ?? 0,
              '_display_name': rawMap['display_name'] ?? rawMap['_display_name'] ?? '',
              'track': rawMap['track'] ?? 0,
              'year': rawMap['year'] ?? 0,
            };

            return SongModel(convertedMap);
          }).toList();
          return MapEntry(key, songs);
        });
        print("📂 Playlists geladen: ${customPlaylists.keys.toList()}");
      }
      print("✅ initPrefs komplett ERFOLGREICH beendet!");
    } catch (e) {
      print("❌ FEHLER in initPrefs: $e");
    }
  }

  Future<void> _saveData() async {
    try {
      print("💾 _saveData gestartet...");
      final prefs = await SharedPreferences.getInstance();
      
      // Favoriten sicher speichern (nutzt s.getMap, um direkte Getter-Crashes zu umgehen)
      final favsMapList = favoriteSongs.map((s) {
        final rawMap = s.getMap; // Holt die Rohdaten als Map
        return {
          'id': rawMap['_id'] ?? rawMap['id'] ?? 0,
          'data': rawMap['_data'] ?? rawMap['data'] ?? '',
          'title': rawMap['_title'] ?? rawMap['title'] ?? 'Unbekannter Titel',
          'artist': rawMap['_artist'] ?? rawMap['artist'] ?? 'Unbekannter Interpret',
          'album': rawMap['_album'] ?? rawMap['album'] ?? 'Unbekanntes Album',
          'duration': rawMap['_duration'] ?? rawMap['duration'] ?? 0,
        };
      }).toList();
      
      await prefs.setString('saved_favorites', jsonEncode(favsMapList));
      print("✅ Favoriten erfolgreich gespeichert!");

      // Playlists sicher speichern
      final playlistsMapList = customPlaylists.map((key, songs) {
        final mappedSongs = songs.map((s) {
          final rawMap = s.getMap;
          return {
            'id': rawMap['_id'] ?? rawMap['id'] ?? 0,
            'data': rawMap['_data'] ?? rawMap['data'] ?? '',
            'title': rawMap['_title'] ?? rawMap['title'] ?? 'Unbekannter Titel',
            'artist': rawMap['_artist'] ?? rawMap['artist'] ?? 'Unbekannter Interpret',
            'album': rawMap['_album'] ?? rawMap['album'] ?? 'Unbekanntes Album',
            'duration': rawMap['_duration'] ?? rawMap['duration'] ?? 0,
          };
        }).toList();
        return MapEntry(key, mappedSongs);
      });
      
      await prefs.setString('saved_playlists', jsonEncode(playlistsMapList));
      print("✅ Playlists erfolgreich gespeichert!");
      
    } catch (e, stackTrace) {
      print("❌ EXAKTER FEHLER in _saveData: $e");
      print("📌 STACKTRACE: $stackTrace");
    }
  }

  bool isFavoriteSong(SongModel song) {
    return favoriteSongs.any((s) => s.id == song.id);
  }

  bool isSongSavedAnywhere(SongModel song) {
    final bool isFav = isFavoriteSong(song);
    final bool isInAnyPlaylist = customPlaylists.values.any(
      (songList) => songList.any((s) => s.id == song.id),
    );
    return isFav || isInAnyPlaylist;
  }

  Future<void> toggleFavorite(SongModel song) async {
    if (isFavoriteSong(song)) {
      favoriteSongs.removeWhere((s) => s.id == song.id);
    } else {
      favoriteSongs.add(song);
    }
    await _saveData(); // save 
  }

  
  Future<void> createPlaylist(String playlistName, SongModel initalSong) async {
    customPlaylists[playlistName] = [initalSong];
    await _saveData();// save
  }

  Future<void> addSongToPlaylist(String playlistName, SongModel song) async {
    if (customPlaylists.containsKey(playlistName)) {
      customPlaylists[playlistName]!.add(song);
    }
    await _saveData(); // save
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
      await audioPlayer.setAudioSources(sources, initialIndex: initialIndex);

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
    if (_isQueuing) return;
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
      final List<AudioSource> sources = currentPlaylist.map<AudioSource>((
        song,
      ) {
        return AudioSource.uri(Uri.parse(song.data));
      }).toList();

      await audioPlayer.setAudioSources(
        sources,
        initialIndex:
            currentIndex, // Hält den aktuellen Song exakt an seiner Position
      );

      print(
        "Song '${newSong.title}' wurde erfolgreich als Nächstes eingereiht!",
      );
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

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import "package:on_audio_query/on_audio_query.dart";
import 'package:palette_generator/palette_generator.dart';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

class MusicPlayerScreen extends StatefulWidget {
  final List<SongModel> playlist;
  final int initialIndex;
  const MusicPlayerScreen({super.key, required this.playlist, required this.initialIndex});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  late AudioPlayer _audioPlayer;
  final OnAudioQuery _audioQuery = OnAudioQuery();
  late int _currentIndex;
  List<String> _favoriteSongIds = [];
  Color _backgroundColor = Colors.grey[900]!;
  Color _accentColor = Colors.grey[800]!;


  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _currentIndex = widget.initialIndex;
    _initAndPlaySong(_currentIndex);
    _loadFavorites();
  }

  // 1. Favoriten aus dem Speicher laden
Future<void> _loadFavorites() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    // Wir speichern die Song-IDs als String-Liste
    _favoriteSongIds = prefs.getStringList('favorite_songs') ?? [];
  });
}

// 2. Song zu Favoriten hinzufügen oder entfernen (Toggle)
Future<void> _toggleFavorite(SongModel song) async {
  final prefs = await SharedPreferences.getInstance();
  final songIdStr = song.id.toString();

  setState(() {
    if (_favoriteSongIds.contains(songIdStr)) {
      _favoriteSongIds.remove(songIdStr);
    } else {
      _favoriteSongIds.add(songIdStr);
    }
  });

  // In den SharedPreferences abspeichern
  await prefs.setStringList('favorite_songs', _favoriteSongIds);
}

  Future<void> _initAndPlaySong(int index) async {
    final song = widget.playlist[index];
    try {
      // Dem Player den Dateipfad des Songs übergeben und starten
      await _audioPlayer.setFilePath(song.data);
      _audioPlayer.play();
      _extractPalette(song.id);
    } catch (e) {
      print("Fehler beim Abspielen: $e");
    }
  }
  Future<void> _extractPalette(int songId) async {
    try {
      final Uint8List? bytes = await _audioQuery.queryArtwork(
        songId,
        ArtworkType.AUDIO,
        size: 500,
      );

      if (bytes != null && bytes.isNotEmpty) {
        final imageProvider = MemoryImage(bytes);
        final paletteGenerator = await PaletteGenerator.fromImageProvider(
          imageProvider,
          maximumColorCount: 16,
        );

        setState(() {
          // Nimmt die dominanteste oder schickste Farbe aus dem Bild
          _backgroundColor = paletteGenerator.dominantColor?.color ??
              paletteGenerator.darkMutedColor?.color ??
              Colors.grey[900]!;

          _accentColor = paletteGenerator.vibrantColor?.color ??
              paletteGenerator.lightMutedColor?.color ??
              Colors.grey[800]!;
        });
      } else {
        // Standard-Farben, falls kein Cover vorhanden ist
        setState(() {
          _backgroundColor = Colors.grey[900]!;
          _accentColor = Colors.black;
        });
      }
    } catch (e) {
      print("Fehler beim Auslesen der Farben: $e");
    }
  }

  // 3. Navigation: Nächster Song
  void _skipNext() {
    if (_currentIndex < widget.playlist.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _initAndPlaySong(_currentIndex);
    }
  }

  // 4. Navigation: Vorheriger Song
  void _skipPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _initAndPlaySong(_currentIndex);
    }
  }
  @override
  void dispose() {
    // WICHTIG: Den Player im Speicher aufräumen, wenn die Seite geschlossen wird!
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}


@override
  Widget build(BuildContext context) {
    final currentSong = widget.playlist[_currentIndex];
    final isFavorite = _favoriteSongIds.contains(currentSong.id.toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text("aktuelle appbar change soon"),
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: Colors.green, size: 35),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Verteilt die Elemente gleichmäßig
          children: [
            // 1. Großes Album Cover
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20), // Abgerundete Ecken wie bei MIUI
                child: QueryArtworkWidget(
                  id: currentSong.id,
                  type: ArtworkType.AUDIO,
                  artworkWidth: 300,
                  artworkHeight: 300,
                  artworkFit: BoxFit.cover,
                  nullArtworkWidget: Container(
                    width: 300,
                    height: 300,
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.music_note,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // 2. Songtitel, Artist & Favoriten-Herz
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentSong.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentSong.artist ?? 'Unbekannter Künstler',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // Das Favoriten-Herz
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.redAccent : Colors.grey,
                    size: 28,
                  ),
                  onPressed: () => _toggleFavorite(currentSong),
                ),
              ],
            ),

            // 3. Slider / Fortschrittsbalken mit StreamBuilder
            StreamBuilder<Duration?>(
              stream: _audioPlayer.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = _audioPlayer.duration ?? Duration.zero;
                final maxDuration = duration.inMilliseconds.toDouble() > 0
                    ? duration.inMilliseconds.toDouble()
                    : 1.0;

                return Column(
                  children: [
                    Slider(
                      min: 0.0,
                      max: maxDuration,
                      value: position.inMilliseconds
                          .clamp(0.0, maxDuration)
                          .toDouble(),
                      onChanged: (value) {
                        _audioPlayer.seek(
                          Duration(milliseconds: value.toInt()),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(position)),
                          Text(_formatDuration(duration)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            // 4. Steuerungs-Buttons (Play / Pause / Vor / Zurück)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  iconSize: 40,
                  icon: const Icon(Icons.skip_previous),
                  onPressed: _currentIndex > 0 ? _skipPrevious : null,
                ),
                StreamBuilder<PlayerState>(
                  stream: _audioPlayer.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final playing = playerState?.playing;

                    if (playing != true) {
                      return IconButton(
                        iconSize: 64,
                        icon: const Icon(Icons.play_circle_fill),
                        onPressed: _audioPlayer.play,
                      );
                    } else {
                      return IconButton(
                        iconSize: 64,
                        icon: const Icon(Icons.pause_circle_filled),
                        onPressed: _audioPlayer.pause,
                      );
                    }
                  },
                ),
                IconButton(
                  iconSize: 40,
                  icon: const Icon(Icons.skip_next),
                  onPressed: _currentIndex < widget.playlist.length - 1 ? _skipNext : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_application_1/helper/song_helper.dart';
import 'package:flutter_application_1/pages/music_player_screen.dart';
import 'package:flutter_application_1/pages/searchPage.dart';
import 'package:flutter_application_1/pages/library_screen.dart';
import 'package:flutter_application_1/pages/videoLibPage.dart';
import 'package:flutter_application_1/pages/homePage.dart';
import 'package:flutter_application_1/services/music_controller.dart';
import 'package:flutter_application_1/widgets/favorite_button_view.dart';
import 'package:on_audio_query/on_audio_query.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  int _currentIndex = 0;
  final MusicController _controller = MusicController();

  final List<Widget> _pages = const [
    HomePage(),
    SearchPage(), // Index 0: Deine Suchseite
    LibraryPage(),
    VideoLibPage(),
  ];

  // (Optional) Titel für die AppBar passend zum Tab
  final List<String> _titles = const [
    "Startseite",
    "Suchen",
    "Bibliothek",
    "VideoLib",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Wir nutzen einen Stack, um den Mini-Player über den Tabs schweben zu lassen
      body: Stack(
        children: [
          // 1. Die regulären Tabs / Seiten der App
          _pages[_currentIndex],

          // 2. Der permanente Mini-Player am unteren Bildschirmrand
          Positioned(
            left: 0,
            right: 0,
            bottom: 0, // Klebt fest über der BottomNavigationBar
            child: StreamBuilder<int?>(
              stream: _controller.audioPlayer.currentIndexStream,
              builder: (context, snapshot) {
                // Wenn noch keine Playlist aktiv ist, wird der Mini-Player komplett ausgeblendet
                if (_controller.currentPlaylist.isEmpty) {
                  return const SizedBox.shrink();
                }

                final currentIndex = _controller.audioPlayer.currentIndex ?? 0;
                if (currentIndex >= _controller.currentPlaylist.length) {
                  return const SizedBox.shrink();
                }

                final currentSong = _controller.currentPlaylist[currentIndex];

                return Container(
                  height: 65,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // Öffnet den großen Fullscreen-Player (jetzt ohne Parameter)
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          sheetAnimationStyle: const AnimationStyle(
                            duration: Duration(milliseconds: 450),
                            reverseDuration: Duration(milliseconds: 400),
                          ),
                          builder: (context) {
                            return const FractionallySizedBox(
                              heightFactor: 1,
                              child: MusicPlayerScreen(),
                            );
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          children: [
                            // Album-Cover links
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 45,
                                height: 45,
                                child: QueryArtworkWidget(
                                  controller: OnAudioQuery(),
                                  id: currentSong.id,
                                  type: ArtworkType.AUDIO,
                                  nullArtworkWidget: Container(
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.music_note,
                                      color: Colors.white54,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Song-Titel & Interpret
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentSong.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currentSong.artist ?? "Unbekannt",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _controller.isSongSavedAnywhere(currentSong)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    _controller.isSongSavedAnywhere(currentSong)
                                    ? Colors.red
                                    : Colors.white,
                              ),

                              onPressed: () {
                                handleSongHeartTap(
                                  context: context,
                                  song: currentSong,
                                  onUpdate: () => setState(() {}),
                                );
                              },
                            ),

                            // Live Play / Pause Button im Mini-Player
                            StreamBuilder<bool>(
                              stream: _controller.audioPlayer.playingStream,
                              builder: (context, playSnapshot) {
                                final playing = playSnapshot.data ?? false;
                                return IconButton(
                                  icon: Icon(
                                    playing ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (playing) {
                                      _controller.audioPlayer.pause();
                                    } else {
                                      _controller.audioPlayer.play();
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Deine gewohnte Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_add),
            label: "Bibliothek",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: "VideoOrdner",
          ),
        ],
      ),
    );
  }
}

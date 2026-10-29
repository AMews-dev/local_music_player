import 'package:flutter_application_1/services/music_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter/material.dart';

class FavoriteButtonView extends StatefulWidget {
  const FavoriteButtonView({super.key, required this.song});
  final SongModel song;

  @override
  State<FavoriteButtonView> createState() => _FavoriteButtonViewState();
}

class _FavoriteButtonViewState extends State<FavoriteButtonView> {
  final TextEditingController _searchController = TextEditingController();
  final MusicController controller = MusicController();
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      snap: true,
      snapSizes: const [0.9, 0.95],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF121212), // Typisches Spotify-Dunkelgrau/Schwarz
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              // Griff-Balken oben
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ==========================================
              // 1. KOPFZEILE: Abbrechen, Titel & "Neue Playlist"
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Abbrechen",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(context), // Schließt das Menü
                    child: const Text(
                      "Fertig",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Gespeichert in",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22, // Schöne, große Überschrift wie bei Spotify
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _showCreatePlaylistDialog(context, controller);
                    },
                    child: const Text(
                      "Neue Playlist",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==========================================
              // 2. LIEBLINGSSONGS (Fester Eintrag ganz oben)
              // ==========================================
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.favorite, color: Colors.white),
                ),
                title: const Text(
                  "Lieblingssongs",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                trailing: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: controller.isFavoriteSong(widget.song)
                        ? Colors.green
                        : Colors.transparent,
                    border: Border.all(
                      color: controller.isFavoriteSong(widget.song)
                          ? Colors.green
                          : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    controller.isFavoriteSong(widget.song)
                        ? Icons.check
                        : Icons.add,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  setState(() {
                    controller.toggleFavorite(widget.song);
                  });
                },
              ),

              const SizedBox(height: 16),

              // ==========================================
              // 3. SUCHLEISTE & SORTIEREN
              // ==========================================
              if (controller.customPlaylists.length > 5) ...[
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          icon: Icon(Icons.search, color: Colors.grey),
                          hintText: "Playlist suchen",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(
                            () {},
                          ); // Aktualisiert die Suche in der Liste
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      // Sortier-Logik (optional)
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Sortieren",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              ],
              // ==========================================
              // 4. LISTE DER EIGENEN PLAYLISTS
              // ==========================================
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.customPlaylists.keys.length,
                itemBuilder: (context, index) {
                  final playlistName = controller.customPlaylists.keys
                      .elementAt(index);

                  // Suchfilter anwenden, falls der Nutzer etwas eingetippt hat
                  if (_searchController.text.isNotEmpty &&
                      !playlistName.toLowerCase().contains(
                        _searchController.text.toLowerCase(),
                      )) {
                    return const SizedBox.shrink();
                  }

                  final songsInPlaylist =
                      controller.customPlaylists[playlistName]!;
                  final bool isInThisPlaylist = songsInPlaylist.any(
                    (s) => s.id == widget.song.id,
                  );

                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.music_note,
                        color: Colors.white54,
                      ),
                    ),
                    title: Text(
                      playlistName,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    subtitle: Text(
                      "${songsInPlaylist.length} Song${songsInPlaylist.length == 1 ? '' : 's'}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isInThisPlaylist
                            ? Colors.green
                            : Colors.transparent,
                        border: Border.all(
                          color: isInThisPlaylist ? Colors.green : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isInThisPlaylist ? Icons.check : Icons.add,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        if (!isInThisPlaylist) {
                          controller.addSongToPlaylist(
                            playlistName,
                            widget.song,
                          );
                        } else {
                          controller.customPlaylists[playlistName]!.removeWhere(
                            (s) => s.id == widget.song.id,
                          );
                        }
                      });
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Hilfsfunktion für den "Neue Playlist"-Dialog
  void _showCreatePlaylistDialog(
    BuildContext context,
    MusicController controller,
  ) {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Neue Playlist",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Name der Playlist",
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Abbrechen",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  controller.createPlaylist(
                    nameController.text.trim(),
                    widget.song,
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text(
              "Erstellen",
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}

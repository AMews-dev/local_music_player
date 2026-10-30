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
    // 1. Prüfen, ob der Song in den Favoriten ist
    final bool isFav = controller.isFavoriteSong(widget.song);

    // 2. Playlists aufteilen
    final allPlaylists = controller.customPlaylists.keys.toList();

    final playlistsWithSong = allPlaylists.where((name) {
      final songs = controller.customPlaylists[name]!;
      return songs.any((s) => s.id == widget.song.id);
    }).toList();

    final playlistsWithoutSong = allPlaylists.where((name) {
      final songs = controller.customPlaylists[name]!;
      return !songs.any((s) => s.id == widget.song.id);
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      snap: true,
      snapSizes: const [0.4, 0.95],
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
              // 1. KOPFZEILE: Abbrechen & Fertig
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
                    onPressed: () => Navigator.pop(context),
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
                      fontSize: 22,
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
              // 2. OBEN: WENN FAVORIT AKTIV IST
              // ==========================================
              if (isFav) ...[_buildFavoriteTile(controller)],

              // ==========================================
              // 3. OBEN: PLAYLISTS MIT SONG + TRENNSTRICH AM ENDE
              // ==========================================
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                // Wir zählen die Playlists + 1 (für den integrierten Trennstrich, falls oben aktive Elemente existieren)
                itemCount:
                    playlistsWithSong.length +
                    (isFav || playlistsWithSong.isNotEmpty ? 1 : 0),
                itemBuilder: (context, index) {
                  // Wenn wir am Ende angekommen sind, rendern wir hier den Trennstrich mit perfekt gleichen Abständen
                  if (index == playlistsWithSong.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Divider(
                        color: Colors.white24,
                        thickness: 1,
                        height: 1,
                      ),
                    );
                  }

                  final playlistName = playlistsWithSong[index];

                  if (_searchController.text.isNotEmpty &&
                      !playlistName.toLowerCase().contains(
                        _searchController.text.toLowerCase(),
                      )) {
                    return const SizedBox.shrink();
                  }

                  final songsInPlaylist =
                      controller.customPlaylists[playlistName]!;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
                        color: Colors.green,
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        controller.customPlaylists[playlistName]!.removeWhere(
                          (s) => s.id == widget.song.id,
                        );
                      });
                    },
                  );
                },
              ),

              // ==========================================
              // 4. UNTEN: WENN FAVORIT INAKTIV IST
              // ==========================================
              if (!isFav) ...[_buildFavoriteTile(controller)],

              // ==========================================
              // 5. SUCHLEISTE & SORTIEREN (Bedingt ab > 5 Playlists)
              // ==========================================
              if (controller.customPlaylists.length > 5) ...[
                const SizedBox(height: 12),
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
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {},
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
                const SizedBox(height: 12),
              ],

              // ==========================================
              // 6. UNTEN: PLAYLISTS OHNE SONG
              // ==========================================
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: playlistsWithoutSong.length,
                itemBuilder: (context, index) {
                  final playlistName = playlistsWithoutSong[index];

                  if (_searchController.text.isNotEmpty &&
                      !playlistName.toLowerCase().contains(
                        _searchController.text.toLowerCase(),
                      )) {
                    return const SizedBox.shrink();
                  }

                  final songsInPlaylist =
                      controller.customPlaylists[playlistName]!;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
                        color: Colors.transparent,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        controller.addSongToPlaylist(playlistName, widget.song);
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

  // Hilfsfunktion für das Favoriten-Tile
  Widget _buildFavoriteTile(MusicController controller) {
    final bool isFav = controller.isFavoriteSong(widget.song);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
      subtitle: Text(
        "${controller.favoriteSongs.length} Songs",
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
      trailing: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isFav ? Colors.green : Colors.transparent,
          border: Border.all(
            color: isFav ? Colors.green : Colors.white,
            width: 2,
          ),
        ),
        child: Icon(
          isFav ? Icons.check : Icons.add,
          size: 18,
          color: Colors.white,
        ),
      ),
      onTap: () {
        setState(() {
          controller.toggleFavorite(widget.song);
        });
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

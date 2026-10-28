import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

// Ein Enum, um zwischen den Unterseiten des Menüs zu unterscheiden
enum MenuState { main, playlists, songInfo }

class SongOptionsBottomSheet extends StatefulWidget {
  const SongOptionsBottomSheet({super.key, required this.song});
  
  final SongModel song;

  @override
  State<SongOptionsBottomSheet> createState() => _SongOptionsBottomSheetState();
}

class _SongOptionsBottomSheetState extends State<SongOptionsBottomSheet> {
  // Startet immer im Hauptmenü
  MenuState _currentMenuState = MenuState.main;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250), // Spotify-artige Animationsdauer
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0), // Slidet von rechts rein
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        // Je nach Zustand wird das Hauptmenü oder die Playlist-Ansicht angezeigt
        child: switch (_currentMenuState) {
          MenuState.main => _buildMainOptions(context),
          MenuState.playlists => _buildPlaylistOptions(context),
          MenuState.songInfo => _buildSongInfoView(context),
        }
      ),
    );
  }

  // --- SEITE 1: Das Hauptmenü ---
  Widget _buildMainOptions(BuildContext context) {
    return Column(
      key: const ValueKey(1), // Wichtig für den AnimatedSwitcher!
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag-Indikator
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 12),
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        
        // Song-Header (Cover & Titel)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.music_note, color: Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.song.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.song.artist ?? "Unbekannter Interpret",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const Divider(),

        // Aktionen-Liste
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Icon(Icons.playlist_play),
                title: const Text('Als Nächstes spielen'),
                onTap: () {
                  Navigator.pop(context);
                  // Logik für "Als Nächstes spielen"
                },
              ),
              ListTile(
                leading: const Icon(Icons.queue_music),
                title: const Text('Am Ende der Warteschlange einreihen'),
                onTap: () {
                  Navigator.pop(context);
                  // Logik für Warteschlange
                },
              ),
              // Hier findet der dynamische Wechsel statt!
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: const Text('Zu Playlist hinzufügen'),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  setState(() {
                    _currentMenuState = MenuState.playlists; // Wechselt geschmeidig zur Playlist-Ansicht
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Song-Informationen'),
                onTap: () {
                  setState(() {
                    _currentMenuState = MenuState.songInfo;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Vom Gerät löschen', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  // Logik zum Löschen
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- SEITE 2: Die Playlist-Auswahl (Slidet von rechts herein) ---
  Widget _buildPlaylistOptions(BuildContext context) {
    return Column(
      key: const ValueKey(2), // Wichtig für den AnimatedSwitcher!
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header mit Zurück-Pfeil
        ListTile(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _currentMenuState = MenuState.main; // Geht zurück zum Hauptmenü
              });
            },
          ),
          title: const Text(
            'Zu Playlist hinzufügen',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        
        const Divider(),

        // Liste der Playlists
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Icon(Icons.folder, color: Colors.amber),
                title: const Text('Favoriten'),
                onTap: () {
                  Navigator.pop(context); // Schließt das gesamte Bottom Sheet
                  // TODO: Logik zum Hinzufügen zur Playlist "Favoriten"
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder, color: Colors.amber),
                title: const Text('Workout Mix'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Logik zum Hinzufügen zur Playlist "Workout Mix"
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

Widget _buildSongInfoView(BuildContext context) {
    return Column(
      key: const ValueKey(3),
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          /* leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _currentMenuState = MenuState.main; // Zurück zum Hauptmenü
              });
            },
          ), */
          title: const Text('Song-Informationen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow('Titel', widget.song.title),
              const SizedBox(height: 12),
              _infoRow('Interpret', widget.song.artist ?? "Unbekannt"),
              const SizedBox(height: 12),
              _infoRow('Format', 'MP3'),
              const SizedBox(height: 12),
              // Hier kannst du später z.B. den echten Dateipfad aus dem Model anzeigen
              _infoRow('Pfad', '/storage/emulated/0/Music/...'),
            ],
          ),
        ),
      ],
    );
  }

  // Kleine Hilfsmethode für saubere Info-Zeilen
  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
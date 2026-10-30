import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/music_controller.dart';
import 'package:flutter_application_1/widgets/favorite_button_view.dart';
import 'package:on_audio_query/on_audio_query.dart';


void handleSongHeartTap({
  required BuildContext context,
  required SongModel song,
  required VoidCallback onUpdate,
}) {
  final controller = MusicController();

  final bool isFav = controller.isFavoriteSong(song);
  final bool isInAnyPlaylist = controller.customPlaylists.values.any(
    (songList) => songList.any((s) => s.id == song.id),
  );

  // Wenn der Song völlig neu ist -> direkt favorisieren
  if (!isFav && !isInAnyPlaylist) {
    controller.toggleFavorite(song);
  }

  // Bottom Sheet öffnen
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FavoriteButtonView(song: song),
  ).then((_) {
    // UI nach dem Schließen aktualisieren
    onUpdate();
  });
}
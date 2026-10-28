import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/music_player_screen.dart';
import 'package:flutter_application_1/services/music_controller.dart';
import 'package:flutter_application_1/widgets/song_menu.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SongListView extends StatelessWidget {
  final List<SongModel> songs;
  final Function(SongModel song)? onSongTap;

  const SongListView({
    super.key,
    required this.songs,
    this.onSongTap
    });

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return const Center(
        child: Text("Keine Songs auf dem Gerät gefunden."),
      );
    }
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        SongModel song = songs[index];
        return ListTile(
          leading: const Icon(Icons.music_note, color: Colors.blue),
          title: Text(song.title),
          subtitle: Text(song.artist ?? "Unbekannter Interpret", maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: IconButton(
            icon:Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top:Radius.circular(16)),
                ),
                builder: (context) => SongOptionsBottomSheet(song: song),
              );
            },
          ),
          onTap: () {
            final controller = MusicController();
            controller.playPlaylist(songs, index);
           showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            sheetAnimationStyle: AnimationStyle(
              duration: const Duration(milliseconds: 450),
              reverseDuration: const Duration(milliseconds: 400)
            ),
            builder: (context) {
              return FractionallySizedBox(
                heightFactor: 1,
                child: MusicPlayerScreen(playlist: songs, initialIndex: index,),
              );
            });
          },
        );
      },
    );
  }
}
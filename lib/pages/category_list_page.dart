import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class CategoryListPage extends StatelessWidget {
  final String title;
  final Map<String, List<SongModel>> items;
  final bool isLoading;
  final String emptyMessage;
  final Widget Function(String key, List<SongModel> songs) detailPageBuilder;

  const CategoryListPage({
    super.key,
    required this.title,
    required this.items,
    required this.isLoading,
    required this.emptyMessage,
    required this.detailPageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      return Center(
        child: Text(emptyMessage),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final key = items.keys.elementAt(index);
        final songs = items[key]!;
        
        // Optional: Falls du bei Ordnern nur den letzten Ordnernamen anzeigen willst, 
        // kannst du das steuern, oder den Namen direkt übergeben.
        final displayName = title == "Ordner" ? key.split('/').last : key;

        return ListTile(
          leading: const Icon(Icons.folder, color: Colors.blue), // Icon dynamisch anpassbar
          title: Text(displayName),
          subtitle: Text('${songs.length} Songs'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => detailPageBuilder(key, songs),
              ),
            );
          },
        );
      },
    );
  }
}
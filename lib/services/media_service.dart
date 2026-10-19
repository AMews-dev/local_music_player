import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  // Berechtigung anfordern
  Future<bool> requestPermission() async {
    var status = await Permission.audio.request();
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  // Alle Songs abrufen
  Future<List<SongModel>> getAllSongs() async {
    if (!await requestPermission()) return [];
    
    return await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
    );
  }

  // Alle Alben/Ordner abrufen
  Future<List<AlbumModel>> getAllAlbums() async {
    if (!await requestPermission()) return [];

    return await _audioQuery.queryAlbums(
      sortType: AlbumSortType.ALBUM,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
    );
  }
  Future<Map<String, List<SongModel>>> getAllOrdner() async {
    if (!await requestPermission()) return {};
    final songs = await getAllSongs();
    final Map<String, List<SongModel>> folderMap = {};
    for (var song in songs) {
      final String fullPath = song.data;

      final int lastSlashIndex = fullPath.lastIndexOf("/");
      final String folderPath = lastSlashIndex != -1
      ? fullPath.substring(0, lastSlashIndex)
      : "Unbekannt";

      if(!folderMap.containsKey(folderPath))  {
        folderMap[folderPath] = [];
      }
    folderMap[folderPath]!.add(song);
    }
    return folderMap;
  }
}


/* List<SongModel> removeDuplicates(List<SongModel> songs) {
  final seen = <String>{};
  return songs.where((song) {
    // Erstellt einen eindeutigen Schlüssel aus Titel und Interpret
    final key = "${song.title.toLowerCase().trim()}_${song.artist?.toLowerCase().trim()}";
    return seen.add(key); // returns true, wenn der Schlüssel neu war
  }).toList();
}

 // Alle Songs abrufen (ohne Duplikate)
  Future<List<SongModel>> getAllSongs() async {
    if (!await requestPermission()) return [];
    
    final List<SongModel> songs = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
    );

    // Filtert doppelte Songs basierend auf Titel und Künstler heraus
    final seen = <String>{};
    return songs.where((song) {
      final key = "${song.title.toLowerCase().trim()}_${song.artist?.toLowerCase().trim()}";
      return seen.add(key);
    }).toList();
  } */
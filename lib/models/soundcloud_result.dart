class SoundCloudResult {
  final String type; // 'single' or 'playlist'
  final String baseUrl;
  final SoundCloudTrack? singleTrack; // For single track
  final SoundCloudPlaylist? playlist; // For playlist

  SoundCloudResult({
    required this.type,
    required this.baseUrl,
    this.singleTrack,
    this.playlist,
  });

  factory SoundCloudResult.fromSingle({
    required SoundCloudTrack track,
    required String baseUrl,
  }) {
    return SoundCloudResult(
      type: 'single',
      baseUrl: baseUrl,
      singleTrack: track,
    );
  }

  factory SoundCloudResult.fromPlaylist({
    required SoundCloudPlaylist playlist,
    required String baseUrl,
  }) {
    return SoundCloudResult(
      type: 'playlist',
      baseUrl: baseUrl,
      playlist: playlist,
    );
  }

  bool get isSingle => type == 'single';
  bool get isPlaylist => type == 'playlist';
}

class SoundCloudTrack {
  final int id;
  final String name;
  final String artist;
  final String cover;
  final String link;
  final String token;
  final String dataBase64; // Original base64 encoded data from HTML form
  final String? albumName; // For playlist tracks

  SoundCloudTrack({
    required this.id,
    required this.name,
    required this.artist,
    required this.cover,
    required this.link,
    required this.token,
    required this.dataBase64,
    this.albumName,
  });

  factory SoundCloudTrack.fromJson(
    Map<String, dynamic> json,
    String token,
    String dataBase64,
  ) {
    return SoundCloudTrack(
      id: json['id'] as int,
      name: json['name'] as String,
      artist: json['artist'] as String,
      cover: json['cover'] as String,
      link: json['link'] as String,
      token: token,
      dataBase64: dataBase64,
      albumName: json['albumname'] as String?,
    );
  }
}

class SoundCloudPlaylist {
  final String name;
  final String artist;
  final List<SoundCloudTrack> tracks;

  SoundCloudPlaylist({
    required this.name,
    required this.artist,
    required this.tracks,
  });

  int get trackCount => tracks.length;
}

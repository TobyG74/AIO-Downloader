class SpotifyTrack {
  final String title;
  final String artist;
  final String album;
  final String coverUrl;
  final int durationMs; // milliseconds
  final String previewUrl; // 30-second preview (may be empty)
  final String type; // 'track' | 'episode' | 'album' | 'playlist'

  /// Set after YouTube search
  final String? youtubeVideoId;
  final String? youtubeVideoTitle;
  final String? youtubeThumbnail;
  final String? youtubeDuration;

  /// Playlist specific fields
  final bool isPlaylist;
  final String? playlistId;
  final int? trackCount;
  final List<SpotifyPlaylistTrack>? playlistTracks;

  const SpotifyTrack({
    required this.title,
    required this.artist,
    required this.album,
    required this.coverUrl,
    required this.durationMs,
    required this.previewUrl,
    required this.type,
    this.youtubeVideoId,
    this.youtubeVideoTitle,
    this.youtubeThumbnail,
    this.youtubeDuration,
    this.isPlaylist = false,
    this.playlistId,
    this.trackCount,
    this.playlistTracks,
  });

  SpotifyTrack copyWith({
    String? youtubeVideoId,
    String? youtubeVideoTitle,
    String? youtubeThumbnail,
    String? youtubeDuration,
  }) {
    return SpotifyTrack(
      title: title,
      artist: artist,
      album: album,
      coverUrl: coverUrl,
      durationMs: durationMs,
      previewUrl: previewUrl,
      type: type,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      youtubeVideoTitle: youtubeVideoTitle ?? this.youtubeVideoTitle,
      youtubeThumbnail: youtubeThumbnail ?? this.youtubeThumbnail,
      youtubeDuration: youtubeDuration ?? this.youtubeDuration,
      isPlaylist: isPlaylist,
      playlistId: playlistId,
      trackCount: trackCount,
      playlistTracks: playlistTracks,
    );
  }

  /// Duration formatted as mm:ss
  String get durationFormatted {
    if (durationMs <= 0) return '';
    final totalSec = durationMs ~/ 1000;
    final m = totalSec ~/ 60;
    final s = totalSec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class SpotifyPlaylistTrack {
  final String title;
  final String artist;
  final String album;
  final String coverUrl;
  final int durationMs;
  final int index;
  final String trackId;

  const SpotifyPlaylistTrack({
    required this.title,
    required this.artist,
    required this.album,
    required this.coverUrl,
    required this.durationMs,
    required this.index,
    required this.trackId,
  });

  String get durationFormatted {
    if (durationMs <= 0) return '';
    final totalSec = durationMs ~/ 1000;
    final m = totalSec ~/ 60;
    final s = totalSec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

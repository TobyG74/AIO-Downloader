class YouTubeResult {
  final String videoId;
  final String title;
  final String thumbnail;
  final String duration;
  final String author;
  final List<YouTubeVideoQuality> videoFormats;
  final List<YouTubeAudioQuality> audioFormats;
  final bool isPlaylist;
  final String? playlistId;
  final int? videoCount;
  final List<YouTubePlaylistItem>? playlistItems;

  YouTubeResult({
    required this.videoId,
    required this.title,
    required this.thumbnail,
    required this.duration,
    required this.author,
    required this.videoFormats,
    required this.audioFormats,
    this.isPlaylist = false,
    this.playlistId,
    this.videoCount,
    this.playlistItems,
  });
}

class YouTubeVideoQuality {
  final String quality;
  final String format;
  final String size;
  final String downloadUrl;

  YouTubeVideoQuality({
    required this.quality,
    required this.format,
    required this.size,
    required this.downloadUrl,
  });
}

class YouTubeAudioQuality {
  final String quality;
  final String format;
  final String size;
  final String downloadUrl;

  YouTubeAudioQuality({
    required this.quality,
    required this.format,
    required this.size,
    required this.downloadUrl,
  });
}

class YouTubePlaylistItem {
  final String videoId;
  final String title;
  final String thumbnail;
  final String duration;
  final String author;
  final int index;

  YouTubePlaylistItem({
    required this.videoId,
    required this.title,
    required this.thumbnail,
    required this.duration,
    required this.author,
    required this.index,
  });
}

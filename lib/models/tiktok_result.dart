class TikTokResult {
  final String title;
  final String author;
  final String authorName;
  final int duration;
  final String cover;
  final String videoUrl; // Standard MP4 (no watermark)
  final String videoUrlHD; // HD quality
  final String videoUrlWatermark; // With watermark
  final String music; // MP3 audio URL
  final int playCount;
  final int diggCount;
  final int commentCount;
  final int shareCount;
  final int downloadCount;
  final List<String> images; // For slide posts

  TikTokResult({
    required this.title,
    required this.author,
    required this.authorName,
    required this.duration,
    required this.cover,
    required this.videoUrl,
    this.videoUrlHD = '',
    this.videoUrlWatermark = '',
    required this.music,
    required this.playCount,
    required this.diggCount,
    required this.commentCount,
    required this.shareCount,
    required this.downloadCount,
    required this.images,
  });
}

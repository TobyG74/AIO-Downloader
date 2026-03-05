class TikTokResult {
  final String title;
  final String author;
  final String authorName;
  final int duration;
  final String cover;
  final String videoUrl;
  final String videoUrlNoWatermark;
  final String music;
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
    required this.videoUrlNoWatermark,
    required this.music,
    required this.playCount,
    required this.diggCount,
    required this.commentCount,
    required this.shareCount,
    required this.downloadCount,
    required this.images,
  });
}

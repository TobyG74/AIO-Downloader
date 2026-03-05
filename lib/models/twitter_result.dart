class TwitterResult {
  final String title;
  final String thumbnail;
  final String duration;
  final List<TwitterVideoQuality> videos;
  final List<String> images;

  TwitterResult({
    required this.title,
    required this.thumbnail,
    this.duration = '',
    this.videos = const [],
    this.images = const [],
  });

  bool get hasVideo => videos.isNotEmpty;
  bool get hasImages => images.isNotEmpty;
}

class TwitterVideoQuality {
  final String quality;
  final String url;
  final String thumbnail;

  TwitterVideoQuality({
    required this.quality,
    required this.url,
    this.thumbnail = '',
  });
}

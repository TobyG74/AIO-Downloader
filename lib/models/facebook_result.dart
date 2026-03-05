class FacebookResult {
  final String title;
  final String duration;
  final String thumbnail;
  final List<FacebookVideoQuality> mp4;

  FacebookResult({
    required this.title,
    required this.duration,
    required this.thumbnail,
    required this.mp4,
  });
}

class FacebookVideoQuality {
  final String quality;
  final bool render;
  final String type; // 'direct' or 'render'
  final String? url;
  final String? videoUrl;
  final String? videoCodec;
  final String? videoType;

  FacebookVideoQuality({
    required this.quality,
    required this.render,
    required this.type,
    this.url,
    this.videoUrl,
    this.videoCodec,
    this.videoType,
  });
}

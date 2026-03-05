enum InstagramMediaType { image, video }

class InstagramResult {
  final InstagramMediaType type;
  final List<InstagramImageItem>? images;
  final InstagramVideoItem? video;

  InstagramResult({
    required this.type,
    this.images,
    this.video,
  });
}

class InstagramImageQuality {
  final String quality;
  final String url;

  InstagramImageQuality({
    required this.quality,
    required this.url,
  });
}

class InstagramImageItem {
  final String id;
  final List<InstagramImageQuality> qualities;
  final String defaultUrl;

  InstagramImageItem({
    required this.id,
    required this.qualities,
    required this.defaultUrl,
  });
}

class InstagramVideoItem {
  final String url;
  final String? thumbnail;

  InstagramVideoItem({
    required this.url,
    this.thumbnail,
  });
}

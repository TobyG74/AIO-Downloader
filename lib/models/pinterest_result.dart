enum PinterestMediaType { video, image, gif }

class PinterestDownloadItem {
  final String type; // e.g. "1080p (HD)", "Image [564x]", "GIF"
  final String url;
  final bool isDirect; // true if no ad redirect

  const PinterestDownloadItem({
    required this.type,
    required this.url,
    this.isDirect = false,
  });
}

class PinterestResult {
  final PinterestMediaType mediaType;
  final String title;
  final String author;
  final String thumbnailUrl;
  final List<PinterestDownloadItem> items;

  const PinterestResult({
    required this.mediaType,
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    required this.items,
  });
}

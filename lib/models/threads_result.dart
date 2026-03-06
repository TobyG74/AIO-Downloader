enum ThreadsMediaType { image, video }

class ThreadsResult {
  final ThreadsMediaType type;
  final List<ThreadsImageItem>? images;
  final List<ThreadsVideoItem>? videos;

  ThreadsResult({
    required this.type,
    this.images,
    this.videos,
  });

  // Backward compatibility getter
  ThreadsVideoItem? get video => videos?.isNotEmpty == true ? videos!.first : null;
}

class ThreadsImageItem {
  final String url;

  ThreadsImageItem({
    required this.url,
  });
}

class ThreadsVideoItem {
  final String url;
  final String? thumbnail;

  ThreadsVideoItem({
    required this.url,
    this.thumbnail,
  });
}

class DownloadHistory {
  final String id;
  final String platform;
  final String title;
  final String url;
  final String thumbnailUrl;
  final String downloadType; // 'video' or 'image'
  final DateTime downloadDate;
  final int fileCount; // for multiple images

  DownloadHistory({
    required this.id,
    required this.platform,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
    required this.downloadType,
    required this.downloadDate,
    this.fileCount = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platform': platform,
      'title': title,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'downloadType': downloadType,
      'downloadDate': downloadDate.toIso8601String(),
      'fileCount': fileCount,
    };
  }

  factory DownloadHistory.fromJson(Map<String, dynamic> json) {
    return DownloadHistory(
      id: json['id'] as String,
      platform: json['platform'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      thumbnailUrl: (json['thumbnailUrl'] as String?) ?? '',
      downloadType: (json['downloadType'] as String?) ?? 'video',
      downloadDate: DateTime.parse(json['downloadDate'] as String),
      fileCount: json['fileCount'] as int? ?? 1,
    );
  }

  String get platformIcon {
    switch (platform.toLowerCase()) {
      case 'tiktok':
        return '🎵';
      case 'youtube':
        return '▶️';
      case 'instagram':
        return '📷';
      case 'facebook':
        return '👍';
      case 'twitter':
      case 'x':
        return '🐦';
      case 'threads':
        return '🧵';
      case 'spotify':
        return '🎵';
      case 'pinterest':
        return '📌';
      default:
        return '📱';
    }
  }

  String get downloadTypeIcon {
    if (downloadType == 'video') return '🎬 Video';
    if (downloadType == 'audio') return '🎵 Audio';
    return '🖼️ Image';
  }
}

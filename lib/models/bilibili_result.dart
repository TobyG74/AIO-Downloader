class BilibiliResult {
  final String videoId;
  final BilibiliPlayUrl playUrl;
  final String? thumbnailUrl;
  final String? title;

  BilibiliResult({
    required this.videoId,
    required this.playUrl,
    this.thumbnailUrl,
    this.title,
  });

  factory BilibiliResult.fromJson(Map<String, dynamic> json, String videoId, {String? thumbnailUrl, String? title}) {
    return BilibiliResult(
      videoId: videoId,
      playUrl: BilibiliPlayUrl.fromJson(json['data']['playurl']),
      thumbnailUrl: thumbnailUrl,
      title: title,
    );
  }
}

class BilibiliPlayUrl {
  final int duration;
  final List<BilibiliQuality> qualities;
  final List<BilibiliAudioResource> audioResources;

  BilibiliPlayUrl({
    required this.duration,
    required this.qualities,
    required this.audioResources,
  });

  factory BilibiliPlayUrl.fromJson(Map<String, dynamic> json) {
    final videoList = json['video'] as List;
    final audioList = json['audio_resource'] as List;

    // Parse all video qualities
    final qualities = <BilibiliQuality>[];
    for (final videoItem in videoList) {
      final videoResource = videoItem['video_resource'];
      
      // Only include H.264 (codec_id: 7) videos with valid URLs
      if (videoResource['codec_id'] == 7 && 
          videoResource['url'] != null && 
          videoResource['url'].toString().isNotEmpty) {
        qualities.add(BilibiliQuality.fromJson(videoItem));
      }
    }

    // Sort qualities by height (highest first)
    qualities.sort((a, b) => b.height.compareTo(a.height));

    // Parse audio resources
    final audios = audioList.map((audio) => BilibiliAudioResource.fromJson(audio)).toList();

    return BilibiliPlayUrl(
      duration: json['duration'] ?? 0,
      qualities: qualities,
      audioResources: audios,
    );
  }

  // Get the best audio quality
  BilibiliAudioResource get bestAudio {
    if (audioResources.isEmpty) {
      throw Exception('No audio resources available');
    }
    // Sort by quality (higher is better)
    final sorted = List<BilibiliAudioResource>.from(audioResources);
    sorted.sort((a, b) => b.quality.compareTo(a.quality));
    return sorted.first;
  }
}

class BilibiliQuality {
  final int quality;
  final String qualityDesc;
  final int width;
  final int height;
  final String url;
  final List<String> backupUrls;
  final int size;
  final int bandwidth;
  final String codecs;
  final int audioQuality;

  BilibiliQuality({
    required this.quality,
    required this.qualityDesc,
    required this.width,
    required this.height,
    required this.url,
    required this.backupUrls,
    required this.size,
    required this.bandwidth,
    required this.codecs,
    required this.audioQuality,
  });

  factory BilibiliQuality.fromJson(Map<String, dynamic> json) {
    final videoResource = json['video_resource'];
    final streamInfo = json['stream_info'];

    return BilibiliQuality(
      quality: streamInfo['quality'] ?? 0,
      qualityDesc: streamInfo['desc_words'] ?? '',
      width: videoResource['width'] ?? 0,
      height: videoResource['height'] ?? 0,
      url: videoResource['url'] ?? '',
      backupUrls: videoResource['backup_url'] != null 
          ? List<String>.from(videoResource['backup_url']) 
          : [],
      size: videoResource['size'] ?? 0,
      bandwidth: videoResource['bandwidth'] ?? 0,
      codecs: videoResource['codecs'] ?? '',
      audioQuality: json['audio_quality'] ?? 0,
    );
  }

  String get qualityLabel {
    final sizeInMB = (size / (1024 * 1024)).toStringAsFixed(2);
    return '$qualityDesc (${width}x$height) - $sizeInMB MB';
  }

  String get videoUrl => url.isNotEmpty ? url : (backupUrls.isNotEmpty ? backupUrls.first : '');
}

class BilibiliAudioResource {
  final int quality;
  final String url;
  final List<String> backupUrls;
  final int size;
  final int bandwidth;
  final String codecs;

  BilibiliAudioResource({
    required this.quality,
    required this.url,
    required this.backupUrls,
    required this.size,
    required this.bandwidth,
    required this.codecs,
  });

  factory BilibiliAudioResource.fromJson(Map<String, dynamic> json) {
    return BilibiliAudioResource(
      quality: json['quality'] ?? 0,
      url: json['url'] ?? '',
      backupUrls: json['backup_url'] != null 
          ? List<String>.from(json['backup_url']) 
          : [],
      size: json['size'] ?? 0,
      bandwidth: json['bandwidth'] ?? 0,
      codecs: json['codecs'] ?? '',
    );
  }

  String get audioUrl => url.isNotEmpty ? url : (backupUrls.isNotEmpty ? backupUrls.first : '');
}

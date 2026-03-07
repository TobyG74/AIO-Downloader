class DouyinResult {
  final DouyinVideo video;

  DouyinResult({
    required this.video,
  });

  factory DouyinResult.fromJson(Map<String, dynamic> json) {
    final awemeDetail = json['data']['aweme_detail'] as Map<String, dynamic>;
    return DouyinResult(
      video: DouyinVideo.fromJson(awemeDetail),
    );
  }
}

class DouyinVideo {
  final String awemeId;
  final String description;
  final DouyinAuthor author;
  final DouyinVideoDetail videoDetail;
  final DouyinMusic music;
  final DouyinStatistics statistics;
  final String coverUrl;
  final String awemeLink;
  final int createTime;

  DouyinVideo({
    required this.awemeId,
    required this.description,
    required this.author,
    required this.videoDetail,
    required this.music,
    required this.statistics,
    required this.coverUrl,
    required this.awemeLink,
    required this.createTime,
  });

  factory DouyinVideo.fromJson(Map<String, dynamic> json) {
    return DouyinVideo(
      awemeId: json['aweme_id'] as String,
      description: json['desc'] as String? ?? '',
      author: DouyinAuthor.fromJson(json['author'] as Map<String, dynamic>),
      videoDetail: DouyinVideoDetail.fromJson(json['video'] as Map<String, dynamic>),
      music: DouyinMusic.fromJson(json['music'] as Map<String, dynamic>),
      statistics: DouyinStatistics.fromJson(json['statistics'] as Map<String, dynamic>),
      coverUrl: json['cover'] as String? ?? '',
      awemeLink: json['aweme_link'] as String? ?? '',
      createTime: json['create_time'] as int? ?? 0,
    );
  }
}

class DouyinAuthor {
  final String uid;
  final String nickname;
  final String uniqueId;
  final String signature;
  final String avatarUrl;
  final String link;

  DouyinAuthor({
    required this.uid,
    required this.nickname,
    required this.uniqueId,
    required this.signature,
    required this.avatarUrl,
    required this.link,
  });

  factory DouyinAuthor.fromJson(Map<String, dynamic> json) {
    final avatarThumb = json['avatar_thumb'] as Map<String, dynamic>?;
    final urlList = avatarThumb?['url_list'] as List?;
    
    return DouyinAuthor(
      uid: json['uid'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      uniqueId: json['unique_id'] as String? ?? '',
      signature: json['signature'] as String? ?? '',
      avatarUrl: urlList != null && urlList.isNotEmpty 
          ? urlList[0] as String 
          : '',
      link: json['link'] as String? ?? '',
    );
  }
}

class DouyinVideoDetail {
  final int duration;
  final String coverUrl;
  final List<DouyinQuality> qualities;
  final String downloadUrl;

  DouyinVideoDetail({
    required this.duration,
    required this.coverUrl,
    required this.qualities,
    required this.downloadUrl,
  });

  factory DouyinVideoDetail.fromJson(Map<String, dynamic> json) {
    final cover = json['cover'] as Map<String, dynamic>?;
    final coverUrlList = cover?['url_list'] as List?;
    
    final bitRateList = json['bit_rate'] as List? ?? [];
    final allQualities = bitRateList
        .map((q) => DouyinQuality.fromJson(q as Map<String, dynamic>))
        .toList();
    
    // Group by resolution and keep only highest bitrate for each unique resolution
    final Map<String, DouyinQuality> uniqueQualities = {};
    for (final quality in allQualities) {
      final resolutionKey = '${quality.width}x${quality.height}';
      final existing = uniqueQualities[resolutionKey];
      
      // Keep quality with highest bitrate for same resolution
      if (existing == null || quality.bitRate > existing.bitRate) {
        uniqueQualities[resolutionKey] = quality;
      }
    }
    
    // Convert to list and sort from highest to lowest resolution
    final qualities = uniqueQualities.values.toList();
    qualities.sort((a, b) {
      final resolutionA = a.height * a.width;
      final resolutionB = b.height * b.width;
      return resolutionB.compareTo(resolutionA); // Descending order
    });
    
    final downloadAddr = json['download_addr'] as Map<String, dynamic>?;
    final downloadUrlList = downloadAddr?['url_list'] as List?;
    
    return DouyinVideoDetail(
      duration: json['duration'] as int? ?? 0,
      coverUrl: coverUrlList != null && coverUrlList.isNotEmpty
          ? coverUrlList[0] as String
          : '',
      qualities: qualities,
      downloadUrl: downloadUrlList != null && downloadUrlList.isNotEmpty
          ? downloadUrlList[0] as String
          : '',
    );
  }
}

class DouyinQuality {
  final String gearName;
  final int bitRate;
  final String format;
  final int qualityType;
  final String url;
  final int width;
  final int height;
  final int dataSize;

  DouyinQuality({
    required this.gearName,
    required this.bitRate,
    required this.format,
    required this.qualityType,
    required this.url,
    required this.width,
    required this.height,
    required this.dataSize,
  });

  factory DouyinQuality.fromJson(Map<String, dynamic> json) {
    final playAddr = json['play_addr'] as Map<String, dynamic>?;
    final urlList = playAddr?['url_list'] as List?;
    
    return DouyinQuality(
      gearName: json['gear_name'] as String? ?? '',
      bitRate: json['bit_rate'] as int? ?? 0,
      format: json['format'] as String? ?? 'mp4',
      qualityType: json['quality_type'] as int? ?? 0,
      url: urlList != null && urlList.isNotEmpty
          ? urlList[0] as String
          : '',
      width: playAddr?['width'] as int? ?? 0,
      height: playAddr?['height'] as int? ?? 0,
      dataSize: playAddr?['data_size'] as int? ?? 0,
    );
  }

  // Human-readable quality label with resolution
  String get qualityLabel {
    String resolution = '${width}x${height}';
    String quality = '';
    
    if (gearName.contains('1080')) {
      quality = '1080p';
    } else if (gearName.contains('720')) {
      quality = '720p';
    } else if (gearName.contains('540')) {
      quality = gearName.contains('lower') ? '540p (Lower)' : '540p';
    } else if (gearName.contains('480')) {
      quality = '480p';
    } else if (gearName.contains('360')) {
      quality = '360p';
    }
    
    return quality.isNotEmpty ? '$resolution - $quality' : resolution;
  }

  // File size in MB
  String get fileSizeMB {
    return (dataSize / (1024 * 1024)).toStringAsFixed(2);
  }
}

class DouyinMusic {
  final int id;
  final String title;
  final String author;
  final String playUrl;
  final String coverUrl;

  DouyinMusic({
    required this.id,
    required this.title,
    required this.author,
    required this.playUrl,
    required this.coverUrl,
  });

  factory DouyinMusic.fromJson(Map<String, dynamic> json) {
    return DouyinMusic(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      playUrl: json['play_url'] as String? ?? '',
      coverUrl: json['cover'] as String? ?? '',
    );
  }
}

class DouyinStatistics {
  final int playCount;
  final int diggCount;
  final int shareCount;
  final int commentCount;
  final int collectCount;

  DouyinStatistics({
    required this.playCount,
    required this.diggCount,
    required this.shareCount,
    required this.commentCount,
    required this.collectCount,
  });

  factory DouyinStatistics.fromJson(Map<String, dynamic> json) {
    return DouyinStatistics(
      playCount: json['play_count'] as int? ?? 0,
      diggCount: json['digg_count'] as int? ?? 0,
      shareCount: json['share_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      collectCount: json['collect_count'] as int? ?? 0,
    );
  }

  // Format large numbers (e.g., 1000 -> 1K)
  String formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  String get playCountFormatted => formatCount(playCount);
  String get diggCountFormatted => formatCount(diggCount);
  String get shareCountFormatted => formatCount(shareCount);
  String get commentCountFormatted => formatCount(commentCount);
  String get collectCountFormatted => formatCount(collectCount);
}

import 'dart:convert';
import 'package:dio/dio.dart';
import '../../models/youtube_result.dart';

/// Response wrapper from dlsrv download API
class DlsrvResponse {
  final String url;
  final String filename;
  final String status;
  final int duration; // in seconds

  DlsrvResponse({
    required this.url,
    required this.filename,
    required this.status,
    required this.duration,
  });

  factory DlsrvResponse.fromJson(Map data) {
    return DlsrvResponse(
      url: data['url'] ?? '',
      filename: data['filename'] ?? '',
      status: data['status'] ?? '',
      duration: (data['duration'] is int)
          ? data['duration'] as int
          : int.tryParse(data['duration']?.toString() ?? '0') ?? 0,
    );
  }

  bool get isSuccess => url.isNotEmpty;

  /// Format duration seconds to mm:ss
  String get durationFormatted {
    if (duration <= 0) return '';
    final m = duration ~/ 60;
    final s = duration % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class YouTubeScraper {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {
      'accept': '*/*',
      'accept-language': 'en,en-US;q=0.9,ja;q=0.8',
      'cache-control': 'no-cache',
      'content-type': 'application/json',
      'pragma': 'no-cache',
      'priority': 'u=1, i',
      'sec-ch-ua':
          '"Not(A:Brand";v="8", "Chromium";v="144", "Microsoft Edge";v="144"',
      'sec-ch-ua-mobile': '?1',
      'sec-ch-ua-platform': '"Android"',
      'sec-fetch-dest': 'empty',
      'sec-fetch-mode': 'cors',
      'sec-fetch-site': 'same-origin',
      'sec-fetch-storage-access': 'active',
    },
  ));

  static const String _baseUrl = 'https://embed.dlsrv.online';
  static const String _infoApiUrl = '$_baseUrl/api/info';
  static const String _videoApiUrl = '$_baseUrl/api/download/mp4';
  static const String _audioApiUrl = '$_baseUrl/api/download/mp3';

  /// Audio MP3 bitrate options (not in /api/info but supported by download API)
  static const List<Map<String, String>> audioBitrateOptions = [
    {'quality': '320', 'label': '320 kbps', 'format': 'mp3'},
    {'quality': '256', 'label': '256 kbps', 'format': 'mp3'},
    {'quality': '128', 'label': '128 kbps', 'format': 'mp3'},
    {'quality': '96', 'label': '96 kbps', 'format': 'mp3'},
    {'quality': '64', 'label': '64 kbps', 'format': 'mp3'},
  ];

  /// Extract video ID from YouTube URL
  String? _extractVideoId(String url) {
    final regexList = [
      RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtube\.com\/embed\/([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtube\.com\/v\/([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtube\.com\/shorts\/([a-zA-Z0-9_-]{11})'),
    ];
    for (var regex in regexList) {
      final match = regex.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }
    return null;
  }

  /// Check if URL is a playlist
  bool isPlaylistUrl(String url) {
    return url.contains('list=') && url.contains('youtube.com');
  }

  /// Extract playlist ID from YouTube URL
  String? _extractPlaylistId(String url) {
    final regex = RegExp(r'[?&]list=([a-zA-Z0-9_-]+)');
    final match = regex.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
  }

  /// Get the Referer URL for a given video ID
  String _getReferer(String videoId) => '$_baseUrl/v1/full?videoId=$videoId';

  /// Format bytes to human-readable size string
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Format seconds to mm:ss
  static String formatDuration(int seconds) {
    if (seconds <= 0) return '';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Strip trailing 'p' from quality string for download API (e.g. "720p" → "720")
  static String _stripP(String quality) => quality.endsWith('p')
      ? quality.substring(0, quality.length - 1)
      : quality;

  /// Fetch video info from /api/info
  Future<YouTubeResult> download(String url) async {
    try {
      // Check if it's a playlist
      if (isPlaylistUrl(url)) {
        return await _downloadPlaylist(url);
      }

      final videoId = _extractVideoId(url);
      if (videoId == null) {
        throw Exception('Invalid YouTube URL');
      }

      final response = await _dio.post(
        _infoApiUrl,
        options: Options(
          headers: {'Referer': _getReferer(videoId)},
        ),
        data: jsonEncode({'videoId': videoId}),
      );

      final data = response.data;
      if (data == null || data['status'] != 'info' || data['info'] == null) {
        throw Exception('Gagal mengambil info video');
      }

      final info = data['info'] as Map;
      final formats = (info['formats'] as List?) ?? [];
      final durationSec = (info['duration'] is int)
          ? info['duration'] as int
          : int.tryParse(info['duration']?.toString() ?? '0') ?? 0;

      // Parse video formats from /api/info
      final List<YouTubeVideoQuality> videoFormats = [];
      for (final f in formats) {
        if (f['type'] == 'video') {
          final qualityRaw = (f['quality'] ?? '').toString(); // e.g. "720p"
          final qualityKey = _stripP(qualityRaw); // e.g. "720"
          final fileSize = (f['fileSize'] is int)
              ? f['fileSize'] as int
              : int.tryParse(f['fileSize']?.toString() ?? '0') ?? 0;
          videoFormats.add(YouTubeVideoQuality(
            quality: qualityRaw, // display: "720p"
            format: f['format'] ?? 'mp4',
            size: formatFileSize(fileSize), // display: "89.0 MB"
            downloadUrl: qualityKey, // key: "720" → sent to API
          ));
        }
      }

      // Sort video formats descending (1080p first)
      videoFormats.sort((a, b) {
        final aNum = int.tryParse(a.downloadUrl) ?? 0;
        final bNum = int.tryParse(b.downloadUrl) ?? 0;
        return bNum - aNum;
      });

      // Parse audio formats from /api/info (m4a, opus)
      final List<YouTubeAudioQuality> audioFormats = [];
      for (final f in formats) {
        if (f['type'] == 'audio') {
          final fmt = (f['format'] ?? '').toString(); // "m4a" or "opus"
          final fileSize = (f['fileSize'] is int)
              ? f['fileSize'] as int
              : int.tryParse(f['fileSize']?.toString() ?? '0') ?? 0;
          audioFormats.add(YouTubeAudioQuality(
            quality: fmt.toUpperCase(), // display: "M4A" / "OPUS"
            format: fmt,
            size: formatFileSize(fileSize),
            downloadUrl: fmt, // key: "m4a" / "opus"
          ));
        }
      }

      // Append MP3 bitrate options (always supported)
      for (final a in audioBitrateOptions) {
        audioFormats.add(YouTubeAudioQuality(
          quality: a['label']!, // display: "320 kbps"
          format: a['format']!,
          size: '', // size unknown until download
          downloadUrl: a['quality']!, // key: "320"
        ));
      }

      return YouTubeResult(
        videoId: videoId,
        title: info['title'] ?? 'YouTube Video',
        thumbnail: info['thumbnail'] ??
            'https://i.ytimg.com/vi/$videoId/maxresdefault.jpg',
        duration: formatDuration(durationSec),
        author: info['author'] ?? '',
        videoFormats: videoFormats,
        audioFormats: audioFormats,
      );
    } catch (e) {
      throw Exception('YouTube download gagal: $e');
    }
  }

  /// Fetch playlist info and videos
  Future<YouTubeResult> _downloadPlaylist(String url) async {
    try {
      final playlistId = _extractPlaylistId(url);
      if (playlistId == null) {
        throw Exception('Invalid playlist URL');
      }

      // Fetch playlist page HTML
      final response = await _dio.get(
        'https://www.youtube.com/playlist?list=$playlistId',
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
        ),
      );

      final html = response.data.toString();
      
      // Extract initial data from ytInitialData
      final ytDataRegex = RegExp(r'var ytInitialData = ({.+?});');
      final match = ytDataRegex.firstMatch(html);
      
      if (match == null) {
        throw Exception('Gagal mengekstrak data playlist');
      }

      final jsonData = jsonDecode(match.group(1)!);
      
      // Navigate to playlist content
      final sidebar = jsonData['sidebar']?['playlistSidebarRenderer']?['items'] as List?;
      final contents = jsonData['contents']?['twoColumnBrowseResultsRenderer']?['tabs']?[0]?['tabRenderer']?['content']?['sectionListRenderer']?['contents']?[0]?['itemSectionRenderer']?['contents']?[0]?['playlistVideoListRenderer']?['contents'] as List?;

      if (contents == null || sidebar == null) {
        throw Exception('Gagal mengekstrak konten playlist');
      }

      // Extract playlist info from sidebar
      String playlistTitle = 'YouTube Playlist';
      String playlistThumbnail = '';
      int videoCount = 0;

      for (var item in sidebar) {
        final primaryInfo = item['playlistSidebarPrimaryInfoRenderer'];
        if (primaryInfo != null) {
          playlistTitle = primaryInfo['title']?['runs']?[0]?['text'] ?? playlistTitle;
          
          final thumbnails = primaryInfo['thumbnailRenderer']?['playlistVideoThumbnailRenderer']?['thumbnail']?['thumbnails'] as List?;
          if (thumbnails != null && thumbnails.isNotEmpty) {
            playlistThumbnail = thumbnails.last['url'] ?? '';
          }
          
          final stats = primaryInfo['stats'] as List?;
          if (stats != null && stats.isNotEmpty) {
            final videoCountText = stats[0]?['runs']?[0]?['text'];
            if (videoCountText != null) {
              videoCount = int.tryParse(videoCountText.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
            }
          }
        }
      }

      // Extract videos from contents
      final List<YouTubePlaylistItem> playlistItems = [];
      int index = 1;

      for (var item in contents) {
        final videoRenderer = item['playlistVideoRenderer'];
        if (videoRenderer != null) {
          final videoId = videoRenderer['videoId']?.toString() ?? '';
          if (videoId.isEmpty) continue;

          final title = videoRenderer['title']?['runs']?[0]?['text'] ?? 'Unknown';
          
          final thumbnails = videoRenderer['thumbnail']?['thumbnails'] as List?;
          String thumbnail = '';
          if (thumbnails != null && thumbnails.isNotEmpty) {
            thumbnail = thumbnails.last['url'] ?? '';
          }

          final lengthText = videoRenderer['lengthText']?['simpleText'] ?? '';
          
          final ownerText = videoRenderer['shortBylineText']?['runs']?[0]?['text'] ?? '';

          playlistItems.add(YouTubePlaylistItem(
            videoId: videoId,
            title: title,
            thumbnail: thumbnail,
            duration: lengthText,
            author: ownerText,
            index: index++,
          ));
        }
      }

      if (playlistItems.isEmpty) {
        throw Exception('Playlist is empty or inaccessible');
      }

      return YouTubeResult(
        videoId: '', // No single video ID for playlist
        title: playlistTitle,
        thumbnail: playlistThumbnail,
        duration: '${playlistItems.length} videos',
        author: '',
        videoFormats: [],
        audioFormats: [],
        isPlaylist: true,
        playlistId: playlistId,
        videoCount: videoCount > 0 ? videoCount : playlistItems.length,
        playlistItems: playlistItems,
      );
    } catch (e) {
      throw Exception('Gagal memuat playlist: $e');
    }
  }

  /// Fetch video download link for a specific quality
  Future<DlsrvResponse> getVideoDownloadUrl(
      String videoId, String quality) async {
    try {
      final response = await _dio.post(
        _videoApiUrl,
        options: Options(
          validateStatus: (_) => true,
          headers: {'Referer': _getReferer(videoId)},
        ),
        data: jsonEncode({
          'videoId': videoId,
          'format': 'mp4',
          'quality': quality, // e.g. "720" (without p)
        }),
      );

      final data = response.data;
      if (data == null) throw Exception('Empty response from server (HTTP ${response.statusCode})');

      if (data is Map) {
        final result = DlsrvResponse.fromJson(data);
        if (!result.isSuccess) {
          throw Exception('Server error: status=${result.status}, http=${response.statusCode}');
        }
        return result;
      }
      throw Exception('Unrecognized response format (HTTP ${response.statusCode}): ${data.toString().substring(0, (data.toString().length).clamp(0, 200))}');
    } catch (e) {
      throw Exception('Gagal mendapatkan link video ${quality}p: $e');
    }
  }

  /// Fetch audio download link for a specific quality/format
  Future<DlsrvResponse> getAudioDownloadUrl(
      String videoId, String quality) async {
    try {
      final String bodyFormat;
      final String bodyQuality;
      if (quality == 'm4a') {
        bodyFormat = 'm4a';
        bodyQuality = '128'; // use bitrate for m4a
      } else if (quality == 'opus') {
        bodyFormat = 'opus';
        bodyQuality = '128';
      } else {
        bodyFormat = 'mp3'; // For bitrate qualities: 320, 256, 128, 96, 64
        bodyQuality = quality;
      }

      final response = await _dio.post(
        _audioApiUrl,
        options: Options(
          validateStatus: (_) => true, // don't throw on 4xx/5xx
          headers: {'Referer': _getReferer(videoId)},
        ),
        data: jsonEncode({
          'videoId': videoId,
          'format': bodyFormat,
          'quality': bodyQuality,
        }),
      );

      final data = response.data;
      if (data == null) throw Exception('Response kosong (HTTP ${response.statusCode})');

      if (data is Map) {
        final result = DlsrvResponse.fromJson(data);
        if (!result.isSuccess) {
          throw Exception(
            'Server menolak: status="${result.status}" (HTTP ${response.statusCode}). '
            'URL=${result.url.isEmpty ? "(kosong)" : result.url}',
          );
        }
        return result;
      }
      // Response was HTML or unexpected string
      final preview = data.toString();
      throw Exception(
        'Invalid response (HTTP ${response.statusCode}): '
        '${preview.substring(0, preview.length.clamp(0, 150))}',
      );
    } catch (e) {
      throw Exception('Gagal mendapatkan link audio $quality: $e');
    }
  }
}

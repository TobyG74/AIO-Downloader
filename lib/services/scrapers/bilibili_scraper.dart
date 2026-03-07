import 'package:dio/dio.dart';
import 'dart:convert';
import '../../models/bilibili_result.dart';

class BilibiliScraper {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    validateStatus: (status) => status != null && status < 500,
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'Accept': 'application/json, text/plain, */*',
      'Accept-Language': 'en-US,en;q=0.9,id;q=0.8',
      'Referer': 'https://www.bilibili.tv/',
      'Origin': 'https://www.bilibili.tv',
      'Sec-Fetch-Dest': 'empty',
      'Sec-Fetch-Mode': 'cors',
      'Sec-Fetch-Site': 'same-site',
    },
  ));

  final String _apiBaseUrl = 'https://api.bilibili.tv/intl/gateway/web/playurl';

  /// Extract video ID from Bilibili URL
  Future<String?> extractVideoId(String url) async {
    // Check if it's a short URL that needs redirect following
    final shortUrlPatterns = [
      RegExp(r'b23\.tv/', caseSensitive: false),
      RegExp(r'bili\.im/', caseSensitive: false),
    ];

    bool isShortUrl = false;
    for (final pattern in shortUrlPatterns) {
      if (pattern.hasMatch(url)) {
        isShortUrl = true;
        break;
      }
    }

    // If it's a short URL, follow redirects to get the actual URL
    String targetUrl = url;
    if (isShortUrl) {
      try {
        final response = await _dio.get(
          url,
          options: Options(
            followRedirects: true,
            maxRedirects: 5,
            validateStatus: (status) => status! < 400,
          ),
        );
        // Get the final URL after redirects
        targetUrl = response.realUri.toString();
      } catch (e) {
        // If redirect fails, try with original URL
        targetUrl = url;
      }
    }

    // Extract video ID from full URL
    final patterns = [
      RegExp(r'bilibili\.tv/[a-z]{2}/video/(\d+)', caseSensitive: false),
      RegExp(r'bilibili\.tv/video/(\d+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(targetUrl);
      if (match != null) {
        return match.group(1);
      }
    }

    return null;
  }

  /// Fetch thumbnail and title from video page
  Future<Map<String, String?>> fetchThumbnailAndTitle(String videoId) async {
    try {
      final pageUrl = 'https://www.bilibili.tv/en/video/$videoId';
      final response = await _dio.get(
        pageUrl,
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          },
        ),
      );

      if (response.statusCode == 200) {
        final html = response.data as String;
        
        // Find JSON-LD script tag
        final jsonLdPattern = RegExp(
          r'<script type="application/ld\+json">(.+?)</script>',
          dotAll: true,
        );
        final match = jsonLdPattern.firstMatch(html);
        
        if (match != null) {
          final jsonLdString = match.group(1);
          if (jsonLdString != null) {
            final jsonLdList = jsonDecode(jsonLdString) as List;
            
            // Find VideoObject in the array
            for (final item in jsonLdList) {
              if (item is Map && item['@type'] == 'VideoObject') {
                return {
                  'thumbnailUrl': item['thumbnailUrl'] as String?,
                  'title': item['name'] as String?,
                };
              }
            }
          }
        }
      }
    } catch (e) {
      // Ignore thumbnail fetch errors, continue without thumbnail
    }
    return {'thumbnailUrl': null, 'title': null};
  }

  /// Fetch video data from Bilibili API
  Future<BilibiliResult> fetchVideo(String url) async {
    try {
      // Extract video ID from URL (may follow redirects for short URLs)
      final videoId = await extractVideoId(url);
      if (videoId == null || videoId.isEmpty) {
        throw Exception('Invalid Bilibili URL. Unable to extract video ID.');
      }

      // Fetch thumbnail and title from page
      final metadata = await fetchThumbnailAndTitle(videoId);

      // Call API with additional headers
      final response = await _dio.get(
        _apiBaseUrl,
        queryParameters: {
          's_locale': 'en_US',
          'platform': 'web',
          'aid': videoId,
          'qn': '112', // Request highest quality
        },
        options: Options(
          headers: {
            'Referer': 'https://www.bilibili.tv/en/video/$videoId',
          },
        ),
      );

      if (response.statusCode == 403) {
        throw Exception('Access denied. This video may be region-locked or requires authentication.');
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch video data: ${response.statusCode}');
      }

      final jsonData = response.data;

      // Check response code
      if (jsonData['code'] != 0) {
        throw Exception('API error: ${jsonData['message'] ?? 'Unknown error'}');
      }

      // Check if video data exists
      if (jsonData['data'] == null || jsonData['data']['playurl'] == null) {
        throw Exception('Video data not found');
      }

      // Parse and return result with thumbnail and title
      return BilibiliResult.fromJson(
        jsonData, 
        videoId,
        thumbnailUrl: metadata['thumbnailUrl'],
        title: metadata['title'],
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Access denied (403). This video may be region-locked or requires authentication. Try using a VPN or check if the video is available in your region.');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.badResponse) {
        throw Exception('Server error: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch Bilibili video: $e');
    }
  }

  /// Get audio URL for a specific quality
  String getAudioUrl(BilibiliResult result, int audioQuality) {
    final audio = result.playUrl.audioResources.firstWhere(
      (a) => a.quality == audioQuality,
      orElse: () => result.playUrl.bestAudio,
    );
    return audio.audioUrl;
  }
}

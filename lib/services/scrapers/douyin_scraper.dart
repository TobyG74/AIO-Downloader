import 'dart:convert';
import 'package:dio/dio.dart';
import '../../models/douyin_result.dart';

class DouyinScraper {
  static const String _encodedUrl = 'aHR0cDovLzY0LjIzLjI1MS4xNDU6ODAwOA==';
  static String get _baseUrl => utf8.decode(base64.decode(_encodedUrl));
  
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  /// Fetch Douyin video details from URL
  Future<DouyinResult> fetchDouyin(String url) async {
    try {
      final redirectResponse = await _dio.post(
        '$_baseUrl/douyin/redirect/',
        data: {'url': url},
      );

      if (redirectResponse.statusCode != 200) {
        throw Exception('Failed to get redirect data: ${redirectResponse.statusCode}');
      }

      final redirectData = redirectResponse.data;
      
      if (redirectData['code'] != 200) {
        throw Exception('API returned error code: ${redirectData['code']}');
      }

      // Extract aweme_id
      final data = redirectData['data'] as Map<String, dynamic>;
      final awemeId = data['aweme_id'] as String?;

      if (awemeId == null || awemeId.isEmpty) {
        throw Exception('Failed to extract aweme_id from URL');
      }

      // Get video details
      final videoResponse = await _dio.post(
        '$_baseUrl/douyin/video/',
        data: {'aweme_id': awemeId},
      );

      if (videoResponse.statusCode != 200) {
        throw Exception('Failed to get video details: ${videoResponse.statusCode}');
      }

      final videoData = videoResponse.data;
      
      if (videoData['code'] != 200) {
        throw Exception('API returned error code: ${videoData['code']}');
      }

      // Parse and return result
      return DouyinResult.fromJson(videoData);
      
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Cannot connect to server. Please try again later.');
      } else if (e.response != null) {
        throw Exception('Server error: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch Douyin video: $e');
    }
  }

  /// Get download URL for specific quality
  String getDownloadUrl(DouyinVideo video, {int? qualityIndex}) {
    if (qualityIndex != null && 
        qualityIndex >= 0 && 
        qualityIndex < video.videoDetail.qualities.length) {
      final quality = video.videoDetail.qualities[qualityIndex];
      if (quality.url.isNotEmpty) {
        return quality.url;
      }
    }
    
    // Fallback to default download URL
    return video.videoDetail.downloadUrl;
  }

  void dispose() {
    _dio.close();
  }
}

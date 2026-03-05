import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import '../../models/twitter_result.dart';

class TwitterScraper {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36',
    },
  ));

  final String _snapvidBase = 'https://snapvid.net';

  Future<TwitterResult> download(String url) async {
    try {
      final cftoken = await _getUserVerifyToken(url);

      final response = await _dio.post(
        '$_snapvidBase/api/ajaxSearch',
        data: {
          'q': url,
          'w': '',
          'v': 'v2',
          'lang': 'en',
          'cftoken': cftoken,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.data != null && response.data['status'] == 'ok') {
        return _parseTwitterData(response.data['data']);
      } else {
        throw Exception('Failed to get Twitter data');
      }
    } catch (e) {
      throw Exception('Twitter scraping failed: $e');
    }
  }

  Future<String> _getUserVerifyToken(String url) async {
    try {
      final response = await _dio.post(
        '$_snapvidBase/api/userverify',
        data: {'url': url},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.data != null && response.data['success'] == true) {
        return response.data['token'];
      } else {
        throw Exception('Failed to get user verify token');
      }
    } catch (error) {
      throw Exception('User verify failed: $error');
    }
  }

  TwitterResult _parseTwitterData(String htmlData) {
    final document = html_parser.parse(htmlData);

    // Get title
    String title = 'Twitter Media';
    final titleElement = document.querySelector('.tw-middle .content h3');
    if (titleElement != null) {
      title = titleElement.text.trim();
    }

    // Get thumbnail (from first video/image)
    String thumbnail = '';
    
    // Get video qualities
    List<TwitterVideoQuality> videos = [];
    List<String> images = [];

    // Check for video format (tw-video class) - could be multiple
    final videoContainers = document.querySelectorAll('.tw-video');
    if (videoContainers.isNotEmpty) {
      // Video/GIF format - parse from each .tw-video container
      for (var i = 0; i < videoContainers.length; i++) {
        final container = videoContainers[i];
        
        // Get thumbnail for this specific video/GIF
        String videoThumbnail = '';
        final thumbnailImg = container.querySelector('.thumbnail .image-tw img');
        if (thumbnailImg != null) {
          videoThumbnail = thumbnailImg.attributes['src'] ?? '';
        }
        
        // Set main thumbnail from first container
        if (thumbnail.isEmpty && videoThumbnail.isNotEmpty) {
          thumbnail = videoThumbnail;
        }
        
        // Get download links from this container
        final downloadLinks = container.querySelectorAll('.dl-action p a');
        for (final link in downloadLinks) {
          final text = link.text;
          final href = link.attributes['href'];

          if (href != null && href.isNotEmpty && href.startsWith('http')) {
            if (text.contains('MP4')) {
              // Extract quality from text like "Download MP4 (1920p)" or "Download MP4 (gif)"
              final qualityMatch = RegExp(r'\(([^)]+)\)').firstMatch(text);
              var quality = qualityMatch?.group(1) ?? 'Unknown';
              
              // Add index if multiple videos/gifs
              if (videoContainers.length > 1) {
                quality = '$quality - ${i + 1}';
              }
              
              videos.add(TwitterVideoQuality(
                quality: quality,
                url: href,
                thumbnail: videoThumbnail,
              ));
            }
            // Don't add images here as they are video thumbnails, not separate images
          }
        }
      }
      
      // Get duration from first container
      String duration = '';
      final durationElement = videoContainers.first.querySelector('.tw-middle .content p');
      if (durationElement != null) {
        duration = durationElement.text.trim();
      }
      
      return TwitterResult(
        title: title,
        thumbnail: thumbnail,
        duration: duration,
        videos: videos,
        images: images,
      );
    } else {
      // Photo format - parse from .photo-list
      final photoItems = document.querySelectorAll('.download-box li');
      for (final item in photoItems) {
        final imgElement = item.querySelector('.download-items__thumb img');
        final linkElement = item.querySelector('.download-items__btn a');
        
        if (imgElement != null && thumbnail.isEmpty) {
          thumbnail = imgElement.attributes['src'] ?? '';
        }
        
        if (linkElement != null) {
          final href = linkElement.attributes['href'];
          if (href != null && href.isNotEmpty && href.startsWith('http')) {
            images.add(href);
          }
        }
      }
      
      return TwitterResult(
        title: title,
        thumbnail: thumbnail,
        duration: '',
        videos: videos,
        images: images,
      );
    }
  }
}

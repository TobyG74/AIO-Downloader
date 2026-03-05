import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import '../../models/instagram_result.dart';

class InstagramScraper {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36',
    },
  ));

  final String _snapvidBase = 'https://snapvid.net';

  /// Get user verification token
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

  /// Parse HTML response to extract download links
  InstagramResult _parseInstagramData(String htmlContent) {
    final document = html_parser.parse(htmlContent);

    // Check if it's video or images
    final firstIcon = document.querySelector('.download-items__thumb .format-icon i');
    final isVideo = firstIcon?.classes.contains('icon-dlvideo') ?? false;

    if (isVideo) {
      // Parse video
      final videoUrl = document.querySelector('.download-items__btn a')?.attributes['href'] ?? '';
      final thumbnail = document.querySelector('.download-items__thumb img')?.attributes['src'] ?? '';

      return InstagramResult(
        type: InstagramMediaType.video,
        video: InstagramVideoItem(
          url: videoUrl,
          thumbnail: thumbnail,
        ),
      );
    } else {
      // Parse images (carousel/multiple images)
      List<InstagramImageItem> images = [];

      final items = document.querySelectorAll('.download-box li');
      for (var i = 0; i < items.length; i++) {
        final elem = items[i];
        final defaultUrl = elem.querySelector('.download-items__btn a')?.attributes['href'] ?? '';

        // Extract ID from select element's onchange attribute
        final onchangeAttr = elem.querySelector('select')?.attributes['onchange'] ?? '';
        final idMatch = RegExp(r"getPhotoLink\('(\d+)'").firstMatch(onchangeAttr);
        final id = idMatch?.group(1) ?? 'image_$i';

        // Extract qualities from select options
        List<InstagramImageQuality> qualities = [];
        final options = elem.querySelectorAll('select option');
        for (var option in options) {
          final quality = option.text.trim();
          final url = option.attributes['value'] ?? '';
          if (quality.isNotEmpty && url.isNotEmpty) {
            qualities.add(InstagramImageQuality(quality: quality, url: url));
          }
        }

        images.add(InstagramImageItem(
          id: id,
          qualities: qualities,
          defaultUrl: defaultUrl,
        ));
      }

      return InstagramResult(
        type: InstagramMediaType.image,
        images: images,
      );
    }
  }

  /// Download Instagram media
  Future<InstagramResult> download(String url) async {
    try {
      // Get user verification token
      final cftoken = await _getUserVerifyToken(url);

      // Get media data
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
        final result = _parseInstagramData(response.data['data']);

        if (result.type == InstagramMediaType.image &&
            (result.images == null || result.images!.isEmpty)) {
          throw Exception('No images found');
        }

        if (result.type == InstagramMediaType.video &&
            (result.video == null || result.video!.url.isEmpty)) {
          throw Exception('No video found');
        }

        return result;
      } else {
        throw Exception('Failed to fetch Instagram media');
      }
    } catch (error) {
      throw Exception('Instagram download failed: $error');
    }
  }

  /// Get best quality image from an image item
  InstagramImageQuality? getBestImageQuality(InstagramImageItem imageItem) {
    if (imageItem.qualities.isEmpty) return null;

    // Sort by quality (1080 > 750 > 640)
    final sorted = List<InstagramImageQuality>.from(imageItem.qualities);
    sorted.sort((a, b) {
      int getSize(String q) {
        final match = RegExp(r'(\d+)').firstMatch(q);
        return match != null ? int.parse(match.group(1)!) : 0;
      }
      return getSize(b.quality) - getSize(a.quality);
    });

    return sorted.first;
  }
}

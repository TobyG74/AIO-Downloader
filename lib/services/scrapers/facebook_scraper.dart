import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import '../../models/facebook_result.dart';

class FacebookScraper {
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
  FacebookResult _parseVideoData(String htmlContent) {
    final document = html_parser.parse(htmlContent);

    // Extract title and duration
    final title = document.querySelector('.content h3')?.text.trim() ?? 'Facebook Video';
    final duration = document.querySelector('.content p')?.text.trim() ?? '';
    final thumbnail = document.querySelector('.image-fb img')?.attributes['src'] ?? '';

    List<FacebookVideoQuality> mp4Videos = [];

    // Extract MP4 videos from first tab
    final mp4Table = document.querySelectorAll('.tab__content').first;
    final rows = mp4Table.querySelectorAll('tbody tr');

    for (var row in rows) {
      final quality = row.querySelector('.video-quality')?.text.trim() ?? '';
      final render = row.querySelectorAll('td')[1].text.trim();
      final downloadBtn = row.querySelector('a.download-link-fb');
      final renderBtn = row.querySelector('button[data-videourl]');

      if (downloadBtn != null) {
        // Direct download link
        mp4Videos.add(FacebookVideoQuality(
          quality: quality,
          render: render == 'Yes',
          type: 'direct',
          url: downloadBtn.attributes['href'],
        ));
      } else if (renderBtn != null) {
        // Needs rendering
        mp4Videos.add(FacebookVideoQuality(
          quality: quality,
          render: render == 'Yes',
          type: 'render',
          videoUrl: renderBtn.attributes['data-videourl'],
          videoCodec: renderBtn.attributes['data-videocodec'],
          videoType: renderBtn.attributes['data-videotype'],
        ));
      }
    }

    return FacebookResult(
      title: title,
      duration: duration,
      thumbnail: thumbnail,
      mp4: mp4Videos,
    );
  }

  /// Download Facebook video
  Future<FacebookResult> download(String url) async {
    try {
      // Get user verification token
      final cftoken = await _getUserVerifyToken(url);

      // Get video data
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
        final result = _parseVideoData(response.data['data']);

        if (result.mp4.isEmpty) {
          throw Exception('No video found. Make sure this URL is a Facebook video, not a photo or other post.');
        }

        return result;
      } else {
        throw Exception('Gagal mengambil data. Pastikan URL adalah video Facebook yang valid.');
      }
    } catch (error) {
      // Check if error already has custom message
      if (error.toString().contains('Pastikan URL')) {
        rethrow;
      }
      throw Exception('Download Facebook gagal. Pastikan URL yang Anda masukkan adalah video Facebook, bukan foto atau postingan lainnya. Error: $error');
    }
  }

  /// Get best quality video (non-render)
  FacebookVideoQuality? getBestQuality(FacebookResult result) {
    final directLinks = result.mp4.where((v) => v.type == 'direct').toList();

    if (directLinks.isEmpty) return null;

    // Sort by quality
    directLinks.sort((a, b) {
      int getQuality(String q) {
        if (q.contains('1080')) return 3;
        if (q.contains('720')) return 2;
        if (q.contains('360')) return 1;
        return 0;
      }
      return getQuality(b.quality) - getQuality(a.quality);
    });

    return directLinks.first;
  }
}

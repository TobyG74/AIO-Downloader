import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import '../../models/twitter_result.dart';

class TwitterScraper {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36',
    },
  ));

  final String _apiBase = 'https://twitterdownloader.snapsave.app';

  /// Download Twitter media
  Future<TwitterResult> download(String url) async {
    try {

      final token = await _getToken();
      if (token.isEmpty) {
        throw Exception('Failed to get token');
      }
      
      final response = await _dio.post(
        '$_apiBase/action.php',
        data: {
          'url': url,
          'token': token,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Accept': '*/*',
            'Origin': _apiBase,
            'Referer': '$_apiBase/',
            'X-Requested-With': 'XMLHttpRequest',
          },
        ),
      );


      if (response.statusCode != 200) {
        throw Exception('API returned status ${response.statusCode}');
      }

      // Response is JSON with 'data' field containing HTML
      final html = response.data['data']?.toString() ?? '';
      
      if (html.isEmpty) {
        throw Exception('Empty response data');
      }

      final result = _parseTwitterData(html);

      return result;
    } catch (error) {
      throw Exception('Twitter download failed: $error');
    }
  }

  Future<String> _getToken() async {
    try {
      final response = await _dio.get(
        _apiBase,
        options: Options(
          responseType: ResponseType.plain,
        ),
      );

      if (response.statusCode != 200) {
        return '';
      }

      final document = html_parser.parse(response.data);
      final tokenInput = document.querySelector('input[name="token"]');
      
      return tokenInput?.attributes['value'] ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Parse HTML response to extract download links
  TwitterResult _parseTwitterData(String htmlContent) {
    final document = html_parser.parse(htmlContent);

    // Extract from #download-block
    final downloadBlock = document.querySelector('#download-block');
    if (downloadBlock == null) {
      throw Exception('Download block not found');
    }

    // Get download URL
    final downloadLink = downloadBlock.querySelector('.abuttons > a');
    final url = downloadLink?.attributes['href'];
    
    if (url == null || url.isEmpty) {
      throw Exception('Download URL not found');
    }

    // Get description
    final descSpan = document.querySelector('.videotikmate-middle > p > span');
    final description = descSpan?.text.trim() ?? '';

    // Get thumbnail
    final thumbnailImg = document.querySelector('.videotikmate-left > img');
    final thumbnail = thumbnailImg?.attributes['src'];

    // Check type (video or image)
    final buttonSpan = downloadBlock.querySelector('.abuttons > a > span > span');
    final buttonText = buttonSpan?.text.trim() ?? '';
    final isVideo = !buttonText.toLowerCase().contains('photo');

    if (isVideo) {
      return TwitterResult(
        title: description,
        thumbnail: thumbnail ?? '',
        duration: '',
        videos: [
          TwitterVideoQuality(
            quality: 'HD',
            url: url,
            thumbnail: thumbnail ?? '',
          ),
        ],
      );
    } else {
      return TwitterResult(
        title: description,
        thumbnail: thumbnail ?? '',
        duration: '',
        images: [url],
      );
    }
  }
}

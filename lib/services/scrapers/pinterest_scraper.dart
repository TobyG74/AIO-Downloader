import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import '../../models/pinterest_result.dart';

class PinterestScraper {
  static const String _baseUrl = 'https://pindown.io';
  static const String _userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'User-Agent': _userAgent,
      'Referer': '$_baseUrl/id1',
      'Origin': _baseUrl,
    },
  ));

  /// Get the hidden token field from the initial page load (required for POST request)
  Future<Map<String, String>> _fetchTokenField({String? cookies}) async {
    final response = await _dio.get(
      '$_baseUrl/id1',
      options: Options(
        headers: cookies != null ? {'Cookie': cookies} : null,
        validateStatus: (_) => true,
      ),
    );
    if (response.statusCode == 403) throw Exception('403');
    final document = html_parser.parse(response.data as String);

    final hiddenInputs = document.querySelectorAll('form input[type="hidden"]');
    for (final input in hiddenInputs) {
      final name = input.attributes['name'] ?? '';
      final value = input.attributes['value'] ?? '';
      if (name.isNotEmpty && name != 'lang' && value.isNotEmpty) {
        return {name: value};
      }
    }
    throw Exception('Could not extract token from pindown.io');
  }

  /// Make the POST request to get download links, using the extracted token field
  Future<String> _postAction(String url, Map<String, String> tokenField, {String? cookies}) async {
    final data = {
      'url': url,
      ...tokenField,
      'lang': 'id',
    };

    final response = await _dio.post(
      '$_baseUrl/action',
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: cookies != null ? {'Cookie': cookies} : null,
      ),
    );

    final body = response.data;
    if (body is Map && body['success'] == true) {
      return body['html'] as String;
    }
    throw Exception('pindown.io: request failed (success != true)');
  }

  /// Parse the HTML response to extract download links and metadata
  PinterestResult _parseResponse(String htmlContent) {
    final document = html_parser.parse(htmlContent);

    // Extract thumbnail (if any)
    final thumbImg =
        document.querySelector('.media-left img, .media .image img');
    final thumbnailUrl = thumbImg?.attributes['src'] ?? '';

    final strongEl = document.querySelector('.media-content strong');
    final spanEl = document.querySelector('.media-content .video-des');
    final title = strongEl?.text.trim() ?? 'Pinterest';
    final author = spanEl?.text.trim() ?? '';

    // Extract download items from the table rows
    final rows = document.querySelectorAll('table tbody tr');
    final items = <PinterestDownloadItem>[];

    for (final row in rows) {
      final typeLabel =
          row.querySelector('.video-quality, td:first-child')?.text.trim() ??
              '';
      final anchor = row.querySelector('a');
      if (anchor == null) continue;

      final href = anchor.attributes['href'] ?? '';
      final linkText = anchor.text.trim();
      final isDirect =
          linkText.contains('Direct') || href.contains('pinimg.com');

      if (typeLabel.isNotEmpty && href.isNotEmpty) {
        items.add(PinterestDownloadItem(
          type: typeLabel,
          url: href,
          isDirect: isDirect,
        ));
      }
    }

    if (items.isEmpty) {
      throw Exception('No download links found in Pinterest response');
    }

    // Determine media type (video, image, or gif) based on HTML cues
    final html = htmlContent.toLowerCase();
    PinterestMediaType mediaType;
    if (html.contains('preview-video') || html.contains('mp4')) {
      mediaType = PinterestMediaType.video;
    } else if (html.contains('.gif') || html.contains("download gif")) {
      mediaType = PinterestMediaType.gif;
    } else {
      mediaType = PinterestMediaType.image;
    }

    return PinterestResult(
      mediaType: mediaType,
      title: title,
      author: author,
      thumbnailUrl: thumbnailUrl,
      items: items,
    );
  }

  /// Main entry point — fetch metadata + download links for a Pinterest URL
  Future<PinterestResult> download(String url, {String? cookies}) async {
    try {
      final token = await _fetchTokenField(cookies: cookies);
      final html = await _postAction(url, token, cookies: cookies);
      return _parseResponse(html);
    } on DioException catch (e) {
      throw Exception('Pinterest network error: ${e.message}');
    } catch (e) {
      throw Exception('Pinterest download failed: $e');
    }
  }

  /// Helper: get best download item (prefer non-redirect / highest resolution)
  PinterestDownloadItem? getBestItem(PinterestResult result) {
    if (result.items.isEmpty) return null;

    // Prefer direct links (no ad redirect)
    final directs = result.items.where((i) => i.isDirect).toList();
    if (directs.isNotEmpty) return directs.first;

    return result.items.first;
  }
}

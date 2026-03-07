import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import '../../models/tiktok_result.dart';

class TikTokScraper {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36',
    },
  ));

  final String _musicaldownUrl = 'https://musicaldown.com';
  final String _musicaldownApi = 'https://musicaldown.com/download';

  /// Download TikTok video using MusicalDown
  /// [cfCookies] - CF cookies for bypassing Cloudflare (from WebViewCookieDialog)
  Future<TikTokResult> download(String url, {String? cfCookies}) async {
    return await _downloadFromMusicalDown(url, cfCookies: cfCookies);
  }

  /// Download using MusicalDown API
  Future<TikTokResult> _downloadFromMusicalDown(String url, {String? cfCookies}) async {
    try {
      final getResponse = await _dio.get(
        _musicaldownUrl,
        options: Options(
          headers: cfCookies != null ? {'Cookie': cfCookies} : null,
          validateStatus: (_) => true,
        ),
      );
      if (getResponse.statusCode == 403) throw Exception('403');
      final document = html_parser.parse(getResponse.data);
      final sessionCookie = getResponse.headers['set-cookie']?.first.split(';')[0] ?? '';
      final cookie = [
        if (cfCookies != null && cfCookies.isNotEmpty) cfCookies,
        if (sessionCookie.isNotEmpty) sessionCookie,
      ].join('; ');

      final inputs = document.querySelectorAll('div > input');
      final requestData = <String, String>{};
      
      for (var input in inputs) {
        final name = input.attributes['name'];
        final value = input.attributes['value'];
        if (name != null) {
          requestData[name] = name == inputs.first.attributes['name'] ? url : (value ?? '');
        }
      }

      final postResponse = await _dio.post(
        _musicaldownApi,
        data: requestData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'cookie': cookie,
            'Origin': 'https://musidown.com/download',
            'Referer': 'https://musidown.com/download/en',
          },
        ),
      );

      final resultDoc = html_parser.parse(postResponse.data);

      // Check for images (slide post)
      final images = <String>[];
      resultDoc.querySelectorAll('div.row > div[class="col s12 m3"]').forEach((element) {
        final imgSrc = element.querySelector('img')?.attributes['src'];
        if (imgSrc != null && imgSrc.isNotEmpty) {
          images.add(imgSrc);
        }
      });

      if (images.isNotEmpty) {
        return TikTokResult(
          title: '',
          author: '',
          authorName: '',
          duration: 0,
          cover: '',
          videoUrl: '',
          videoUrlHD: '',
          videoUrlWatermark: '',
          music: '',
          playCount: 0,
          diggCount: 0,
          commentCount: 0,
          shareCount: 0,
          downloadCount: 0,
          images: images,
        );
      }

      // Parse video links
      final videos = <String, String>{};
      final videoContainer = resultDoc.querySelectorAll('div.row > div');
      if (videoContainer.length > 1) {
        videoContainer[1].querySelectorAll('a').forEach((link) {
          final href = link.attributes['href'];
          if (href != null && href != '#modal2') {
            final dataEvent = link.attributes['data-event'] ?? '';
            
            if (dataEvent.contains('hd')) {
              videos['videoHD'] = href;
            } else if (dataEvent.contains('mp4')) {
              videos['videoSD'] = href;
            } else if (dataEvent.contains('watermark')) {
              videos['videoWatermark'] = href;
            } else if (href.contains('type=mp3')) {
              videos['music'] = href;
            }
          }
        });
      }

      // Extract author info
      final avatar = resultDoc.querySelector('div.img-area > img')?.attributes['src'] ?? '';
      final nickname = resultDoc.querySelector('h2.video-author > b')?.text ?? '';
      final desc = resultDoc.querySelector('p.video-desc')?.text ?? '';

      return TikTokResult(
        title: desc,
        author: '',
        authorName: nickname,
        duration: 0,
        cover: avatar,
        videoUrl: videos['videoSD'] ?? videos['videoHD'] ?? '',
        videoUrlHD: videos['videoHD'] ?? '',
        videoUrlWatermark: videos['videoWatermark'] ?? '',
        music: videos['music'] ?? '',
        playCount: 0,
        diggCount: 0,
        commentCount: 0,
        shareCount: 0,
        downloadCount: 0,
        images: [],
      );
    } catch (error) {
      throw Exception('MusicalDown download failed: $error');
    }
  }

  /// Check if URL is TikTok slide/image post
  bool isSlidePost(TikTokResult result) {
    return result.images.isNotEmpty;
  }
}

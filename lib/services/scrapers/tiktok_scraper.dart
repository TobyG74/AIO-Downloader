import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import '../../models/tiktok_result.dart';

enum TikTokServer { musicaldown, ssstik }

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
  final String _ssstikUrl = 'https://ssstik.io';
  final String _ssstikApi = 'https://ssstik.io/abc?url=dl';

  /// Download TikTok video using selected server
  /// [server] - Choose between musicaldown (default) or ssstik
  Future<TikTokResult> download(String url, {TikTokServer server = TikTokServer.musicaldown}) async {
    try {
      switch (server) {
        case TikTokServer.musicaldown:
          return await _downloadFromMusicalDown(url);
        case TikTokServer.ssstik:
          return await _downloadFromSSSTik(url);
      }
    } catch (error) {
      throw Exception('TikTok download failed: $error');
    }
  }

  /// Download using MusicalDown API
  Future<TikTokResult> _downloadFromMusicalDown(String url) async {
    try {
      final getResponse = await _dio.get(_musicaldownUrl);
      final document = html_parser.parse(getResponse.data);
      final cookie = getResponse.headers['set-cookie']?.first.split(';')[0] ?? '';

      // Extract form inputs
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
          videoUrlNoWatermark: '',
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
        videoUrlNoWatermark: videos['videoHD'] ?? videos['videoSD'] ?? '',
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

  /// Download using SSSTik API
  Future<TikTokResult> _downloadFromSSSTik(String url) async {
    try {
      final getResponse = await _dio.get(_ssstikUrl);
      final ttValue = _extractTTValue(getResponse.data);
      
      if (ttValue == null) {
        throw Exception('Failed to get TT token');
      }

      final postResponse = await _dio.post(
        _ssstikApi,
        data: {
          'id': url,
          'locale': 'en',
          'tt': ttValue,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Origin': _ssstikUrl,
            'Referer': '$_ssstikUrl/en',
          },
        ),
      );

      final document = html_parser.parse(postResponse.data);

      // Parse author info
      final avatar = document.querySelector('img.result_author')?.attributes['src'] ?? '';
      final nickname = document.querySelector('h2')?.text.trim() ?? '';
      final desc = document.querySelector('p.maintext')?.text.trim() ?? '';

      // Parse statistics
      final likeCount = document.querySelector('#trending-actions > .justify-content-start')?.text.trim() ?? '0';
      final commentCount = document.querySelector('#trending-actions > .justify-content-center')?.text.trim() ?? '0';
      final shareCount = document.querySelector('#trending-actions > .justify-content-end')?.text.trim() ?? '0';

      // Check for images (slide post)
      final images = <String>[];
      document.querySelectorAll('ul.splide__list > li').forEach((li) {
        final href = li.querySelector('a')?.attributes['href'];
        if (href != null) {
          images.add(href);
        }
      });

      if (images.isNotEmpty) {
        return TikTokResult(
          title: desc,
          author: '',
          authorName: nickname,
          duration: 0,
          cover: avatar,
          videoUrl: '',
          videoUrlNoWatermark: '',
          music: '',
          playCount: 0,
          diggCount: _parseCount(likeCount),
          commentCount: _parseCount(commentCount),
          shareCount: _parseCount(shareCount),
          downloadCount: 0,
          images: images,
        );
      }

      // Parse video link
      final videoUrl = document.querySelector('a.without_watermark')?.attributes['href'] ?? '';
      final musicUrl = document.querySelector('a.music')?.attributes['href'] ?? '';

      return TikTokResult(
        title: desc,
        author: '',
        authorName: nickname,
        duration: 0,
        cover: avatar,
        videoUrl: videoUrl,
        videoUrlNoWatermark: videoUrl,
        music: musicUrl,
        playCount: 0,
        diggCount: _parseCount(likeCount),
        commentCount: _parseCount(commentCount),
        shareCount: _parseCount(shareCount),
        downloadCount: 0,
        images: [],
      );
    } catch (error) {
      throw Exception('SSSTik download failed: $error');
    }
  }

  /// Extract TT value from HTML
  String? _extractTTValue(String html) {
    final regex = RegExp(r's_tt\s*=\s*["\' + "'" + r']([^"\' + "'" + r']+)["\' + "'" + r']');
    final match = regex.firstMatch(html);
    return match?.group(1);
  }

  /// Parse count string to integer (handles K, M notations)
  int _parseCount(String count) {
    if (count.isEmpty) return 0;
    
    count = count.trim().toUpperCase();
    if (count.contains('K')) {
      return (double.parse(count.replaceAll('K', '')) * 1000).toInt();
    } else if (count.contains('M')) {
      return (double.parse(count.replaceAll('M', '')) * 1000000).toInt();
    }
    
    return int.tryParse(count) ?? 0;
  }

  /// Check if URL is TikTok slide/image post
  bool isSlidePost(TikTokResult result) {
    return result.images.isNotEmpty;
  }

  /// Get video without watermark
  String? getNoWatermarkUrl(TikTokResult result) {
    return result.videoUrlNoWatermark;
  }
}

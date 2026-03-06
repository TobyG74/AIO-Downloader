import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import '../../models/threads_result.dart';

class ThreadsScraper {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36',
    },
  ));

  final String _apiBase = 'https://threads.snapsave.app';

  /// Download Threads media
  Future<ThreadsResult> download(String url) async {
    try {
      final response = await _dio.get(
        '$_apiBase/api/action',
        queryParameters: {
          'url': url,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Origin': _apiBase,
            'Referer': '$_apiBase/',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('API returned status ${response.statusCode}');
      }

      final responseData = response.data;
      
      // Check if response is new JSON format
      if (responseData is Map && 
          responseData.containsKey('items') && 
          responseData.containsKey('status_code')) {
        return _parseJsonResponse(Map<String, dynamic>.from(responseData));
      }
      
      // Old format handling
      String html = '';
      
      if (responseData is Map && responseData.containsKey('data')) {
        html = responseData['data']?.toString() ?? '';
      } else {
        final encryptedData = responseData.toString();
        html = _decryptResponse(encryptedData);
      }
      
      if (html.isEmpty) {
        throw Exception('Failed to get response data');
      }

      final result = _parseThreadsData(html);

      return result;
    } catch (error) {
      throw Exception('Threads download failed: $error');
    }
  }

  /// Parse new JSON response format
  ThreadsResult _parseJsonResponse(Map<String, dynamic> data) {
    try {
      final items = data['items'] as List?;
      if (items == null || items.isEmpty) {
        throw Exception('No items found in response');
      }

      final firstItem = items[0] as Map<String, dynamic>;
      final type = firstItem['type']?.toString() ?? '';

      if (type == 'video') {
        // Handle video posts (single or carousel)
        final videoItems = items
            .where((item) => (item as Map<String, dynamic>)['type'] == 'video')
            .map((item) {
          final videoItem = item as Map<String, dynamic>;
          return ThreadsVideoItem(
            url: videoItem['downloadUrl']?.toString() ?? videoItem['videoUrl']?.toString() ?? '',
            thumbnail: videoItem['thumbnail']?.toString(),
          );
        }).toList();

        if (videoItems.isEmpty) {
          throw Exception('No videos found');
        }

        return ThreadsResult(
          type: ThreadsMediaType.video,
          videos: videoItems,
        );
      } else if (type == 'image') {
        // Handle image posts
        final images = items.where((item) {
          return (item as Map<String, dynamic>)['type'] == 'image';
        }).map((item) {
          final imageItem = item as Map<String, dynamic>;
          return ThreadsImageItem(
            url: imageItem['downloadUrl']?.toString() ?? imageItem['imageUrl']?.toString() ?? '',
          );
        }).toList();

        if (images.isEmpty) {
          throw Exception('No images found');
        }

        return ThreadsResult(
          type: ThreadsMediaType.image,
          images: images,
        );
      } else {
        throw Exception('Unknown media type: $type');
      }
    } catch (e) {
      throw Exception('Failed to parse JSON response: $e');
    }
  }

  String _decryptResponse(String encryptedData) {
    try {
      final params = _getEncodedParams(encryptedData);
      if (params.isEmpty) return '';
      
      final decoded = _decodeSnapApp(params);
      if (decoded.isEmpty) return '';
      
      final html = _getDecodedSnapSave(decoded);
      return html;
    } catch (e) {
      return '';
    }
  }
  
  List<String> _getEncodedParams(String data) {
    try {
      final parts = data.split('decodeURIComponent(escape(r))}(');
      if (parts.length < 2) return [];
      
      final paramString = parts[1].split('))')[0];
      final params = paramString.split(',').map((v) => v.replaceAll('"', '').trim()).toList();
      
      return params;
    } catch (e) {
      return [];
    }
  }
  
  String _decodeSnapApp(List<String> args) {
    if (args.length < 6) return '';
    
    final t = args[0];
    final o = args[2];
    final b = int.tryParse(args[3]) ?? 0;
    final z = int.tryParse(args[4]) ?? 0;
    
    const alphabet = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+/';
    final tArr = alphabet.substring(0, z).split('');
    
    final result = StringBuffer();
    
    for (int i = 0; i < t.length;) {
      String s = '';
      
      while (i < t.length && t[i] != o[z]) {
        s += t[i];
        i++;
      }
      i++;
      
      for (int j = 0; j < o.length; j++) {
        s = s.replaceAll(o[j], j.toString());
      }
      
      final decoded = _decodeBase(s, z, tArr);
      final charCode = decoded - b;
      
      if (charCode > 0) {
        result.writeCharCode(charCode);
      }
    }
    
    return result.toString();
  }
  
  int _decodeBase(String d, int z, List<String> tArr) {
    final reversed = d.split('').reversed.toList();
    int j = 0;
    
    for (int c = 0; c < reversed.length; c++) {
      final idx = tArr.indexOf(reversed[c]);
      if (idx != -1) {
        j += idx * _pow(z, c);
      }
    }
    
    return j;
  }
  
  int _pow(int base, int exp) {
    int result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
  
  String _getDecodedSnapSave(String data) {
    try {
      final parts = data.split('getElementById("download-section").innerHTML = "');
      if (parts.length < 2) return '';
      
      final html = parts[1]
          .split('"; document.getElementById("inputData").remove(); ')[0]
          .replaceAll(r'\', '');
      
      return html;
    } catch (e) {
      return '';
    }
  }

  /// Parse HTML response to extract download links
  ThreadsResult _parseThreadsData(String htmlContent) {
    final document = html_parser.parse(htmlContent);

    // Check for download block (similar to Twitter)
    final downloadBlock = document.querySelector('#download-block');
    if (downloadBlock != null) {
      return _parseDownloadBlock(document);
    }

    // Check for table layout
    if (document.querySelector('table.table') != null) {
      return _parseTableLayout(document);
    }
    
    // Check for download-items
    if (document.querySelector('div.download-items') != null) {
      return _parseDownloadItems(document);
    }
    
    // Fallback to simple parsing
    return _parseSingleItem(document);
  }
  
  /// Parse download block layout (Twitter-style)
  ThreadsResult _parseDownloadBlock(dynamic document) {
    final downloadBlock = document.querySelector('#download-block');
    final downloadLink = downloadBlock?.querySelector('.abuttons > a');
    final url = downloadLink?.attributes['href'];
    
    if (url == null || url.isEmpty) {
      throw Exception('Download URL not found');
    }

    final thumbnailImg = document.querySelector('.videotikmate-left > img');
    final thumbnail = thumbnailImg?.attributes['src'];

    final buttonSpan = downloadBlock?.querySelector('.abuttons > a > span > span');
    final buttonText = buttonSpan?.text.trim() ?? '';
    final isVideo = !buttonText.toLowerCase().contains('photo');

    if (isVideo) {
      return ThreadsResult(
        type: ThreadsMediaType.video,
        videos: [ThreadsVideoItem(
          url: url,
          thumbnail: thumbnail,
        )],
      );
    } else {
      return ThreadsResult(
        type: ThreadsMediaType.image,
        images: [ThreadsImageItem(url: url)],
      );
    }
  }
  
  /// Parse table layout
  ThreadsResult _parseTableLayout(dynamic document) {
    final rows = document.querySelectorAll('table.table tbody tr');
    
    if (rows.isEmpty) {
      throw Exception('No table rows found');
    }
    
    final firstRow = rows.first;
    final cells = firstRow.querySelectorAll('td');
    
    String? videoUrl;
    if (cells.length >= 3) {
      final button = cells[2].querySelector('button');
      videoUrl = button?.attributes['onclick'];
      
      if (videoUrl != null && videoUrl.contains('get_progressApi')) {
        final match = RegExp(r"get_progressApi\('(.*?)'\)").firstMatch(videoUrl);
        if (match != null) {
          videoUrl = 'https://threads.snapsave.app${match.group(1)}';
        }
      } else {
        videoUrl = button?.attributes['href'] ?? cells[2].querySelector('a')?.attributes['href'];
      }
    }
    
    if (videoUrl == null || videoUrl.isEmpty) {
      throw Exception('Video URL not found');
    }
    
    final thumbnail = document.querySelector('article.media > figure img')?.attributes['src'];
    
    return ThreadsResult(
      type: ThreadsMediaType.video,
      videos: [ThreadsVideoItem(
        url: videoUrl,
        thumbnail: thumbnail,
      )],
    );
  }
  
  /// Parse download-items layout
  ThreadsResult _parseDownloadItems(dynamic document) {
    final downloadItems = document.querySelectorAll('div.download-items');
    
    if (downloadItems.isEmpty) {
      throw Exception('No download items found');
    }
    
    final firstItem = downloadItems.first;
    final videoElement = firstItem.querySelector('video');
    final downloadBtn = firstItem.querySelector('div.download-items__btn');
    final spanText = downloadBtn?.querySelector('span')?.text.trim() ?? '';
    final isVideo = videoElement != null || spanText.toLowerCase().contains('video');
    
    if (isVideo) {
      final thumbnail = firstItem.querySelector('div.download-items__thumb > img')?.attributes['src'];
      final videoUrl = downloadBtn?.querySelector('a')?.attributes['href'];
      
      if (videoUrl == null || videoUrl.isEmpty) {
        throw Exception('Video URL not found');
      }
      
      return ThreadsResult(
        type: ThreadsMediaType.video,
        videos: [ThreadsVideoItem(
          url: videoUrl,
          thumbnail: thumbnail,
        )],
      );
    } else {
      List<ThreadsImageItem> images = [];
      
      for (var item in downloadItems) {
        final itemThumb = item.querySelector('div.download-items__thumb > img');
        final imageUrl = itemThumb?.attributes['src'];
        
        if (imageUrl != null && imageUrl.isNotEmpty) {
          images.add(ThreadsImageItem(url: imageUrl));
        }
      }
      
      if (images.isEmpty) {
        throw Exception('No images found');
      }
      
      return ThreadsResult(
        type: ThreadsMediaType.image,
        images: images,
      );
    }
  }
  
  /// Parse simple single item
  ThreadsResult _parseSingleItem(dynamic document) {
    final link = document.querySelector('a');
    final url = link?.attributes['href'];
    final linkText = link?.text.trim() ?? '';
    
    if (url == null || url.isEmpty) {
      throw Exception('No download URL found');
    }
    
    final isImage = linkText.toLowerCase().contains('photo');
    
    if (isImage) {
      return ThreadsResult(
        type: ThreadsMediaType.image,
        images: [ThreadsImageItem(url: url)],
      );
    } else {
      return ThreadsResult(
        type: ThreadsMediaType.video,
        videos: [ThreadsVideoItem(url: url)],
      );
    }
  }
}

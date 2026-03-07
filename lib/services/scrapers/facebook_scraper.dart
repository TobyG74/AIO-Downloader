import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import '../../models/facebook_result.dart';

class FacebookScraper {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36',
    },
  ));

  final String _apiBase = 'https://snapsave.app';

  /// Download Facebook media
  Future<FacebookResult> download(String url) async {
    try {

      final response = await _dio.post(
        '$_apiBase/action.php?lang=en',
        data: {'url': url},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Accept': '*/*',
            'Origin': _apiBase,
            'Referer': '$_apiBase/id/facebook-reels-download',
            'X-Requested-With': 'XMLHttpRequest',
          },
        ),
      );


      if (response.statusCode != 200) {
        throw Exception('API returned status ${response.statusCode}');
      }

      final encryptedData = response.data.toString();
      
      final decryptedHtml = _decryptResponse(encryptedData);
      
      if (decryptedHtml.isEmpty) {
        throw Exception('Failed to decrypt response');
      }

      final result = _parseFacebookData(decryptedHtml);

      return result;
    } catch (error) {
      throw Exception('Facebook download failed: $error');
    }
  }

  /// Decrypt obfuscated JavaScript response 
  String _decryptResponse(String encryptedData) {
    try {
      final params = _getEncodedParams(encryptedData);
      if (params.isEmpty) {
        return '';
      }
      
      final decoded = _decodeSnapApp(params);
      if (decoded.isEmpty) {
        return '';
      }
      
      final html = _getDecodedSnapSave(decoded);
      if (html.isEmpty) {
        return '';
      }
      
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
  
  /// Base conversion from base-e to base-10
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
  
  /// Extract final HTML from decoded JavaScript
  String _getDecodedSnapSave(String data) {
    try {
      final errorParts = data.split('document.querySelector("#alert").innerHTML = "');
      if (errorParts.length > 1) {
        final errorMsg = errorParts[1].split('";')[0].trim();
        if (errorMsg.isNotEmpty) {
          throw Exception('API Error: $errorMsg');
        }
      }
      
      final parts = data.split('getElementById("download-section").innerHTML = "');
      if (parts.length < 2) {
        return '';
      }
      
      final html = parts[1]
          .split('"; document.getElementById("inputData").remove(); ')[0]
          .replaceAll(r'\', '');
      
      return html;
    } catch (e) {
      return '';
    }
  }

  /// Parse HTML response to extract download links
  FacebookResult _parseFacebookData(String htmlContent) {
    final document = html_parser.parse(htmlContent);

    // Try different parsing strategies (similar to Instagram)
    
    // Strategy 1: Table layout with video quality options
    if (document.querySelector('table.table') != null) {
      return _parseTableLayout(document);
    }
    
    // Strategy 2: Card layout
    if (document.querySelector('div.card') != null) {
      return _parseCardLayout(document);
    }
    
    // Strategy 3: Download-items
    if (document.querySelector('div.download-items') != null) {
      return _parseDownloadItems(document);
    }
    
    // Strategy 4: Simple single item
    return _parseSingleItem(document);
  }
  
  /// Parse table layout (videos with quality options)
  FacebookResult _parseTableLayout(dynamic document) {
    final rows = document.querySelectorAll('table.table tbody tr');
    
    if (rows.isEmpty) {
      throw Exception('No table rows found');
    }
    
    String thumbnail = '';
    final articleImg = document.querySelector('article.media > figure img');
    if (articleImg != null) {
      thumbnail = articleImg.attributes['src'] ?? '';
    }
    
    List<FacebookVideoQuality> qualities = [];
    
    for (var row in rows) {
      final cells = row.querySelectorAll('td');
      
      if (cells.length >= 3) {
        final resolution = cells[0].text.trim();
        final button = cells[2].querySelector('button');
        String? videoUrl = button?.attributes['onclick'];
        
        bool shouldRender = false;
        if (videoUrl != null && videoUrl.contains('get_progressApi')) {
          shouldRender = true;
          final match = RegExp(r"get_progressApi\('(.*?)'\)").firstMatch(videoUrl);
          if (match != null) {
            videoUrl = 'https://snapsave.app${match.group(1)}';
          }
        } else {
          videoUrl = button?.attributes['href'] ?? cells[2].querySelector('a')?.attributes['href'];
        }
        
        if (videoUrl != null && videoUrl.isNotEmpty) {
          qualities.add(FacebookVideoQuality(
            quality: resolution,
            render: shouldRender,
            type: shouldRender ? 'render' : 'direct',
            url: videoUrl,
          ));
        }
      }
    }
    
    if (qualities.isEmpty) {
      throw Exception('No video qualities found');
    }
    
    return FacebookResult(
      title: '',
      duration: '',
      thumbnail: thumbnail,
      mp4: qualities,
    );
  }
  
  /// Parse card layout
  FacebookResult _parseCardLayout(dynamic document) {
    final firstCard = document.querySelector('div.card');
    final cardBody = firstCard?.querySelector('div.card-body');
    final link = cardBody?.querySelector('a');
    final url = link?.attributes['href'];
    
    if (url == null || url.isEmpty) {
      throw Exception('No URL found in card');
    }
    
    return FacebookResult(
      title: '',
      duration: '',
      thumbnail: '',
      mp4: [
        FacebookVideoQuality(
          quality: 'HD',
          render: false,
          type: 'direct',
          url: url,
        ),
      ],
    );
  }
  
  /// Parse download-items layout
  FacebookResult _parseDownloadItems(dynamic document) {
    final firstItem = document.querySelector('div.download-items');
    final thumbnail = firstItem?.querySelector('div.download-items__thumb > img')?.attributes['src'] ?? '';
    final downloadBtn = firstItem?.querySelector('div.download-items__btn');
    final videoUrl = downloadBtn?.querySelector('a')?.attributes['href'];
    
    if (videoUrl == null || videoUrl.isEmpty) {
      throw Exception('Video URL not found');
    }
    
    return FacebookResult(
      title: '',
      duration: '',
      thumbnail: thumbnail,
      mp4: [
        FacebookVideoQuality(
          quality: 'HD',
          render: false,
          type: 'direct',
          url: videoUrl,
        ),
      ],
    );
  }
  
  /// Parse simple single item
  FacebookResult _parseSingleItem(dynamic document) {
    final link = document.querySelector('a');
    final button = document.querySelector('button');
    
    String? url = link?.attributes['href'];
    
    if (url == null || url.isEmpty) {
      url = button?.attributes['onclick'];
      if (url != null && url.contains('get_progressApi')) {
        final match = RegExp(r"get_progressApi\('(.*?)'\)").firstMatch(url);
        if (match != null) {
          url = 'https://snapsave.app${match.group(1)}';
        }
      }
    }
    
    if (url == null || url.isEmpty) {
      throw Exception('No download URL found');
    }
    
    return FacebookResult(
      title: '',
      duration: '',
      thumbnail: '',
      mp4: [
        FacebookVideoQuality(
          quality: 'HD',
          render: false,
          type: 'direct',
          url: url,
        ),
      ],
    );
  }
}

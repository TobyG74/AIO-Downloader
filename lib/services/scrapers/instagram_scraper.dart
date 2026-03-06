import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import '../../models/instagram_result.dart';

class InstagramScraper {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36',
    },
  ));

  final String _apiBase = 'https://snapsave.app';

  /// Download Instagram media
  Future<InstagramResult> download(String url) async {
    try {

      final response = await _dio.post(
        '$_apiBase/id/action.php?lang=id',
        data: {'url': url},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Accept': '*/*',
            'Origin': _apiBase,
            'Referer': '$_apiBase/id',
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

      final result = _parseInstagramData(decryptedHtml);

      return result;
    } catch (error) {
      throw Exception('Instagram download failed: $error');
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
    final iArr = alphabet.substring(0, 10).split('');
    
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
      
      final decoded = _decodeBase(s, z, 10, tArr, iArr);
      final charCode = decoded - b;
      
      if (charCode > 0) {
        result.writeCharCode(charCode);
      }
    }
    
    return result.toString();
  }
  
  int _decodeBase(String d, int z, int f, List<String> tArr, List<String> iArr) {
    // Reverse and convert from base-z to base-10
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

  int _pow(int base, int exp) {
    int result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }

  /// Parse HTML response to extract download links
  InstagramResult _parseInstagramData(String htmlContent) {
    final document = html_parser.parse(htmlContent);

    if (document.querySelector('table.table') != null) {
      return _parseTableLayout(document);
    }
    
    if (document.querySelector('div.card') != null) {
      return _parseCardLayout(document);
    }
    
    if (document.querySelector('div.download-items') != null) {
      return _parseDownloadItems(document);
    }
    
    return _parseSingleItem(document);
  }
  
  /// Parse table layout (videos with quality options)
  InstagramResult _parseTableLayout(dynamic document) {
    final rows = document.querySelectorAll('table.table tbody tr');
    
    if (rows.isEmpty) {
      throw Exception('No table rows found');
    }
    
    String? thumbnail;
    final articleImg = document.querySelector('article.media > figure img');
    if (articleImg != null) {
      thumbnail = articleImg.attributes['src'];
    }
    
    final firstRow = rows.first;
    final cells = firstRow.querySelectorAll('td');
    
    if (cells.length >= 3) {
      cells[0].text.trim();
      final button = cells[2].querySelector('button');
      String? videoUrl = button?.attributes['onclick'];
      
      if (videoUrl != null && videoUrl.contains('get_progressApi')) {
        final match = RegExp(r"get_progressApi\('(.*?)'\)").firstMatch(videoUrl);
        if (match != null) {
          videoUrl = 'https://snapsave.app${match.group(1)}';
        }
      } else {
        videoUrl = button?.attributes['href'] ?? cells[2].querySelector('a')?.attributes['href'];
      }
      
      if (videoUrl != null && videoUrl.isNotEmpty) {
        return InstagramResult(
          type: InstagramMediaType.video,
          video: InstagramVideoItem(
            url: videoUrl,
            thumbnail: thumbnail,
          ),
        );
      }
    }
    
    throw Exception('Failed to parse table layout');
  }
  
  /// Parse card layout
  InstagramResult _parseCardLayout(dynamic document) {
    final cards = document.querySelectorAll('div.card');
    
    if (cards.isEmpty) {
      throw Exception('No cards found');
    }
    
    final firstCard = cards.first;
    final cardBody = firstCard.querySelector('div.card-body');
    final link = cardBody?.querySelector('a');
    final linkText = link?.text.trim() ?? '';
    final url = link?.attributes['href'];
    
    if (url == null || url.isEmpty) {
      throw Exception('No URL found in card');
    }
    
    final isImage = linkText.toLowerCase().contains('photo');
    
    if (isImage) {
      return InstagramResult(
        type: InstagramMediaType.image,
        images: [
          InstagramImageItem(
            id: 'image_0',
            qualities: [
              InstagramImageQuality(quality: 'Original', url: url),
            ],
            defaultUrl: url,
          ),
        ],
      );
    } else {
      return InstagramResult(
        type: InstagramMediaType.video,
        video: InstagramVideoItem(url: url),
      );
    }
  }
  
  /// Parse download-items layout (carousel)
  InstagramResult _parseDownloadItems(dynamic document) {
    final downloadItems = document.querySelectorAll('div.download-items');
    
    if (downloadItems.isEmpty) {
      throw Exception('No download items found');
    }
    
    // Check first item to determine type
    final firstItem = downloadItems.first;
    final videoElement = firstItem.querySelector('video');
    final downloadBtn = firstItem.querySelector('div.download-items__btn');
    final spanText = downloadBtn?.querySelector('span')?.text.trim() ?? '';
    final isVideo = videoElement != null || spanText.toLowerCase().contains('video');
    
    if (isVideo) {
      // Video - use first item
      final thumbnail = firstItem.querySelector('div.download-items__thumb > img')?.attributes['src'] 
                     ?? videoElement?.attributes['poster'];
      final videoUrl = downloadBtn?.querySelector('a')?.attributes['href'];
      
      if (videoUrl == null || videoUrl.isEmpty) {
        throw Exception('Video URL not found');
      }
      
      return InstagramResult(
        type: InstagramMediaType.video,
        video: InstagramVideoItem(
          url: videoUrl,
          thumbnail: thumbnail,
        ),
      );
    } else {
      // Images (carousel)
      List<InstagramImageItem> images = [];
      
      for (var i = 0; i < downloadItems.length; i++) {
        final item = downloadItems[i];
        final itemBtn = item.querySelector('div.download-items__btn');
        final itemThumb = item.querySelector('div.download-items__thumb > img');
        
        // For images, use thumbnail src as the image URL
        final imageUrl = itemThumb?.attributes['src'] 
                      ?? itemBtn?.querySelector('a')?.attributes['href'];
        
        if (imageUrl != null && imageUrl.isNotEmpty && !imageUrl.contains('.mp4')) {
          images.add(InstagramImageItem(
            id: 'image_$i',
            qualities: [
              InstagramImageQuality(quality: 'Original', url: imageUrl),
            ],
            defaultUrl: imageUrl,
          ));
        }
      }
      
      if (images.isEmpty) {
        throw Exception('No images found');
      }
      
      return InstagramResult(
        type: InstagramMediaType.image,
        images: images,
      );
    }
  }
  
  /// Parse simple single item
  InstagramResult _parseSingleItem(dynamic document) {
    final link = document.querySelector('a');
    final button = document.querySelector('button');
    
    String? url = link?.attributes['href'];
    final linkText = link?.text.trim() ?? '';
    
    // Check button onclick for progressive download
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
    
    final isImage = linkText.toLowerCase().contains('photo');
    
    if (isImage) {
      return InstagramResult(
        type: InstagramMediaType.image,
        images: [
          InstagramImageItem(
            id: 'image_0',
            qualities: [
              InstagramImageQuality(quality: 'Original', url: url),
            ],
            defaultUrl: url,
          ),
        ],
      );
    } else {
      return InstagramResult(
        type: InstagramMediaType.video,
        video: InstagramVideoItem(url: url),
      );
    }
  }

  /// Get best quality image from an image item
  InstagramImageQuality? getBestImageQuality(InstagramImageItem imageItem) {
    if (imageItem.qualities.isEmpty) return null;
    return imageItem.qualities.first;
  }
}

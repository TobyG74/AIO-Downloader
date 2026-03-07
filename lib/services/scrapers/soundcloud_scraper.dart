import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:html/parser.dart' as html_parser;
import '../../models/soundcloud_result.dart';

class SoundCloudScraper {
  late final Dio _dio;
  final CookieJar _cookieJar = CookieJar();

  SoundCloudScraper() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'accept': '*/*',
        'accept-language': 'en,en-US;q=0.9',
        'cache-control': 'no-cache',
        'pragma': 'no-cache',
        'user-agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
    ));
    
    // Add cookie manager to automatically handle cookies
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  /// Scrape the soundloadmate page to get the hidden token field
  Future<Map<String, String>?> _getHiddenToken() async {
    try {
      final response = await _dio.get(
        'https://soundloadmate.com/enB13',
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
      );
      
      if (response.statusCode == 200) {
        final document = html_parser.parse(response.data);
        final hiddenInput = document.querySelector('input[type="hidden"]');
        
        if (hiddenInput != null) {
          final name = hiddenInput.attributes['name'];
          final value = hiddenInput.attributes['value'];
          
          if (name != null && value != null) {
            return {'name': name, 'value': value};
          }
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetch SoundCloud track or playlist data
  Future<SoundCloudResult?> fetchSoundCloud(String url) async {
    try {
      final tokenData = await _getHiddenToken();
      
      if (tokenData == null) {
        return null;
      }
      
      final response = await _dio.post(
        'https://soundloadmate.com/action',
        data: {
          'url': url,
          tokenData['name']!: tokenData['value']!,
        },
        options: Options(
          headers: {
            'origin': 'https://soundloadmate.com',
            'referer': 'https://soundloadmate.com/enB13',
          },
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.plain,
        ),
      );

      if (response.statusCode == 200) {
        var data = response.data;
        
        if (data is String) {
          try {
            data = json.decode(data);
          } catch (e) {
            return null;
          }
        }
        
        if (data is Map) {
          if (data['error'] == true) {
            return null;
          }
          
          if (data['success'] == true && data['html'] != null) {
            final htmlContent = data['html'] as String;
            return _parseHtmlResponse(htmlContent, url);
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Parse the HTML response to extract track data
  SoundCloudResult? _parseHtmlResponse(String htmlContent, String baseUrl) {
    try {
      final document = html_parser.parse(htmlContent);
      
      final forms = document.querySelectorAll('form[name="submitapurl"]');
      
      if (forms.isEmpty) {
        return null;
      }

      final tracks = <SoundCloudTrack>[];
      String? playlistName;
      String? playlistArtist;

      for (final form in forms) {
        final dataInput = form.querySelector('input[name="data"]');
        final tokenInput = form.querySelector('input[name="token"]');
        
        if (dataInput != null && tokenInput != null) {
          final dataValue = dataInput.attributes['value'];
          final tokenValue = tokenInput.attributes['value'];
          
          if (dataValue != null && tokenValue != null) {
            try {
              // Decode base64 data to get track info
              final jsonString = utf8.decode(base64.decode(dataValue));
              final jsonData = json.decode(jsonString);         
              // Create track from JSON, keeping the original base64 data
              final track = SoundCloudTrack.fromJson(
                jsonData,
                tokenValue,
                dataValue, 
              );
              tracks.add(track);
              
              // For playlist, extract playlist info from first track
              if (tracks.length == 1 && jsonData['albumname'] != null) {
                playlistName = jsonData['albumname'] as String;
                // Extract artist from the playlist name or use first track's artist
                // Playlist name format: "Playlist Name - Artist"
                if (playlistName.contains(' - ')) {
                  final parts = playlistName.split(' - ');
                  if (parts.length == 2) {
                    playlistArtist = parts[1];
                    playlistName = parts[0];
                  }
                } else {
                  playlistArtist = track.artist;
                }
              }
            } catch (e) {
              continue;
            }
          }
        }
      }

      if (tracks.isEmpty) {
        return null;
      }

      // Determine if it's a single track or playlist
      if (tracks.length == 1 && tracks[0].albumName == null) {
        // Single track
        return SoundCloudResult.fromSingle(
          track: tracks[0],
          baseUrl: baseUrl,
        );
      } else {
        // Playlist
        final playlist = SoundCloudPlaylist(
          name: playlistName ?? 'Playlist',
          artist: playlistArtist ?? tracks[0].artist,
          tracks: tracks,
        );
        
        return SoundCloudResult.fromPlaylist(
          playlist: playlist,
          baseUrl: baseUrl,
        );
      }
    } catch (e) {
      return null;
    }
  }

  /// Get download URL from track data
  /// Makes a POST request to /action/track with the track data
  Future<String?> getDownloadUrl(SoundCloudTrack track, String baseUrl) async {
    try {
      
      // POST to get download URL using the original base64 data from HTML
      final response = await _dio.post(
        'https://soundloadmate.com/action/track',
        data: {
          'data': track.dataBase64, // Use original base64 from server
          'base': baseUrl,
          'token': track.token,
        },
        options: Options(
          headers: {
            'origin': 'https://soundloadmate.com',
            'referer': 'https://soundloadmate.com/enB13',
          },
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.plain,
        ),
      );
      
      if (response.statusCode == 200) {
        var data = response.data;
        
        // Parse String response to JSON if needed
        if (data is String) {
          try {
            data = json.decode(data);
          } catch (e) {
            return null;
          }
        }
        
        if (data is Map) {
          // Check for error
          if (data['error'] == true) {
            return null;
          }
          
          // Extract download URL from HTML
          if (data['data'] != null) {
            final htmlContent = data['data'] as String;
            final document = html_parser.parse(htmlContent);
            
            // Find the first download link (Download Mp3)
            final downloadLink = document.querySelector('a.button.is-download');
            
            if (downloadLink != null) {
              final href = downloadLink.attributes['href'];
              if (href != null && href.isNotEmpty) {
                return href;
              }
            }
          }
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}

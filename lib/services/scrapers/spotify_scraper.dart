import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:youtube_scrape_api/youtube_scrape_api.dart';
import '../../models/spotify_result.dart';

/// Helper to carry YouTube search result info
class _YtInfo {
  final String videoId;
  final String title;
  final String thumbnail;
  final String duration;
  const _YtInfo({
    required this.videoId,
    required this.title,
    required this.thumbnail,
    required this.duration,
  });
}

class SpotifyScraper {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    followRedirects: true,
    maxRedirects: 5,
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.9',
    },
  ));

  final YoutubeDataApi _ytApi = YoutubeDataApi();

  /// Main entry point: fetch Spotify track/playlist info + YouTube match

  /// Convert any Spotify URL to the embed URL.
  /// Handles:
  ///   https://open.spotify.com/track/{id}
  ///   https://open.spotify.com/intl-xx/track/{id}
  ///   https://spotify.link/{short}  (resolved via redirect)
  String _toEmbedUrl(String rawUrl, {String? resolvedUrl}) {
    final source = resolvedUrl ?? rawUrl;
    final uri = Uri.parse(source.trim());
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();

    if (segments.isEmpty) throw Exception('Invalid Spotify URL: $rawUrl');

    // Strip locale prefix (e.g. intl-id, en, id-id …)
    int start = 0;
    if (segments.length > 1 &&
        (segments[0].startsWith('intl-') ||
            RegExp(r'^[a-z]{2}(-[a-z]{2})?$', caseSensitive: false)
                .hasMatch(segments[0]))) {
      start = 1;
    }

    if (segments.length < start + 2) {
      throw Exception('Invalid Spotify URL: $rawUrl');
    }

    final type = segments[start]; // track | album | playlist | episode
    final id = segments[start + 1];
    return 'https://open.spotify.com/embed/$type/$id';
  }

  /// Check if URL is a playlist
  bool isPlaylistUrl(String url) {
    return url.contains('/playlist/') && url.contains('spotify.com');
  }

  /// Extract playlist ID from URL
  String? _extractPlaylistId(String url) {
    final regex = RegExp(r'/playlist/([a-zA-Z0-9]+)');
    final match = regex.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
  }

  /// Fetch track info from Spotify embed page, then find the matching
  SpotifyTrack _parseHtml(String html) {
    final document = html_parser.parse(html);

    // 1) <script id="__NEXT_DATA__">  — raw JSON (most common, current format)
    final nextDataEl = document.querySelector('script#__NEXT_DATA__');
    if (nextDataEl != null && nextDataEl.text.trim().isNotEmpty) {
      try {
        final json = jsonDecode(nextDataEl.text) as Map<String, dynamic>;
        final entity =
            json['props']?['pageProps']?['state']?['data']?['entity']
                as Map<String, dynamic>?;
        if (entity != null) return _entityToTrack(entity);
      } catch (_) {}
    }

    // 2) <script id="initial-state">  — base64 encoded JSON
    final initialEl = document.querySelector('script#initial-state');
    if (initialEl != null && initialEl.text.trim().isNotEmpty) {
      try {
        final decoded = utf8.decode(base64.decode(initialEl.text.trim()));
        final json = jsonDecode(decoded) as Map<String, dynamic>;
        final entity = json['data']?['entity'] as Map<String, dynamic>?;
        if (entity != null) return _entityToTrack(entity);
      } catch (_) {}
    }

    // 3) <script id="resource">  — base64 encoded JSON
    final resourceEl = document.querySelector('script[id="resource"]');
    if (resourceEl != null && resourceEl.text.trim().isNotEmpty) {
      try {
        final decoded = utf8.decode(base64.decode(resourceEl.text.trim()));
        final json = jsonDecode(decoded) as Map<String, dynamic>;
        return _entityToTrack(json);
      } catch (_) {}
    }

    throw Exception(
        'Unable to extract Spotify data from embed page. '
        'Make sure the URL is valid and the track is accessible.');
  }

  // Convert Spotify API entity to SpotifyTrack model used in the app
  SpotifyTrack _entityToTrack(Map<String, dynamic> e) {
    final title = e['name']?.toString() ?? 'Unknown';
    final type = (e['uri']?.toString().split(':').elementAtOrNull(1)) ??
        e['type']?.toString() ??
        'track';

    // Artists
    String artist = '';
    final rawArtists = e['artists'];
    if (rawArtists is List && rawArtists.isNotEmpty) {
      // Encore format: [{profile: {name: "..."}}]
      final names = rawArtists
          .map((a) {
            final m = a as Map<String, dynamic>;
            return m['name']?.toString() ??
                (m['profile'] as Map<String, dynamic>?)?['name']?.toString() ??
                '';
          })
          .where((n) => n.isNotEmpty)
          .toList();
      artist = names.join(', ');
    } else if (rawArtists is Map) {
      // {items: [{profile: {name: "..."}}]}
      final items = rawArtists['items'] as List?;
      if (items != null) {
        artist = items
            .map((a) =>
                (a as Map<String, dynamic>)['profile']?['name']?.toString() ??
                '')
            .where((n) => n.isNotEmpty)
            .join(', ');
      }
    }
    if (artist.isEmpty) {
      // Fallback: show / subtitle
      artist = (e['show'] as Map<String, dynamic>?)?['publisher']?.toString() ??
          e['subtitle']?.toString() ??
          '';
    }

    // Album (for tracks) or season (for episodes)
    String album = '';
    final albumMap =
        (e['album'] ?? e['albumOfTrack']) as Map<String, dynamic>?;
    if (albumMap != null) {
      album = albumMap['name']?.toString() ?? '';
    }

    // Cover image (multiple possible fields, try them in order until we find one)
    String coverUrl = '';
    String bestUrl(List sources) {
      if (sources.isEmpty) return '';
      final best = sources.reduce(
        (a, b) => ((a as Map)['width'] ?? (a)['maxWidth'] ?? 0) >=
                ((b as Map)['width'] ?? (b)['maxWidth'] ?? 0)
            ? a
            : b,
      ) as Map;
      return best['url']?.toString() ?? best['uri']?.toString() ?? '';
    }

    // 1) coverArt.sources
    final coverArt = e['coverArt'] as Map<String, dynamic>?;
    if (coverArt != null) {
      final sources = coverArt['sources'] as List?;
      if (sources != null && sources.isNotEmpty) {
        coverUrl = bestUrl(sources);
      }
    }

    // 2) images[]
    if (coverUrl.isEmpty) {
      final images = e['images'] as List?;
      if (images != null && images.isNotEmpty) {
        coverUrl = bestUrl(images);
      }
    }

    // 3) visualIdentity.image[]  (items have "uri" key, not "url")
    if (coverUrl.isEmpty) {
      final vi = e['visualIdentity'] as Map<String, dynamic>?;
      if (vi != null) {
        final viImages = vi['image'] as List?;
        if (viImages != null && viImages.isNotEmpty) {
          coverUrl = bestUrl(viImages);
        }
      }
    }

    // 4) albumOfTrack.coverArt.sources
    if (coverUrl.isEmpty) {
      final atCover =
          (e['albumOfTrack'] as Map<String, dynamic>?)?['coverArt']
              as Map<String, dynamic>?;
      if (atCover != null) {
        final sources = atCover['sources'] as List?;
        if (sources != null && sources.isNotEmpty) {
          coverUrl = bestUrl(sources);
        }
      }
    }

    // 5) album.images[]
    if (coverUrl.isEmpty) {
      final albumImages =
          (e['album'] as Map<String, dynamic>?)?['images'] as List?;
      if (albumImages != null && albumImages.isNotEmpty) {
        coverUrl = bestUrl(albumImages);
      }
    }

    // Duration (in ms, may be in different fields depending on track/episode and API version)
    int durationMs = 0;
    final dur = e['duration'];
    if (dur is Map) {
      durationMs = (dur['totalMilliseconds'] as int?) ?? 0;
    } else if (dur is int) {
      durationMs = dur;
    }
    if (durationMs == 0 && e['duration_ms'] is int) {
      durationMs = e['duration_ms'] as int;
    }

    // Audio preview URL (may be in different fields or nested under "audioPreview")
    String previewUrl = '';
    final preview = e['audioPreview'] as Map<String, dynamic>?;
    if (preview != null) {
      previewUrl = preview['url']?.toString() ?? '';
    }
    if (previewUrl.isEmpty) {
      previewUrl = e['preview_url']?.toString() ?? '';
    }

    return SpotifyTrack(
      title: title,
      artist: artist,
      album: album,
      coverUrl: coverUrl,
      durationMs: durationMs,
      previewUrl: previewUrl,
      type: type,
    );
  }

  // Search YouTube for the track using its title, artist, and album as keywords.
  // ignore: library_private_types_in_public_api
  Future<_YtInfo?> searchYouTube(SpotifyTrack track) async {
    return await _searchYouTube(track);
  }

  Future<_YtInfo?> _searchYouTube(SpotifyTrack track) async {
    final parts = <String>[track.title];
    if (track.artist.isNotEmpty) parts.add(track.artist);
    if (track.album.isNotEmpty) parts.add(track.album);
    parts.add('official audio');

    final query = parts.join(' ');

    List results;
    try {
      results = await _ytApi.fetchSearchVideo(query);
    } catch (e) {
      final fallback = '${track.title} ${track.artist} audio';
      try {
        results = await _ytApi.fetchSearchVideo(fallback);
      } catch (_) {
        return null;
      }
    }

    if (results.isEmpty) return null;

    for (int i = 0; i < results.length; i++) {
      final item = results[i];
      try {
        final dynamic d = item;
        String? id;
        String title = '';
        String thumb = '';
        String duration = '';

        try { id = d.videoId as String?; } catch (_) {}
        try { title = (d.title as String?) ?? ''; } catch (_) {}
        try { thumb = (d.thumbnailUrl as String?) ?? ''; } catch (_) {}
        duration = _safeDuration(d);

        if (id == null || id.isEmpty) continue;

        final resolvedThumb = thumb.isNotEmpty
            ? thumb
            : 'https://i.ytimg.com/vi/$id/mqdefault.jpg';

        return _YtInfo(
          videoId: id,
          title: title,
          thumbnail: resolvedThumb,
          duration: duration,
        );
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  String _safeDuration(dynamic d) {
    try {
      return (d.duration as String?) ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Fetch track info from Spotify embed page, then find the matching
  /// YouTube video.  Returns [SpotifyTrack] enriched with YouTube data.
  Future<SpotifyTrack> fetch(String url) async {
    try {
      String resolvedUrl = url.trim();
      if (resolvedUrl.contains('spotify.link')) {
        final resp = await _dio.get(
          resolvedUrl,
          options: Options(followRedirects: true),
        );
        resolvedUrl = resp.realUri.toString();
      }

      // Check if it's a playlist
      if (isPlaylistUrl(resolvedUrl)) {
        return await _fetchPlaylist(url, resolvedUrl: resolvedUrl);
      }

      final embedUrl = _toEmbedUrl(url, resolvedUrl: resolvedUrl);
      final response = await _dio.get(embedUrl);
      final track = _parseHtml(response.data as String);

      final ytInfo = await _searchYouTube(track);
      if (ytInfo == null) {
        throw Exception(
            'Unable to find this track on YouTube. Try again later.');
      }

      return track.copyWith(
        youtubeVideoId: ytInfo.videoId,
        youtubeVideoTitle: ytInfo.title,
        youtubeThumbnail: ytInfo.thumbnail,
        youtubeDuration: ytInfo.duration,
      );
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message ?? e.type.name}');
    } catch (e) {
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception('Spotify fetch gagal: $e');
    }
  }

  /// Fetch playlist info and tracks from Spotify embed page
  Future<SpotifyTrack> _fetchPlaylist(String url, {String? resolvedUrl}) async {
    try {
      final playlistId = _extractPlaylistId(resolvedUrl ?? url);
      if (playlistId == null) {
        throw Exception('Invalid playlist URL');
      }

      // Use spotmate.online API
      return await _fetchPlaylistViaSpotmate(url);
    } catch (e) {
      throw Exception('Gagal memuat playlist: $e');
    }
  }

  /// Fetch playlist using spotmate.online API
  Future<SpotifyTrack> _fetchPlaylistViaSpotmate(String playlistUrl) async {
    try {
      final pageResponse = await _dio.get(
        'https://spotmate.online/en1',
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
      );

      final pageHtml = pageResponse.data as String;
      final document = html_parser.parse(pageHtml);

      // Extract CSRF token from meta tag
      final csrfMeta = document.querySelector('meta[name="csrf-token"]');
      final csrfToken = csrfMeta?.attributes['content'] ?? '';

      if (csrfToken.isEmpty) {
        throw Exception('CSRF token not found');
      }

      // Extract cookies from response headers
      final cookies = <String>[];
      final setCookieHeaders = pageResponse.headers['set-cookie'];
      if (setCookieHeaders != null) {
        for (var cookieHeader in setCookieHeaders) {
          // Extract cookie name and value (before first semicolon)
          final cookieParts = cookieHeader.split(';');
          if (cookieParts.isNotEmpty) {
            cookies.add(cookieParts[0]);
          }
        }
      }

      final cookieString = cookies.join('; ');
      final apiResponse = await _dio.post(
        'https://spotmate.online/getTrackData',
        data: {'spotify_url': playlistUrl},
        options: Options(
          headers: {
            'Cookie': cookieString,
            'Origin': 'https://spotmate.online',
            'Referer': 'https://spotmate.online/en1',
            'X-CSRF-TOKEN': csrfToken,
            'Content-Type': 'application/json',
            'Accept': 'application/json, text/plain, */*',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      final data = apiResponse.data as Map<String, dynamic>;

      // Parse playlist data
      final playlistId = data['id']?.toString() ?? '';
      final playlistName = data['name']?.toString() ?? 'Spotify Playlist';
      final ownerData = data['owner'] as Map<String, dynamic>?;
      final ownerName = ownerData?['display_name']?.toString() ?? '';

      // Extract cover image
      String coverUrl = '';
      final images = data['images'] as List?;
      if (images != null && images.isNotEmpty) {
        final img = images.first as Map<String, dynamic>;
        coverUrl = img['url']?.toString() ?? '';
      }

      // Extract tracks
      final List<SpotifyPlaylistTrack> tracks = [];
      final tracksData = data['tracks'] as Map<String, dynamic>?;
      final items = tracksData?['items'] as List?;

      if (items == null || items.isEmpty) {
        throw Exception('Playlist kosong');
      }

      int index = 1;
      for (var item in items) {
        try {
          final trackData = item['track'] as Map<String, dynamic>?;
          if (trackData == null) continue;

          final trackId = trackData['id']?.toString() ?? '';
          final trackName = trackData['name']?.toString() ?? '';
          final durationMs = trackData['duration_ms'] as int? ?? 0;

          if (trackName.isEmpty) continue;

          // Extract artists
          String artists = '';
          final artistsList = trackData['artists'] as List?;
          if (artistsList != null && artistsList.isNotEmpty) {
            artists = artistsList
                .map((a) => (a as Map<String, dynamic>)['name']?.toString() ?? '')
                .where((n) => n.isNotEmpty)
                .join(', ');
          }

          // Extract album cover
          String trackCover = '';
          final albumData = trackData['album'] as Map<String, dynamic>?;
          if (albumData != null) {
            final albumImages = albumData['images'] as List?;
            if (albumImages != null && albumImages.isNotEmpty) {
              final img = albumImages.first as Map<String, dynamic>;
              trackCover = img['url']?.toString() ?? '';
            }
          }

          tracks.add(SpotifyPlaylistTrack(
            title: trackName,
            artist: artists,
            album: albumData?['name']?.toString() ?? '',
            coverUrl: trackCover,
            durationMs: durationMs,
            index: index++,
            trackId: trackId,
          ));
        } catch (e) {
          // Skip invalid tracks
          continue;
        }
      }

      if (tracks.isEmpty) {
        throw Exception('No valid tracks in playlist');
      }

      return SpotifyTrack(
        title: playlistName,
        artist: ownerName,
        album: '',
        coverUrl: coverUrl,
        durationMs: 0,
        previewUrl: '',
        type: 'playlist',
        isPlaylist: true,
        playlistId: playlistId,
        trackCount: tracks.length,
        playlistTracks: tracks,
      );
    } catch (e) {
      throw Exception('Failed to load playlist from Spotmate: $e');
    }
  }
}

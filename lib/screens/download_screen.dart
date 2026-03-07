import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../l10n/app_localizations.dart';
import '../models/spotify_result.dart';
import '../models/soundcloud_result.dart';
import '../models/youtube_result.dart';
import '../models/douyin_result.dart';
import '../models/bilibili_result.dart';
import '../services/scrapers/tiktok_scraper.dart';
import '../services/scrapers/youtube_scraper.dart';
import '../services/scrapers/douyin_scraper.dart';
import '../services/scrapers/bilibili_scraper.dart';
import '../services/scrapers/instagram_scraper.dart';
import '../services/scrapers/facebook_scraper.dart';
import '../services/scrapers/twitter_scraper.dart';
import '../services/scrapers/threads_scraper.dart';
import '../services/scrapers/pinterest_scraper.dart';
import '../services/scrapers/spotify_scraper.dart';
import '../services/scrapers/soundcloud_scraper.dart';
import '../services/download_service.dart';
import '../services/platform_download_handler.dart';
import '../services/id3_tagger.dart';
import '../services/web_cookie_service.dart';
import '../widgets/webview_cookie_dialog.dart';
import '../widgets/platform_downloaders/tiktok_result_widget.dart';
import '../widgets/platform_downloaders/instagram_result_widget.dart';
import '../widgets/platform_downloaders/facebook_result_widget.dart';
import '../widgets/platform_downloaders/twitter_result_widget.dart';
import '../widgets/platform_downloaders/threads_result_widget.dart';
import '../widgets/platform_downloaders/pinterest_result_widget.dart';
import '../widgets/platform_downloaders/youtube_result_widget.dart';
import '../widgets/platform_downloaders/spotify_result_widget.dart';
import '../widgets/platform_downloaders/soundcloud_result_widget.dart';
import '../widgets/platform_downloaders/douyin_result_widget.dart';
import '../widgets/platform_downloaders/bilibili_result_widget.dart';

class DownloadScreen extends StatefulWidget {
  final String platform;
  final String? initialUrl;

  const DownloadScreen({
    super.key,
    required this.platform,
    this.initialUrl,
  });

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  final TextEditingController _urlController = TextEditingController();
  final DownloadService _downloadService = DownloadService();
  late PlatformDownloadHandler _downloadHandler;

  bool _isLoading = false;
  bool _isDownloading = false;
  double? _downloadProgress;
  dynamic _result;
  String _inputUrl = '';
  SoundCloudScraper? _soundcloudScraper; // Store scraper instance to reuse cookies

  String _selectedSpotifyQuality = '320';

  @override
  void initState() {
    super.initState();
    
    // Initialize download handler
    _downloadHandler = PlatformDownloadHandler(
      downloadService: _downloadService,
      context: context,
      setDownloading: (value) => setState(() => _isDownloading = value),
      setProgress: (value) => setState(() => _downloadProgress = value),
      showToast: _showToast,
    );
    
    if (widget.initialUrl != null && widget.initialUrl!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _urlController.text = widget.initialUrl!;
        _fetchMedia();
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  /// Updates download progress. When [total] is -1 (no Content-Length),
  /// sets null so the UI shows an indeterminate indicator.
  void _setProgress(int received, int total) {
    setState(() {
      _downloadProgress = total > 0 ? received / total : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.platform} Downloader'),
        actions: [
          if (_isCookiePlatform)
            IconButton(
              icon: const Icon(Icons.travel_explore),
              tooltip: 'Buka WebView',
              onPressed: _openCookieWebView,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // URL Input
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.enterUrl} ${widget.platform}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _urlController,
                        decoration: InputDecoration(
                          hintText: 'https://${_getPlatformUrl()}',
                          prefixIcon: const Icon(Icons.link),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.paste),
                            onPressed: _pasteFromClipboard,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _fetchMedia,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.search),
                          label:
                              Text(_isLoading ? l10n.processing : l10n.searchMedia),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Result Display
              if (_result != null) _buildResultWidget(),

              // Download Progress
              if (_isDownloading)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(l10n.downloading),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(value: _downloadProgress),
                        const SizedBox(height: 8),
                        Text(
                            _downloadProgress != null
                                ? '${(_downloadProgress! * 100).toStringAsFixed(0)}%'
                                : l10n.waiting),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPlatformUrl() {
    switch (widget.platform) {
      case 'TikTok':
        return 'www.tiktok.com/@user/video/xxxxx';
      case 'Douyin':
        return 'v.douyin.com/xxxxx';
      case 'Bilibili':
        return 'www.bilibili.tv/id/video/xxxxx';
      case 'YouTube':
        return 'www.youtube.com/watch?v=xxxxx';
      case 'Instagram':
        return 'www.instagram.com/p/xxxxx/';
      case 'Facebook':
        return 'www.facebook.com/watch?v=xxxxx';
      case 'Twitter':
        return 'twitter.com/user/status/xxxxx';
      case 'Pinterest':
        return 'www.pinterest.com/pin/xxxxx';
      case 'Spotify':
        return 'open.spotify.com/track/xxxxx';
      case 'SoundCloud':
        return 'soundcloud.com/artist/track-name';
      default:
        return 'www.threads.com/@user/post/xxxxx';
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null) {
      setState(() {
        _urlController.text = data.text!;
      });
    }
  }

  Future<void> _fetchMedia() async {
    final l10n = AppLocalizations.of(context)!;
    if (_urlController.text.trim().isEmpty) {
      _showToast(l10n.enterUrlFirst);
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
      _inputUrl = _urlController.text.trim();
      // Reset YouTube state
      // Reset Spotify state
      _selectedSpotifyQuality = '320';
    });

    try {
      dynamic result;

      switch (widget.platform) {
        case 'TikTok':
          result = await _downloadWithCookies(
            'https://musicaldown.com',
            (cookies) => TikTokScraper().download(
              _urlController.text.trim(),
              cfCookies: cookies,
            ),
          );
          break;
        case 'YouTube':
          final scraper = YouTubeScraper();
          result = await scraper.download(_urlController.text.trim());
          break;
        case 'Douyin':
          final douyinScraper = DouyinScraper();
          result = await douyinScraper.fetchDouyin(_urlController.text.trim());
          break;
        case 'Bilibili':
          final bilibiliScraper = BilibiliScraper();
          result = await bilibiliScraper.fetchVideo(_urlController.text.trim());
          break;
        case 'Instagram':
          final instagramScraper = InstagramScraper();
          result = await instagramScraper.download(_urlController.text.trim());
          break;
        case 'Facebook':
          final facebookScraper = FacebookScraper();
          result = await facebookScraper.download(_urlController.text.trim());
          break;
        case 'Twitter':
          final twitterScraper = TwitterScraper();
          result = await twitterScraper.download(_urlController.text.trim());
          break;
        case 'Threads':
          final threadsScraper = ThreadsScraper();
          result = await threadsScraper.download(_urlController.text.trim());
          break;
        case 'Pinterest':
          result = await _downloadWithCookies(
            'https://pindown.io',
            (cookies) => PinterestScraper().download(_urlController.text.trim(), cookies: cookies),
          );
          break;
        case 'Spotify':
          final spotifyScraper = SpotifyScraper();
          result = await spotifyScraper.fetch(_urlController.text.trim());
          break;
        case 'SoundCloud':
          _soundcloudScraper = SoundCloudScraper();
          result = await _soundcloudScraper!.fetchSoundCloud(_urlController.text.trim());
          break;
      }

      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showToast(l10n.error(e.toString()));
    }
  }

  Widget _buildResultWidget() {
    if (widget.platform == 'TikTok') {
      return TikTokResultWidget(
        result: _result,
        onDownloadVideo: (qualityType) => _downloadHandler.downloadTikTokVideo(_result, _inputUrl, qualityType),
        onDownloadImages: () => _downloadHandler.downloadTikTokImages(_result, _inputUrl),
        onDownloadAudio: () => _downloadHandler.downloadTikTokAudio(_result, _inputUrl),
      );
    } else if (widget.platform == 'YouTube') {
      return YouTubeResultWidget(
        result: _result,
        onDownloadVideo: (quality) => _downloadHandler.downloadYouTubeVideo(_result, _inputUrl, quality),
        onDownloadAudio: (quality, format) => _downloadHandler.downloadYouTubeAudio(_result, _inputUrl, quality, format),
        onDownloadPlaylistVideo: _downloadPlaylistVideo,
        isDownloading: _isDownloading,
      );
    } else if (widget.platform == 'Instagram') {
      return InstagramResultWidget(
        result: _result,
        onDownloadVideo: (url) => _downloadHandler.downloadInstagramVideo(_result, _inputUrl, url),
        onDownloadSingleImage: (url, index) => _downloadHandler.downloadInstagramSingleImage(_result, _inputUrl, url, index),
        onDownloadAllImages: (images) => _downloadHandler.downloadInstagramAllImages(_result, _inputUrl, images),
      );
    } else if (widget.platform == 'Facebook') {
      return FacebookResultWidget(
        result: _result,
        onDownloadVideo: (url) => _downloadHandler.downloadFacebookVideo(_result, _inputUrl, url),
      );
    } else if (widget.platform == 'Twitter') {
      return TwitterResultWidget(
        result: _result,
        onDownloadVideo: (url) => _downloadHandler.downloadTwitterVideo(_result, _inputUrl, url),
        onDownloadImage: (url) => _downloadHandler.downloadTwitterImage(_result, _inputUrl, url),
        onDownloadAllImages: (urls) => _downloadHandler.downloadTwitterAllImages(_result, _inputUrl, urls),
      );
    } else if (widget.platform == 'Threads') {
      return ThreadsResultWidget(
        result: _result,
        onDownloadVideo: (url) => _downloadHandler.downloadThreadsVideo(_result, _inputUrl, url),
        onDownloadImage: (url) => _downloadHandler.downloadThreadsImage(_result, _inputUrl, url),
      );
    } else if (widget.platform == 'Pinterest') {
      return PinterestResultWidget(
        result: _result,
        onDownloadItem: (item) => _downloadHandler.downloadPinterestItem(item, _result, _inputUrl),
        isDownloading: _isDownloading,
      );
    } else if (widget.platform == 'Spotify') {
      return SpotifyResultWidget(
        track: _result,
        onDownloadAudio: _downloadSpotifyAudio,
        onDownloadPlaylistTrack: _downloadSpotifyPlaylistTrack,
        selectedQuality: _selectedSpotifyQuality,
        onQualityChanged: (quality) => setState(() => _selectedSpotifyQuality = quality),
        isDownloading: _isDownloading,
      );
    } else if (widget.platform == 'SoundCloud') {
      final soundcloudResult = _result as SoundCloudResult;
      return SoundCloudResultWidget(
        result: soundcloudResult,
        onDownloadTrack: (track) => _downloadHandler.downloadSoundCloudTrack(
          track,
          soundcloudResult.baseUrl,
          _inputUrl,
          _soundcloudScraper!, // Pass scraper instance with cookies
        ),
        isDownloading: _isDownloading,
      );
    } else if (widget.platform == 'Douyin') {
      final douyinResult = _result as DouyinResult;
      return DouyinResultWidget(
        result: douyinResult,
        onDownloadVideo: (qualityIndex) => _downloadHandler.downloadDouyinVideo(
          douyinResult.video,
          _inputUrl,
          qualityIndex,
        ),
        onDownloadMusic: () => _downloadHandler.downloadDouyinMusic(
          douyinResult.video,
          _inputUrl,
        ),
      );
    } else if (widget.platform == 'Bilibili') {
      final bilibiliResult = _result as BilibiliResult;
      return BilibiliResultWidget(
        result: bilibiliResult,
        onDownloadVideo: (qualityIndex) => _downloadHandler.downloadBilibiliVideo(
          bilibiliResult,
          _inputUrl,
          qualityIndex,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _downloadSpotifyPlaylistTrack(SpotifyPlaylistTrack track) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text('Searching for ${track.title} on YouTube...')),
            ],
          ),
        ),
      );

      // Search on YouTube
      final scraper = SpotifyScraper();
      final spotifyTrack = SpotifyTrack(
        title: track.title,
        artist: track.artist,
        album: track.album,
        coverUrl: track.coverUrl,
        durationMs: track.durationMs,
        previewUrl: '',
        type: 'track',
      );

      final ytInfo = await scraper.searchYouTube(spotifyTrack);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (ytInfo == null) {
        _showToast('Unable to find this track on YouTube');
        return;
      }

      // Show quality selection dialog
      _showSpotifyTrackQualityDialog(track, ytInfo.videoId);
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _showToast('Failed to find track: ${e.toString()}');
    }
  }

  void _showSpotifyTrackQualityDialog(SpotifyPlaylistTrack track, String youtubeVideoId) {
    final qualities = [
      {'quality': '320', 'label': '320 kbps'},
      {'quality': '256', 'label': '256 kbps'},
      {'quality': '192', 'label': '192 kbps'},
      {'quality': '128', 'label': '128 kbps'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          track.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Audio Quality:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ...qualities.map((q) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: const Icon(Icons.music_note, size: 20, color: Color(0xFF1DB954)),
                  title: Text(q['label']!),
                  onTap: () {
                    Navigator.of(context).pop();
                    _downloadSpotifyTrackWithQuality(track, youtubeVideoId, q['quality']!);
                  },
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadSpotifyTrackWithQuality(
    SpotifyPlaylistTrack track,
    String youtubeVideoId,
    String quality,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isDownloading = true;
      _downloadProgress = null;
    });

    try {
      final scraper = YouTubeScraper();
      final dlRes = await scraper.getAudioDownloadUrl(youtubeVideoId, quality);

      // Build a clean filename: "title - artist_quality.mp3"
      String safe(title) => title
          .toString()
          .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
          .trim();
      final filename = '${safe(track.title)} - ${safe(track.artist)}_${quality}kbps.mp3';

      await _downloadService.downloadAudio(
        url: dlRes.url,
        filename: filename,
        platform: 'Spotify',
        title: track.title,
        thumbnailUrl: track.coverUrl,
        originalUrl: 'https://open.spotify.com/track/${track.trackId}',
        onProgress: _setProgress,
      );

      setState(() {
        _isDownloading = false;
      });
      _showToast(l10n.downloadSuccess);
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      _showToast(l10n.downloadFailed(e.toString()));
    }
  }

  Future<void> _downloadSpotifyAudio() async {
    final l10n = AppLocalizations.of(context)!;
    final track = _result as SpotifyTrack;
    final videoId = track.youtubeVideoId;
    if (videoId == null) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = null;
    });

    try {
      final scraper = YouTubeScraper();
      final dlRes =
          await scraper.getAudioDownloadUrl(videoId, _selectedSpotifyQuality);

      // Build a clean filename from track title & artist: "title - artist_quality.mp3"
      String safe(title) => title
          .toString()
          .replaceAll(RegExp(r'[\\/:*?"<>|]'), '')
          .trim();
      final filename = '${safe(track.title)} - ${safe(track.artist)}_'
          '${_selectedSpotifyQuality}kbps.mp3';

      final savedPath = await _downloadService.downloadAudio(
        url: dlRes.url,
        filename: filename,
        platform: 'Spotify',
        title: '${track.title} - ${track.artist}',
        thumbnailUrl: track.coverUrl,
        originalUrl: _inputUrl,
        onProgress: _setProgress,
      );

      // Embed cover art + metadata as ID3v2 tags
      await Id3Tagger.embedTags(
        filePath: savedPath,
        title: track.title,
        artist: track.artist,
        album: track.album,
        coverUrl: track.coverUrl,
      );

      _showToast(l10n.downloadSuccess);
    } catch (e) {
      _showToast(l10n.downloadFailed(e.toString()));
    } finally {
      setState(() => _isDownloading = false);
    }
  }


  Future<void> _downloadPlaylistVideo(YouTubePlaylistItem item) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Fetch video details
      final scraper = YouTubeScraper();
      final videoUrl = 'https://www.youtube.com/watch?v=${item.videoId}';
      final videoResult = await scraper.download(videoUrl);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show quality selection dialog
      _showPlaylistVideoQualityDialog(item, videoResult);
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _showToast('Failed to load video: ${e.toString()}');
    }
  }

  void _showPlaylistVideoQualityDialog(
      YouTubePlaylistItem item, YouTubeResult videoResult) {
    final videoFormats = videoResult.videoFormats;
    final audioFormats = videoResult.audioFormats;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Video Quality:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ...videoFormats.take(5).map((format) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(Icons.videocam, size: 20),
                    title: Text(format.quality),
                    subtitle: format.size.isNotEmpty ? Text(format.size) : null,
                    onTap: () {
                      Navigator.of(context).pop();
                      _downloadPlaylistVideoWithQuality(
                          item, videoResult.videoId, format.downloadUrl, isVideo: true);
                    },
                  )),
              const Divider(height: 24),
              const Text(
                'Or Download Audio:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ...audioFormats.take(5).map((format) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(Icons.music_note, size: 20),
                    title: Text(format.quality),
                    subtitle: format.size.isNotEmpty ? Text(format.size) : null,
                    onTap: () {
                      Navigator.of(context).pop();
                      _downloadPlaylistVideoWithQuality(item, videoResult.videoId,
                          format.downloadUrl, isVideo: false, format: format.format);
                    },
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPlaylistVideoWithQuality(
    YouTubePlaylistItem item,
    String videoId,
    String quality, {
    required bool isVideo,
    String? format,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isDownloading = true;
      _downloadProgress = null;
    });

    try {
      final scraper = YouTubeScraper();
      
      if (isVideo) {
        final dlRes = await scraper.getVideoDownloadUrl(videoId, quality);
        final filename = dlRes.filename.isNotEmpty
            ? _cleanApiFilename(dlRes.filename)
            : 'youtube_${DateTime.now().millisecondsSinceEpoch}_${quality}p.mp4';

        await _downloadService.downloadVideo(
          url: dlRes.url,
          filename: filename,
          platform: 'YouTube',
          title: item.title,
          thumbnailUrl: item.thumbnail,
          originalUrl: 'https://www.youtube.com/watch?v=${item.videoId}',
          onProgress: _setProgress,
        );
      } else {
        final dlRes = await scraper.getAudioDownloadUrl(videoId, quality);
        final ext = format == 'm4a' ? 'm4a' : (format == 'opus' ? 'opus' : 'mp3');
        final filename = dlRes.filename.isNotEmpty
            ? _cleanApiFilename(dlRes.filename)
            : 'youtube_audio_${DateTime.now().millisecondsSinceEpoch}_$quality.$ext';

        await _downloadService.downloadAudio(
          url: dlRes.url,
          filename: filename,
          platform: 'YouTube',
          title: item.title,
          thumbnailUrl: item.thumbnail,
          originalUrl: 'https://www.youtube.com/watch?v=${item.videoId}',
          onProgress: _setProgress,
        );
      }

      setState(() {
        _isDownloading = false;
      });
      _showToast(l10n.downloadSuccess);
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      _showToast(l10n.downloadFailed(e.toString()));
    }
  }


  bool get _isCookiePlatform => const {
        'TikTok', 'Pinterest', 'Instagram', 'Facebook', 'Twitter', 'Threads',
        'YouTube', 'Spotify'
      }.contains(widget.platform);

  String get _cookieBaseUrl {
    switch (widget.platform) {
      case 'TikTok':
        return 'https://musicaldown.com';
      case 'Pinterest':
        return 'https://pindown.io';
      case 'Instagram':
      case 'Facebook':
        return 'https://snapsave.app';
      case 'Twitter':
        return 'https://twitterdownloader.snapsave.app';
      case 'Threads':
        return 'https://threads.snapsave.app';
      case 'YouTube':
        return 'https://embed.dlsrv.online';
      case 'Spotify':
        return 'https://spotmate.online';
      default:
        return 'https://snapvid.net';
    }
  }

  Future<void> _openCookieWebView() async {
    await WebCookieService.instance.invalidate(_cookieBaseUrl);
    if (!mounted) return;
    await WebViewCookieDialog.show(context, _cookieBaseUrl);
  }

  Future<T> _downloadWithCookies<T>(
    String baseUrl,
    Future<T> Function(String? cookies) action,
  ) async {
    final cached = await WebCookieService.instance.getCookies(baseUrl);
    
    try {
      return await action(cached);
    } catch (e) {
      if (!e.toString().contains('403')) rethrow;

      final l10n = AppLocalizations.of(context)!;
      throw Exception(l10n.webviewRequired);
    }
  }




  /// Strip the " - Channel Name (youtube)" suffix the API appends to filenames.
  /// e.g. "TWICE - SIGNAL (Audio) - MelOn Music Channel (youtube).mp3"
  ///   ?  "TWICE - SIGNAL (Audio).mp3"
  String _cleanApiFilename(String name) {
    // Remove the last " - <anything> (youtube)" segment before the extension
    return name.replaceFirstMapped(
      RegExp(r'\s*-\s*.+?\(youtube\)(\.[^.]+)$', caseSensitive: false),
      (m) => m.group(1)!,
    );
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }
}

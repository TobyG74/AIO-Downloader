import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../l10n/app_localizations.dart';
import '../models/instagram_result.dart';
import '../models/facebook_result.dart';
import '../models/pinterest_result.dart';
import '../models/spotify_result.dart';
import '../models/youtube_result.dart';
import '../models/threads_result.dart';
import '../services/scrapers/tiktok_scraper.dart';
import '../services/scrapers/youtube_scraper.dart';
import '../services/scrapers/instagram_scraper.dart';
import '../services/scrapers/facebook_scraper.dart';
import '../services/scrapers/twitter_scraper.dart';
import '../services/scrapers/threads_scraper.dart';
import '../services/scrapers/pinterest_scraper.dart';
import '../services/scrapers/spotify_scraper.dart';
import '../services/download_service.dart';
import '../services/id3_tagger.dart';
import '../services/web_cookie_service.dart';
import '../widgets/webview_cookie_dialog.dart';

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

  bool _isLoading = false;
  bool _isDownloading = false;
  double? _downloadProgress;
  dynamic _result;
  String _inputUrl = '';
  TikTokServer _selectedTikTokServer = TikTokServer.musicaldown;

  int _youtubeTabIndex = 0;
  String? _selectedVideoQuality;
  String? _selectedAudioQuality;

  String _selectedSpotifyQuality = '320';

  @override
  void initState() {
    super.initState();
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
                      // TikTok Server Selection
                      if (widget.platform == 'TikTok') ...[
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          l10n.serverOption,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<TikTokServer>(
                                contentPadding: EdgeInsets.zero,
                                title: Text(l10n.server1),
                                subtitle: const Text('MusicalDown'),
                                value: TikTokServer.musicaldown,
                                groupValue: _selectedTikTokServer,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedTikTokServer = value!;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<TikTokServer>(
                                contentPadding: EdgeInsets.zero,
                                title: Text(l10n.server2),
                                subtitle: const Text('SSSTik'),
                                value: TikTokServer.ssstik,
                                groupValue: _selectedTikTokServer,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedTikTokServer = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
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
      _youtubeTabIndex = 0;
      _selectedVideoQuality = null;
      _selectedAudioQuality = null;
      // Reset Spotify state
      _selectedSpotifyQuality = '320';
    });

    try {
      dynamic result;

      switch (widget.platform) {
        case 'TikTok':
          final tiktokBaseUrl = _selectedTikTokServer == TikTokServer.ssstik
              ? 'https://ssstik.io'
              : 'https://musicaldown.com';
          result = await _downloadWithCookies(
            tiktokBaseUrl,
            (cookies) => TikTokScraper().download(
              _urlController.text.trim(),
              server: _selectedTikTokServer,
              cookies: cookies,
            ),
          );
          break;
        case 'YouTube':
          final scraper = YouTubeScraper();
          result = await scraper.download(_urlController.text.trim());
          break;
        case 'Instagram':
          // V2: Tidak butuh cookies - pakai snapsave.app
          final instagramScraper = InstagramScraper();
          result = await instagramScraper.download(_urlController.text.trim());
          break;
        case 'Facebook':
          // V2: Tidak butuh cookies - pakai snapsave.app
          final facebookScraper = FacebookScraper();
          result = await facebookScraper.download(_urlController.text.trim());
          break;
        case 'Twitter':
          // V2: Tidak butuh cookies - pakai twitterdownloader.snapsave.app
          final twitterScraper = TwitterScraper();
          result = await twitterScraper.download(_urlController.text.trim());
          break;
        case 'Threads':
          // Pakai threads.snapsave.app
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
      return _buildTikTokResult();
    } else if (widget.platform == 'YouTube') {
      return _buildYouTubeResult();
    } else if (widget.platform == 'Instagram') {
      return _buildInstagramResult();
    } else if (widget.platform == 'Facebook') {
      return _buildFacebookResult();
    } else if (widget.platform == 'Twitter') {
      return _buildTwitterResult();
    } else if (widget.platform == 'Threads') {
      return _buildThreadsResult();
    } else if (widget.platform == 'Pinterest') {
      return _buildPinterestResult();
    } else if (widget.platform == 'Spotify') {
      return _buildSpotifyResult();
    }
    return const SizedBox.shrink();
  }

  Widget _buildTikTokResult() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_result.cover.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _result.cover,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            if (_result.title.isNotEmpty) ...[
              Text(
                _result.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
            ],
            if (_result.authorName.isNotEmpty)
              Text('Author: ${_result.authorName}'),
            if (_result.diggCount > 0 ||
                _result.commentCount > 0 ||
                _result.shareCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                  '❤️ ${_formatCount(_result.diggCount)} • 💬 ${_formatCount(_result.commentCount)} • 🔄 ${_formatCount(_result.shareCount)}'),
            ],
            const SizedBox(height: 16),
            if (_result.images.isEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _downloadTikTokVideo(_result.videoUrlNoWatermark),
                  icon: const Icon(Icons.download),
                  label: Text(l10n.noWatermarkVideo),
                ),
              )
            else
              Column(
                children: [
                  Text(l10n.imageCount(_result.images.length)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadTikTokImages(_result.images),
                      icon: const Icon(Icons.download),
                      label: Text(l10n.downloadAllImages),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Widget _buildYouTubeResult() {
    final l10n = AppLocalizations.of(context)!;
    
    // Check if it's a playlist
    if (_result.isPlaylist == true) {
      return _buildYouTubePlaylistResult();
    }
    
    final videoFormats = (_result.videoFormats as List).cast<YouTubeVideoQuality>();
    final audioFormats = (_result.audioFormats as List).cast<YouTubeAudioQuality>();

    return Column(
      children: [
        // Thumbnail card
        Card(
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_result.thumbnail.isNotEmpty)
                Image.network(
                  _result.thumbnail,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(Icons.play_circle_outline,
                          size: 64, color: Colors.white54),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _result.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (_result.author.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Channel: ${_result.author}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (_result.duration.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Durasi: ${_result.duration}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Tab selector: Video / Audio
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tab buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _youtubeTabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _youtubeTabIndex == 0
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.videocam,
                                size: 18,
                                color: _youtubeTabIndex == 0
                                    ? Colors.white
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Video',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _youtubeTabIndex == 0
                                      ? Colors.white
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _youtubeTabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _youtubeTabIndex == 1
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.music_note,
                                size: 18,
                                color: _youtubeTabIndex == 1
                                    ? Colors.white
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Audio',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _youtubeTabIndex == 1
                                      ? Colors.white
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Video quality options
                if (_youtubeTabIndex == 0) ...[
                  Text(
                    l10n.selectQuality,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: videoFormats.map<Widget>((format) {
                      final isSelected =
                          _selectedVideoQuality == format.downloadUrl;
                      return ChoiceChip(
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              format.quality,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            if (format.size.isNotEmpty)
                              Text(
                                format.size,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? Colors.white70
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                ),
                              ),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedVideoQuality =
                                selected ? format.downloadUrl : null;
                          });
                        },
                        selectedColor: Theme.of(context).colorScheme.primary,
                        labelStyle: const TextStyle(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isDownloading || _selectedVideoQuality == null
                          ? null
                          : () => _downloadYouTubeVideo(_selectedVideoQuality!),
                      icon: const Icon(Icons.download),
                      label: Text(
                        _selectedVideoQuality == null
                            ? l10n.selectQualityFirst
                            : l10n.downloadMp4,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),
                ],

                // Audio quality options
                if (_youtubeTabIndex == 1) ...[
                  Text(
                    l10n.selectAudioQuality,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: audioFormats.map<Widget>((format) {
                      final isSelected =
                          _selectedAudioQuality == format.downloadUrl;
                      return ChoiceChip(
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              format.quality,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            if (format.size.isNotEmpty)
                              Text(
                                format.size,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? Colors.white70
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                ),
                              ),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedAudioQuality =
                                selected ? format.downloadUrl : null;
                          });
                        },
                        selectedColor: Theme.of(context).colorScheme.primary,
                        labelStyle: const TextStyle(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isDownloading || _selectedAudioQuality == null
                          ? null
                          : () => _downloadYouTubeAudio(
                                _selectedAudioQuality!,
                                audioFormats
                                    .firstWhere(
                                      (f) =>
                                          f.downloadUrl ==
                                          _selectedAudioQuality,
                                      orElse: () => audioFormats.first,
                                    )
                                    .format,
                              ),
                      icon: const Icon(Icons.audio_file),
                      label: Text(
                        _selectedAudioQuality == null
                            ? l10n.selectQualityFirst
                            : l10n.downloadAudio,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYouTubePlaylistResult() {
    final playlistItems = _result.playlistItems ?? [];

    return Column(
      children: [
        // Playlist Info Card
        Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_result.thumbnail.isNotEmpty)
                Image.network(
                  _result.thumbnail,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(Icons.playlist_play, size: 64, color: Colors.white54),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.playlist_play, size: 20, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'PLAYLIST',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _result.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${playlistItems.length} video${playlistItems.length > 1 ? "s" : ""}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Videos List
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Videos in Playlist',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: playlistItems.length,
                  separatorBuilder: (_, __) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final item = playlistItems[index];
                    return InkWell(
                      onTap: () => _downloadPlaylistVideo(item),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                children: [
                                  Image.network(
                                    item.thumbnail,
                                    width: 120,
                                    height: 68,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 120,
                                      height: 68,
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.play_circle_outline, color: Colors.white54),
                                    ),
                                  ),
                                  if (item.duration.isNotEmpty)
                                    Positioned(
                                      right: 4,
                                      bottom: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black87,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item.duration,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.index}. ${item.title}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (item.author.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      item.author,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Download icon
                            Icon(
                              Icons.download,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstagramResult() {
    final l10n = AppLocalizations.of(context)!;
    if (_result.type.toString().contains('video')) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video preview/thumbnail
              if (_result.video?.url != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Show thumbnail if available
                        if (_result.video?.thumbnail != null &&
                            _result.video!.thumbnail!.isNotEmpty)
                          Image.network(
                            _result.video!.thumbnail!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[900],
                              child: const Icon(
                                Icons.videocam,
                                size: 64,
                                color: Colors.white54,
                              ),
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[900],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                          )
                        else
                          Container(
                            color: Colors.grey[900],
                            child: const Icon(
                              Icons.videocam,
                              size: 64,
                              color: Colors.white54,
                            ),
                          ),
                        // Play button overlay
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Video label
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'VIDEO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'Instagram Video',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _downloadInstagramVideo(_result.video.url),
                  icon: const Icon(Icons.download),
                  label: Text(l10n.downloadVideo),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Get all images with their URLs
      final scraper = InstagramScraper();

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Instagram Images',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text('${_result.images.length} images found'),
              const SizedBox(height: 16),
              // Individual image cards
              ...List.generate(_result.images.length, (index) {
                final image = _result.images[index];
                final bestQuality = scraper.getBestImageQuality(image);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image preview
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: bestQuality != null
                              ? Image.network(
                                  bestQuality.url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image, size: 40),
                                  ),
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image, size: 40),
                                ),
                        ),
                      ),
                      // Download button
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.imageNum(index + 1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: bestQuality != null
                                  ? () => _downloadSingleInstagramImage(
                                        bestQuality.url,
                                        index,
                                      )
                                  : null,
                              icon: const Icon(Icons.download, size: 18),
                              label: Text(l10n.download),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 8),
              // Download all button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _downloadInstagramImages(_result.images),
                  icon: const Icon(Icons.download_for_offline),
                  label: Text(l10n.downloadAllImages),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildFacebookResult() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_result.thumbnail.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _result.thumbnail,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              _result.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (_result.duration.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Duration: ${_result.duration}'),
            ],
            const SizedBox(height: 16),
            Text(
              l10n.selectQuality,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._result.mp4
                .where((v) => v.type == 'direct' && v.url != null)
                .map((quality) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _downloadFacebookVideo(quality.url!),
                          child: Text(quality.quality),
                        ),
                      ),
                    )),
          ],
        ),
      ),
    );
  }

  Widget _buildTwitterResult() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_result.thumbnail.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _result.thumbnail,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              _result.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (_result.duration.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Duration: ${_result.duration}'),
            ],
            const SizedBox(height: 16),

            // Video download options with thumbnails
            if (_result.hasVideo) ...[
              Text(
                _result.videos.length > 1
                    ? l10n.videoGif(_result.videos.length)
                    : l10n.selectQuality,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_result.videos.length == 1) ...[
                // Single video - simple buttons
                ..._result.videos.map((quality) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _downloadTwitterVideo(quality.url),
                          child: Text('Download MP4 (${quality.quality})'),
                        ),
                      ),
                    )),
              ] else ...[
                // Multiple videos/GIFs - cards with thumbnails
                ..._result.videos.map((quality) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Card(
                      child: Column(
                        children: [
                          if (quality.thumbnail.isNotEmpty)
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Image.network(
                                  quality.thumbnail,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.play_circle_outline,
                                        size: 40),
                                  ),
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  },
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    quality.quality,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _downloadTwitterVideo(quality.url),
                                  icon: const Icon(Icons.download, size: 18),
                                  label: Text(l10n.download),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ],

            // Images download options (for standalone images, not video thumbnails)
            if (_result.hasImages && !_result.hasVideo) ...[
              if (_result.hasVideo) const SizedBox(height: 8),
              Text(
                _result.images.length > 1
                    ? l10n.imageCount(_result.images.length)
                    : l10n.image,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_result.images.length == 1) ...[
                // Single image
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadTwitterImage(_result.images[0]),
                    icon: const Icon(Icons.image),
                    label: Text(l10n.downloadImage),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ] else ...[
                // Multiple images
                ..._result.images.asMap().entries.map((entry) {
                  final index = entry.key;
                  final imageUrl = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Card(
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              child: Image.network(
                                _result.thumbnail,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image, size: 40),
                                ),
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                        child: CircularProgressIndicator()),
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.imageNum(index + 1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _downloadTwitterImage(imageUrl),
                                  icon: const Icon(Icons.download, size: 18),
                                  label: Text(l10n.download),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 8),
                // Download all images button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadAllTwitterImages(_result.images),
                    icon: const Icon(Icons.download_for_offline),
                    label: Text(l10n.downloadAllImages),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildThreadsResult() {
    final l10n = AppLocalizations.of(context)!;
    final result = _result as ThreadsResult;
    
    if (result.type == ThreadsMediaType.video && result.videos != null && result.videos!.isNotEmpty) {
      // Video result (single or multiple)
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Threads Video${result.videos!.length > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (result.videos!.length > 1) ...[
                const SizedBox(height: 8),
                Text('${result.videos!.length} video(s) found'),
              ],
              const SizedBox(height: 16),
              ...result.videos!.map((video) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      // Thumbnail preview
                      if (video.thumbnail != null && video.thumbnail!.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: AspectRatio(
                            aspectRatio: 9 / 16,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  video.thumbnail!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey[900],
                                    child: const Icon(Icons.videocam, size: 64, color: Colors.white54),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.play_arrow, size: 48, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _downloadThreadsVideo(video.url),
                            icon: const Icon(Icons.download),
                            label: Text(l10n.downloadVideo),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    } else if (result.images != null && result.images!.isNotEmpty) {
      // Images result
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Threads Images',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('${result.images!.length} image(s) found'),
              const SizedBox(height: 16),
              ...result.images!.map((image) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.network(
                            image.url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 40),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _downloadThreadsImage(image.url),
                            icon: const Icon(Icons.download, size: 18),
                            label: Text(l10n.download),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPinterestResult() {
    final l10n = AppLocalizations.of(context)!;
    final result = _result as PinterestResult;
    final isVideo = result.mediaType == PinterestMediaType.video;
    final isGif = result.mediaType == PinterestMediaType.gif;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            if (result.thumbnailUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  result.thumbnailUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(Icons.image, size: 64, color: Colors.white54),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Title & author
            Text(
              result.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (result.author.isNotEmpty) ...[  
              const SizedBox(height: 4),
              Text(
                result.author,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],

            // Media type badge
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isVideo
                        ? Colors.red.withOpacity(0.15)
                        : isGif
                            ? Colors.orange.withOpacity(0.15)
                            : const Color(0xFFE60023).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isVideo
                            ? Icons.videocam
                            : isGif
                                ? Icons.gif
                                : Icons.image,
                        size: 14,
                        color: isVideo
                            ? Colors.red
                            : isGif
                                ? Colors.orange
                                : const Color(0xFFE60023),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isVideo
                            ? 'Video'
                            : isGif
                                ? 'GIF'
                                : 'Image',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isVideo
                              ? Colors.red
                              : isGif
                                  ? Colors.orange
                                  : const Color(0xFFE60023),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            Text(
              l10n.selectQuality,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),

            // Download buttons for each quality
            ...result.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isDownloading
                          ? null
                          : () => _downloadPinterestItem(item),
                      icon: Icon(
                        isVideo ? Icons.video_file : Icons.download,
                        size: 18,
                      ),
                      label: Text(item.type),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadPinterestItem(PinterestDownloadItem item) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isDownloading = true;
      _downloadProgress = null;
    });

    final result = _result as PinterestResult;
    final isVideo = result.mediaType == PinterestMediaType.video &&
        !item.type.toLowerCase().contains('cover');
    final isGif = result.mediaType == PinterestMediaType.gif ||
        item.url.toLowerCase().contains('.gif');

    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      if (isVideo) {
        final filename = 'pinterest_$ts.mp4';
        await _downloadService.downloadVideo(
          url: item.url,
          filename: filename,
          platform: 'Pinterest',
          title: result.title,
          thumbnailUrl: result.thumbnailUrl,
          originalUrl: _inputUrl,
          onProgress: _setProgress,
        );
        _showToast(l10n.downloadSuccess);
      } else {
        final ext = isGif ? 'gif' : 'jpg';
        final filename = 'pinterest_$ts.$ext';
        await _downloadService.downloadImage(
          url: item.url,
          filename: filename,
          platform: 'Pinterest',
          title: result.title,
          thumbnailUrl: result.thumbnailUrl,
          originalUrl: _inputUrl,
          onProgress: _setProgress,
        );
        _showToast(l10n.downloadSuccess);
      }
    } catch (e) {
      _showToast(l10n.downloadFailed(e.toString()));
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  static const _spotifyQualities = [
    {'quality': '320', 'label': '320 kbps'},
    {'quality': '256', 'label': '256 kbps'},
    {'quality': '128', 'label': '128 kbps'},
  ];

  Widget _buildSpotifyResult() {
    final l10n = AppLocalizations.of(context)!;
    final track = _result as SpotifyTrack;
    
    // Check if it's a playlist
    if (track.isPlaylist) {
      return _buildSpotifyPlaylistResult();
    }
    
    return Column(
      children: [
        // Track Info
        Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover art
              if (track.coverUrl.isNotEmpty)
                Image.network(
                  track.coverUrl,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    color: const Color(0xFF1DB954).withOpacity(0.15),
                    child: const Center(
                      child: Icon(Icons.music_note_rounded,
                          size: 72, color: Color(0xFF1DB954)),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      track.title,
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    if (track.artist.isNotEmpty) ...
                      [
                        const SizedBox(height: 4),
                        Text(
                          track.artist,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: const Color(0xFF1DB954),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    if (track.album.isNotEmpty) ...
                      [
                        const SizedBox(height: 2),
                        Text(
                          track.album,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[500]),
                        ),
                      ],
                    if (track.durationFormatted.isNotEmpty) ...
                      [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.timer_outlined,
                                size: 13, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              track.durationFormatted,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ],
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Quality selection & download button
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.selectAudioQuality,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _spotifyQualities
                      .map((q) => ChoiceChip(
                            label: Text(q['label']!),
                            selected: _selectedSpotifyQuality == q['quality'],
                            selectedColor: const Color(0xFF1DB954),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  _selectedSpotifyQuality == q['quality']
                                      ? Colors.white
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedSpotifyQuality =
                                    q['quality']!);
                              }
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1DB954),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(14),
                    ),
                    onPressed: _isDownloading || track.youtubeVideoId == null
                        ? null
                        : _downloadSpotifyAudio,
                    icon: _isDownloading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.download_rounded),
                    label: Text(
                      _isDownloading
                          ? l10n.downloading
                          : l10n.downloadAudio,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpotifyPlaylistResult() {
    final playlist = _result as SpotifyTrack;
    final tracks = playlist.playlistTracks ?? [];

    return Column(
      children: [
        // Playlist Info Card
        Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (playlist.coverUrl.isNotEmpty)
                Image.network(
                  playlist.coverUrl,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    color: const Color(0xFF1DB954).withOpacity(0.15),
                    child: const Center(
                      child: Icon(Icons.queue_music, size: 72, color: Color(0xFF1DB954)),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.playlist_play, size: 20, color: Color(0xFF1DB954)),
                        SizedBox(width: 8),
                        Text(
                          'SPOTIFY PLAYLIST',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1DB954),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      playlist.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (playlist.artist.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'By ${playlist.artist}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF1DB954),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      '${tracks.length} track${tracks.length > 1 ? "s" : ""}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tracks List
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tracks in Playlist',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tracks.length,
                  separatorBuilder: (_, __) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    return InkWell(
                      onTap: () => _downloadSpotifyPlaylistTrack(track),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cover art
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: track.coverUrl.isNotEmpty
                                  ? Image.network(
                                      track.coverUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 60,
                                        height: 60,
                                        color: const Color(0xFF1DB954).withOpacity(0.2),
                                        child: const Icon(Icons.music_note, color: Color(0xFF1DB954), size: 30),
                                      ),
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      color: const Color(0xFF1DB954).withOpacity(0.2),
                                      child: const Icon(Icons.music_note, color: Color(0xFF1DB954), size: 30),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${track.index}. ${track.title}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (track.artist.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      track.artist,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  if (track.durationFormatted.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      track.durationFormatted,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Download icon
                            const Icon(
                              Icons.download,
                              color: Color(0xFF1DB954),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
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

  Future<void> _downloadTikTokVideo(String url) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isDownloading = true;
      _downloadProgress = null;
    });

    try {
      final filename = 'tiktok_${DateTime.now().millisecondsSinceEpoch}.mp4';
      await _downloadService.downloadVideo(
        url: url,
        filename: filename,
        platform: 'TikTok',
        title: _result?.title ?? 'TikTok Video',
        thumbnailUrl: _result?.cover ?? '',
        originalUrl: _inputUrl,
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

  Future<void> _downloadTikTokImages(List<String> imageUrls) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isDownloading = true;
      _downloadProgress = null;
    });

    try {
      await _downloadService.downloadMultipleImages(
        urls: imageUrls,
        filenamePrefix: 'tiktok_${DateTime.now().millisecondsSinceEpoch}',
        platform: 'TikTok',
        title: _result?.title ?? 'TikTok Images',
        thumbnailUrl: imageUrls.isNotEmpty ? imageUrls.first : '',
        originalUrl: _inputUrl,
        onProgress: _setProgress,
      );

      setState(() {
        _isDownloading = false;
      });
      _showToast(l10n.downloadAllSuccess);
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      _showToast(l10n.downloadFailed(e.toString()));
    }
  }

  Future<void> _downloadYouTubeVideo(String qualityStr) async {
    final l10n = AppLocalizations.of(context)!;
    final videoId = _result?.videoId as String?;
    if (videoId == null) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = null;
    });

    try {
      final scraper = YouTubeScraper();
      final dlRes = await scraper.getVideoDownloadUrl(videoId, qualityStr);

      // Use filename from API, fallback to generated name
      final filename = dlRes.filename.isNotEmpty
          ? _cleanApiFilename(dlRes.filename)
          : 'youtube_${DateTime.now().millisecondsSinceEpoch}_${qualityStr}p.mp4';

      await _downloadService.downloadVideo(
        url: dlRes.url,
        filename: filename,
        platform: 'YouTube',
        title: _result?.title ?? 'YouTube Video',
        thumbnailUrl: _result?.thumbnail ?? '',
        originalUrl: _inputUrl,
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

  Future<void> _downloadYouTubeAudio(String qualityStr, String format) async {
    final l10n = AppLocalizations.of(context)!;
    final videoId = _result?.videoId as String?;
    if (videoId == null) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = null;
    });

    try {
      final scraper = YouTubeScraper();
      final dlRes = await scraper.getAudioDownloadUrl(videoId, qualityStr);

      // Use filename from API, fallback to generated name
      final ext = format == 'm4a' ? 'm4a' : (format == 'opus' ? 'opus' : 'mp3');
      final filename = dlRes.filename.isNotEmpty
          ? _cleanApiFilename(dlRes.filename)
          : 'youtube_audio_${DateTime.now().millisecondsSinceEpoch}_$qualityStr.$ext';

      final savedPath = await _downloadService.downloadAudio(
        url: dlRes.url,
        filename: filename,
        platform: 'YouTube',
        title: _result?.title ?? 'YouTube Audio',
        thumbnailUrl: _result?.thumbnail ?? '',
        originalUrl: _inputUrl,
        onProgress: _setProgress,
      );

      // Embed ID3 tags (title + thumbnail as cover art)
      await Id3Tagger.embedTags(
        filePath: savedPath,
        title: _result?.title ?? '',
        coverUrl: _result?.thumbnail ?? '',
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

  bool get _isCookiePlatform => const {
        'TikTok', 'Pinterest', 'Instagram', 'Facebook', 'Twitter', 'Threads',
        'YouTube', 'Spotify'
      }.contains(widget.platform);

  String get _cookieBaseUrl {
    switch (widget.platform) {
      case 'TikTok':
        return _selectedTikTokServer == TikTokServer.ssstik
            ? 'https://ssstik.io'
            : 'https://musicaldown.com';
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

  Future<void> _downloadInstagramVideo(String url) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isDownloading = true;
      _downloadProgress = null;
    });

    try {
      final filename = 'instagram_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final instagramResult = _result as InstagramResult?;
      await _downloadService.downloadVideo(
        url: url,
        filename: filename,
        platform: 'Instagram',
        title: 'Instagram Video',
        thumbnailUrl: instagramResult?.video?.thumbnail ?? '',
        originalUrl: _inputUrl,
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

  Future<void> _downloadInstagramImages(List images) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isDownloading = true;
      _downloadProgress = null;
    });

    try {
      final scraper = InstagramScraper();
      List<String> urls = [];

      for (var image in images) {
        final bestQuality = scraper.getBestImageQuality(image);
        if (bestQuality != null) {
          urls.add(bestQuality.url);
        }
      }

      await _downloadService.downloadMultipleImages(
        urls: urls,
        filenamePrefix: 'instagram_${DateTime.now().millisecondsSinceEpoch}',
        platform: 'Instagram',
        title: 'Instagram Images',
        thumbnailUrl: urls.isNotEmpty ? urls.first : '',
        originalUrl: _inputUrl,
        onProgress: _setProgress,
      );

      setState(() {
        _isDownloading = false;
      });
      _showToast(l10n.downloadAllSuccess);
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      _showToast(l10n.downloadFailed(e.toString()));
    }
  }

  Future<void> _downloadSingleInstagramImage(String url, int index) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isDownloading = true;
      _downloadProgress = null;
    });

    try {
      final filename =
          'instagram_${DateTime.now().millisecondsSinceEpoch}_$index.jpg';
      await _downloadService.downloadImage(
        url: url,
        filename: filename,
        platform: 'Instagram',
        title: 'Instagram Image ${index + 1}',
        thumbnailUrl: url,
        originalUrl: _inputUrl,
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

  Future<void> _downloadThreadsVideo(String url) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isDownloading = true;
      _downloadProgress = null;
    });

    try {
      final filename = 'threads_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final threadsResult = _result as ThreadsResult?;
      final thumbUrl = threadsResult?.videos?.firstWhere(
        (v) => v.url == url,
        orElse: () => threadsResult.videos!.first,
      ).thumbnail ?? '';
      await _downloadService.downloadVideo(
        url: url,
        filename: filename,
        platform: 'Threads',
        title: 'Threads Video',
        thumbnailUrl: thumbUrl,
        originalUrl: _inputUrl,
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

  Future<void> _downloadThreadsImage(String url) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isDownloading = true;
      _downloadProgress = null;
    });

    try {
      final filename = 'threads_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _downloadService.downloadImage(
        url: url,
        filename: filename,
        platform: 'Threads',
        title: 'Threads Image',
        thumbnailUrl: url,
        originalUrl: _inputUrl,
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

  Future<void> _downloadFacebookVideo(String url) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isDownloading = true;
      _downloadProgress = null;
    });

    try {
      final filename = 'facebook_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final facebookResult = _result as FacebookResult?;
      await _downloadService.downloadVideo(
        url: url,
        filename: filename,
        platform: 'Facebook',
        title: facebookResult?.title ?? 'Facebook Video',
        thumbnailUrl: facebookResult?.thumbnail ?? '',
        originalUrl: _inputUrl,
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

  Future<void> _downloadTwitterVideo(String url) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isDownloading = true;
      _downloadProgress = null;
    });

    try {
      final filename = 'twitter_${DateTime.now().millisecondsSinceEpoch}.mp4';
      await _downloadService.downloadVideo(
        url: url,
        filename: filename,
        platform: 'Twitter',
        title: _result?.title ?? 'Twitter Video',
        thumbnailUrl: _result?.thumbnail ?? '',
        originalUrl: _inputUrl,
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

  Future<void> _downloadTwitterImage(String url) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isDownloading = true;
      _downloadProgress = null;
    });

    try {
      final filename = 'twitter_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _downloadService.downloadImage(
        url: url,
        filename: filename,
        platform: 'Twitter',
        title: _result?.title ?? 'Twitter Image',
        thumbnailUrl: url,
        originalUrl: _inputUrl,
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

  Future<void> _downloadAllTwitterImages(List<String> imageUrls) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isDownloading = true;
      _downloadProgress = null;
    });

    try {
      await _downloadService.downloadMultipleImages(
        urls: imageUrls,
        filenamePrefix: 'twitter_${DateTime.now().millisecondsSinceEpoch}',
        platform: 'Twitter',
        title: _result?.title ?? 'Twitter Images',
        thumbnailUrl: imageUrls.isNotEmpty ? imageUrls.first : '',
        originalUrl: _inputUrl,
        onProgress: _setProgress,
      );

      setState(() {
        _isDownloading = false;
      });
      _showToast(l10n.downloadAllSuccess);
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      _showToast(l10n.downloadFailed(e.toString()));
    }
  }

  /// Strip the " - Channel Name (youtube)" suffix the API appends to filenames.
  /// e.g. "TWICE - SIGNAL (Audio) - MelOn Music Channel (youtube).mp3"
  ///   →  "TWICE - SIGNAL (Audio).mp3"
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

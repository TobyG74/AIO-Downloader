import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../services/theme_provider.dart';
import '../services/url_detector_service.dart';
import '../services/version_check_service.dart';
import '../widgets/platform_card.dart';
import 'download_screen.dart';
import 'history_screen.dart';
import 'whatsapp_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  StreamSubscription? _intentSub;
  String? _lastClipboard;
  final _versionCheckService = VersionCheckService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initShareIntent();
    _checkForUpdates();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _intentSub?.cancel();
    super.dispose();
  }

  /// Check for app updates
  Future<void> _checkForUpdates() async {
    // Delay to ensure UI is built
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    try {
      final updateInfo = await _versionCheckService.checkForUpdate();
      if (updateInfo != null && mounted) {
        _showUpdateDialog(updateInfo);
      }
    } catch (e) {
      // Silently fail 
    }
  }

  /// Show update available dialog
  void _showUpdateDialog(Map<String, dynamic> updateInfo) {
    final l10n = AppLocalizations.of(context)!;
    final currentVersion = updateInfo['current_version'] as String;
    final latestVersion = updateInfo['latest_version'] as String;
    final downloadUrl = updateInfo['download_url'] as String;
    final releaseNotes = updateInfo['release_notes'] as String? ?? '';
    final releaseName = updateInfo['release_name'] as String? ?? '';
    final forceUpdate = updateInfo['force_update'] as bool? ?? false;

    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (context) => WillPopScope(
        onWillPop: () async => !forceUpdate,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.system_update_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.updateAvailable,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.updateAvailableDesc,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.currentVersion(currentVersion),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const Icon(Icons.arrow_forward, size: 16),
                        Text(
                          latestVersion,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (releaseName.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  releaseName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
              if (releaseNotes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.releaseNotes,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      releaseNotes,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (!forceUpdate)
              TextButton(
                onPressed: () {
                  _versionCheckService.skipVersion(latestVersion);
                  Navigator.pop(context);
                },
                child: Text(l10n.later),
              ),
            FilledButton.icon(
              onPressed: () async {
                final uri = Uri.parse(downloadUrl);
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                  if (!forceUpdate) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  // Fallback
                  await launchUrl(uri);
                  if (!forceUpdate) {
                    Navigator.pop(context);
                  }
                }
              },
              icon: const Icon(Icons.download_rounded, size: 18),
              label: Text(l10n.updateNow),
            ),
          ],
        ),
      ),
    );
  }

  /// Initialize share intent receiver from other apps
  void _initShareIntent() {
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> files) {
        _handleSharedFiles(files);
      },
    );

    ReceiveSharingIntent.instance.getInitialMedia().then(
      (List<SharedMediaFile> files) {
        if (files.isNotEmpty) {
          _handleSharedFiles(files);
          ReceiveSharingIntent.instance.reset();
        }
      },
    );
  }

  /// Process shared files and extract valid media URLs
  void _handleSharedFiles(List<SharedMediaFile> files) {
    for (final file in files) {
      final text = file.path;
      final url = UrlDetectorService.extractUrl(text);
      if (url != null) {
        _navigateFromUrl(url);
        return;
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboard();
    }
  }

  /// Check clipboard for valid media URLs
  Future<void> _checkClipboard() async {
    try {
      final data = await Clipboard.getData('text/plain');
      final text = data?.text ?? '';
      final url = UrlDetectorService.extractUrl(text);

      if (url != null && url != _lastClipboard && mounted) {
        _lastClipboard = url;
        _showClipboardBanner(url);
      }
    } catch (_) {}
  }

  /// Show SnackBar confirmation for detected clipboard URL
  void _showClipboardBanner(String url) {
    final platform = UrlDetectorService.detectPlatform(url)!;
    final emoji = UrlDetectorService.getPlatformEmoji(platform);
    final l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.urlDetected(platform),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    _shortenUrl(url),
                    style: const TextStyle(
                      fontSize: 11,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Download',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            _navigateFromUrl(url);
          },
        ),
      ),
    );
  }

  /// Navigate to appropriate DownloadScreen based on URL
  void _navigateFromUrl(String url) {
    final platform = UrlDetectorService.detectPlatform(url);
    if (platform == null || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DownloadScreen(
          platform: platform,
          initialUrl: url,
        ),
      ),
    );
  }

  String _shortenUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return '${uri.host}${uri.path}'.replaceAll(RegExp(r'\?.*'), '');
    } catch (_) {
      return url.length > 50 ? '${url.substring(0, 47)}...' : url;
    }
  }

  void _navigateToDownload(BuildContext context, String platform) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DownloadScreen(platform: platform),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AIO Downloader',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Dark/Light mode toggle
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                ),
                tooltip: isDark ? l10n.lightMode : l10n.darkMode,
                onPressed: () => themeProvider.toggleTheme(context),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
            tooltip: l10n.history,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Share hint banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.share_rounded,
                      size: 18,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.shareHint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Platform Selection
              Text(
                l10n.selectPlatform,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Platform Cards
              PlatformCard(
                icon: FontAwesomeIcons.tiktok,
                title: l10n.tiktok,
                description: l10n.tiktokDesc,
                color: Colors.black,
                onTap: () => _navigateToDownload(context, 'TikTok'),
              ),
              const SizedBox(height: 12),

              PlatformCard(
                icon: Icons.video_library,
                title: l10n.douyin,
                description: l10n.douyinDesc,
                color: Colors.black,
                onTap: () => _navigateToDownload(context, 'Douyin'),
              ),
              const SizedBox(height: 12),

              PlatformCard(
                icon: FontAwesomeIcons.youtube,
                title: l10n.youtube,
                description: l10n.youtubeDesc,
                color: Colors.red,
                onTap: () => _navigateToDownload(context, 'YouTube'),
              ),
              const SizedBox(height: 12),

              PlatformCard(
                icon: FontAwesomeIcons.instagram,
                title: l10n.instagram,
                description: l10n.instagramDesc,
                color: Colors.purple,
                onTap: () => _navigateToDownload(context, 'Instagram'),
              ),
              const SizedBox(height: 12),

              PlatformCard(
                icon: FontAwesomeIcons.facebook,
                title: l10n.facebook,
                description: l10n.facebookDesc,
                color: Colors.blue,
                onTap: () => _navigateToDownload(context, 'Facebook'),
              ),
              const SizedBox(height: 12),

              PlatformCard(
                icon: FontAwesomeIcons.twitter,
                title: l10n.twitter,
                description: l10n.twitterDesc,
                color: Colors.black87,
                onTap: () => _navigateToDownload(context, 'Twitter'),
              ),
              const SizedBox(height: 12),

              PlatformCard(
                icon: FontAwesomeIcons.threads,
                title: l10n.threads,
                description: l10n.threadsDesc,
                color: Colors.black,
                onTap: () => _navigateToDownload(context, 'Threads'),
              ),
              const SizedBox(height: 12),

              PlatformCard(
                icon: FontAwesomeIcons.pinterest,
                title: l10n.pinterest,
                description: l10n.pinterestDesc,
                color: const Color(0xFFE60023),
                onTap: () => _navigateToDownload(context, 'Pinterest'),
              ),
              const SizedBox(height: 12),

              PlatformCard(
                icon: FontAwesomeIcons.spotify,
                title: l10n.spotify,
                description: l10n.spotifyDesc,
                color: const Color(0xFF1DB954),
                onTap: () => _navigateToDownload(context, 'Spotify'),
              ),
              const SizedBox(height: 12),

              PlatformCard(
                icon: FontAwesomeIcons.soundcloud,
                title: l10n.soundcloud,
                description: l10n.soundcloudDesc,
                color: const Color(0xFFFF5500),
                onTap: () => _navigateToDownload(context, 'SoundCloud'),
              ),
              const SizedBox(height: 12),

              PlatformCard(
                icon: Icons.play_circle_outline,
                title: l10n.bilibili,
                description: l10n.bilibiliDesc,
                color: const Color(0xFF00A1D6),
                onTap: () => _navigateToDownload(context, 'Bilibili'),
              ),
              const SizedBox(height: 12),

              PlatformCard(
                icon: FontAwesomeIcons.whatsapp,
                title: l10n.whatsappStatus,
                description: l10n.whatsappStatusDesc,
                color: const Color(0xFF25D366),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WhatsAppStatusScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext ctx) {
    final l10n = AppLocalizations.of(ctx)!;
    showDialog(
      context: ctx,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        'https://avatars.githubusercontent.com/u/32604979?v=4',
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tobi Saputra',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'AIO Downloader Developer',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App info
                  Row(
                    children: [
                      Icon(
                        Icons.download_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'AIO Downloader',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'v1.0.2',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.aboutDesc,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Social links
                  Text(
                    'SOCIAL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Instagram button
                  const _SocialLinkButton(
                    icon: FontAwesomeIcons.instagram,
                    iconColor: Color(0xFFE1306C),
                    label: '@ini.tobz',
                    subtitle: 'Instagram',
                    url: 'https://instagram.com/ini.tobz',
                  ),
                  const SizedBox(height: 8),

                  // GitHub button
                  const _SocialLinkButton(
                    icon: FontAwesomeIcons.github,
                    iconColor: Color(0xFF333333),
                    label: 'tobyg74',
                    subtitle: 'GitHub',
                    url: 'https://github.com/tobyg74',
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Co-Authors
                  Text(
                    'CO-AUTHORS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  const _ContributorRow(
                    name: 'arugaz',
                    avatarUrl: 'https://avatars.githubusercontent.com/u/53950128?v=4',
                    igUrl: 'https://instagram.com/ini.arga',
                    igLabel: '@ini.arga',
                    githubUrl: 'https://github.com/arugaz',
                    githubLabel: 'arugaz',
                  ),
                  const SizedBox(height: 8),

                  const _ContributorRow(
                    name: 'nugraizy',
                    avatarUrl: 'https://avatars.githubusercontent.com/u/69896924?v=4',
                    igUrl: 'https://instagram.com/dizy.himself',
                    igLabel: '@dizy.himself',
                    githubUrl: 'https://github.com/nugraizy',
                    githubLabel: 'nugraizy',
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '© 2026 Tobi Saputra. All rights reserved.',
                      style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Close button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.close),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable social link button widget
class _SocialLinkButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final String url;

  const _SocialLinkButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final uri = Uri.parse(url);
          try {
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cannot open link')),
                );
              }
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(icon, size: 18, color: iconColor),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.open_in_new_rounded,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Contributor row with Instagram + GitHub links
class _ContributorRow extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final String igUrl;
  final String igLabel;
  final String githubUrl;
  final String githubLabel;

  const _ContributorRow({
    required this.name,
    required this.avatarUrl,
    required this.igUrl,
    required this.igLabel,
    required this.githubUrl,
    required this.githubLabel,
  });

  Future<void> _launch(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cannot open link')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            backgroundImage: NetworkImage(avatarUrl),
            onBackgroundImageError: (_, __) {},
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _launch(igUrl, context),
                      child: Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.instagram,
                              size: 11, color: Color(0xFFE1306C)),
                          const SizedBox(width: 3),
                          Text(
                            igLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFE1306C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _launch(githubUrl, context),
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.github,
                              size: 11, color: Colors.grey[600]),
                          const SizedBox(width: 3),
                          Text(
                            githubLabel,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

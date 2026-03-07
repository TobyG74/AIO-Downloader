/// Service to detect platform from copied/shared URLs
class UrlDetectorService {
  /// URL patterns for each platform
  static final Map<String, List<RegExp>> _platformPatterns = {
    'YouTube': [
      RegExp(r'youtube\.com\/watch', caseSensitive: false),
      RegExp(r'youtube\.com\/playlist', caseSensitive: false),
      RegExp(r'youtu\.be\/', caseSensitive: false),
      RegExp(r'youtube\.com\/shorts\/', caseSensitive: false),
      RegExp(r'youtube\.com\/embed\/', caseSensitive: false),
      RegExp(r'm\.youtube\.com', caseSensitive: false),
    ],
    'TikTok': [
      RegExp(r'tiktok\.com\/@', caseSensitive: false),
      RegExp(r'tiktok\.com\/v\/', caseSensitive: false),
      RegExp(r'vm\.tiktok\.com', caseSensitive: false),
      RegExp(r'vt\.tiktok\.com', caseSensitive: false),
    ],
    'Instagram': [
      RegExp(r'instagram\.com\/p\/', caseSensitive: false),
      RegExp(r'instagram\.com\/reel\/', caseSensitive: false),
      RegExp(r'instagram\.com\/reels\/', caseSensitive: false),
      RegExp(r'instagram\.com\/tv\/', caseSensitive: false),
      RegExp(r'instagr\.am\/', caseSensitive: false),
    ],
    'Facebook': [
      RegExp(r'facebook\.com\/.*\/videos\/', caseSensitive: false),
      RegExp(r'facebook\.com\/watch', caseSensitive: false),
      RegExp(r'facebook\.com\/groups\/', caseSensitive: false),
      RegExp(r'fb\.watch\/', caseSensitive: false),
      RegExp(r'fb\.com\/', caseSensitive: false),
      RegExp(r'm\.facebook\.com', caseSensitive: false),
    ],
    'Twitter': [
      RegExp(r'twitter\.com\/.*\/status\/', caseSensitive: false),
      RegExp(r'x\.com\/.*\/status\/', caseSensitive: false),
      RegExp(r't\.co\/', caseSensitive: false),
    ],
    'Threads': [
      RegExp(r'threads\.net\/@', caseSensitive: false),
      RegExp(r'threads\.net\/t\/', caseSensitive: false),
      RegExp(r'www\.threads\.net', caseSensitive: false),
      RegExp(r'threads\.com\/@.*\/post\/', caseSensitive: false),
      RegExp(r'www\.threads\.com\/@', caseSensitive: false),
    ],
    'Pinterest': [
      RegExp(r'pinterest\.com\/pin\/', caseSensitive: false),
      RegExp(r'pinterest\.\w+\/pin\/', caseSensitive: false),
      RegExp(r'pin\.it\/', caseSensitive: false),
    ],
    'Spotify': [
      RegExp(r'open\.spotify\.com\/track\/', caseSensitive: false),
      RegExp(r'open\.spotify\.com\/playlist\/', caseSensitive: false),
      RegExp(r'open\.spotify\.com\/intl-[a-z]+\/track\/', caseSensitive: false),
      RegExp(r'open\.spotify\.com\/intl-[a-z]+\/playlist\/', caseSensitive: false),
      RegExp(r'open\.spotify\.com\/episode\/', caseSensitive: false),
      RegExp(r'spotify\.link\/', caseSensitive: false),
    ],
    'SoundCloud': [
      RegExp(r'soundcloud\.com\/[^\/]+\/[^\/]+', caseSensitive: false),
      RegExp(r'soundcloud\.com\/[^\/]+\/sets\/', caseSensitive: false),
      RegExp(r'soundcloud\.app\.goo\.gl', caseSensitive: false),
      RegExp(r'on\.soundcloud\.com', caseSensitive: false),
    ],
    'Douyin': [
      RegExp(r'v\.douyin\.com\/', caseSensitive: false),
      RegExp(r'(www\.)?douyin\.com\/video\/', caseSensitive: false),
      RegExp(r'(www\.)?douyin\.com\/user\/', caseSensitive: false),
      RegExp(r'iesdouyin\.com', caseSensitive: false),
      RegExp(r'm\.douyin\.com', caseSensitive: false),
    ],
    'Bilibili': [
      RegExp(r'bilibili\.tv\/[a-z]{2}\/video\/', caseSensitive: false),
      RegExp(r'bilibili\.tv\/video\/', caseSensitive: false),
      RegExp(r'www\.bilibili\.tv', caseSensitive: false),
      RegExp(r'b23\.tv\/', caseSensitive: false),
      RegExp(r'bili\.im\/', caseSensitive: false),
    ],
  };

  /// Detect platform from URL
  /// Returns: 'YouTube' | 'TikTok' | 'Instagram' | 'Facebook' | 'Twitter' | null
  static String? detectPlatform(String url) {
    if (url.isEmpty) return null;

    final cleanUrl = url.trim();

    for (final entry in _platformPatterns.entries) {
      for (final pattern in entry.value) {
        if (pattern.hasMatch(cleanUrl)) {
          return entry.key;
        }
      }
    }
    return null;
  }

  /// Check if string is a valid media URL
  static bool isValidMediaUrl(String text) {
    final trimmed = text.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return false;
    }
    return detectPlatform(trimmed) != null;
  }

  /// Extract first valid URL from text (for share intents containing text + URL)
  static String? extractUrl(String text) {
    if (text.isEmpty) return null;

    final trimmed = text.trim();
    if (isValidMediaUrl(trimmed)) return trimmed;

    final urlRegex = RegExp(
      r'https?://[^\s]+',
      caseSensitive: false,
    );
    final matches = urlRegex.allMatches(text);

    for (final match in matches) {
      final url = match.group(0) ?? '';
      if (isValidMediaUrl(url)) {
        return url;
      }
    }

    return null;
  }

  /// Get icon emoji for platform
  static String getPlatformEmoji(String platform) {
    switch (platform) {
      case 'YouTube':
        return '▶️';
      case 'TikTok':
        return '🎵';
      case 'Instagram':
        return '📸';
      case 'Facebook':
        return '👤';
      case 'Twitter':
        return '🐦';
      case 'Pinterest':
        return '📌';
      case 'Spotify':
        return '🎵';
      case 'SoundCloud':
        return '🔊';
      case 'Douyin':
        return '🎬';
      case 'Bilibili':
        return '📺';
      default:
        return '🔗';
    }
  }
}

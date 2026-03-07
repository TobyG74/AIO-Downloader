import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to check for app updates from GitHub repository
class VersionCheckService {
  static const String _githubApiUrl =
      'https://api.github.com/repos/TobyG74/AIO-Downloader/releases/latest';
  
  static const String _skipVersionKey = 'skip_version';

  final Dio _dio = Dio();

  /// Check if update is available
  Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      if (await _shouldSkipCheck()) {
        return null;
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await _dio.get(_githubApiUrl);
      if (response.statusCode != 200) {
        return null;
      }

      final releaseData = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      // Parse version from tag_name (e.g., "v1.0.1" -> "1.0.1")
      String latestVersion = releaseData['tag_name'] as String;
      if (latestVersion.startsWith('v')) {
        latestVersion = latestVersion.substring(1);
      }

      final hasUpdate = _isNewerVersion(currentVersion, latestVersion);

      if (hasUpdate) {
        // Find appropriate APK download URL
        final assets = releaseData['assets'] as List;
        String downloadUrl = '';
        
        // Priority: arm64-v8a > universal (app-release.apk) > armeabi-v7a
        final arm64Asset = assets.firstWhere(
          (asset) => (asset['name'] as String).contains('arm64-v8a'),
          orElse: () => null,
        );
        final universalAsset = assets.firstWhere(
          (asset) => (asset['name'] as String) == 'app-release.apk',
          orElse: () => null,
        );
        
        if (arm64Asset != null) {
          downloadUrl = arm64Asset['browser_download_url'] as String;
        } else if (universalAsset != null) {
          downloadUrl = universalAsset['browser_download_url'] as String;
        } else if (assets.isNotEmpty) {
          downloadUrl = assets.first['browser_download_url'] as String;
        }

        return {
          'current_version': currentVersion,
          'latest_version': latestVersion,
          'download_url': downloadUrl,
          'release_notes': releaseData['body'] ?? '',
          'release_name': releaseData['name'] ?? '',
          'force_update': false,
        };
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if latestVersion is newer than currentVersion
  bool _isNewerVersion(String currentVersion, String latestVersion) {
    // If versions are identical, no update needed
    if (currentVersion == latestVersion) {
      return false;
    }

    final current = _parseVersion(currentVersion);
    final latest = _parseVersion(latestVersion);

    // Compare each part (major, minor, patch)
    for (int i = 0; i < 3; i++) {
      if (latest[i] > current[i]) return true;
      if (latest[i] < current[i]) return false;
    }

    return false;
  }

  /// Parse semantic version string (e.g., "1.0.0" -> [1, 0, 0])
  List<int> _parseVersion(String version) {
    return version
        .split('.')
        .take(3)
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
  }

  /// Check if we should skip this version check
  Future<bool> _shouldSkipCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final skippedVersion = prefs.getString(_skipVersionKey);
    if (skippedVersion != null) {
      final packageInfo = await PackageInfo.fromPlatform();
      if (skippedVersion != packageInfo.version) {
        await prefs.remove(_skipVersionKey);
      } else {
        return true;
      }
    }

    return false;
  }

  Future<void> skipVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_skipVersionKey, version);
  }

  Future<void> clearSkippedVersion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_skipVersionKey);
  }
}

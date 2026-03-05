import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to check for app updates from GitHub repository
class VersionCheckService {
  static const String _versionJsonUrl =
      'https://raw.githubusercontent.com/TobyG74/AIO-Downloader/master/version.json';
  
  static const String _lastVersionCheckKey = 'last_version_check';
  static const String _skipVersionKey = 'skip_version';
  static const Duration _checkInterval = Duration(hours: 24);

  final Dio _dio = Dio();

  /// Check if update is available
  Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      if (await _shouldSkipCheck()) {
        return null;
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 1;

      final response = await _dio.get(_versionJsonUrl);
      if (response.statusCode != 200) {
        return null;
      }

      final versionData = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      final latestVersion = versionData['version'] as String;
      final latestBuildNumber = versionData['build_number'] as int;
      final forceUpdate = versionData['force_update'] as bool? ?? false;

      final hasUpdate = _compareVersions(
        currentVersion,
        currentBuildNumber,
        latestVersion,
        latestBuildNumber,
      );

      if (hasUpdate) {
        await _saveLastCheckTime();
        return {
          'current_version': currentVersion,
          'latest_version': latestVersion,
          'download_url': versionData['download_url'],
          'release_notes': versionData['release_notes'],
          'force_update': forceUpdate,
        };
      }

      await _saveLastCheckTime();
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Compare version strings and build numbers
  bool _compareVersions(
    String currentVersion,
    int currentBuild,
    String latestVersion,
    int latestBuild,
  ) {
    if (latestBuild > currentBuild) {
      return true;
    }

    final current = _parseVersion(currentVersion);
    final latest = _parseVersion(latestVersion);

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

    final lastCheck = prefs.getInt(_lastVersionCheckKey);
    if (lastCheck != null) {
      final lastCheckTime = DateTime.fromMillisecondsSinceEpoch(lastCheck);
      if (DateTime.now().difference(lastCheckTime) < _checkInterval) {
        return true;
      }
    }

    return false;
  }

  Future<void> _saveLastCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastVersionCheckKey,
      DateTime.now().millisecondsSinceEpoch,
    );
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

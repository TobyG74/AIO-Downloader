import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/download_history.dart';

class HistoryService {
  static const String _historyKey = 'download_history';
  static const int _maxHistoryItems = 100;

  /// Save download to history
  Future<void> saveDownload({
    required String platform,
    required String title,
    required String url,
    required String thumbnailUrl,
    required String downloadType,
    int fileCount = 1,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();

      final newItem = DownloadHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        platform: platform,
        title: title.isEmpty ? 'Untitled' : title,
        url: url,
        thumbnailUrl: thumbnailUrl,
        downloadType: downloadType,
        downloadDate: DateTime.now(),
        fileCount: fileCount,
      );

      history.insert(0, newItem);

      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      final jsonList = history.map((item) => item.toJson()).toList();
      await prefs.setString(_historyKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  /// Get all download history
  Future<List<DownloadHistory>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_historyKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => DownloadHistory.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Get history filtered by platform
  Future<List<DownloadHistory>> getHistoryByPlatform(String platform) async {
    final history = await getHistory();
    return history
        .where((item) => item.platform.toLowerCase() == platform.toLowerCase())
        .toList();
  }

  /// Get history filtered by type (video/image)
  Future<List<DownloadHistory>> getHistoryByType(String type) async {
    final history = await getHistory();
    return history.where((item) => item.downloadType == type).toList();
  }

  /// Delete single history item
  Future<void> deleteHistory(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();

      history.removeWhere((item) => item.id == id);

      final jsonList = history.map((item) => item.toJson()).toList();
      await prefs.setString(_historyKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  /// Clear all history
  Future<void> clearAllHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (_) {}
  }

  /// Get history statistics
  Future<Map<String, int>> getStatistics() async {
    final history = await getHistory();
    
    return {
      'total': history.length,
      'videos': history.where((item) => item.downloadType == 'video').length,
      'images': history.where((item) => item.downloadType == 'image').length,
      'tiktok': history.where((item) => item.platform.toLowerCase() == 'tiktok').length,
      'youtube': history.where((item) => item.platform.toLowerCase() == 'youtube').length,
      'instagram': history.where((item) => item.platform.toLowerCase() == 'instagram').length,
      'facebook': history.where((item) => item.platform.toLowerCase() == 'facebook').length,
    };
  }
}

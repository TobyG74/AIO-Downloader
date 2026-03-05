import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'history_service.dart';

class DownloadService {
  final Dio _dio = Dio();
  final HistoryService _historyService = HistoryService();

  /// Request storage permission
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.photos.isPermanentlyDenied ||
          await Permission.videos.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }

      final photoStatus = await Permission.photos.request();
      final videoStatus = await Permission.videos.request();

      return photoStatus.isGranted && videoStatus.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return true;
  }

  /// Download video and save to gallery
  Future<String> downloadVideo({
    required String url,
    required String filename,
    Function(int, int)? onProgress,
    String platform = '',
    String title = '',
    String thumbnailUrl = '',
    String originalUrl = '',
  }) async {
    try {
      // Request permission
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$filename';

      // Download file
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          onProgress?.call(received, total);
        },
      );

      // Save to gallery
      await Gal.putVideo(filePath);
      
      // Save to history
      if (platform.isNotEmpty) {
        await _historyService.saveDownload(
          platform: platform,
          title: title,
          url: originalUrl.isNotEmpty ? originalUrl : url,
          thumbnailUrl: thumbnailUrl,
          downloadType: 'video',
        );
      }
      
      // Delete temp file
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      return 'Video berhasil disimpan ke galeri';
    } catch (error) {
      throw Exception('Download failed: $error');
    }
  }

  /// Download image and save to gallery
  Future<String> downloadImage({
    required String url,
    required String filename,
    Function(int, int)? onProgress,
    String platform = '',
    String title = '',
    String thumbnailUrl = '',
    String originalUrl = '',
  }) async {
    try {
      // Request permission
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$filename';

      // Download file
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          onProgress?.call(received, total);
        },
      );

      // Save to gallery
      await Gal.putImage(filePath);
      
      // Save to history
      if (platform.isNotEmpty) {
        await _historyService.saveDownload(
          platform: platform,
          title: title,
          url: originalUrl.isNotEmpty ? originalUrl : url,
          thumbnailUrl: thumbnailUrl,
          downloadType: 'image',
        );
      }
      
      // Delete temp file
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      return 'Gambar berhasil disimpan ke galeri';
    } catch (error) {
      throw Exception('Download failed: $error');
    }
  }

  /// Download audio file and save to Music / Downloads folder
  Future<String> downloadAudio({
    required String url,
    required String filename,
    Function(int, int)? onProgress,
    String platform = '',
    String title = '',
    String thumbnailUrl = '',
    String originalUrl = '',
  }) async {
    try {
      String savedPath = '';

      if (Platform.isAndroid) {
        // Try Music folder first, then Downloads
        final candidates = [
          '/storage/emulated/0/Music',
          '/storage/emulated/0/Download',
        ];

        Directory? saveDir;
        for (final path in candidates) {
          final dir = Directory(path);
          if (await dir.exists()) {
            saveDir = dir;
            break;
          }
          try {
            await dir.create(recursive: true);
            saveDir = dir;
            break;
          } catch (_) {}
        }

        if (saveDir == null) {
          // Fallback: app external files dir
          final extDir = await getApplicationDocumentsDirectory();
          saveDir = Directory('${extDir.path}/music');
          await saveDir.create(recursive: true);
        }

        savedPath = '${saveDir.path}/$filename';
      } else {
        // iOS: app documents directory
        final appDir = await getApplicationDocumentsDirectory();
        savedPath = '${appDir.path}/$filename';
      }

      await _dio.download(
        url,
        savedPath,
        onReceiveProgress: (received, total) {
          onProgress?.call(received, total);
        },
      );

      // Trigger media scan on Android so Music apps see the file
      if (Platform.isAndroid) {
        try {
          await Process.run('am', [
            'broadcast',
            '-a', 'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
            '-d', 'file://$savedPath',
          ]);
        } catch (_) {}
      }

      if (platform.isNotEmpty) {
        await _historyService.saveDownload(
          platform: platform,
          title: title,
          url: originalUrl.isNotEmpty ? originalUrl : url,
          thumbnailUrl: thumbnailUrl,
          downloadType: 'audio',
        );
      }

      return savedPath;
    } catch (error) {
      throw Exception('Download failed: $error');
    }
  }

  /// Download multiple images
  Future<List<String>> downloadMultipleImages({
    required List<String> urls,
    required String filenamePrefix,
    Function(int current, int total)? onProgress,
    String platform = '',
    String title = '',
    String thumbnailUrl = '',
    String originalUrl = '',
  }) async {
    List<String> results = [];

    for (int i = 0; i < urls.length; i++) {
      try {
        final filename = '${filenamePrefix}_${i + 1}.jpg';
        final result = await downloadImage(
          url: urls[i],
          filename: filename,
          platform: '', // Don't save individual images to history
          title: '',
          thumbnailUrl: '',
          originalUrl: '',
        );
        results.add(result);
        
        if (onProgress != null) {
          onProgress(i + 1, urls.length);
        }
      } catch (e) {
        results.add('Gagal: ${e.toString()}');
      }
    }

    // Save to history after all images downloaded
    if (platform.isNotEmpty && results.isNotEmpty) {
      await _historyService.saveDownload(
        platform: platform,
        title: title,
        url: originalUrl,
        thumbnailUrl: thumbnailUrl,
        downloadType: 'image',
        fileCount: urls.length,
      );
    }

    return results;
  }

  /// Get file size from URL
  Future<String> getFileSize(String url) async {
    try {
      final response = await _dio.head(url);
      final contentLength = response.headers.value('content-length');
      
      if (contentLength != null) {
        final bytes = int.parse(contentLength);
        return _formatBytes(bytes);
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Format bytes to human readable format
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

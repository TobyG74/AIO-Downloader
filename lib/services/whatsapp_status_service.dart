import 'dart:io';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/whatsapp_status.dart';

class WhatsAppStatusService {
  static const List<String> _statusPaths = [
    '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
    '/storage/emulated/0/WhatsApp/Media/.Statuses',
    '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses',
  ];

  static const List<String> _imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
  static const List<String> _videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.3gp'];

  /// Request required permissions. Returns true if granted.
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getSdkInt();
      if (sdkInt >= 30) {
        // Android 11+ needs MANAGE_EXTERNAL_STORAGE
        final status = await Permission.manageExternalStorage.request();
        return status.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return false; // iOS not supported
  }

  Future<bool> checkPermissions() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getSdkInt();
      if (sdkInt >= 30) {
        return await Permission.manageExternalStorage.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    }
    return false;
  }

  /// Finds the first WhatsApp .Statuses directory that exists on this device.
  Future<String?> findStatusDirectory() async {
    for (final path in _statusPaths) {
      final dir = Directory(path);
      if (await dir.exists()) {
        return path;
      }
    }
    return null;
  }

  /// Returns all visible statuses (images + videos), sorted newest first.
  Future<List<WhatsAppStatus>> getStatuses() async {
    final statuses = <WhatsAppStatus>[];

    for (final path in _statusPaths) {
      final dir = Directory(path);
      if (!await dir.exists()) continue;

      try {
        final entities = await dir.list().toList();
        for (final entity in entities) {
          if (entity is! File) continue;
          final name = entity.path.split(Platform.pathSeparator).last;
          // WhatsApp hides nomedia files
          if (name.startsWith('.')) continue;

          final ext = _getExtension(name);
          WhatsAppStatusType? type;
          if (_imageExtensions.contains(ext)) {
            type = WhatsAppStatusType.image;
          } else if (_videoExtensions.contains(ext)) {
            type = WhatsAppStatusType.video;
          }
          if (type == null) continue;

          final stat = await entity.stat();
          statuses.add(WhatsAppStatus(
            filePath: entity.path,
            fileName: name,
            type: type,
            lastModified: stat.modified,
            fileSize: stat.size,
          ));
        }
      } catch (_) {
        // May be denied access – skip this path
      }
    }

    statuses.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    return statuses;
  }

  /// Save a single status to device gallery.
  Future<void> saveStatus(WhatsAppStatus status) async {
    if (status.isImage) {
      await Gal.putImage(status.filePath);
    } else {
      await Gal.putVideo(status.filePath);
    }
  }

  /// Save all statuses to device gallery. Returns count saved.
  Future<int> saveAllStatuses(List<WhatsAppStatus> statuses) async {
    int saved = 0;
    for (final s in statuses) {
      try {
        await saveStatus(s);
        saved++;
      } catch (_) {}
    }
    return saved;
  }

  static String _getExtension(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) return '';
    return fileName.substring(lastDot).toLowerCase();
  }

  Future<int> _getSdkInt() async {
    try {
      final result = await Process.run('getprop', ['ro.build.version.sdk']);
      return int.tryParse(result.stdout.toString().trim()) ?? 30;
    } catch (_) {
      return 30;
    }
  }
}

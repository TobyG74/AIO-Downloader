enum WhatsAppStatusType { image, video }

class WhatsAppStatus {
  final String filePath;
  final String fileName;
  final WhatsAppStatusType type;
  final DateTime lastModified;
  final int fileSize;

  const WhatsAppStatus({
    required this.filePath,
    required this.fileName,
    required this.type,
    required this.lastModified,
    required this.fileSize,
  });

  bool get isVideo => type == WhatsAppStatusType.video;
  bool get isImage => type == WhatsAppStatusType.image;

  String get fileSizeFormatted {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

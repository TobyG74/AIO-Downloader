import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/pinterest_result.dart';

class PinterestResultWidget extends StatelessWidget {
  final PinterestResult result;
  final Function(PinterestDownloadItem) onDownloadItem;
  final bool isDownloading;

  const PinterestResultWidget({
    super.key,
    required this.result,
    required this.onDownloadItem,
    required this.isDownloading,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                      child: Icon(Icons.image,
                          size: 64, color: Colors.white54),
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
                      onPressed: isDownloading
                          ? null
                          : () => onDownloadItem(item),
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
}

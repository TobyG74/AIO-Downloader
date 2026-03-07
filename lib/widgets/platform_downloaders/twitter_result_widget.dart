import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/twitter_result.dart';

class TwitterResultWidget extends StatelessWidget {
  final TwitterResult result;
  final Function(String) onDownloadVideo;
  final Function(String) onDownloadImage;
  final Function(List<String>) onDownloadAllImages;

  const TwitterResultWidget({
    super.key,
    required this.result,
    required this.onDownloadVideo,
    required this.onDownloadImage,
    required this.onDownloadAllImages,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.thumbnail.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  result.thumbnail,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              result.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (result.duration.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Duration: ${result.duration}'),
            ],
            const SizedBox(height: 16),

            // Video download options with thumbnails
            if (result.hasVideo) ...[
              Text(
                result.videos.length > 1
                    ? l10n.videoGif(result.videos.length)
                    : l10n.selectQuality,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (result.videos.length == 1) ...[
                // Single video - simple buttons
                ...result.videos.map((quality) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => onDownloadVideo(quality.url),
                          child: Text('Download MP4 (${quality.quality})'),
                        ),
                      ),
                    )),
              ] else ...[
                // Multiple videos/GIFs - cards with thumbnails
                ...result.videos.map((quality) {
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
                                  onPressed: () => onDownloadVideo(quality.url),
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
            if (result.hasImages && !result.hasVideo) ...[
              if (result.hasVideo) const SizedBox(height: 8),
              Text(
                result.images.length > 1
                    ? l10n.imageCount(result.images.length)
                    : l10n.image,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (result.images.length == 1) ...[
                // Single image
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => onDownloadImage(result.images[0]),
                    icon: const Icon(Icons.image),
                    label: Text(l10n.downloadImage),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ] else ...[
                // Multiple images
                ...result.images.asMap().entries.map((entry) {
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
                                result.thumbnail,
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
                                  onPressed: () => onDownloadImage(imageUrl),
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
                    onPressed: () => onDownloadAllImages(result.images),
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
}

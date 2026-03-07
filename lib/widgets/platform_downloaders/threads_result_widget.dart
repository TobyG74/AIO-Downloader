import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/threads_result.dart';

class ThreadsResultWidget extends StatelessWidget {
  final ThreadsResult result;
  final Function(String) onDownloadVideo;
  final Function(String) onDownloadImage;

  const ThreadsResultWidget({
    super.key,
    required this.result,
    required this.onDownloadVideo,
    required this.onDownloadImage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (result.type == ThreadsMediaType.video &&
        result.videos != null &&
        result.videos!.isNotEmpty) {
      return _buildVideoResult(context, l10n);
    } else if (result.images != null && result.images!.isNotEmpty) {
      return _buildImagesResult(context, l10n);
    }
    return const SizedBox.shrink();
  }

  Widget _buildVideoResult(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Threads Video${result.videos!.length > 1 ? 's' : ''}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (result.videos!.length > 1) ...[
              const SizedBox(height: 8),
              Text('${result.videos!.length} video(s) found'),
            ],
            const SizedBox(height: 16),
            ...result.videos!.map((video) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    // Thumbnail preview
                    if (video.thumbnail != null && video.thumbnail!.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                video.thumbnail!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[900],
                                  child: const Icon(Icons.videocam,
                                      size: 64, color: Colors.white54),
                                ),
                              ),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.play_arrow,
                                      size: 48, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => onDownloadVideo(video.url),
                          icon: const Icon(Icons.download),
                          label: Text(l10n.downloadVideo),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesResult(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Threads Images',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${result.images!.length} image(s) found'),
            const SizedBox(height: 16),
            ...result.images!.map((image) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          image.url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 40),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => onDownloadImage(image.url),
                          icon: const Icon(Icons.download, size: 18),
                          label: Text(l10n.download),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

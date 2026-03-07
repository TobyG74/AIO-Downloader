import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/instagram_result.dart';
import '../../services/scrapers/instagram_scraper.dart';

class InstagramResultWidget extends StatelessWidget {
  final InstagramResult result;
  final Function(String) onDownloadVideo;
  final Function(String, int) onDownloadSingleImage;
  final Function(List<InstagramImageItem>) onDownloadAllImages;

  const InstagramResultWidget({
    super.key,
    required this.result,
    required this.onDownloadVideo,
    required this.onDownloadSingleImage,
    required this.onDownloadAllImages,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (result.type.toString().contains('video')) {
      return _buildVideoResult(context, l10n);
    } else {
      return _buildImagesResult(context, l10n);
    }
  }

  Widget _buildVideoResult(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.video?.url != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (result.video!.thumbnail != null &&
                          result.video!.thumbnail!.isNotEmpty)
                        Image.network(
                          result.video!.thumbnail!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[900],
                            child: const Icon(
                              Icons.videocam,
                              size: 64,
                              color: Colors.white54,
                            ),
                          ),
                        )
                      else
                        Container(
                          color: Colors.grey[900],
                          child: const Icon(
                            Icons.videocam,
                            size: 64,
                            color: Colors.white54,
                          ),
                        ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'VIDEO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Instagram Video',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => onDownloadVideo(result.video!.url),
                icon: const Icon(Icons.download),
                label: Text(l10n.downloadVideo),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesResult(BuildContext context, AppLocalizations l10n) {
    final scraper = InstagramScraper();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instagram Images',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text('${result.images?.length ?? 0} images found'),
            const SizedBox(height: 16),
            ...List.generate(result.images?.length ?? 0, (index) {
              final image = result.images![index];
              final bestQuality = scraper.getBestImageQuality(image);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: bestQuality != null
                            ? Image.network(
                                bestQuality.url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image, size: 40),
                                ),
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 40),
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
                            onPressed: bestQuality != null
                                ? () => onDownloadSingleImage(
                                      bestQuality.url,
                                      index,
                                    )
                                : null,
                            icon: const Icon(Icons.download, size: 18),
                            label: Text(l10n.download),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: result.images != null
                    ? () => onDownloadAllImages(result.images!)
                    : null,
                icon: const Icon(Icons.download_for_offline),
                label: Text(l10n.downloadAllImages),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

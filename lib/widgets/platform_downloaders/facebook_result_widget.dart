import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/facebook_result.dart';

class FacebookResultWidget extends StatelessWidget {
  final FacebookResult result;
  final Function(String) onDownloadVideo;

  const FacebookResultWidget({
    super.key,
    required this.result,
    required this.onDownloadVideo,
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
            Text(
              l10n.selectQuality,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...result.mp4
                .where((v) => v.type == 'direct' && v.url != null)
                .map((quality) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => onDownloadVideo(quality.url!),
                          child: Text(quality.quality),
                        ),
                      ),
                    )),
          ],
        ),
      ),
    );
  }
}

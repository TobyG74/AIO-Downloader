import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/tiktok_result.dart';

class TikTokResultWidget extends StatefulWidget {
  final TikTokResult result;
  final Function(String qualityType) onDownloadVideo;
  final VoidCallback onDownloadImages;
  final VoidCallback? onDownloadAudio;
  
  const TikTokResultWidget({
    super.key,
    required this.result,
    required this.onDownloadVideo,
    required this.onDownloadImages,
    this.onDownloadAudio,
  });

  @override
  State<TikTokResultWidget> createState() => _TikTokResultWidgetState();
}

class _TikTokResultWidgetState extends State<TikTokResultWidget> {
  String _selectedQuality = 'sd'; // Default: SD (No Watermark)

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  List<Map<String, String>> _getAvailableQualities() {
    final qualities = <Map<String, String>>[];
    
    // SD (No Watermark) - always available if videoUrl exists
    if (widget.result.videoUrl.isNotEmpty) {
      qualities.add({'type': 'sd', 'label': 'SD (No Watermark)'});
    }
    
    // HD Quality
    if (widget.result.videoUrlHD.isNotEmpty) {
      qualities.add({'type': 'hd', 'label': 'HD Quality'});
    }
    
    // With Watermark
    if (widget.result.videoUrlWatermark.isNotEmpty) {
      qualities.add({'type': 'watermark', 'label': 'With Watermark'});
    }
    
    return qualities;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final availableQualities = _getAvailableQualities();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.result.cover.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.result.cover,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            if (widget.result.title.isNotEmpty) ...[
              Text(
                widget.result.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
            ],
            if (widget.result.authorName.isNotEmpty)
              Text('Author: ${widget.result.authorName}'),
            if (widget.result.diggCount > 0 ||
                widget.result.commentCount > 0 ||
                widget.result.shareCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                  '❤️ ${_formatCount(widget.result.diggCount)} • 💬 ${_formatCount(widget.result.commentCount)} • 🔄 ${_formatCount(widget.result.shareCount)}'),
            ],
            const SizedBox(height: 16),
            
            // Video download section with quality selection
            if (widget.result.images.isEmpty && availableQualities.isNotEmpty) ...[
              Text(
                'Select Quality:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: availableQualities.map((quality) {
                  return ChoiceChip(
                    label: Text(quality['label']!),
                    selected: _selectedQuality == quality['type'],
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedQuality = quality['type']!;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => widget.onDownloadVideo(_selectedQuality),
                  icon: const Icon(Icons.download),
                  label: Text('Download Video'),
                ),
              ),
              
              // Audio download button
              if (widget.result.music.isNotEmpty && widget.onDownloadAudio != null) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: widget.onDownloadAudio,
                    icon: const Icon(Icons.audiotrack),
                    label: Text('Download Audio (MP3)'),
                  ),
                ),
              ],
            ]
            // Image download section for slide posts
            else if (widget.result.images.isNotEmpty) ...[
              Text(l10n.imageCount(widget.result.images.length)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onDownloadImages,
                  icon: const Icon(Icons.download),
                  label: Text(l10n.downloadAllImages),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/douyin_result.dart';

class DouyinResultWidget extends StatefulWidget {
  final DouyinResult result;
  final Function(int qualityIndex) onDownloadVideo;
  final VoidCallback onDownloadMusic;

  const DouyinResultWidget({
    super.key,
    required this.result,
    required this.onDownloadVideo,
    required this.onDownloadMusic,
  });

  @override
  State<DouyinResultWidget> createState() => _DouyinResultWidgetState();
}

class _DouyinResultWidgetState extends State<DouyinResultWidget> {
  int _selectedQuality = 0;

  @override
  void initState() {
    super.initState();
    // Select highest quality by default
    if (widget.result.video.videoDetail.qualities.isNotEmpty) {
      _selectedQuality = 0;
    }
  }

  String _formatDuration(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final video = widget.result.video;
    final stats = video.statistics;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Cover
            if (video.coverUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  video.coverUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.video_library, size: 64),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),

            // Description
            if (video.description.isNotEmpty) ...[
              Text(
                video.description,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],

            // Author Info
            Row(
              children: [
                if (video.author.avatarUrl.isNotEmpty)
                  CircleAvatar(
                    backgroundImage: NetworkImage(video.author.avatarUrl),
                    radius: 20,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.author.nickname,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (video.author.uniqueId.isNotEmpty)
                        Text(
                          '@${video.author.uniqueId}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.favorite,
                  stats.diggCountFormatted,
                  Colors.red,
                ),
                _buildStatItem(
                  Icons.comment,
                  stats.commentCountFormatted,
                  Colors.blue,
                ),
                _buildStatItem(
                  Icons.share,
                  stats.shareCountFormatted,
                  Colors.green,
                ),
                _buildStatItem(
                  Icons.bookmark,
                  stats.collectCountFormatted,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Video Info
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  Icons.access_time,
                  _formatDuration(video.videoDetail.duration),
                ),
                _buildInfoChip(
                  Icons.calendar_today,
                  _formatDate(video.createTime),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Music Info
            if (video.music.title.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.music_note,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.music.title,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (video.music.author.isNotEmpty)
                            Text(
                              video.music.author,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.download,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: widget.onDownloadMusic,
                      tooltip: l10n.downloadMusic,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Quality Selection
            if (video.videoDetail.qualities.isNotEmpty) ...[
              Text(
                l10n.selectQuality,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: video.videoDetail.qualities
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final quality = entry.value;
                  final isSelected = _selectedQuality == index;
                  
                  return ChoiceChip(
                    label: Text(
                      '${quality.qualityLabel} (${quality.fileSizeMB} MB)',
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedQuality = index;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Download Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => widget.onDownloadVideo(_selectedQuality),
                icon: const Icon(Icons.download),
                label: Text(l10n.downloadVideo),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/youtube_result.dart';

class YouTubeResultWidget extends StatefulWidget {
  final YouTubeResult result;
  final Function(String) onDownloadVideo;
  final Function(String, String) onDownloadAudio;
  final Function(YouTubePlaylistItem) onDownloadPlaylistVideo;
  final bool isDownloading;

  const YouTubeResultWidget({
    super.key,
    required this.result,
    required this.onDownloadVideo,
    required this.onDownloadAudio,
    required this.onDownloadPlaylistVideo,
    required this.isDownloading,
  });

  @override
  State<YouTubeResultWidget> createState() => _YouTubeResultWidgetState();
}

class _YouTubeResultWidgetState extends State<YouTubeResultWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedVideoQuality;
  String? _selectedAudioQuality;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.result.isPlaylist) {
      return _buildPlaylistResult();
    } else {
      return _buildVideoResult();
    }
  }

  Widget _buildVideoResult() {
    final l10n = AppLocalizations.of(context)!;
    final videoFormats = widget.result.videoFormats;
    final audioFormats = widget.result.audioFormats;

    return Column(
      children: [
        // Video Info Card
        Card(
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.result.thumbnail.isNotEmpty)
                Image.network(
                  widget.result.thumbnail,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(Icons.play_circle_outline,
                          size: 64, color: Colors.white54),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.result.title,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    if (widget.result.author.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.result.author,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (widget.result.duration.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            widget.result.duration,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Quality Selection Card
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  onTap: (index) => setState(() {}),
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.video_file),
                      text: l10n.video,
                    ),
                    Tab(
                      icon: const Icon(Icons.audio_file),
                      text: l10n.audio,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Video quality options
                if (_tabController.index == 0) ...[
                  Text(
                    l10n.selectQuality,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: videoFormats.map<Widget>((format) {
                      final isSelected =
                          _selectedVideoQuality == format.downloadUrl;
                      return ChoiceChip(
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              format.quality,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            if (format.size.isNotEmpty)
                              Text(
                                format.size,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? Colors.white70
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                ),
                              ),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedVideoQuality =
                                selected ? format.downloadUrl : null;
                          });
                        },
                        selectedColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          widget.isDownloading || _selectedVideoQuality == null
                              ? null
                              : () => widget.onDownloadVideo(_selectedVideoQuality!),
                      icon: const Icon(Icons.download),
                      label: Text(
                        _selectedVideoQuality == null
                            ? l10n.selectQualityFirst
                            : l10n.downloadMp4,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),
                ],

                // Audio quality options
                if (_tabController.index == 1) ...[
                  Text(
                    l10n.selectAudioQuality,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: audioFormats.map<Widget>((format) {
                      final isSelected =
                          _selectedAudioQuality == format.downloadUrl;
                      return ChoiceChip(
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              format.quality,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            if (format.size.isNotEmpty)
                              Text(
                                format.size,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? Colors.white70
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                ),
                              ),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedAudioQuality =
                                selected ? format.downloadUrl : null;
                          });
                        },
                        selectedColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          widget.isDownloading || _selectedAudioQuality == null
                              ? null
                              : () => widget.onDownloadAudio(
                                    _selectedAudioQuality!,
                                    audioFormats
                                        .firstWhere(
                                          (f) =>
                                              f.downloadUrl ==
                                              _selectedAudioQuality,
                                          orElse: () => audioFormats.first,
                                        )
                                        .format,
                                  ),
                      icon: const Icon(Icons.audio_file),
                      label: Text(
                        _selectedAudioQuality == null
                            ? l10n.selectQualityFirst
                            : l10n.downloadAudio,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistResult() {
    final playlistItems = widget.result.playlistItems ?? [];

    return Column(
      children: [
        // Playlist Info Card
        Card(
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.result.thumbnail.isNotEmpty)
                Image.network(
                  widget.result.thumbnail,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(Icons.playlist_play,
                          size: 64, color: Colors.white54),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.playlist_play,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'PLAYLIST',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.result.title,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${playlistItems.length} video${playlistItems.length > 1 ? "s" : ""}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Videos List
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Videos in Playlist',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: playlistItems.length,
                  separatorBuilder: (_, __) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final item = playlistItems[index];
                    return InkWell(
                      onTap: () => widget.onDownloadPlaylistVideo(item),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                children: [
                                  Image.network(
                                    item.thumbnail,
                                    width: 120,
                                    height: 68,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 120,
                                      height: 68,
                                      color: Colors.grey[800],
                                      child: const Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.white54),
                                    ),
                                  ),
                                  if (item.duration.isNotEmpty)
                                    Positioned(
                                      right: 4,
                                      bottom: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black87,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item.duration,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.index}. ${item.title}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (item.author.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      item.author,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.6),
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Download icon
                            Icon(
                              Icons.download,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/spotify_result.dart';

class SpotifyResultWidget extends StatefulWidget {
  final SpotifyTrack track;
  final Function() onDownloadAudio;
  final Function(SpotifyPlaylistTrack) onDownloadPlaylistTrack;
  final String selectedQuality;
  final Function(String) onQualityChanged;
  final bool isDownloading;

  const SpotifyResultWidget({
    super.key,
    required this.track,
    required this.onDownloadAudio,
    required this.onDownloadPlaylistTrack,
    required this.selectedQuality,
    required this.onQualityChanged,
    required this.isDownloading,
  });

  @override
  State<SpotifyResultWidget> createState() => _SpotifyResultWidgetState();
}

class _SpotifyResultWidgetState extends State<SpotifyResultWidget> {
  static const _spotifyQualities = [
    {'quality': '320', 'label': '320 kbps'},
    {'quality': '256', 'label': '256 kbps'},
    {'quality': '128', 'label': '128 kbps'},
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.track.isPlaylist) {
      return _buildPlaylistResult();
    } else {
      return _buildTrackResult();
    }
  }

  Widget _buildTrackResult() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Track Info
        Card(
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover art
              if (widget.track.coverUrl.isNotEmpty)
                Image.network(
                  widget.track.coverUrl,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    color: const Color(0xFF1DB954).withOpacity(0.15),
                    child: const Center(
                      child: Icon(Icons.music_note_rounded,
                          size: 72, color: Color(0xFF1DB954)),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.track.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (widget.track.artist.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.track.artist,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF1DB954),
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                    if (widget.track.album.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.track.album,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey[500]),
                      ),
                    ],
                    if (widget.track.durationFormatted.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 13, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            widget.track.durationFormatted,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500]),
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

        // Quality selection & download button
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.selectAudioQuality,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _spotifyQualities
                      .map((q) => ChoiceChip(
                            label: Text(q['label']!),
                            selected: widget.selectedQuality == q['quality'],
                            selectedColor: const Color(0xFF1DB954),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: widget.selectedQuality == q['quality']
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                widget.onQualityChanged(q['quality']!);
                              }
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1DB954),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(14),
                    ),
                    onPressed: widget.isDownloading ||
                            widget.track.youtubeVideoId == null
                        ? null
                        : widget.onDownloadAudio,
                    icon: widget.isDownloading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.download_rounded),
                    label: Text(
                      widget.isDownloading
                          ? l10n.downloading
                          : l10n.downloadAudio,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistResult() {
    final tracks = widget.track.playlistTracks ?? [];

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
              if (widget.track.coverUrl.isNotEmpty)
                Image.network(
                  widget.track.coverUrl,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    color: const Color(0xFF1DB954).withOpacity(0.15),
                    child: const Center(
                      child: Icon(Icons.queue_music,
                          size: 72, color: Color(0xFF1DB954)),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.playlist_play,
                            size: 20, color: Color(0xFF1DB954)),
                        SizedBox(width: 8),
                        Text(
                          'SPOTIFY PLAYLIST',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1DB954),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.track.title,
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    if (widget.track.artist.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'By ${widget.track.artist}',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF1DB954),
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      '${tracks.length} track${tracks.length > 1 ? "s" : ""}',
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

        // Tracks List
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tracks in Playlist',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tracks.length,
                  separatorBuilder: (_, __) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    return InkWell(
                      onTap: () => widget.onDownloadPlaylistTrack(track),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cover art
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: track.coverUrl.isNotEmpty
                                  ? Image.network(
                                      track.coverUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 60,
                                        height: 60,
                                        color: const Color(0xFF1DB954)
                                            .withOpacity(0.2),
                                        child: const Icon(Icons.music_note,
                                            color: Color(0xFF1DB954), size: 30),
                                      ),
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      color: const Color(0xFF1DB954)
                                          .withOpacity(0.2),
                                      child: const Icon(Icons.music_note,
                                          color: Color(0xFF1DB954), size: 30),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${track.index}. ${track.title}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (track.artist.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      track.artist,
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
                                  if (track.durationFormatted.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      track.durationFormatted,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.5),
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Download icon
                            const Icon(
                              Icons.download,
                              color: Color(0xFF1DB954),
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

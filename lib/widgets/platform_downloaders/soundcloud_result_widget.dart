import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/soundcloud_result.dart';

class SoundCloudResultWidget extends StatelessWidget {
  final SoundCloudResult result;
  final Function(SoundCloudTrack) onDownloadTrack;
  final bool isDownloading;

  const SoundCloudResultWidget({
    super.key,
    required this.result,
    required this.onDownloadTrack,
    required this.isDownloading,
  });

  @override
  Widget build(BuildContext context) {
    if (result.isSingle) {
      return _buildSingleTrack(context);
    } else {
      return _buildPlaylist(context);
    }
  }

  Widget _buildSingleTrack(BuildContext context) {
    final track = result.singleTrack!;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Track Info Card
        Card(
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover art
              if (track.cover.isNotEmpty)
                Image.network(
                  track.cover,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    color: const Color(0xFFFF5500).withOpacity(0.15),
                    child: const Center(
                      child: Icon(Icons.cloud_rounded,
                          size: 72, color: Color(0xFFFF5500)),
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
                      track.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    // Artist
                    Text(
                      track.artist,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Download Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isDownloading ? null : () => onDownloadTrack(track),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5500),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.download_rounded),
            label: Text(
              isDownloading ? l10n.downloading : l10n.downloadAudio,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylist(BuildContext context) {
    final playlist = result.playlist!;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Playlist Header Card
        Card(
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First track cover as playlist cover
              if (playlist.tracks.isNotEmpty &&
                  playlist.tracks.first.cover.isNotEmpty)
                Image.network(
                  playlist.tracks.first.cover,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    color: const Color(0xFFFF5500).withOpacity(0.15),
                    child: const Center(
                      child: Icon(Icons.queue_music_rounded,
                          size: 72, color: Color(0xFFFF5500)),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Playlist badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5500),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        l10n.playlist.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Playlist title
                    Text(
                      playlist.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    // Playlist artist
                    Text(
                      playlist.artist,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 10),
                    // Track count
                    Row(
                      children: [
                        const Icon(Icons.audiotrack, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${playlist.trackCount} ${playlist.trackCount > 1 ? l10n.tracks : l10n.track}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Track List
        Text(
          l10n.tracks,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...playlist.tracks.asMap().entries.map((entry) {
          final index = entry.key;
          final track = entry.value;
          return _buildTrackItem(context, track, index + 1);
        }),
      ],
    );
  }

  Widget _buildTrackItem(BuildContext context, SoundCloudTrack track, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: isDownloading ? null : () => onDownloadTrack(track),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Track number or thumbnail
              if (track.cover.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    track.cover,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 50,
                      height: 50,
                      color: const Color(0xFFFF5500).withOpacity(0.15),
                      child: Center(
                        child: Text(
                          '$index',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF5500),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5500).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF5500),
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              // Track info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track.artist,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Download icon
              Icon(
                Icons.download_rounded,
                color: isDownloading
                    ? Colors.grey[400]
                    : const Color(0xFFFF5500),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

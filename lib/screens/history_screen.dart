import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../l10n/app_localizations.dart';
import '../models/download_history.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  List<DownloadHistory> _history = [];
  String _filter = 'all';
  String _platformFilter = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    List<DownloadHistory> history;

    if (_filter != 'all') {
      history = await _historyService.getHistoryByType(_filter);
    } else {
      history = await _historyService.getHistory();
    }

    if (_platformFilter != 'all') {
      history = history
          .where((item) => item.platform.toLowerCase() == _platformFilter)
          .toList();
    }

    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  Future<void> _deleteItem(String id) async {
    final l10n = AppLocalizations.of(context)!;
    await _historyService.deleteHistory(id);
    _loadHistory();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.deleteItem)),
      );
    }
  }

  Future<void> _clearAll() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeleteAll),
        content: Text(l10n.cannotUndo),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteBtn, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _historyService.clearAllHistory();
      _loadHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.allDeleted)),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.history),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAll,
              tooltip: l10n.clearAll,
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter section
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.5),
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type filter row
                Row(
                  children: [
                    Text(
                      l10n.typeFilter,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                            letterSpacing: 0.8,
                          ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildTypeChip(l10n.all, 'all', Icons.apps),
                            const SizedBox(width: 6),
                            _buildTypeChip(l10n.video, 'video', Icons.videocam),
                            const SizedBox(width: 6),
                            _buildTypeChip(l10n.image, 'image', Icons.image),
                            const SizedBox(width: 6),
                            _buildTypeChip(l10n.audio, 'audio', Icons.music_note_rounded),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Platform filter row
                Row(
                  children: [
                    Text(
                      l10n.platformFilter,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                            letterSpacing: 0.8,
                          ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildPlatformChip(l10n.all, 'all'),
                            const SizedBox(width: 6),
                            _buildPlatformChip('TikTok', 'tiktok'),
                            const SizedBox(width: 6),
                            _buildPlatformChip('YouTube', 'youtube'),
                            const SizedBox(width: 6),
                            _buildPlatformChip('Instagram', 'instagram'),
                            const SizedBox(width: 6),
                            _buildPlatformChip('Facebook', 'facebook'),
                            const SizedBox(width: 6),
                            _buildPlatformChip('Twitter', 'twitter'),
                            const SizedBox(width: 6),
                            _buildPlatformChip('Threads', 'threads'),
                            const SizedBox(width: 6),
                            _buildPlatformChip('Spotify', 'spotify'),
                            const SizedBox(width: 6),
                            _buildPlatformChip('Pinterest', 'pinterest'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Result count
                if (!_isLoading) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.itemsFound(_history.length),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

          // History list or empty state
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 72,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noDownloads,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.noDownloadsDesc,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadHistory,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            final item = _history[index];
                            return Dismissible(
                              key: Key(item.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.delete, color: Colors.white),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.deleteBtn,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onDismissed: (_) => _deleteItem(item.id),
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Theme.of(context)
                                        .dividerColor
                                        .withOpacity(0.4),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: item.thumbnailUrl.isNotEmpty
                                        ? Image.network(
                                            item.thumbnailUrl,
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                            headers: const {
                                              'User-Agent':
                                                  'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/124.0.0.0 Mobile Safari/537.36',
                                              'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
                                              'Accept-Language': 'en-US,en;q=0.9',
                                            },
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Container(
                                                width: 56,
                                                height: 56,
                                                color: Theme.of(context).colorScheme.surfaceVariant,
                                                child: Center(
                                                  child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      value: loadingProgress.expectedTotalBytes != null
                                                          ? loadingProgress.cumulativeBytesLoaded / 
                                                            loadingProgress.expectedTotalBytes!
                                                          : null,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder: (_, __, ___) =>
                                                _placeholderIcon(
                                                    context, item.downloadType),
                                          )
                                        : _placeholderIcon(
                                            context, item.downloadType),
                                  ),
                                  title: Text(
                                    item.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            // Platform badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 7,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primaryContainer,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  FaIcon(
                                                    _platformFaIcon(item.platform),
                                                    size: 10,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryContainer,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    item.platform,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimaryContainer,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            // Type badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 7,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondaryContainer,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    item.downloadType == 'video'
                                                        ? Icons.videocam_rounded
                                                        : item.downloadType == 'audio'
                                                            ? Icons.music_note_rounded
                                                            : Icons.image_rounded,
                                                    size: 10,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSecondaryContainer,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    item.downloadType,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSecondaryContainer,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatDate(item.downloadDate),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                    ),
                                    onPressed: () => _deleteItem(item.id),
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  /// Placeholder icon widget for missing thumbnail
  Widget _placeholderIcon(BuildContext context, String type) {
    return Container(
      width: 56,
      height: 56,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Icon(
        type == 'video'
            ? Icons.videocam_rounded
            : type == 'audio'
                ? Icons.music_note_rounded
                : Icons.image_rounded,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  /// Build type filter chip (Semua / Video / Gambar)
  Widget _buildTypeChip(String label, String value, IconData icon) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _filter = value);
        _loadHistory();
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        color: isSelected ? Theme.of(context).colorScheme.onPrimary : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }

  /// Returns FontAwesome icon for platform name
  IconData _platformFaIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'tiktok':
        return FontAwesomeIcons.tiktok;
      case 'youtube':
        return FontAwesomeIcons.youtube;
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'facebook':
        return FontAwesomeIcons.facebookF;
      case 'twitter':
      case 'x':
        return FontAwesomeIcons.xTwitter;
      case 'threads':
        return FontAwesomeIcons.threads;
      case 'spotify':
        return FontAwesomeIcons.spotify;
      case 'pinterest':
        return FontAwesomeIcons.pinterest;
      default:
        return FontAwesomeIcons.link;
    }
  }

  /// Build platform filter chip with FA icon
  Widget _buildPlatformChip(String label, String value) {
    final isSelected = _platformFilter == value;
    final chipColor = isSelected
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    final Map<String, IconData> icons = {
      'tiktok': FontAwesomeIcons.tiktok,
      'youtube': FontAwesomeIcons.youtube,
      'instagram': FontAwesomeIcons.instagram,
      'facebook': FontAwesomeIcons.facebookF,
      'twitter': FontAwesomeIcons.xTwitter,
      'threads': FontAwesomeIcons.threads,
      'spotify': FontAwesomeIcons.spotify,
      'pinterest': FontAwesomeIcons.pinterest,
    };

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != 'all') ...[
            FaIcon(
              icons[value] ?? FontAwesomeIcons.globe,
              size: 11,
              color: chipColor,
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color:
                  isSelected ? Theme.of(context).colorScheme.onPrimary : null,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _platformFilter = value);
        _loadHistory();
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }
}

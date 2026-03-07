import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/whatsapp_status.dart';
import '../services/whatsapp_status_service.dart';

class WhatsAppStatusScreen extends StatefulWidget {
  const WhatsAppStatusScreen({super.key});

  @override
  State<WhatsAppStatusScreen> createState() => _WhatsAppStatusScreenState();
}

class _WhatsAppStatusScreenState extends State<WhatsAppStatusScreen> {
  final WhatsAppStatusService _service = WhatsAppStatusService();

  List<WhatsAppStatus> _statuses = [];
  bool _isLoading = true;
  bool _hasPermission = false;
  String? _errorMessage;
  String? _statusDir;

  // Track which items are being saved
  final Set<String> _saving = {};
  bool _savingAll = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _initialize();
    }
  }

  Future<void> _initialize() async {
    final l10n = AppLocalizations.of(context)!;
    if (Platform.isIOS) {
      setState(() {
        _isLoading = false;
        _hasPermission = false;
        _errorMessage = l10n.iosNotAvailable;
      });
      return;
    }
    await _checkAndRequest();
  }

  Future<void> _checkAndRequest() async {
    setState(() => _isLoading = true);
    final granted = await _service.checkPermissions();
    if (granted) {
      await _loadStatuses();
    } else {
      setState(() {
        _isLoading = false;
        _hasPermission = false;
        _errorMessage = null;
      });
    }
  }

  Future<void> _requestPermission() async {
    final l10n = AppLocalizations.of(context)!;
    final granted = await _service.requestPermissions();
    if (granted) {
      await _loadStatuses();
    } else {
      setState(() {
        _hasPermission = false;
        _errorMessage = l10n.permissionDenied;
      });
    }
  }

  Future<void> _loadStatuses() async {
    setState(() {
      _isLoading = true;
      _hasPermission = true;
      _errorMessage = null;
    });

    try {
      final dir = await _service.findStatusDirectory();
      final statuses = await _service.getStatuses();
      setState(() {
        _statusDir = dir;
        _statuses = statuses;
        _isLoading = false;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _isLoading = false;
        _errorMessage = l10n.failedToReadStatus(e);
      });
    }
  }

  Future<void> _saveStatus(WhatsAppStatus status) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving.add(status.filePath));
    try {
      await _service.saveStatus(status);
      _showToast(l10n.savedToGallery);
    } catch (e) {
      _showToast(l10n.failedToSave(e.toString()));
    } finally {
      setState(() => _saving.remove(status.filePath));
    }
  }

  Future<void> _saveAll() async {
    if (_statuses.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _savingAll = true);
    try {
      final count = await _service.saveAllStatuses(_statuses);
      _showToast(l10n.savedCount(count));
    } catch (e) {
      _showToast(l10n.failedToSave(e.toString()));
    } finally {
      setState(() => _savingAll = false);
    }
  }

  void _showToast(String msg) {
    Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_SHORT);
  }

  void _openPreview(WhatsAppStatus status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _StatusPreviewScreen(status: status, onSave: _saveStatus),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.whatsappStatus),
        backgroundColor: const Color(0xFF25D366),
        foregroundColor: Colors.white,
        actions: [
          if (_hasPermission && _statuses.isNotEmpty)
            IconButton(
              icon: _savingAll
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.save_alt),
              tooltip: l10n.saveAll,
              onPressed: _savingAll ? null : _saveAll,
            ),
          if (_hasPermission)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: _loadStatuses,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF25D366)),
            const SizedBox(height: 16),
            Text(l10n.loadingStatuses),
          ],
        ),
      );
    }

    if (Platform.isIOS) {
      return _buildIosMessage();
    }

    if (!_hasPermission) {
      return _buildPermissionRequest();
    }

    if (_errorMessage != null) {
      return _buildError(_errorMessage!);
    }

    if (_statuses.isEmpty) {
      return _buildEmpty();
    }

    return _buildGrid();
  }

  Widget _buildIosMessage() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone_iphone, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.notAvailableIOS,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRequest() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open, size: 64, color: Color(0xFF25D366)),
            const SizedBox(height: 16),
            Text(
              l10n.permissionRequired,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.permissionRequiredDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _requestPermission,
              icon: const Icon(Icons.security),
              label: Text(l10n.grantPermission),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(l10n.errorOccurred, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadStatuses,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retryButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.noStatusTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _statusDir != null
                  ? l10n.noStatusFoundIn(_statusDir!)
                  : l10n.whatsappNotFound,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadStatuses,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retryButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final l10n = AppLocalizations.of(context)!;
    final images = _statuses.where((s) => s.isImage).toList();
    final videos = _statuses.where((s) => s.isVideo).toList();

    return CustomScrollView(
      slivers: [
        // Stats bar
        SliverToBoxAdapter(
          child: Container(
            color: const Color(0xFF25D366).withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.image, size: 18, color: Color(0xFF25D366)),
                const SizedBox(width: 4),
                Text('${images.length} photos', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 16),
                const Icon(Icons.videocam, size: 18, color: Color(0xFF25D366)),
                const SizedBox(width: 4),
                Text('${videos.length} videos', style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(
                  'Total: ${_statuses.length}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),

        if (images.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(l10n.photoLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _buildImageTile(images[i]),
                childCount: images.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
            ),
          ),
        ],

        if (videos.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(l10n.video, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _buildVideoTile(videos[i]),
                childCount: videos.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildImageTile(WhatsAppStatus status) {
    final isSaving = _saving.contains(status.filePath);
    return GestureDetector(
      onTap: () => _openPreview(status),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(status.filePath), fit: BoxFit.cover),
          Positioned(
            right: 4,
            bottom: 4,
            child: _saveButton(status, isSaving),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoTile(WhatsAppStatus status) {
    final isSaving = _saving.contains(status.filePath);
    
    return GestureDetector(
      onTap: () => _openPreview(status),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video thumbnail with key to prevent rebuild issues
          _VideoThumbnailWidget(
            key: ValueKey(status.filePath),
            videoPath: status.filePath,
          ),
          
          // Play icon overlay
          Center(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black38,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          
          // File size badge
          Positioned(
            left: 4,
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status.fileSizeFormatted,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
          
          // Save button
          Positioned(
            right: 4,
            bottom: 4,
            child: _saveButton(status, isSaving),
          ),
        ],
      ),
    );
  }

  Widget _saveButton(WhatsAppStatus status, bool isSaving) {
    return GestureDetector(
      onTap: isSaving ? null : () => _saveStatus(status),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Color(0xFF25D366),
          shape: BoxShape.circle,
        ),
        child: isSaving
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.save_alt, color: Colors.white, size: 14),
      ),
    );
  }
}

// VIDEO THUMBNAIL WIDGET
class _VideoThumbnailWidget extends StatefulWidget {
  final String videoPath;

  const _VideoThumbnailWidget({super.key, required this.videoPath});

  @override
  State<_VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<_VideoThumbnailWidget> {
  String? _thumbnailPath;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: widget.videoPath,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 300,
        quality: 75,
      );

      if (mounted) {
        setState(() {
          _thumbnailPath = thumbnail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.black87,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF25D366)),
            ),
          ),
        ),
      );
    }

    if (_thumbnailPath != null && !_hasError) {
      return Image.file(
        File(_thumbnailPath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.black87,
      child: const Center(
        child: Icon(Icons.videocam, color: Colors.white, size: 36),
      ),
    );
  }
}

// PREVIEW SCREEN
class _StatusPreviewScreen extends StatelessWidget {
  final WhatsAppStatus status;
  final Future<void> Function(WhatsAppStatus) onSave;

  const _StatusPreviewScreen({required this.status, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          status.isVideo ? l10n.previewVideo : l10n.previewPhoto,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt, color: Colors.white),
            tooltip: l10n.saveBtn,
            onPressed: () async {
              await onSave(status);
            },
          ),
        ],
      ),
      body: Center(
        child: status.isImage
            ? InteractiveViewer(
                child: Image.file(File(status.filePath), fit: BoxFit.contain),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam, color: Colors.white, size: 80),
                  const SizedBox(height: 16),
                  Text(
                    status.fileName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    status.fileSizeFormatted,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await onSave(status);
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.save_alt),
                    label: Text(l10n.saveToGallery),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

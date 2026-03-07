import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../l10n/app_localizations.dart';
import '../services/download_service.dart';
import '../services/scrapers/youtube_scraper.dart';
import '../services/scrapers/instagram_scraper.dart';
import '../services/scrapers/soundcloud_scraper.dart';
import '../services/scrapers/douyin_scraper.dart';
import '../services/id3_tagger.dart';
import '../models/tiktok_result.dart';
import '../models/youtube_result.dart';
import '../models/pinterest_result.dart';
import '../models/spotify_result.dart';
import '../models/soundcloud_result.dart';
import '../models/douyin_result.dart';
import '../models/instagram_result.dart';
import '../models/facebook_result.dart';
import '../models/twitter_result.dart';
import '../models/threads_result.dart';
import '../models/bilibili_result.dart';
import '../services/scrapers/bilibili_scraper.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min/return_code.dart';

/// Helper class untuk menangani download actions dari berbagai platform
class PlatformDownloadHandler {
  final DownloadService downloadService;
  final BuildContext context;
  final Function(bool) setDownloading;
  final Function(double?) setProgress;
  final Function(String) showToast;

  PlatformDownloadHandler({
    required this.downloadService,
    required this.context,
    required this.setDownloading,
    required this.setProgress,
    required this.showToast,
  });

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  // TikTok Downloads
  Future<void> downloadTikTokVideo(TikTokResult result, String inputUrl, String qualityType) async {
    setDownloading(true);
    setProgress(null);

    try {
      // Select URL based on quality type
      String videoUrl;
      String qualityLabel;
      
      switch (qualityType) {
        case 'hd':
          videoUrl = result.videoUrlHD;
          qualityLabel = 'HD';
          break;
        case 'watermark':
          videoUrl = result.videoUrlWatermark;
          qualityLabel = 'Watermark';
          break;
        case 'sd':
        default:
          videoUrl = result.videoUrl;
          qualityLabel = 'SD';
          break;
      }
      
      if (videoUrl.isEmpty) {
        throw Exception('Video URL not available for selected quality');
      }
      
      final filename = 'tiktok_${qualityLabel}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      await downloadService.downloadVideo(
        url: videoUrl,
        filename: filename,
        platform: 'TikTok',
        title: result.title,
        thumbnailUrl: result.cover,
        originalUrl: inputUrl,
        onProgress: (received, total) {
          setProgress(total > 0 ? received / total : null);
        },
      );

      setDownloading(false);
      showToast(l10n.downloadSuccess);
    } catch (e) {
      setDownloading(false);
      showToast(l10n.downloadFailed(e.toString()));
    }
  }

  Future<void> downloadTikTokAudio(TikTokResult result, String inputUrl) async {
    setDownloading(true);
    setProgress(null);

    try {
      if (result.music.isEmpty) {
        throw Exception('Audio URL not available');
      }
      
      final filename = 'tiktok_audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
      await downloadService.downloadVideo(
        url: result.music,
        filename: filename,
        platform: 'TikTok',
        title: result.title,
        thumbnailUrl: result.cover,
        originalUrl: inputUrl,
        onProgress: (received, total) {
          setProgress(total > 0 ? received / total : null);
        },
      );

      setDownloading(false);
      showToast(l10n.downloadSuccess);
    } catch (e) {
      setDownloading(false);
      showToast(l10n.downloadFailed(e.toString()));
    }
  }

  Future<void> downloadTikTokImages(TikTokResult result, String inputUrl) async {
    setDownloading(true);
    setProgress(null);

    try {
      await downloadService.downloadMultipleImages(
        urls: result.images,
        filenamePrefix: 'tiktok_${DateTime.now().millisecondsSinceEpoch}',
        platform: 'TikTok',
        title: result.title,
        thumbnailUrl: result.images.isNotEmpty ? result.images.first : '',
        originalUrl: inputUrl,
        onProgress: (current, total) {
          setProgress(current / total);
        },
      );

      setDownloading(false);
      showToast(l10n.downloadAllSuccess);
    } catch (e) {
      setDownloading(false);
      showToast(l10n.downloadFailed(e.toString()));
    }
  }

  // YouTube Downloads
  Future<void> downloadYouTubeVideo(
    YouTubeResult result,
    String inputUrl,
    String qualityStr,
  ) async {
    setDownloading(true);
    setProgress(null);

    try {
      final videoId = result.videoId;
      final scraper = YouTubeScraper();
      final dlResult = await scraper.getVideoDownloadUrl(videoId, qualityStr);

      final filename = 'youtube_${DateTime.now().millisecondsSinceEpoch}.mp4';
      await downloadService.downloadVideo(
        url: dlResult.url,
        filename: filename,
        platform: 'YouTube',
        title: result.title,
        thumbnailUrl: result.thumbnail,
        originalUrl: inputUrl,
        onProgress: (received, total) {
          setProgress(total > 0 ? received / total : null);
        },
      );

      setDownloading(false);
      showToast(l10n.downloadSuccess);
    } catch (e) {
      setDownloading(false);
      showToast(l10n.downloadFailed(e.toString()));
    }
  }

  Future<void> downloadYouTubeAudio(
    YouTubeResult result,
    String inputUrl,
    String qualityStr,
    String format,
  ) async {
    setDownloading(true);
    setProgress(null);

    try {
      final videoId = result.videoId;
      final scraper = YouTubeScraper();
      final dlResult = await scraper.getAudioDownloadUrl(videoId, qualityStr);

      String ext = 'mp3';
      if (format == 'm4a') ext = 'm4a';
      if (format == 'opus') ext = 'opus';

      final filename = 'youtube_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final savedPath = await downloadService.downloadAudio(
        url: dlResult.url,
        filename: filename,
        platform: 'YouTube',
        title: result.title,
        thumbnailUrl: result.thumbnail,
        originalUrl: inputUrl,
        onProgress: (received, total) {
          setProgress(total > 0 ? received / total : null);
        },
      );

      setDownloading(false);
      showToast('${l10n.downloadSuccess}\n$savedPath');
    } catch (e) {
      setDownloading(false);
      showToast(l10n.downloadFailed(e.toString()));
    }
  }

  Future<void> downloadPlaylistVideo(
    YouTubePlaylistItem item,
    String qualityStr,
  ) async {
    setDownloading(true);
    setProgress(null);

    try {
      final scraper = YouTubeScraper();
      final dlResult = await scraper.getVideoDownloadUrl(item.videoId, qualityStr);

      final filename = 'youtube_${DateTime.now().millisecondsSinceEpoch}.mp4';
      await downloadService.downloadVideo(
        url: dlResult.url,
        filename: filename,
        platform: 'YouTube',
        title: item.title,
        thumbnailUrl: item.thumbnail,
        originalUrl: 'https://www.youtube.com/watch?v=${item.videoId}',
        onProgress: (received, total) {
          setProgress(total > 0 ? received / total : null);
        },
      );

      setDownloading(false);
      showToast(l10n.downloadSuccess);
    } catch (e) {
      setDownloading(false);
      showToast(l10n.downloadFailed(e.toString()));
    }
  }

  // Pinterest  Downloads
  Future<void> downloadPinterestItem(
    PinterestDownloadItem item,
    PinterestResult result,
    String inputUrl,
  ) async {
    setDownloading(true);
    setProgress(null);

    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final isVideo = item.type == 'video';
      final isGif = item.url.toLowerCase().endsWith('.gif');

      if (isVideo) {
        final filename = 'pinterest_$ts.mp4';
        await downloadService.downloadVideo(
          url: item.url,
          filename: filename,
          platform: 'Pinterest',
          title: result.title,
          thumbnailUrl: result.thumbnailUrl,
          originalUrl: inputUrl,
          onProgress: (received, total) {
            setProgress(total > 0 ? received / total : null);
          },
        );
        showToast(l10n.downloadSuccess);
      } else {
        final ext = isGif ? 'gif' : 'jpg';
        final filename = 'pinterest_$ts.$ext';
        await downloadService.downloadImage(
          url: item.url,
          filename: filename,
          platform: 'Pinterest',
          title: result.title,
          thumbnailUrl: result.thumbnailUrl,
          originalUrl: inputUrl,
          onProgress: (received, total) {
            setProgress(total > 0 ? received / total : null);
          },
        );
        showToast(l10n.downloadSuccess);
      }
    } catch (e) {
      showToast(l10n.downloadFailed(e.toString()));
    } finally {
      setDownloading(false);
    }
  }

  // Spotify Downloads
  Future<void> downloadSpotifyAudio(
    SpotifyTrack result,
    String inputUrl,
    String quality,
  ) async {
    setDownloading(true);
    setProgress(null);

    try {
      // We need to get audio URL from YouTube since Spotify doesn't provide direct download
      // This should use the youtubeVideoId from result to get download URL
      if (result.youtubeVideoId == null) {
        throw Exception('YouTube video ID not found');
      }

      final scraper = YouTubeScraper();
      final dlResult = await scraper.getAudioDownloadUrl(result.youtubeVideoId!, quality);

      final filename = 'spotify_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final tempPath = await downloadService.downloadAudio(
        url: dlResult.url,
        filename: filename,
        platform: 'Spotify',
        title: result.title,
        thumbnailUrl: result.coverUrl,
        originalUrl: inputUrl,
        onProgress: (received, total) {
          setProgress(total > 0 ? received / total : null);
        },
      );

      // Add ID3 tags if available
      if (result.title.isNotEmpty) {
        await Id3Tagger.embedTags(
          filePath: tempPath,
          title: result.title,
          artist: result.artist,
          album: result.album,
          coverUrl: result.coverUrl,
        );
      }

      setDownloading(false);
      showToast('${l10n.downloadSuccess}\n$tempPath');
    } catch (e) {
      setDownloading(false);
      showToast(l10n.downloadFailed(e.toString()));
    }
  }

  Future<void> downloadSpotifyPlaylistTrack(
    SpotifyPlaylistTrack track,
    String youtubeVideoId,
    String quality,
  ) async {
    setDownloading(true);
    setProgress(null);

    try {
      final scraper = YouTubeScraper();
      final dlResult = await scraper.getAudioDownloadUrl(youtubeVideoId, quality);

      final filename = 'spotify_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final savedPath = await downloadService.downloadAudio(
        url: dlResult.url,
        filename: filename,
        platform: 'Spotify',
        title: track.title,
        thumbnailUrl: track.coverUrl,
        originalUrl: 'https://open.spotify.com/track/${track.trackId}',
        onProgress: (received, total) {
          setProgress(total > 0 ? received / total : null);
        },
      );

      // Add ID3 tags
      if (track.title.isNotEmpty) {
        await Id3Tagger.embedTags(
          filePath: savedPath,
          title: track.title,
          artist: track.artist,
          album: track.album,
          coverUrl: track.coverUrl,
        );
      }

      setDownloading(false);
      showToast(l10n.downloadSuccess);
    } catch (e) {
      setDownloading(false);
      showToast(l10n.downloadFailed(e.toString()));
    }
  }

  // Instagram Downloads
  Future<void> downloadInstagramVideo(
    InstagramResult result,
    String inputUrl,
    String videoUrl,
  ) async {
    setDownloading(true);
    setProgress(null);

    try {
      final filename = 'instagram_${DateTime.now().millisecondsSinceEpoch}.mp4';
      await downloadService.downloadVideo(
        url: videoUrl,
        filename: filename,
        platform: 'Instagram',
        title: 'Instagram Video',
        thumbnailUrl: result.video?.thumbnail ?? '',
        originalUrl: inputUrl,
        onProgress: (received, total) {
          setProgress(total > 0 ? received / total : null);
        },
      );

      setDownloading(false);
      showToast(l10n.downloadSuccess);
    } catch (e) {
      setDownloading(false);
      showToast(l10n.downloadFailed(e.toString()));
    }
  }

  Future<void> downloadInstagramSingleImage(
    InstagramResult result,
    String inputUrl,
    String imageUrl,
    int index,
  ) async {
    setDownloading(true);
    setProgress(null);

    try {
      final filename = 'instagram_${DateTime.now().millisecondsSinceEpoch}_$index.jpg';
      await downloadService.downloadImage(
        url: imageUrl,
        filename: filename,
        platform: 'Instagram',
        title: 'Instagram Image $index',
        thumbnailUrl: imageUrl,
        originalUrl: inputUrl,
        onProgress: (received, total) {
          setProgress(total > 0 ? received / total : null);
        },
      );

      setDownloading(false);
      showToast(l10n.downloadSuccess);
    } catch (e) {
      setDownloading(false);
      showToast(l10n.downloadFailed(e.toString()));
    }
  }

  Future<void> downloadInstagramAllImages(
    InstagramResult result,
    String inputUrl,
    List<InstagramImageItem> images,
  ) async {
    setDownloading(true);
    setProgress(null);

    try {
      final scraper = InstagramScraper();
      final urls = images
          .map((img) => scraper.getBestImageQuality(img)?.url)
          .where((url) => url != null)
          .cast<String>()
          .toList();

      await downloadService.downloadMultipleImages(
        urls: urls,
        filenamePrefix: 'instagram_${DateTime.now().millisecondsSinceEpoch}',
        platform: 'Instagram',
        title: 'Instagram Images',
        thumbnailUrl: urls.isNotEmpty ? urls.first : '',
        originalUrl: inputUrl,
        onProgress: (current, total) {
          setProgress(current / total);
        },
      );

      setDownloading(false);
      showToast(l10n.downloadAllSuccess);
    } catch (e) {
      setDownloading(false);
      showToast(l10n.downloadFailed(e.toString()));
    }
  }

  // Facebook Downloads
  Future<void> downloadFacebookVideo(
    FacebookResult result,
    String inputUrl,
    String videoUrl,
  ) async {
    setDownloading(true);
    setProgress(null);

    try {
      final filename = 'facebook_${DateTime.now().millisecondsSinceEpoch}.mp4';
      await downloadService.downloadVideo(
        url: videoUrl,
        filename: filename,
        platform: 'Facebook',
        title: result.title,
        thumbnailUrl: result.thumbnail,
        originalUrl: inputUrl,
        onProgress: (received, total) {
          setProgress(total > 0 ? received / total : null);
        },
      );

      setDownloading(false);
      showToast(l10n.downloadSuccess);
    } catch (e) {
      setDownloading(false);
      showToast(l10n.downloadFailed(e.toString()));
    }
  }

  // Twitter Downloads
  Future<void> downloadTwitterVideo(
    TwitterResult result,
    String inputUrl,
    String videoUrl,
  ) async {
    setDownloading(true);
    setProgress(null);

    try {
      final filename = 'twitter_${DateTime.now().millisecondsSinceEpoch}.mp4';
      await downloadService.downloadVideo(
        url: videoUrl,
        filename: filename,
        platform: 'Twitter',
        title: result.title,
        thumbnailUrl: result.thumbnail,
        originalUrl: inputUrl,
        onProgress: (received, total) {
          setProgress(total > 0 ? received / total : null);
        },
      );

      setDownloading(false);
      showToast(l10n.downloadSuccess);
    } catch (e) {
      setDownloading(false);
      showToast(l10n.downloadFailed(e.toString()));
    }
  }

  Future<void> downloadTwitterImage(
    TwitterResult result,
    String inputUrl,
    String imageUrl,
  ) async {
    setDownloading(true);
    setProgress(null);

    try {
      final filename = 'twitter_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await downloadService.downloadImage(
        url: imageUrl,
        filename: filename,
        platform: 'Twitter',
        title: result.title,
        thumbnailUrl: result.thumbnail,
        originalUrl: inputUrl,
        onProgress: (received, total) {
          setProgress(total > 0 ? received / total : null);
        },
      );

      setDownloading(false);
      showToast(l10n.downloadSuccess);
    } catch (e) {
      setDownloading(false);
      showToast(l10n.downloadFailed(e.toString()));
    }
  }

  Future<void> downloadTwitterAllImages(
    TwitterResult result,
    String inputUrl,
    List<String> images,
  ) async {
    setDownloading(true);
    setProgress(null);

    try {
      await downloadService.downloadMultipleImages(
        urls: images,
        filenamePrefix: 'twitter_${DateTime.now().millisecondsSinceEpoch}',
        platform: 'Twitter',
        title: result.title,
        thumbnailUrl: result.thumbnail,
        originalUrl: inputUrl,
        onProgress: (current, total) {
          setProgress(current / total);
        },
      );

      setDownloading(false);
      showToast(l10n.downloadAllSuccess);
    } catch (e) {
      setDownloading(false);
      showToast(l10n.downloadFailed(e.toString()));
    }
  }

  // Threads Downloads
  Future<void> downloadThreadsVideo(
    ThreadsResult result,
    String inputUrl,
    String videoUrl,
  ) async {
    setDownloading(true);
    setProgress(null);

    try {
      final filename = 'threads_${DateTime.now().millisecondsSinceEpoch}.mp4';
      await downloadService.downloadVideo(
        url: videoUrl,
        filename: filename,
        platform: 'Threads',
        title: 'Threads Video',
        thumbnailUrl: '',
        originalUrl: inputUrl,
        onProgress: (received, total) {
          setProgress(total > 0 ? received / total : null);
        },
      );

      setDownloading(false);
      showToast(l10n.downloadSuccess);
    } catch (e) {
      setDownloading(false);
      showToast(l10n.downloadFailed(e.toString()));
    }
  }

  Future<void> downloadThreadsImage(
    ThreadsResult result,
    String inputUrl,
    String imageUrl,
  ) async {
    setDownloading(true);
    setProgress(null);

    try {
      final filename = 'threads_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await downloadService.downloadImage(
        url: imageUrl,
        filename: filename,
        platform: 'Threads',
        title: 'Threads Image',
        thumbnailUrl: imageUrl,
        originalUrl: inputUrl,
        onProgress: (received, total) {
          setProgress(total > 0 ? received / total : null);
        },
      );

      setDownloading(false);
      showToast(l10n.downloadSuccess);
    } catch (e) {
      setDownloading(false);
      showToast(l10n.downloadFailed(e.toString()));
    }
  }

  // SoundCloud Downloads
  Future<void> downloadSoundCloudTrack(
    SoundCloudTrack track,
    String baseUrl,
    String inputUrl,
    SoundCloudScraper scraper, // Reuse scraper instance with cookies
  ) async {
    setDownloading(true);
    setProgress(null);

    try {
      final downloadUrl = await scraper.getDownloadUrl(track, baseUrl);
      
      if (downloadUrl == null) {
        throw Exception('Failed to get download URL');
      }

      final filename = 'soundcloud_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final savedPath = await downloadService.downloadAudio(
        url: downloadUrl,
        filename: filename,
        platform: 'SoundCloud',
        title: track.name,
        thumbnailUrl: track.cover,
        originalUrl: inputUrl,
        onProgress: (received, total) {
          setProgress(total > 0 ? received / total : null);
        },
      );

      // Add ID3 tags
      if (track.name.isNotEmpty) {
        await Id3Tagger.embedTags(
          filePath: savedPath,
          title: track.name,
          artist: track.artist,
          album: track.albumName ?? '',
          coverUrl: track.cover,
        );
      }

      setDownloading(false);
      showToast(l10n.downloadSuccess);
    } catch (e) {
      setDownloading(false);
      showToast(l10n.downloadFailed(e.toString()));
    }
  }

  // Douyin Downloads
  Future<void> downloadDouyinVideo(
    DouyinVideo video,
    String inputUrl,
    int qualityIndex,
  ) async {
    setDownloading(true);
    setProgress(null);

    try {
      final scraper = DouyinScraper();
      final downloadUrl = scraper.getDownloadUrl(video, qualityIndex: qualityIndex);

      if (downloadUrl.isEmpty) {
        throw Exception('Failed to get download URL');
      }

      final quality = qualityIndex >= 0 && qualityIndex < video.videoDetail.qualities.length
          ? video.videoDetail.qualities[qualityIndex]
          : null;
      final qualityLabel = quality?.qualityLabel ?? 'video';

      final filename = 'douyin_${video.awemeId}_${qualityLabel.replaceAll(' ', '_')}.mp4';
      
      await downloadService.downloadVideo(
        url: downloadUrl,
        filename: filename,
        platform: 'Douyin',
        title: video.description.isNotEmpty ? video.description : 'Douyin Video',
        thumbnailUrl: video.coverUrl,
        originalUrl: inputUrl,
        onProgress: (received, total) {
          setProgress(total > 0 ? received / total : null);
        },
      );

      setDownloading(false);
      showToast(l10n.downloadSuccess);
    } catch (e) {
      setDownloading(false);
      showToast(l10n.downloadFailed(e.toString()));
    }
  }

  Future<void> downloadDouyinMusic(
    DouyinVideo video,
    String inputUrl,
  ) async {
    setDownloading(true);
    setProgress(null);

    try {
      if (video.music.playUrl.isEmpty) {
        throw Exception('No music URL available');
      }

      final filename = 'douyin_music_${video.music.id}.mp3';
      
      final savedPath = await downloadService.downloadAudio(
        url: video.music.playUrl,
        filename: filename,
        platform: 'Douyin',
        title: video.music.title.isNotEmpty ? video.music.title : 'Douyin Music',
        thumbnailUrl: video.music.coverUrl,
        originalUrl: inputUrl,
        onProgress: (received, total) {
          setProgress(total > 0 ? received / total : null);
        },
      );

      // Add ID3 tags
      if (video.music.title.isNotEmpty) {
        await Id3Tagger.embedTags(
          filePath: savedPath,
          title: video.music.title,
          artist: video.music.author.isNotEmpty ? video.music.author : video.author.nickname,
          album: '',
          coverUrl: video.music.coverUrl,
        );
      }

      setDownloading(false);
      showToast(l10n.downloadSuccess);
    } catch (e) {
      setDownloading(false);
      showToast(l10n.downloadFailed(e.toString()));
    }
  }

  // Bilibili Downloads
  Future<void> downloadBilibiliVideo(
    BilibiliResult result,
    String inputUrl,
    int qualityIndex,
  ) async {
    setDownloading(true);
    setProgress(null);

    try {
      if (result.playUrl.qualities.isEmpty) {
        throw Exception('No video qualities available');
      }

      if (qualityIndex < 0 || qualityIndex >= result.playUrl.qualities.length) {
        throw Exception('Invalid quality index');
      }

      final quality = result.playUrl.qualities[qualityIndex];
      final videoUrl = quality.videoUrl;
      
      if (videoUrl.isEmpty) {
        throw Exception('Video URL not available');
      }

      // Get audio URL
      final scraper = BilibiliScraper();
      final audioUrl = scraper.getAudioUrl(result, quality.audioQuality);
      
      if (audioUrl.isEmpty) {
        throw Exception('Audio URL not available');
      }

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final videoTempPath = '${tempDir.path}/bilibili_video_$timestamp.m4s';
      final audioTempPath = '${tempDir.path}/bilibili_audio_$timestamp.m4s';
      final outputPath = '${tempDir.path}/bilibili_${result.videoId}_${quality.qualityDesc}_$timestamp.mp4';
      
      // Download video file
      showToast('Downloading video...');
      await downloadService.dio.download(
        videoUrl,
        videoTempPath,
        options: Options(
          headers: {
            'Referer': 'https://www.bilibili.tv/',
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': '*/*',
            'Accept-Language': 'en-US,en;q=0.9',
            'Origin': 'https://www.bilibili.tv',
          },
        ),
        onReceiveProgress: (received, total) {
          setProgress(total > 0 ? received / 2 / total : null); // 50% for video
        },
      );

      // Download audio file
      showToast('Downloading audio...');
      await downloadService.dio.download(
        audioUrl,
        audioTempPath,
        options: Options(
          headers: {
            'Referer': 'https://www.bilibili.tv/',
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': '*/*',
            'Accept-Language': 'en-US,en;q=0.9',
            'Origin': 'https://www.bilibili.tv',
          },
        ),
        onReceiveProgress: (received, total) {
          final progress = 0.5 + (total > 0 ? received / 2 / total : 0); // 50% for audio
          setProgress(progress);
        },
      );

      // Merge video and audio using ffmpeg
      showToast('Merging video and audio...');
      setProgress(null); // Indeterminate progress for merging

      // FFmpeg command to merge video and audio
      final command = '-i "$videoTempPath" -i "$audioTempPath" -c:v copy -c:a aac -strict experimental "$outputPath"';
      
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      // Clean up temporary files
      try {
        await File(videoTempPath).delete();
        await File(audioTempPath).delete();
      } catch (e) {
        // Ignore cleanup errors
      }

      if (ReturnCode.isSuccess(returnCode)) {
        // Save to gallery
        await downloadService.saveVideoToGallery(
          filePath: outputPath,
          platform: 'Bilibili',
          title: result.title ?? 'Bilibili Video ${result.videoId}',
          originalUrl: inputUrl,
          thumbnailUrl: result.thumbnailUrl,
        );

        // Delete merged temp file
        try {
          await File(outputPath).delete();
        } catch (e) {
          // Ignore cleanup errors
        }

        setDownloading(false);
        showToast(l10n.downloadSuccess);
      } else {
        throw Exception('Failed to merge video and audio');
      }
    } catch (e) {
      setDownloading(false);
      showToast(l10n.downloadFailed(e.toString()));
    }
  }
}


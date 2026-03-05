// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'AIO Downloader';

  @override
  String get downloadMedia => 'Download Media';

  @override
  String get downloadMediaDesc =>
      'Download videos & images from various platforms';

  @override
  String get selectPlatform => 'Select Platform';

  @override
  String get tiktok => 'TikTok';

  @override
  String get tiktokDesc => 'Download videos & slides from TikTok';

  @override
  String get youtube => 'YouTube';

  @override
  String get youtubeDesc => 'Download videos from YouTube';

  @override
  String get instagram => 'Instagram';

  @override
  String get instagramDesc => 'Download photos & videos from Instagram';

  @override
  String get facebook => 'Facebook';

  @override
  String get facebookDesc => 'Download videos from Facebook';

  @override
  String get twitter => 'Twitter / X';

  @override
  String get twitterDesc => 'Download videos & images from Twitter';

  @override
  String get pinterest => 'Pinterest';

  @override
  String get pinterestDesc => 'Download videos, GIFs & images from Pinterest';

  @override
  String get spotify => 'Spotify';

  @override
  String get spotifyDesc => 'Download Spotify tracks';

  @override
  String get whatsappStatus => 'WhatsApp Status';

  @override
  String get whatsappStatusDesc => 'Save photos & videos from WhatsApp Status';

  @override
  String get history => 'Download History';

  @override
  String get about => 'About App';

  @override
  String get aboutDesc =>
      'Application to download media from various social media platforms.';

  @override
  String get version => 'Version';

  @override
  String get close => 'Close';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get enterUrl => 'Enter URL';

  @override
  String get pasteUrl => 'Paste URL here';

  @override
  String get getMedia => 'Get Media';

  @override
  String get searchMedia => 'Search Media';

  @override
  String get processing => 'Processing...';

  @override
  String get downloading => 'Downloading...';

  @override
  String get waiting => 'Please wait...';

  @override
  String get enterUrlFirst => 'Please enter a URL';

  @override
  String get selectQuality => 'Select Video Quality:';

  @override
  String get selectAudioQuality => 'Select Audio Quality:';

  @override
  String get selectQualityFirst => 'Select a quality first';

  @override
  String get downloadVideo => 'Download Video';

  @override
  String get downloadAudio => 'Download Audio';

  @override
  String get downloadMp4 => 'Download MP4';

  @override
  String get downloadImage => 'Download Image';

  @override
  String get downloadImages => 'Download Images';

  @override
  String get downloadAllImages => 'Download All Images';

  @override
  String get downloadAllVideos => 'Download All Videos';

  @override
  String get downloadThumbnail => 'Download Thumbnail';

  @override
  String get downloadSlides => 'Download All Slides';

  @override
  String get downloadSuccess => 'Successfully downloaded and saved to gallery!';

  @override
  String get downloadAllSuccess => 'All images successfully downloaded!';

  @override
  String downloadFailed(Object error) {
    return 'Download failed: $error';
  }

  @override
  String error(Object error) {
    return 'Error: $error';
  }

  @override
  String get image => 'Image';

  @override
  String get images => 'Images';

  @override
  String get video => 'Video';

  @override
  String get videos => 'Video/GIF';

  @override
  String get audio => 'Audio';

  @override
  String get photoLabel => 'Photos';

  @override
  String get slides => 'Slides';

  @override
  String get duration => 'Duration';

  @override
  String get videoQuality => 'Video Quality';

  @override
  String get hdVideo => 'HD Video';

  @override
  String get watermarkVideo => 'Video with Watermark';

  @override
  String get noWatermarkVideo => 'Video without Watermark';

  @override
  String get serverOption => 'Select Server';

  @override
  String get server1 => 'Server 1';

  @override
  String get server2 => 'Server 2';

  @override
  String get download => 'Download';

  @override
  String get saveBtn => 'Save';

  @override
  String get saveToGallery => 'Save to Gallery';

  @override
  String get saveAll => 'Save All';

  @override
  String get savedToGallery => 'Saved to gallery!';

  @override
  String failedToSave(Object error) {
    return 'Failed to save: $error';
  }

  @override
  String savedCount(Object count) {
    return '$count file(s) saved to gallery';
  }

  @override
  String get previewVideo => 'Video Preview';

  @override
  String get previewPhoto => 'Photo Preview';

  @override
  String videoGif(Object count) {
    return 'Video/GIF ($count)';
  }

  @override
  String imageCount(Object count) {
    return 'Images ($count)';
  }

  @override
  String imageNum(Object num) {
    return 'Image $num';
  }

  @override
  String get all => 'All';

  @override
  String get filter => 'Filter';

  @override
  String get typeFilter => 'Type';

  @override
  String get platformFilter => 'Platform';

  @override
  String get allTypes => 'All Types';

  @override
  String get videosOnly => 'Videos Only';

  @override
  String get imagesOnly => 'Images Only';

  @override
  String get clearAll => 'Clear All';

  @override
  String get confirmDeleteAll => 'Delete All History?';

  @override
  String get cannotUndo => 'This action cannot be undone.';

  @override
  String get confirmClearAll => 'Are you sure you want to delete all history?';

  @override
  String get deleteBtn => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleted => 'Deleted';

  @override
  String get deleteItem => 'Item deleted from history';

  @override
  String get allDeleted => 'All history cleared';

  @override
  String get statistics => 'Statistics';

  @override
  String totalDownloads(Object count) {
    return 'Total Downloads: $count';
  }

  @override
  String get noData => 'No data';

  @override
  String get noDownloads => 'No downloads yet';

  @override
  String get noDownloadsDesc => 'Your first download will appear here';

  @override
  String itemsFound(Object count) {
    return '$count items found';
  }

  @override
  String get loadingStatuses => 'Loading statuses...';

  @override
  String get notAvailableIOS => 'Not Available on iOS';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get errorOccurred => 'An Error Occurred';

  @override
  String get retryButton => 'Try Again';

  @override
  String get shareHint =>
      'Tap the Share button on YouTube, TikTok, Instagram, etc. — choose AIO Downloader to download instantly!';

  @override
  String get iosNotAvailable =>
      'This feature is unavailable on iOS due to system restrictions. Please use an Android device to view and save WhatsApp Status.';

  @override
  String get permissionDenied =>
      'Permission denied. Please grant storage permission to access WhatsApp Status.';

  @override
  String failedToReadStatus(Object error) {
    return 'Failed to read status: $error';
  }

  @override
  String get permissionRequiredDesc =>
      'This app requires storage access permission to read WhatsApp Status files on your device.';

  @override
  String get noStatusTitle => 'No Status';

  @override
  String noStatusFoundIn(Object dir) {
    return 'No status found in:\n$dir';
  }

  @override
  String get whatsappNotFound =>
      'WhatsApp Status folder not found.\nPlease make sure WhatsApp is installed and you\'ve viewed someone\'s status.';

  @override
  String urlDetected(Object platform) {
    return '$platform URL detected';
  }

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get updateAvailableDesc =>
      'A new version of AIO Downloader is available!';

  @override
  String get updateNow => 'Update Now';

  @override
  String get later => 'Later';

  @override
  String newVersionAvailable(Object version) {
    return 'New version $version is available';
  }

  @override
  String currentVersion(Object version) {
    return 'Current version: $version';
  }

  @override
  String get releaseNotes => 'Release Notes:';

  @override
  String get checkingUpdate => 'Checking for updates...';

  @override
  String get updateCheckFailed => 'Failed to check for updates';

  @override
  String get appUpToDate => 'App is up to date';
}

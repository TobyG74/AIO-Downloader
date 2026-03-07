import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
    Locale('ja'),
    Locale('zh')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'AIO Downloader'**
  String get appName;

  /// No description provided for @downloadMedia.
  ///
  /// In en, this message translates to:
  /// **'Download Media'**
  String get downloadMedia;

  /// No description provided for @downloadMediaDesc.
  ///
  /// In en, this message translates to:
  /// **'Download videos & images from various platforms'**
  String get downloadMediaDesc;

  /// No description provided for @selectPlatform.
  ///
  /// In en, this message translates to:
  /// **'Select Platform'**
  String get selectPlatform;

  /// No description provided for @tiktok.
  ///
  /// In en, this message translates to:
  /// **'TikTok'**
  String get tiktok;

  /// No description provided for @tiktokDesc.
  ///
  /// In en, this message translates to:
  /// **'Download videos & slides from TikTok'**
  String get tiktokDesc;

  /// No description provided for @youtube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get youtube;

  /// No description provided for @youtubeDesc.
  ///
  /// In en, this message translates to:
  /// **'Download videos from YouTube'**
  String get youtubeDesc;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @instagramDesc.
  ///
  /// In en, this message translates to:
  /// **'Download photos & videos from Instagram'**
  String get instagramDesc;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @facebookDesc.
  ///
  /// In en, this message translates to:
  /// **'Download videos from Facebook'**
  String get facebookDesc;

  /// No description provided for @twitter.
  ///
  /// In en, this message translates to:
  /// **'Twitter / X'**
  String get twitter;

  /// No description provided for @twitterDesc.
  ///
  /// In en, this message translates to:
  /// **'Download videos & images from Twitter'**
  String get twitterDesc;

  /// No description provided for @pinterest.
  ///
  /// In en, this message translates to:
  /// **'Pinterest'**
  String get pinterest;

  /// No description provided for @pinterestDesc.
  ///
  /// In en, this message translates to:
  /// **'Download videos, GIFs & images from Pinterest'**
  String get pinterestDesc;

  /// No description provided for @spotify.
  ///
  /// In en, this message translates to:
  /// **'Spotify'**
  String get spotify;

  /// No description provided for @spotifyDesc.
  ///
  /// In en, this message translates to:
  /// **'Download Spotify tracks'**
  String get spotifyDesc;

  /// No description provided for @soundcloud.
  ///
  /// In en, this message translates to:
  /// **'SoundCloud'**
  String get soundcloud;

  /// No description provided for @soundcloudDesc.
  ///
  /// In en, this message translates to:
  /// **'Download SoundCloud tracks & playlists'**
  String get soundcloudDesc;

  /// No description provided for @douyin.
  ///
  /// In en, this message translates to:
  /// **'Douyin'**
  String get douyin;

  /// No description provided for @douyinDesc.
  ///
  /// In en, this message translates to:
  /// **'Download videos & music from Douyin'**
  String get douyinDesc;

  /// No description provided for @bilibili.
  ///
  /// In en, this message translates to:
  /// **'BiliBili'**
  String get bilibili;

  /// No description provided for @bilibiliDesc.
  ///
  /// In en, this message translates to:
  /// **'Download videos from BiliBili TV'**
  String get bilibiliDesc;

  /// No description provided for @threads.
  ///
  /// In en, this message translates to:
  /// **'Threads'**
  String get threads;

  /// No description provided for @threadsDesc.
  ///
  /// In en, this message translates to:
  /// **'Download Threads videos & images'**
  String get threadsDesc;

  /// No description provided for @whatsappStatus.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Status'**
  String get whatsappStatus;

  /// No description provided for @whatsappStatusDesc.
  ///
  /// In en, this message translates to:
  /// **'Save photos & videos from WhatsApp Status'**
  String get whatsappStatusDesc;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'Download History'**
  String get history;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get about;

  /// No description provided for @aboutDesc.
  ///
  /// In en, this message translates to:
  /// **'Application to download media from various social media platforms.'**
  String get aboutDesc;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @enterUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter URL'**
  String get enterUrl;

  /// No description provided for @pasteUrl.
  ///
  /// In en, this message translates to:
  /// **'Paste URL here'**
  String get pasteUrl;

  /// No description provided for @getMedia.
  ///
  /// In en, this message translates to:
  /// **'Get Media'**
  String get getMedia;

  /// No description provided for @searchMedia.
  ///
  /// In en, this message translates to:
  /// **'Search Media'**
  String get searchMedia;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloading;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get waiting;

  /// No description provided for @enterUrlFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter a URL'**
  String get enterUrlFirst;

  /// No description provided for @selectQuality.
  ///
  /// In en, this message translates to:
  /// **'Select Video Quality:'**
  String get selectQuality;

  /// No description provided for @selectAudioQuality.
  ///
  /// In en, this message translates to:
  /// **'Select Audio Quality:'**
  String get selectAudioQuality;

  /// No description provided for @selectQualityFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a quality first'**
  String get selectQualityFirst;

  /// No description provided for @downloadVideo.
  ///
  /// In en, this message translates to:
  /// **'Download Video'**
  String get downloadVideo;

  /// No description provided for @downloadAudio.
  ///
  /// In en, this message translates to:
  /// **'Download Audio'**
  String get downloadAudio;

  /// No description provided for @downloadMusic.
  ///
  /// In en, this message translates to:
  /// **'Download Music'**
  String get downloadMusic;

  /// No description provided for @downloadMp4.
  ///
  /// In en, this message translates to:
  /// **'Download MP4'**
  String get downloadMp4;

  /// No description provided for @downloadImage.
  ///
  /// In en, this message translates to:
  /// **'Download Image'**
  String get downloadImage;

  /// No description provided for @downloadImages.
  ///
  /// In en, this message translates to:
  /// **'Download Images'**
  String get downloadImages;

  /// No description provided for @downloadAllImages.
  ///
  /// In en, this message translates to:
  /// **'Download All Images'**
  String get downloadAllImages;

  /// No description provided for @downloadAllVideos.
  ///
  /// In en, this message translates to:
  /// **'Download All Videos'**
  String get downloadAllVideos;

  /// No description provided for @downloadThumbnail.
  ///
  /// In en, this message translates to:
  /// **'Download Thumbnail'**
  String get downloadThumbnail;

  /// No description provided for @downloadSlides.
  ///
  /// In en, this message translates to:
  /// **'Download All Slides'**
  String get downloadSlides;

  /// No description provided for @downloadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully downloaded and saved to gallery!'**
  String get downloadSuccess;

  /// No description provided for @downloadAllSuccess.
  ///
  /// In en, this message translates to:
  /// **'All images successfully downloaded!'**
  String get downloadAllSuccess;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed: {error}'**
  String downloadFailed(Object error);

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(Object error);

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @playlist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlist;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'track'**
  String get track;

  /// No description provided for @tracks.
  ///
  /// In en, this message translates to:
  /// **'tracks'**
  String get tracks;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Video/GIF'**
  String get videos;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @photoLabel.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photoLabel;

  /// No description provided for @slides.
  ///
  /// In en, this message translates to:
  /// **'Slides'**
  String get slides;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @videoQuality.
  ///
  /// In en, this message translates to:
  /// **'Video Quality'**
  String get videoQuality;

  /// No description provided for @hdVideo.
  ///
  /// In en, this message translates to:
  /// **'HD Video'**
  String get hdVideo;

  /// No description provided for @watermarkVideo.
  ///
  /// In en, this message translates to:
  /// **'Video with Watermark'**
  String get watermarkVideo;

  /// No description provided for @noWatermarkVideo.
  ///
  /// In en, this message translates to:
  /// **'Video without Watermark'**
  String get noWatermarkVideo;

  /// No description provided for @serverOption.
  ///
  /// In en, this message translates to:
  /// **'Select Server'**
  String get serverOption;

  /// No description provided for @server1.
  ///
  /// In en, this message translates to:
  /// **'Server 1'**
  String get server1;

  /// No description provided for @server2.
  ///
  /// In en, this message translates to:
  /// **'Server 2'**
  String get server2;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @saveBtn.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveBtn;

  /// No description provided for @saveToGallery.
  ///
  /// In en, this message translates to:
  /// **'Save to Gallery'**
  String get saveToGallery;

  /// No description provided for @saveAll.
  ///
  /// In en, this message translates to:
  /// **'Save All'**
  String get saveAll;

  /// No description provided for @savedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Saved to gallery!'**
  String get savedToGallery;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String failedToSave(Object error);

  /// No description provided for @savedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} file(s) saved to gallery'**
  String savedCount(Object count);

  /// No description provided for @previewVideo.
  ///
  /// In en, this message translates to:
  /// **'Video Preview'**
  String get previewVideo;

  /// No description provided for @previewPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo Preview'**
  String get previewPhoto;

  /// No description provided for @videoGif.
  ///
  /// In en, this message translates to:
  /// **'Video/GIF ({count})'**
  String videoGif(Object count);

  /// No description provided for @imageCount.
  ///
  /// In en, this message translates to:
  /// **'Images ({count})'**
  String imageCount(Object count);

  /// No description provided for @imageNum.
  ///
  /// In en, this message translates to:
  /// **'Image {num}'**
  String imageNum(Object num);

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @typeFilter.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeFilter;

  /// No description provided for @platformFilter.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platformFilter;

  /// No description provided for @allTypes.
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get allTypes;

  /// No description provided for @videosOnly.
  ///
  /// In en, this message translates to:
  /// **'Videos Only'**
  String get videosOnly;

  /// No description provided for @imagesOnly.
  ///
  /// In en, this message translates to:
  /// **'Images Only'**
  String get imagesOnly;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @confirmDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All History?'**
  String get confirmDeleteAll;

  /// No description provided for @cannotUndo.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get cannotUndo;

  /// No description provided for @confirmClearAll.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all history?'**
  String get confirmClearAll;

  /// No description provided for @deleteBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteBtn;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Item deleted from history'**
  String get deleteItem;

  /// No description provided for @allDeleted.
  ///
  /// In en, this message translates to:
  /// **'All history cleared'**
  String get allDeleted;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @totalDownloads.
  ///
  /// In en, this message translates to:
  /// **'Total Downloads: {count}'**
  String totalDownloads(Object count);

  /// No description provided for @storagePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Storage permission denied'**
  String get storagePermissionDenied;

  /// No description provided for @videoSavedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Video successfully saved to gallery'**
  String get videoSavedToGallery;

  /// No description provided for @imageSavedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Image successfully saved to gallery'**
  String get imageSavedToGallery;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @noDownloads.
  ///
  /// In en, this message translates to:
  /// **'No downloads yet'**
  String get noDownloads;

  /// No description provided for @noDownloadsDesc.
  ///
  /// In en, this message translates to:
  /// **'Your first download will appear here'**
  String get noDownloadsDesc;

  /// No description provided for @itemsFound.
  ///
  /// In en, this message translates to:
  /// **'{count} items found'**
  String itemsFound(Object count);

  /// No description provided for @loadingStatuses.
  ///
  /// In en, this message translates to:
  /// **'Loading statuses...'**
  String get loadingStatuses;

  /// No description provided for @notAvailableIOS.
  ///
  /// In en, this message translates to:
  /// **'Not Available on iOS'**
  String get notAvailableIOS;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An Error Occurred'**
  String get errorOccurred;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retryButton;

  /// No description provided for @shareHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the Share button on YouTube, TikTok, Instagram, etc. — choose AIO Downloader to download instantly!'**
  String get shareHint;

  /// No description provided for @iosNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'This feature is unavailable on iOS due to system restrictions. Please use an Android device to view and save WhatsApp Status.'**
  String get iosNotAvailable;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Please grant storage permission to access WhatsApp Status.'**
  String get permissionDenied;

  /// No description provided for @failedToReadStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to read status: {error}'**
  String failedToReadStatus(Object error);

  /// No description provided for @permissionRequiredDesc.
  ///
  /// In en, this message translates to:
  /// **'This app requires storage access permission to read WhatsApp Status files on your device.'**
  String get permissionRequiredDesc;

  /// No description provided for @noStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'No Status'**
  String get noStatusTitle;

  /// No description provided for @noStatusFoundIn.
  ///
  /// In en, this message translates to:
  /// **'No status found in:\n{dir}'**
  String noStatusFoundIn(Object dir);

  /// No description provided for @whatsappNotFound.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Status folder not found.\nPlease make sure WhatsApp is installed and you\'ve viewed someone\'s status.'**
  String get whatsappNotFound;

  /// No description provided for @urlDetected.
  ///
  /// In en, this message translates to:
  /// **'{platform} URL detected'**
  String urlDetected(Object platform);

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailable;

  /// No description provided for @updateAvailableDesc.
  ///
  /// In en, this message translates to:
  /// **'A new version of AIO Downloader is available!'**
  String get updateAvailableDesc;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @newVersionAvailable.
  ///
  /// In en, this message translates to:
  /// **'New version {version} is available'**
  String newVersionAvailable(Object version);

  /// No description provided for @currentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current version: {version}'**
  String currentVersion(Object version);

  /// No description provided for @releaseNotes.
  ///
  /// In en, this message translates to:
  /// **'Release Notes:'**
  String get releaseNotes;

  /// No description provided for @checkingUpdate.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates...'**
  String get checkingUpdate;

  /// No description provided for @updateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to check for updates'**
  String get updateCheckFailed;

  /// No description provided for @appUpToDate.
  ///
  /// In en, this message translates to:
  /// **'App is up to date'**
  String get appUpToDate;

  /// No description provided for @webviewVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection Verification'**
  String get webviewVerifyTitle;

  /// No description provided for @webviewVerifySuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification successful!'**
  String get webviewVerifySuccess;

  /// No description provided for @webviewLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get webviewLoading;

  /// No description provided for @webviewSearchingCookie.
  ///
  /// In en, this message translates to:
  /// **'Looking for cookies...'**
  String get webviewSearchingCookie;

  /// No description provided for @webviewContinueManual.
  ///
  /// In en, this message translates to:
  /// **'Continue Manually'**
  String get webviewContinueManual;

  /// No description provided for @webviewCancelled.
  ///
  /// In en, this message translates to:
  /// **'Verification cancelled. Please try again.'**
  String get webviewCancelled;

  /// No description provided for @webviewRequired.
  ///
  /// In en, this message translates to:
  /// **'Connection blocked (403). Tap the ἱ0 icon at the top right to verify, then try again.'**
  String get webviewRequired;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

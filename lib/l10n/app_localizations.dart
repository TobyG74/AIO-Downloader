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
  /// In id, this message translates to:
  /// **'AIO Downloader'**
  String get appName;

  /// No description provided for @downloadMedia.
  ///
  /// In id, this message translates to:
  /// **'Download Media'**
  String get downloadMedia;

  /// No description provided for @downloadMediaDesc.
  ///
  /// In id, this message translates to:
  /// **'Download video & gambar dari berbagai platform'**
  String get downloadMediaDesc;

  /// No description provided for @selectPlatform.
  ///
  /// In id, this message translates to:
  /// **'Pilih Platform'**
  String get selectPlatform;

  /// No description provided for @tiktok.
  ///
  /// In id, this message translates to:
  /// **'TikTok'**
  String get tiktok;

  /// No description provided for @tiktokDesc.
  ///
  /// In id, this message translates to:
  /// **'Download video & slide dari TikTok'**
  String get tiktokDesc;

  /// No description provided for @youtube.
  ///
  /// In id, this message translates to:
  /// **'YouTube'**
  String get youtube;

  /// No description provided for @youtubeDesc.
  ///
  /// In id, this message translates to:
  /// **'Download video dari YouTube'**
  String get youtubeDesc;

  /// No description provided for @instagram.
  ///
  /// In id, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @instagramDesc.
  ///
  /// In id, this message translates to:
  /// **'Download foto & video dari Instagram'**
  String get instagramDesc;

  /// No description provided for @facebook.
  ///
  /// In id, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @facebookDesc.
  ///
  /// In id, this message translates to:
  /// **'Download video dari Facebook'**
  String get facebookDesc;

  /// No description provided for @twitter.
  ///
  /// In id, this message translates to:
  /// **'Twitter / X'**
  String get twitter;

  /// No description provided for @twitterDesc.
  ///
  /// In id, this message translates to:
  /// **'Download video & gambar dari Twitter'**
  String get twitterDesc;

  /// No description provided for @pinterest.
  ///
  /// In id, this message translates to:
  /// **'Pinterest'**
  String get pinterest;

  /// No description provided for @pinterestDesc.
  ///
  /// In id, this message translates to:
  /// **'Download video, gambar & GIF dari Pinterest'**
  String get pinterestDesc;

  /// No description provided for @spotify.
  ///
  /// In id, this message translates to:
  /// **'Spotify'**
  String get spotify;

  /// No description provided for @spotifyDesc.
  ///
  /// In id, this message translates to:
  /// **'Download lagu Spotify'**
  String get spotifyDesc;

  /// No description provided for @whatsappStatus.
  ///
  /// In id, this message translates to:
  /// **'WhatsApp Status'**
  String get whatsappStatus;

  /// No description provided for @whatsappStatusDesc.
  ///
  /// In id, this message translates to:
  /// **'Simpan foto & video dari WhatsApp Status teman'**
  String get whatsappStatusDesc;

  /// No description provided for @history.
  ///
  /// In id, this message translates to:
  /// **'Download History'**
  String get history;

  /// No description provided for @about.
  ///
  /// In id, this message translates to:
  /// **'Tentang Aplikasi'**
  String get about;

  /// No description provided for @aboutDesc.
  ///
  /// In id, this message translates to:
  /// **'Aplikasi untuk mendownload media dari berbagai platform sosial media.'**
  String get aboutDesc;

  /// No description provided for @version.
  ///
  /// In id, this message translates to:
  /// **'Versi'**
  String get version;

  /// No description provided for @close.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get close;

  /// No description provided for @lightMode.
  ///
  /// In id, this message translates to:
  /// **'Mode Terang'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In id, this message translates to:
  /// **'Mode Gelap'**
  String get darkMode;

  /// No description provided for @enterUrl.
  ///
  /// In id, this message translates to:
  /// **'Masukkan URL'**
  String get enterUrl;

  /// No description provided for @pasteUrl.
  ///
  /// In id, this message translates to:
  /// **'Paste URL di sini'**
  String get pasteUrl;

  /// No description provided for @getMedia.
  ///
  /// In id, this message translates to:
  /// **'Dapatkan Media'**
  String get getMedia;

  /// No description provided for @searchMedia.
  ///
  /// In id, this message translates to:
  /// **'Cari Media'**
  String get searchMedia;

  /// No description provided for @processing.
  ///
  /// In id, this message translates to:
  /// **'Memproses...'**
  String get processing;

  /// No description provided for @downloading.
  ///
  /// In id, this message translates to:
  /// **'Downloading...'**
  String get downloading;

  /// No description provided for @waiting.
  ///
  /// In id, this message translates to:
  /// **'Mohon tunggu...'**
  String get waiting;

  /// No description provided for @enterUrlFirst.
  ///
  /// In id, this message translates to:
  /// **'Masukkan URL terlebih dahulu'**
  String get enterUrlFirst;

  /// No description provided for @selectQuality.
  ///
  /// In id, this message translates to:
  /// **'Pilih Kualitas Video:'**
  String get selectQuality;

  /// No description provided for @selectAudioQuality.
  ///
  /// In id, this message translates to:
  /// **'Pilih Kualitas Audio:'**
  String get selectAudioQuality;

  /// No description provided for @selectQualityFirst.
  ///
  /// In id, this message translates to:
  /// **'Pilih kualitas dahulu'**
  String get selectQualityFirst;

  /// No description provided for @downloadVideo.
  ///
  /// In id, this message translates to:
  /// **'Download Video'**
  String get downloadVideo;

  /// No description provided for @downloadAudio.
  ///
  /// In id, this message translates to:
  /// **'Download Audio'**
  String get downloadAudio;

  /// No description provided for @downloadMp4.
  ///
  /// In id, this message translates to:
  /// **'Download MP4'**
  String get downloadMp4;

  /// No description provided for @downloadImage.
  ///
  /// In id, this message translates to:
  /// **'Download Gambar'**
  String get downloadImage;

  /// No description provided for @downloadImages.
  ///
  /// In id, this message translates to:
  /// **'Download Gambar'**
  String get downloadImages;

  /// No description provided for @downloadAllImages.
  ///
  /// In id, this message translates to:
  /// **'Download Semua Gambar'**
  String get downloadAllImages;

  /// No description provided for @downloadAllVideos.
  ///
  /// In id, this message translates to:
  /// **'Download Semua Video'**
  String get downloadAllVideos;

  /// No description provided for @downloadThumbnail.
  ///
  /// In id, this message translates to:
  /// **'Download Gambar Thumbnail'**
  String get downloadThumbnail;

  /// No description provided for @downloadSlides.
  ///
  /// In id, this message translates to:
  /// **'Download Semua Slide'**
  String get downloadSlides;

  /// No description provided for @downloadSuccess.
  ///
  /// In id, this message translates to:
  /// **'Berhasil didownload dan disimpan ke galeri!'**
  String get downloadSuccess;

  /// No description provided for @downloadAllSuccess.
  ///
  /// In id, this message translates to:
  /// **'Semua gambar berhasil didownload!'**
  String get downloadAllSuccess;

  /// No description provided for @downloadFailed.
  ///
  /// In id, this message translates to:
  /// **'Download gagal: {error}'**
  String downloadFailed(Object error);

  /// No description provided for @error.
  ///
  /// In id, this message translates to:
  /// **'Error: {error}'**
  String error(Object error);

  /// No description provided for @image.
  ///
  /// In id, this message translates to:
  /// **'Gambar'**
  String get image;

  /// No description provided for @images.
  ///
  /// In id, this message translates to:
  /// **'Gambar'**
  String get images;

  /// No description provided for @video.
  ///
  /// In id, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @videos.
  ///
  /// In id, this message translates to:
  /// **'Video/GIF'**
  String get videos;

  /// No description provided for @audio.
  ///
  /// In id, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @photoLabel.
  ///
  /// In id, this message translates to:
  /// **'Foto'**
  String get photoLabel;

  /// No description provided for @slides.
  ///
  /// In id, this message translates to:
  /// **'Slide'**
  String get slides;

  /// No description provided for @duration.
  ///
  /// In id, this message translates to:
  /// **'Durasi'**
  String get duration;

  /// No description provided for @videoQuality.
  ///
  /// In id, this message translates to:
  /// **'Kualitas Video'**
  String get videoQuality;

  /// No description provided for @hdVideo.
  ///
  /// In id, this message translates to:
  /// **'Video HD'**
  String get hdVideo;

  /// No description provided for @watermarkVideo.
  ///
  /// In id, this message translates to:
  /// **'Video dengan Watermark'**
  String get watermarkVideo;

  /// No description provided for @noWatermarkVideo.
  ///
  /// In id, this message translates to:
  /// **'Video tanpa Watermark'**
  String get noWatermarkVideo;

  /// No description provided for @serverOption.
  ///
  /// In id, this message translates to:
  /// **'Pilih Server'**
  String get serverOption;

  /// No description provided for @server1.
  ///
  /// In id, this message translates to:
  /// **'Server 1'**
  String get server1;

  /// No description provided for @server2.
  ///
  /// In id, this message translates to:
  /// **'Server 2'**
  String get server2;

  /// No description provided for @download.
  ///
  /// In id, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @saveBtn.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get saveBtn;

  /// No description provided for @saveToGallery.
  ///
  /// In id, this message translates to:
  /// **'Simpan ke Galeri'**
  String get saveToGallery;

  /// No description provided for @saveAll.
  ///
  /// In id, this message translates to:
  /// **'Simpan Semua'**
  String get saveAll;

  /// No description provided for @savedToGallery.
  ///
  /// In id, this message translates to:
  /// **'Berhasil disimpan ke galeri!'**
  String get savedToGallery;

  /// No description provided for @failedToSave.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan: {error}'**
  String failedToSave(Object error);

  /// No description provided for @savedCount.
  ///
  /// In id, this message translates to:
  /// **'{count} file berhasil disimpan ke galeri'**
  String savedCount(Object count);

  /// No description provided for @previewVideo.
  ///
  /// In id, this message translates to:
  /// **'Preview Video'**
  String get previewVideo;

  /// No description provided for @previewPhoto.
  ///
  /// In id, this message translates to:
  /// **'Preview Foto'**
  String get previewPhoto;

  /// No description provided for @videoGif.
  ///
  /// In id, this message translates to:
  /// **'Video/GIF ({count})'**
  String videoGif(Object count);

  /// No description provided for @imageCount.
  ///
  /// In id, this message translates to:
  /// **'Gambar ({count})'**
  String imageCount(Object count);

  /// No description provided for @imageNum.
  ///
  /// In id, this message translates to:
  /// **'Gambar {num}'**
  String imageNum(Object num);

  /// No description provided for @all.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get all;

  /// No description provided for @filter.
  ///
  /// In id, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @typeFilter.
  ///
  /// In id, this message translates to:
  /// **'Tipe'**
  String get typeFilter;

  /// No description provided for @platformFilter.
  ///
  /// In id, this message translates to:
  /// **'Platform'**
  String get platformFilter;

  /// No description provided for @allTypes.
  ///
  /// In id, this message translates to:
  /// **'Semua Tipe'**
  String get allTypes;

  /// No description provided for @videosOnly.
  ///
  /// In id, this message translates to:
  /// **'Video Saja'**
  String get videosOnly;

  /// No description provided for @imagesOnly.
  ///
  /// In id, this message translates to:
  /// **'Gambar Saja'**
  String get imagesOnly;

  /// No description provided for @clearAll.
  ///
  /// In id, this message translates to:
  /// **'Hapus Semua'**
  String get clearAll;

  /// No description provided for @confirmDeleteAll.
  ///
  /// In id, this message translates to:
  /// **'Hapus Semua History?'**
  String get confirmDeleteAll;

  /// No description provided for @cannotUndo.
  ///
  /// In id, this message translates to:
  /// **'Tindakan ini tidak dapat dibatalkan.'**
  String get cannotUndo;

  /// No description provided for @confirmClearAll.
  ///
  /// In id, this message translates to:
  /// **'Yakin ingin menghapus semua history?'**
  String get confirmClearAll;

  /// No description provided for @deleteBtn.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get deleteBtn;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @deleted.
  ///
  /// In id, this message translates to:
  /// **'Dihapus'**
  String get deleted;

  /// No description provided for @deleteItem.
  ///
  /// In id, this message translates to:
  /// **'Item dihapus dari history'**
  String get deleteItem;

  /// No description provided for @allDeleted.
  ///
  /// In id, this message translates to:
  /// **'Semua history telah dihapus'**
  String get allDeleted;

  /// No description provided for @statistics.
  ///
  /// In id, this message translates to:
  /// **'Statistik'**
  String get statistics;

  /// No description provided for @totalDownloads.
  ///
  /// In id, this message translates to:
  /// **'Total Download: {count}'**
  String totalDownloads(Object count);

  /// No description provided for @noData.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada data'**
  String get noData;

  /// No description provided for @noDownloads.
  ///
  /// In id, this message translates to:
  /// **'Belum ada history download'**
  String get noDownloads;

  /// No description provided for @noDownloadsDesc.
  ///
  /// In id, this message translates to:
  /// **'Download pertama kamu akan muncul di sini'**
  String get noDownloadsDesc;

  /// No description provided for @itemsFound.
  ///
  /// In id, this message translates to:
  /// **'{count} item ditemukan'**
  String itemsFound(Object count);

  /// No description provided for @loadingStatuses.
  ///
  /// In id, this message translates to:
  /// **'Memuat status...'**
  String get loadingStatuses;

  /// No description provided for @notAvailableIOS.
  ///
  /// In id, this message translates to:
  /// **'Tidak Tersedia di iOS'**
  String get notAvailableIOS;

  /// No description provided for @permissionRequired.
  ///
  /// In id, this message translates to:
  /// **'Izin Diperlukan'**
  String get permissionRequired;

  /// No description provided for @grantPermission.
  ///
  /// In id, this message translates to:
  /// **'Berikan Izin'**
  String get grantPermission;

  /// No description provided for @errorOccurred.
  ///
  /// In id, this message translates to:
  /// **'Terjadi Kesalahan'**
  String get errorOccurred;

  /// No description provided for @retryButton.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get retryButton;

  /// No description provided for @shareHint.
  ///
  /// In id, this message translates to:
  /// **'Tap tombol Share di YouTube, TikTok, Instagram, dll — pilih AIO Downloader untuk langsung download!'**
  String get shareHint;

  /// No description provided for @iosNotAvailable.
  ///
  /// In id, this message translates to:
  /// **'Fitur ini tidak tersedia di iOS karena pembatasan sistem. Silakan gunakan perangkat Android untuk melihat dan menyimpan Status WhatsApp.'**
  String get iosNotAvailable;

  /// No description provided for @permissionDenied.
  ///
  /// In id, this message translates to:
  /// **'Izin ditolak. Harap berikan izin penyimpanan untuk mengakses Status WhatsApp.'**
  String get permissionDenied;

  /// No description provided for @failedToReadStatus.
  ///
  /// In id, this message translates to:
  /// **'Gagal membaca status: {error}'**
  String failedToReadStatus(Object error);

  /// No description provided for @permissionRequiredDesc.
  ///
  /// In id, this message translates to:
  /// **'Aplikasi ini memerlukan izin akses penyimpanan untuk membaca file Status WhatsApp di perangkat Anda.'**
  String get permissionRequiredDesc;

  /// No description provided for @noStatusTitle.
  ///
  /// In id, this message translates to:
  /// **'Tidak Ada Status'**
  String get noStatusTitle;

  /// No description provided for @noStatusFoundIn.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada status ditemukan di:\n{dir}'**
  String noStatusFoundIn(Object dir);

  /// No description provided for @whatsappNotFound.
  ///
  /// In id, this message translates to:
  /// **'Folder Status WhatsApp tidak ditemukan.\nPastikan WhatsApp terinstall dan Anda sudah melihat status seseorang.'**
  String get whatsappNotFound;

  /// No description provided for @urlDetected.
  ///
  /// In id, this message translates to:
  /// **'URL {platform} terdeteksi'**
  String urlDetected(Object platform);

  /// No description provided for @updateAvailable.
  ///
  /// In id, this message translates to:
  /// **'Pembaruan Tersedia'**
  String get updateAvailable;

  /// No description provided for @updateAvailableDesc.
  ///
  /// In id, this message translates to:
  /// **'Versi baru AIO Downloader telah tersedia!'**
  String get updateAvailableDesc;

  /// No description provided for @updateNow.
  ///
  /// In id, this message translates to:
  /// **'Perbarui Sekarang'**
  String get updateNow;

  /// No description provided for @later.
  ///
  /// In id, this message translates to:
  /// **'Nanti'**
  String get later;

  /// No description provided for @newVersionAvailable.
  ///
  /// In id, this message translates to:
  /// **'Versi baru {version} tersedia'**
  String newVersionAvailable(Object version);

  /// No description provided for @currentVersion.
  ///
  /// In id, this message translates to:
  /// **'Versi saat ini: {version}'**
  String currentVersion(Object version);

  /// No description provided for @releaseNotes.
  ///
  /// In id, this message translates to:
  /// **'Catatan Rilis:'**
  String get releaseNotes;

  /// No description provided for @checkingUpdate.
  ///
  /// In id, this message translates to:
  /// **'Memeriksa pembaruan...'**
  String get checkingUpdate;

  /// No description provided for @updateCheckFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memeriksa pembaruan'**
  String get updateCheckFailed;

  /// No description provided for @appUpToDate.
  ///
  /// In id, this message translates to:
  /// **'Aplikasi sudah versi terbaru'**
  String get appUpToDate;
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

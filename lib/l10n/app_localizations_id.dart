// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'AIO Downloader';

  @override
  String get downloadMedia => 'Download Media';

  @override
  String get downloadMediaDesc =>
      'Download video & gambar dari berbagai platform';

  @override
  String get selectPlatform => 'Pilih Platform';

  @override
  String get tiktok => 'TikTok';

  @override
  String get tiktokDesc => 'Download video & slide dari TikTok';

  @override
  String get youtube => 'YouTube';

  @override
  String get youtubeDesc => 'Download video dari YouTube';

  @override
  String get instagram => 'Instagram';

  @override
  String get instagramDesc => 'Download foto & video dari Instagram';

  @override
  String get facebook => 'Facebook';

  @override
  String get facebookDesc => 'Download video dari Facebook';

  @override
  String get twitter => 'Twitter / X';

  @override
  String get twitterDesc => 'Download video & gambar dari Twitter';

  @override
  String get pinterest => 'Pinterest';

  @override
  String get pinterestDesc => 'Download video, gambar & GIF dari Pinterest';

  @override
  String get spotify => 'Spotify';

  @override
  String get spotifyDesc => 'Download lagu & playlist Spotify';

  @override
  String get soundcloud => 'SoundCloud';

  @override
  String get soundcloudDesc => 'Download lagu & playlist SoundCloud';

  @override
  String get douyin => 'Douyin';

  @override
  String get douyinDesc => 'Download video & musik dari Douyin';

  @override
  String get bilibili => 'BiliBili';

  @override
  String get bilibiliDesc => 'Download videos from BiliBili TV';

  @override
  String get threads => 'Threads';

  @override
  String get threadsDesc => 'Download video & gambar dari Threads';

  @override
  String get whatsappStatus => 'WhatsApp Status';

  @override
  String get whatsappStatusDesc =>
      'Simpan foto & video dari WhatsApp Status teman';

  @override
  String get history => 'Download History';

  @override
  String get about => 'Tentang Aplikasi';

  @override
  String get aboutDesc =>
      'Aplikasi untuk mendownload media dari berbagai platform sosial media.';

  @override
  String get version => 'Versi';

  @override
  String get close => 'Tutup';

  @override
  String get lightMode => 'Mode Terang';

  @override
  String get darkMode => 'Mode Gelap';

  @override
  String get enterUrl => 'Masukkan URL';

  @override
  String get pasteUrl => 'Paste URL di sini';

  @override
  String get getMedia => 'Dapatkan Media';

  @override
  String get searchMedia => 'Cari Media';

  @override
  String get processing => 'Memproses...';

  @override
  String get downloading => 'Downloading...';

  @override
  String get waiting => 'Mohon tunggu...';

  @override
  String get enterUrlFirst => 'Masukkan URL terlebih dahulu';

  @override
  String get selectQuality => 'Pilih Kualitas Video:';

  @override
  String get selectAudioQuality => 'Pilih Kualitas Audio:';

  @override
  String get selectQualityFirst => 'Pilih kualitas dahulu';

  @override
  String get downloadVideo => 'Download Video';

  @override
  String get downloadAudio => 'Download Audio';

  @override
  String get downloadMusic => 'Download Musik';

  @override
  String get downloadMp4 => 'Download MP4';

  @override
  String get downloadImage => 'Download Gambar';

  @override
  String get downloadImages => 'Download Gambar';

  @override
  String get downloadAllImages => 'Download Semua Gambar';

  @override
  String get downloadAllVideos => 'Download Semua Video';

  @override
  String get downloadThumbnail => 'Download Gambar Thumbnail';

  @override
  String get downloadSlides => 'Download Semua Slide';

  @override
  String get downloadSuccess => 'Berhasil didownload dan disimpan ke galeri!';

  @override
  String get downloadAllSuccess => 'Semua gambar berhasil didownload!';

  @override
  String downloadFailed(Object error) {
    return 'Download gagal: $error';
  }

  @override
  String error(Object error) {
    return 'Error: $error';
  }

  @override
  String get image => 'Gambar';

  @override
  String get images => 'Gambar';

  @override
  String get video => 'Video';

  @override
  String get playlist => 'Playlist';

  @override
  String get track => 'lagu';

  @override
  String get tracks => 'lagu';

  @override
  String get videos => 'Video/GIF';

  @override
  String get audio => 'Audio';

  @override
  String get photoLabel => 'Foto';

  @override
  String get slides => 'Slide';

  @override
  String get duration => 'Durasi';

  @override
  String get videoQuality => 'Kualitas Video';

  @override
  String get hdVideo => 'Video HD';

  @override
  String get watermarkVideo => 'Video dengan Watermark';

  @override
  String get noWatermarkVideo => 'Video tanpa Watermark';

  @override
  String get serverOption => 'Pilih Server';

  @override
  String get server1 => 'Server 1';

  @override
  String get server2 => 'Server 2';

  @override
  String get download => 'Download';

  @override
  String get saveBtn => 'Simpan';

  @override
  String get saveToGallery => 'Simpan ke Galeri';

  @override
  String get saveAll => 'Simpan Semua';

  @override
  String get savedToGallery => 'Berhasil disimpan ke galeri!';

  @override
  String failedToSave(Object error) {
    return 'Gagal menyimpan: $error';
  }

  @override
  String savedCount(Object count) {
    return '$count file berhasil disimpan ke galeri';
  }

  @override
  String get previewVideo => 'Preview Video';

  @override
  String get previewPhoto => 'Preview Foto';

  @override
  String videoGif(Object count) {
    return 'Video/GIF ($count)';
  }

  @override
  String imageCount(Object count) {
    return 'Gambar ($count)';
  }

  @override
  String imageNum(Object num) {
    return 'Gambar $num';
  }

  @override
  String get all => 'Semua';

  @override
  String get filter => 'Filter';

  @override
  String get typeFilter => 'Tipe';

  @override
  String get platformFilter => 'Platform';

  @override
  String get allTypes => 'Semua Tipe';

  @override
  String get videosOnly => 'Video Saja';

  @override
  String get imagesOnly => 'Gambar Saja';

  @override
  String get clearAll => 'Hapus Semua';

  @override
  String get confirmDeleteAll => 'Hapus Semua History?';

  @override
  String get cannotUndo => 'Tindakan ini tidak dapat dibatalkan.';

  @override
  String get confirmClearAll => 'Yakin ingin menghapus semua history?';

  @override
  String get deleteBtn => 'Hapus';

  @override
  String get cancel => 'Batal';

  @override
  String get deleted => 'Dihapus';

  @override
  String get deleteItem => 'Item dihapus dari history';

  @override
  String get allDeleted => 'Semua history telah dihapus';

  @override
  String get statistics => 'Statistik';

  @override
  String totalDownloads(Object count) {
    return 'Total Download: $count';
  }

  @override
  String get storagePermissionDenied => 'Izin penyimpanan ditolak';

  @override
  String get videoSavedToGallery => 'Video berhasil disimpan ke galeri';

  @override
  String get imageSavedToGallery => 'Gambar berhasil disimpan ke galeri';

  @override
  String get noData => 'Tidak ada data';

  @override
  String get noDownloads => 'Belum ada history download';

  @override
  String get noDownloadsDesc => 'Download pertama kamu akan muncul di sini';

  @override
  String itemsFound(Object count) {
    return '$count item ditemukan';
  }

  @override
  String get loadingStatuses => 'Memuat status...';

  @override
  String get notAvailableIOS => 'Tidak Tersedia di iOS';

  @override
  String get permissionRequired => 'Izin Diperlukan';

  @override
  String get grantPermission => 'Berikan Izin';

  @override
  String get errorOccurred => 'Terjadi Kesalahan';

  @override
  String get retryButton => 'Coba Lagi';

  @override
  String get shareHint =>
      'Tap tombol Share di YouTube, TikTok, Instagram, dll — pilih AIO Downloader untuk langsung download!';

  @override
  String get iosNotAvailable =>
      'Fitur ini tidak tersedia di iOS karena pembatasan sistem. Silakan gunakan perangkat Android untuk melihat dan menyimpan Status WhatsApp.';

  @override
  String get permissionDenied =>
      'Izin ditolak. Harap berikan izin penyimpanan untuk mengakses Status WhatsApp.';

  @override
  String failedToReadStatus(Object error) {
    return 'Gagal membaca status: $error';
  }

  @override
  String get permissionRequiredDesc =>
      'Aplikasi ini memerlukan izin akses penyimpanan untuk membaca file Status WhatsApp di perangkat Anda.';

  @override
  String get noStatusTitle => 'Tidak Ada Status';

  @override
  String noStatusFoundIn(Object dir) {
    return 'Tidak ada status ditemukan di:\n$dir';
  }

  @override
  String get whatsappNotFound =>
      'Folder Status WhatsApp tidak ditemukan.\nPastikan WhatsApp terinstall dan Anda sudah melihat status seseorang.';

  @override
  String urlDetected(Object platform) {
    return 'URL $platform terdeteksi';
  }

  @override
  String get updateAvailable => 'Pembaruan Tersedia';

  @override
  String get updateAvailableDesc => 'Versi baru AIO Downloader telah tersedia!';

  @override
  String get updateNow => 'Perbarui Sekarang';

  @override
  String get later => 'Nanti';

  @override
  String newVersionAvailable(Object version) {
    return 'Versi baru $version tersedia';
  }

  @override
  String currentVersion(Object version) {
    return 'Versi saat ini: $version';
  }

  @override
  String get releaseNotes => 'Catatan Rilis:';

  @override
  String get checkingUpdate => 'Memeriksa pembaruan...';

  @override
  String get updateCheckFailed => 'Gagal memeriksa pembaruan';

  @override
  String get appUpToDate => 'Aplikasi sudah versi terbaru';

  @override
  String get webviewVerifyTitle => 'Verifikasi Koneksi';

  @override
  String get webviewVerifySuccess => 'Verifikasi berhasil!';

  @override
  String get webviewLoading => 'Memuat...';

  @override
  String get webviewSearchingCookie => 'Mencari cookie...';

  @override
  String get webviewContinueManual => 'Lanjutkan Manual';

  @override
  String get webviewCancelled => 'Verifikasi dibatalkan. Silakan coba lagi.';

  @override
  String get webviewRequired =>
      'Koneksi diblokir (403). Ketuk ikon ἱ0 di kanan atas untuk verifikasi, lalu coba lagi.';
}

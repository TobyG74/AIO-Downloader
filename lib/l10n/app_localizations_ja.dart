// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'AIO Downloader';

  @override
  String get downloadMedia => 'メディアダウンロード';

  @override
  String get downloadMediaDesc => '様々なプラットフォームから動画と画像をダウンロード';

  @override
  String get selectPlatform => 'プラットフォームを選択';

  @override
  String get tiktok => 'TikTok';

  @override
  String get tiktokDesc => 'TikTokから動画とスライドをダウンロード';

  @override
  String get youtube => 'YouTube';

  @override
  String get youtubeDesc => 'YouTubeから動画をダウンロード';

  @override
  String get instagram => 'Instagram';

  @override
  String get instagramDesc => 'Instagramから写真と動画をダウンロード';

  @override
  String get facebook => 'Facebook';

  @override
  String get facebookDesc => 'Facebookから動画をダウンロード';

  @override
  String get twitter => 'Twitter / X';

  @override
  String get twitterDesc => 'Twitterから動画と画像をダウンロード';

  @override
  String get pinterest => 'Pinterest';

  @override
  String get pinterestDesc => 'Pinterestから動画、GIF、画像をダウンロード';

  @override
  String get spotify => 'Spotify';

  @override
  String get spotifyDesc => 'Spotifyからトラックをダウンロード';

  @override
  String get threads => 'Threads';

  @override
  String get threadsDesc => 'Threadsから動画と画像をダウンロード';

  @override
  String get whatsappStatus => 'WhatsApp Status';

  @override
  String get whatsappStatusDesc => 'WhatsApp Statusから写真と動画を保存';

  @override
  String get history => 'ダウンロード履歴';

  @override
  String get about => 'アプリについて';

  @override
  String get aboutDesc => '様々なソーシャルメディアプラットフォームからメディアをダウンロードするアプリケーション。';

  @override
  String get version => 'バージョン';

  @override
  String get close => '閉じる';

  @override
  String get lightMode => 'ライトモード';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get enterUrl => 'URLを入力';

  @override
  String get pasteUrl => 'ここにURLを貼り付け';

  @override
  String get getMedia => 'メディアを取得';

  @override
  String get searchMedia => 'メディアを検索';

  @override
  String get processing => '処理中...';

  @override
  String get downloading => 'ダウンロード中...';

  @override
  String get waiting => 'お待ちください...';

  @override
  String get enterUrlFirst => 'URLを入力してください';

  @override
  String get selectQuality => '動画品質を選択:';

  @override
  String get selectAudioQuality => '音声品質を選択:';

  @override
  String get selectQualityFirst => '品質を選んでください';

  @override
  String get downloadVideo => '動画をダウンロード';

  @override
  String get downloadAudio => '音声をダウンロード';

  @override
  String get downloadMp4 => 'MP4をダウンロード';

  @override
  String get downloadImage => '画像をダウンロード';

  @override
  String get downloadImages => '画像をダウンロード';

  @override
  String get downloadAllImages => 'すべての画像をダウンロード';

  @override
  String get downloadAllVideos => 'すべての動画をダウンロード';

  @override
  String get downloadThumbnail => 'サムネイル画像をダウンロード';

  @override
  String get downloadSlides => 'すべてのスライドをダウンロード';

  @override
  String get downloadSuccess => 'ダウンロード成功！ギャラリーに保存されました！';

  @override
  String get downloadAllSuccess => 'すべての画像をダウンロードしました！';

  @override
  String downloadFailed(Object error) {
    return 'ダウンロード失敗: $error';
  }

  @override
  String error(Object error) {
    return 'エラー: $error';
  }

  @override
  String get image => '画像';

  @override
  String get images => '画像';

  @override
  String get video => '動画';

  @override
  String get videos => '動画/GIF';

  @override
  String get audio => 'オーディオ';

  @override
  String get photoLabel => '写真';

  @override
  String get slides => 'スライド';

  @override
  String get duration => '再生時間';

  @override
  String get videoQuality => '動画品質';

  @override
  String get hdVideo => 'HD動画';

  @override
  String get watermarkVideo => '透かし入り動画';

  @override
  String get noWatermarkVideo => '透かしなし動画';

  @override
  String get serverOption => 'サーバーを選択';

  @override
  String get server1 => 'サーバー 1';

  @override
  String get server2 => 'サーバー 2';

  @override
  String get download => 'ダウンロード';

  @override
  String get saveBtn => '保存';

  @override
  String get saveToGallery => 'ギャラリーに保存';

  @override
  String get saveAll => 'すべて保存';

  @override
  String get savedToGallery => 'ギャラリーに保存しました！';

  @override
  String failedToSave(Object error) {
    return '保存に失敗: $error';
  }

  @override
  String savedCount(Object count) {
    return '$count件をギャラリーに保存しました';
  }

  @override
  String get previewVideo => '動画プレビュー';

  @override
  String get previewPhoto => '写真プレビュー';

  @override
  String videoGif(Object count) {
    return '動画/GIF ($count)';
  }

  @override
  String imageCount(Object count) {
    return '画像 ($count)';
  }

  @override
  String imageNum(Object num) {
    return '画像 $num';
  }

  @override
  String get all => 'すべて';

  @override
  String get filter => 'フィルター';

  @override
  String get typeFilter => 'タイプ';

  @override
  String get platformFilter => 'プラットフォーム';

  @override
  String get allTypes => 'すべてのタイプ';

  @override
  String get videosOnly => '動画のみ';

  @override
  String get imagesOnly => '画像のみ';

  @override
  String get clearAll => 'すべてクリア';

  @override
  String get confirmDeleteAll => 'すべての履歴を削除しますか？';

  @override
  String get cannotUndo => 'この操作は元に戻せません。';

  @override
  String get confirmClearAll => 'すべての履歴を削除してもよろしいですか？';

  @override
  String get deleteBtn => '削除';

  @override
  String get cancel => 'キャンセル';

  @override
  String get deleted => '削除しました';

  @override
  String get deleteItem => '履歴から削除しました';

  @override
  String get allDeleted => 'すべての履歴をクリアしました';

  @override
  String get statistics => '統計';

  @override
  String totalDownloads(Object count) {
    return '合計ダウンロード数: $count';
  }

  @override
  String get noData => 'データがありません';

  @override
  String get noDownloads => 'ダウンロード履歴がありません';

  @override
  String get noDownloadsDesc => '最初のダウンロードがここに表示されます';

  @override
  String itemsFound(Object count) {
    return '$count件見つかりました';
  }

  @override
  String get loadingStatuses => 'ステータスを読み込んでいます...';

  @override
  String get notAvailableIOS => 'iOSでは利用不可';

  @override
  String get permissionRequired => '許可が必要です';

  @override
  String get grantPermission => '許可する';

  @override
  String get errorOccurred => 'エラーが発生しました';

  @override
  String get retryButton => '再試行';

  @override
  String get shareHint =>
      'YouTube、TikTok、Instagramなどの共有ボタンをタップ — AIO Downloaderを選んですぐダウンロード！';

  @override
  String get iosNotAvailable =>
      'この機能は、システムの制限によりiOSでは利用できません。WhatsAppステータスを表示および保存するには、Androidデバイスをご使用ください。';

  @override
  String get permissionDenied =>
      '権限が拒否されました。WhatsAppステータスにアクセスするには、ストレージ権限を許可してください。';

  @override
  String failedToReadStatus(Object error) {
    return 'ステータスの読み取りに失敗しました：$error';
  }

  @override
  String get permissionRequiredDesc =>
      'このアプリは、デバイス上のWhatsAppステータスファイルを読み取るために、ストレージアクセス権限が必要です。';

  @override
  String get noStatusTitle => 'ステータスなし';

  @override
  String noStatusFoundIn(Object dir) {
    return '次の場所でステータスが見つかりませんでした：\n$dir';
  }

  @override
  String get whatsappNotFound =>
      'WhatsAppステータスフォルダーが見つかりませんでした。\nWhatsAppがインストールされており、誰かのステータスを表示したことがあることを確認してください。';

  @override
  String urlDetected(Object platform) {
    return '$platform URLが検出されました';
  }

  @override
  String get updateAvailable => 'アップデートがあります';

  @override
  String get updateAvailableDesc => 'AIO Downloaderの新しいバージョンが利用可能です！';

  @override
  String get updateNow => '今すぐ更新';

  @override
  String get later => '後で';

  @override
  String newVersionAvailable(Object version) {
    return '新しいバージョン $version が利用可能です';
  }

  @override
  String currentVersion(Object version) {
    return '現在のバージョン：$version';
  }

  @override
  String get releaseNotes => 'リリースノート：';

  @override
  String get checkingUpdate => 'アップデートを確認中...';

  @override
  String get updateCheckFailed => 'アップデート確認に失敗しました';

  @override
  String get appUpToDate => 'アプリは最新です';

  @override
  String get webviewVerifyTitle => '接続の確認';

  @override
  String get webviewVerifySuccess => '確認が完了しました！';

  @override
  String get webviewLoading => '読み込み中...';

  @override
  String get webviewSearchingCookie => 'Cookieを取得中...';

  @override
  String get webviewContinueManual => '手動で続行';

  @override
  String get webviewCancelled => '確認がキャンセルされました。もう一度お試しください。';

  @override
  String get webviewRequired =>
      '接続がブロックされました (403)。右上の ἱ0 アイコンをタップして確認後、再試行してください。';
}

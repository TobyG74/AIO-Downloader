// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'AIO Downloader';

  @override
  String get downloadMedia => '下载媒体';

  @override
  String get downloadMediaDesc => '从各种平台下载视频和图片';

  @override
  String get selectPlatform => '选择平台';

  @override
  String get tiktok => 'TikTok';

  @override
  String get tiktokDesc => '从TikTok下载视频和幻灯片';

  @override
  String get youtube => 'YouTube';

  @override
  String get youtubeDesc => '从YouTube下载视频';

  @override
  String get instagram => 'Instagram';

  @override
  String get instagramDesc => '从Instagram下载照片和视频';

  @override
  String get facebook => 'Facebook';

  @override
  String get facebookDesc => '从Facebook下载视频';

  @override
  String get twitter => 'Twitter / X';

  @override
  String get twitterDesc => '从Twitter下载视频和图片';

  @override
  String get pinterest => 'Pinterest';

  @override
  String get pinterestDesc => '从Pinterest下载视频、GIF和图片';

  @override
  String get spotify => 'Spotify';

  @override
  String get spotifyDesc => '下载Spotify歌曲和播放列表';

  @override
  String get soundcloud => 'SoundCloud';

  @override
  String get soundcloudDesc => '下载SoundCloud歌曲和播放列表';

  @override
  String get douyin => '抖音';

  @override
  String get douyinDesc => '从抖音下载视频和音乐';

  @override
  String get bilibili => 'BiliBili';

  @override
  String get bilibiliDesc => '从BiliBili TV下载视频';

  @override
  String get threads => 'Threads';

  @override
  String get threadsDesc => '从Threads下载视频和图片';

  @override
  String get whatsappStatus => 'WhatsApp Status';

  @override
  String get whatsappStatusDesc => '保存WhatsApp状态中的照片和视频';

  @override
  String get history => '下载记录';

  @override
  String get about => '关于应用';

  @override
  String get aboutDesc => '一款从各类社交媒体平台下载媒体内容的应用。';

  @override
  String get version => '版本';

  @override
  String get close => '关闭';

  @override
  String get lightMode => '浅色模式';

  @override
  String get darkMode => '深色模式';

  @override
  String get enterUrl => '输入链接';

  @override
  String get pasteUrl => '在此粘贴链接';

  @override
  String get getMedia => '获取媒体';

  @override
  String get searchMedia => '搜索媒体';

  @override
  String get processing => '处理中...';

  @override
  String get downloading => '下载中...';

  @override
  String get waiting => '请稍候...';

  @override
  String get enterUrlFirst => '请先输入链接';

  @override
  String get selectQuality => '选择视频质量：';

  @override
  String get selectAudioQuality => '选择音频质量：';

  @override
  String get selectQualityFirst => '请先选择质量';

  @override
  String get downloadVideo => '下载视频';

  @override
  String get downloadAudio => '下载音频';

  @override
  String get downloadMusic => '下载音乐';

  @override
  String get downloadMp4 => '下载MP4';

  @override
  String get downloadImage => '下载图片';

  @override
  String get downloadImages => '下载图片';

  @override
  String get downloadAllImages => '下载全部图片';

  @override
  String get downloadAllVideos => '下载全部视频';

  @override
  String get downloadThumbnail => '下载缩略图';

  @override
  String get downloadSlides => '下载全部幻灯片';

  @override
  String get downloadSuccess => '下载成功，已保存到相册！';

  @override
  String get downloadAllSuccess => '全部图片下载成功！';

  @override
  String downloadFailed(Object error) {
    return '下载失败：$error';
  }

  @override
  String error(Object error) {
    return '错误：$error';
  }

  @override
  String get image => '图片';

  @override
  String get images => '图片';

  @override
  String get video => '视频';

  @override
  String get playlist => '播放列表';

  @override
  String get track => '歌曲';

  @override
  String get tracks => '歌曲';

  @override
  String get videos => '视频/GIF';

  @override
  String get audio => '音频';

  @override
  String get photoLabel => '照片';

  @override
  String get slides => '幻灯片';

  @override
  String get duration => '时长';

  @override
  String get videoQuality => '视频质量';

  @override
  String get hdVideo => '高清视频';

  @override
  String get watermarkVideo => '带水印视频';

  @override
  String get noWatermarkVideo => '无水印视频';

  @override
  String get serverOption => '选择服务器';

  @override
  String get server1 => '服务器 1';

  @override
  String get server2 => '服务器 2';

  @override
  String get download => '下载';

  @override
  String get saveBtn => '保存';

  @override
  String get saveToGallery => '保存到相册';

  @override
  String get saveAll => '保存全部';

  @override
  String get savedToGallery => '已保存到相册！';

  @override
  String failedToSave(Object error) {
    return '保存失败：$error';
  }

  @override
  String savedCount(Object count) {
    return '$count 个文件已保存到相册';
  }

  @override
  String get previewVideo => '视频预览';

  @override
  String get previewPhoto => '照片预览';

  @override
  String videoGif(Object count) {
    return '视频/GIF ($count)';
  }

  @override
  String imageCount(Object count) {
    return '图片 ($count)';
  }

  @override
  String imageNum(Object num) {
    return '图片 $num';
  }

  @override
  String get all => '全部';

  @override
  String get filter => '筛选';

  @override
  String get typeFilter => '类型';

  @override
  String get platformFilter => '平台';

  @override
  String get allTypes => '全部类型';

  @override
  String get videosOnly => '仅视频';

  @override
  String get imagesOnly => '仅图片';

  @override
  String get clearAll => '清除全部';

  @override
  String get confirmDeleteAll => '删除所有记录？';

  @override
  String get cannotUndo => '此操作无法撤销。';

  @override
  String get confirmClearAll => '确定要删除所有记录吗？';

  @override
  String get deleteBtn => '删除';

  @override
  String get cancel => '取消';

  @override
  String get deleted => '已删除';

  @override
  String get deleteItem => '已从记录中删除';

  @override
  String get allDeleted => '所有记录已清除';

  @override
  String get statistics => '统计';

  @override
  String totalDownloads(Object count) {
    return '总下载次数：$count';
  }

  @override
  String get storagePermissionDenied => '存储权限被拒绝';

  @override
  String get videoSavedToGallery => '视频已成功保存到相册';

  @override
  String get imageSavedToGallery => '图片已成功保存到相册';

  @override
  String get noData => '暂无数据';

  @override
  String get noDownloads => '暂无下载记录';

  @override
  String get noDownloadsDesc => '您的第一次下载将显示在这里';

  @override
  String itemsFound(Object count) {
    return '找到 $count 项';
  }

  @override
  String get loadingStatuses => '正在加载状态...';

  @override
  String get notAvailableIOS => 'iOS不可用';

  @override
  String get permissionRequired => '需要权限';

  @override
  String get grantPermission => '授予权限';

  @override
  String get errorOccurred => '发生错误';

  @override
  String get retryButton => '重试';

  @override
  String get shareHint =>
      '点击 YouTube、TikTok、Instagram 等应用的分享按钮 — 选择 AIO Downloader 即可立即下载！';

  @override
  String get iosNotAvailable =>
      '由于系统限制，此功能在 iOS 上不可用。请使用 Android 设备查看和保存 WhatsApp 状态。';

  @override
  String get permissionDenied => '权限被拒绝。请授予存储权限以访问 WhatsApp 状态。';

  @override
  String failedToReadStatus(Object error) {
    return '读取状态失败：$error';
  }

  @override
  String get permissionRequiredDesc => '该应用需要存储访问权限才能读取设备上的 WhatsApp 状态文件。';

  @override
  String get noStatusTitle => '无状态';

  @override
  String noStatusFoundIn(Object dir) {
    return '在以下位置未找到状态：\n$dir';
  }

  @override
  String get whatsappNotFound =>
      '未找到 WhatsApp 状态文件夹。\n请确保已安装 WhatsApp 并且您已查看过某人的状态。';

  @override
  String urlDetected(Object platform) {
    return '检测到 $platform URL';
  }

  @override
  String get updateAvailable => '可用更新';

  @override
  String get updateAvailableDesc => 'AIO Downloader 新版本已发布！';

  @override
  String get updateNow => '立即更新';

  @override
  String get later => '稍后';

  @override
  String newVersionAvailable(Object version) {
    return '新版本 $version 已发布';
  }

  @override
  String currentVersion(Object version) {
    return '当前版本：$version';
  }

  @override
  String get releaseNotes => '更新说明：';

  @override
  String get checkingUpdate => '正在检查更新...';

  @override
  String get updateCheckFailed => '检查更新失败';

  @override
  String get appUpToDate => '应用已是最新版本';

  @override
  String get webviewVerifyTitle => '连接验证';

  @override
  String get webviewVerifySuccess => '验证成功！';

  @override
  String get webviewLoading => '加载中...';

  @override
  String get webviewSearchingCookie => '正在获取Cookie...';

  @override
  String get webviewContinueManual => '手动继续';

  @override
  String get webviewCancelled => '验证已取消，请重试。';

  @override
  String get webviewRequired => '连接被拦截 (403)。请点击右上角 ἱ0 图标进行验证，然后重试。';
}

# AIO Downloader

<div align="center">
   <img src="https://raw.githubusercontent.com/TobyG74/AIO-Downloader/refs/heads/master/icons.png" alt="Icon" width="180">
   <h3>A Flutter app for downloading media from popular social platforms.<br>Paste a link, pick a quality, save to gallery.</h3>

   <p>
      <img src="https://img.shields.io/badge/Flutter-3.0%2B-blue?logo=flutter" alt="Flutter">
      <img src="https://img.shields.io/badge/Dart-3.0%2B-blue?logo=dart" alt="Dart">
      <img src="https://img.shields.io/badge/Android-5.0%2B-green?logo=android" alt="Android">
      <img src="https://img.shields.io/badge/License-MIT-yellow" alt="MIT">
   </p>
</div>

---

## Table of Contents

- [Co-Authors](#co-authors)
- [Screenshots](#screenshots)
- [Supported Platforms](#supported-platforms)
- [Features](#features)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Localization](#localization)
- [Permissions (Android)](#permissions-android)
- [Disclaimer](#disclaimer)
- [License](#license)

---

## Co-Authors

| | Name | Instagram | GitHub |
|---|---|---|---|
| <img src="https://avatars.githubusercontent.com/u/53950128?v=4" width="36" style="border-radius:50%"> | **arugaz** | [@ini.arga](https://instagram.com/ini.arga) | [arugaz](https://github.com/arugaz) |
| <img src="https://avatars.githubusercontent.com/u/69896924?v=4" width="36" style="border-radius:50%"> | **nugraizy** | [@dizy.himself](https://instagram.com/dizy.himself) | [nugraizy](https://github.com/nugraizy) |

---

## Screenshots

### Dark / Light Mode

<img src="https://raw.githubusercontent.com/TobyG74/AIO-Downloader/refs/heads/master/assets/dashboard_dark.jpg" alt="Dark mode" width="300">
<img src="https://raw.githubusercontent.com/TobyG74/AIO-Downloader/refs/heads/master/assets/dashboard_light.jpg" alt="Light mode" width="300">

### Download History

<img src="https://raw.githubusercontent.com/TobyG74/AIO-Downloader/refs/heads/master/assets/download_history.jpg" alt="Download history" width="300">

### About

<img src="https://raw.githubusercontent.com/TobyG74/AIO-Downloader/refs/heads/master/assets/about.jpg" alt="About screen" width="300">

---

## Supported Platforms

| Platform | What you can download |
|---|---|
| TikTok | Videos (no watermark / with watermark), slideshows |
| YouTube | Videos (multiple qualities), audio (MP3 / M4A / Opus) |
| Instagram | Photos, videos, carousels, Reels |
| Facebook | Videos (multiple qualities) |
| Twitter / X | Videos, GIFs, photos, multi-image posts |
| Threads | Videos, images |
| Pinterest | Videos, GIFs, images |
| Spotify | Tracks (MP3 with ID3 tags & cover art) |
| WhatsApp Status | Photos & videos from contacts' statuses |

---

## Features

- **Multiple quality selection** — video and audio where available
- **Batch download** — carousels and multi-image posts downloaded in one tap
- **Playlist support** — YouTube and Spotify playlists
- **Download history** — filterable by platform and media type
- **Share intent** — share a URL from any app and AIO Downloader picks it up automatically
- **Clipboard detection** — URL detected on app resume
- **WebView verification** — bypass Cloudflare / cookie challenges on any platform
- **Dark / Light mode** toggle
- **Multi-language UI** — English, Indonesian, Japanese, Chinese (Simplified), auto-detected from device locale
- **ID3 tag embedding** — Spotify tracks saved with title, artist and cover art

---

## Requirements

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android 5.0+ (API 21)

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Build release APK
flutter build apk --release
```

---

## Project Structure

```
lib/
├── main.dart
├── models/                      # Data models per platform
│   ├── download_history.dart
│   ├── facebook_result.dart
│   ├── instagram_result.dart
│   ├── pinterest_result.dart
│   ├── spotify_result.dart
│   ├── threads_result.dart
│   ├── tiktok_result.dart
│   ├── twitter_result.dart
│   ├── whatsapp_status.dart
│   └── youtube_result.dart
├── screens/                     # UI screens
│   ├── home_screen.dart
│   ├── download_screen.dart
│   ├── history_screen.dart
│   └── whatsapp_screen.dart
├── services/
│   ├── download_service.dart
│   ├── history_service.dart
│   ├── id3_tagger.dart
│   ├── theme_provider.dart
│   ├── url_detector_service.dart
│   ├── version_check_service.dart
│   ├── web_cookie_service.dart
│   ├── whatsapp_status_service.dart
│   └── scrapers/                # One scraper per platform
│       ├── facebook_scraper.dart
│       ├── instagram_scraper.dart
│       ├── pinterest_scraper.dart
│       ├── spotify_scraper.dart
│       ├── threads_scraper.dart
│       ├── tiktok_scraper.dart
│       ├── twitter_scraper.dart
│       └── youtube_scraper.dart
├── l10n/                        # Localization
│   ├── app_localizations.dart
│   ├── app_localizations_en.dart
│   ├── app_localizations_id.dart
│   ├── app_localizations_ja.dart
│   ├── app_localizations_zh.dart
│   ├── app_en.arb
│   ├── app_id.arb
│   ├── app_ja.arb
│   └── app_zh.arb
└── widgets/
    ├── platform_card.dart
    └── webview_cookie_dialog.dart
```

---

## Localization

The app supports 4 languages, auto-detected from device locale:

| Code | Language |
|------|----------|
| `en` | English |
| `id` | Indonesian |
| `ja` | Japanese |
| `zh` | Chinese (Simplified) |

Translations are stored as ARB files in `lib/l10n/` and implemented as hand-written Dart classes.

---

## Permissions (Android)

| Permission | Purpose |
|---|---|
| `INTERNET` | Network access for downloading media |
| `WRITE_EXTERNAL_STORAGE` | Saving files on Android 9 and below |
| `READ_MEDIA_IMAGES` | Gallery access for images (Android 13+) |
| `READ_MEDIA_VIDEO` | Gallery access for videos (Android 13+) |
| `READ_EXTERNAL_STORAGE` | Reading files (Android 12 and below) |
| `MANAGE_MEDIA` | Used by the gallery saver library |

---

## Disclaimer

This app is built for personal and educational use. You are responsible for ensuring you have the right to download any content and for complying with each platform's terms of service.

---

## License

[MIT](https://github.com/TobyG74/AIO-Downloader-Dart/blob/master/LICENSE)


## Table of Contents

- [Screenshot](#screenshot)
- [Supported Platforms](#supported-platforms)
- [Features](#features)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Localization](#localization)
- [Permissions (Android)](#permissions-android)
- [Disclaimer](#disclaimer)
- [License](#license)

---

## Screenshot

### Dark / Light mode

<img src="https://raw.githubusercontent.com/TobyG74/AIO-Downloader/refs/heads/master/assets/dashboard_dark.jpg" alt="Screenshot" width="400">
<img src="https://raw.githubusercontent.com/TobyG74/AIO-Downloader/refs/heads/master/assets/dashboard_light.jpg" alt="Screenshot" width="400">

### Download history with filters

<img src="https://raw.githubusercontent.com/TobyG74/AIO-Downloader/refs/heads/master/assets/download_history.jpg" alt="Screenshot" width="400">

### About

<img src="https://raw.githubusercontent.com/TobyG74/AIO-Downloader/refs/heads/master/assets/about.jpg" alt="Screenshot" width="400">

## Supported Platforms

| Platform | What you can download |
|---|---|
| TikTok | Videos (no watermark), slideshows (images) |
| YouTube | Videos (multiple qualities), audio (MP3/M4A/Opus) |
| Instagram | Photos, videos, carousels, Reels |
| Facebook | Videos (multiple qualities) |
| Twitter / X | Videos, GIFs, photos, multi-image posts |
| Pinterest | Videos, GIFs, images |
| Spotify | Tracks (MP3 with ID3 tags & cover art) |
| WhatsApp Status | Photos & videos from contacts' statuses |

## Features

- **Multiple quality selection** for video and audio where available
- **Batch download** for carousels and multi-image posts
- **Playlist support** for YouTube and Spotify (download entire playlists)
- **Download history** with filter by platform and media type
- **Share intent**  share a URL from any app, AIO Downloader picks it up automatically
- **Clipboard detection**  URL in clipboard is detected on app resume
- **Dark / Light mode** toggle
- **Multi-language UI**  English, Indonesian, Japanese, Chinese (auto-detected from device locale)
- **ID3 tag embedding** for Spotify tracks (title + cover art)
- Two server options for certain platforms

## Requirements

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android 5.0+ (API 21)

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Build release APK
flutter build apk --release
```

## Project Structure

```
lib/
 main.dart
 models/                     # Data models per platform
    download_history.dart
    facebook_result.dart
    instagram_result.dart
    pinterest_result.dart
    spotify_result.dart
    tiktok_result.dart
    twitter_result.dart
    whatsapp_status.dart
    youtube_result.dart
 screens/                    # UI screens
    home_screen.dart
    download_screen.dart
    history_screen.dart
    whatsapp_screen.dart
 services/
    download_service.dart
    history_service.dart
    id3_tagger.dart
    theme_provider.dart
    url_detector_service.dart
    whatsapp_status_service.dart
    scrapers/               # One scraper per platform
        facebook_scraper.dart
        instagram_scraper.dart
        pinterest_scraper.dart
        spotify_scraper.dart
        tiktok_scraper.dart
        twitter_scraper.dart
        youtube_scraper.dart
 l10n/                       # Localization
    app_localizations.dart
    app_localizations_en.dart
    app_localizations_id.dart
    app_localizations_ja.dart
    app_localizations_zh.dart
    app_en.arb
    app_id.arb
    app_ja.arb
    app_zh.arb
 widgets/
     platform_card.dart
```

## Localization

The app supports 4 languages, auto-detected from device locale:

| Code | Language |
|------|----------|
| `en` | English |
| `id` | Indonesian |
| `ja` | Japanese |
| `zh` | Chinese (Simplified) |

Translations are stored as ARB files in `lib/l10n/` and implemented as hand-written Dart classes (not code-generated).

## Permissions (Android)

| Permission | Purpose |
|---|---|
| `INTERNET` | Network access for downloading media |
| `WRITE_EXTERNAL_STORAGE` | Saving files on Android 9 and below |
| `READ_MEDIA_IMAGES` | Gallery access for images (Android 13+) |
| `READ_MEDIA_VIDEO` | Gallery access for videos (Android 13+) |
| `READ_EXTERNAL_STORAGE` | Reading files |
| `MANAGE_MEDIA` | Used by the gallery saver library |

## Disclaimer

This app is built for personal and educational use. You are responsible for ensuring you have the right to download any content and for complying with each platform's terms of service.

## License

[MIT](https://github.com/TobyG74/AIO-Downloader-Dart/blob/master/LICENSE)

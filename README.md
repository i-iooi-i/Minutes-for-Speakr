# Minutes for Speakr

> 简体中文分支：保留原版界面，默认中文，支持中英文切换。详见 [中文说明](README.zh-CN.md)。
> Simplified Chinese fork with an English language option. Original project: [Inrego/Minutes-for-Speakr](https://github.com/Inrego/Minutes-for-Speakr).

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS%20%7C%20Windows-informational.svg)](#requirements)
[![Latest release](https://img.shields.io/github/v/release/Inrego/Minutes-for-Speakr?sort=semver)](https://github.com/Inrego/Minutes-for-Speakr/releases/latest)
[![Google Play](https://img.shields.io/badge/Google%20Play-Minutes%20for%20Speakr-414141?logo=googleplay)](https://play.google.com/store/apps/details?id=com.inrego.speakr_app)

An unofficial Flutter client for [Speakr](https://github.com/learnedmachine/speakr), the self-hosted audio transcription and meeting-notes server. Runs on **Android**, **iOS**, and **Windows desktop**.

Record meetings live, upload existing audio, watch transcription progress, then read AI-generated summaries with speaker-attributed transcripts — all against your own Speakr instance.

## Features

- **Live recording** with a tag picker, pause/resume, and a Windows always-on-top mini recorder that survives switching apps.
- **Upload existing audio** (m4a, mp3, wav, …) with optional min/max speakers, language, tags, meeting date, and notes.
- **Auto-upload** watcher (Android + Windows): drop files into a folder and they upload in the background via `workmanager`.
- **Auto-record** (Windows): start recording automatically when system audio or the mic crosses a threshold — implemented in pure-Dart FFI, no native build glue.
- **Library** with live status badges (`PENDING → PROCESSING → SUMMARIZING → COMPLETED`).
- **Detail view** with three tabs: Markdown summary, speaker-attributed transcript, and metadata.
- **Speaker review**: rename speakers with autocomplete from your global speaker list and per-segment suggestion chips.
- **Auth** via `X-API-Token` stored in OS secure storage (Keychain / Keystore / Windows Credential Manager).

## Screenshots

<table>
  <tr>
    <td align="center" width="40%">
      <img src="docs/screenshots/mobile-library.png" alt="Minutes running on Android — recordings list" width="280" /><br />
      <sub>Mobile (Android)</sub>
    </td>
    <td align="center" width="60%">
      <img src="docs/screenshots/desktop-library.png" alt="Minutes running on Windows desktop — recordings list" width="520" /><br />
      <sub>Windows desktop</sub>
    </td>
  </tr>
</table>

More screenshots (onboarding, recording detail, live capture, settings) for both platforms are in [`docs/screenshots/`](docs/screenshots/).

## Download / Releases

Prebuilt artifacts for tagged versions are published on the [GitHub Releases](https://github.com/Inrego/Minutes-for-Speakr/releases) page.

### Android

- **Direct download (free):** grab the universal `.apk` from the latest [release](https://github.com/Inrego/Minutes-for-Speakr/releases/latest) and install it (enable "install from unknown sources" if your device prompts you).
- **Google Play:** [Minutes for Speakr on Google Play](https://play.google.com/store/apps/details?id=com.inrego.speakr_app).

The app is and will remain free on GitHub — every release ships the same APK here. If you'd like to support development, getting it through Google Play is a nice way to do so, and you get automatic updates in return.

### Windows

The desktop app ships in two forms on each release:

- **Installer** — `MinutesForSpeakr-Setup-<version>.exe` (Inno Setup). Recommended for most users; adds Start Menu entries and handles upgrades.
- **Portable zip** — `MinutesForSpeakr-<version>-windows-x64.zip`. Unzip anywhere and run `speakr_app.exe`; no install required.

> **Note:** the Windows builds are **unsigned**. Windows SmartScreen may show a "Windows protected your PC" warning the first time you run the installer or executable. Choose **More info → Run anyway** to proceed. This is expected for an unsigned community build.

## Android permissions

If you sideload the APK, Android will ask for a few permissions that deserve an
explanation:

- **Access to folders you pick** — only used by **auto-upload**. You point
  Minutes at folders written by your call recorder or voice recorder using
  Android's own folder picker (the Storage Access Framework); Minutes keeps that
  per-folder grant, uploads new recordings to your own Speakr server and then
  **deletes the local copy** so the phone does not fill up. The grant covers
  only the folders you picked, so Minutes cannot browse or upload anything else.
  Leave auto-upload off and you never grant it.
  *Earlier builds requested **All files access** (`MANAGE_EXTERNAL_STORAGE`) for
  this instead. That permission is being removed — the migration to the folder
  picker lands in a separate PR — and a SAF folder grant deletes other apps'
  files in that folder without any per-file prompt, so All files access was never
  actually needed.*
- **Phone state** (`READ_PHONE_STATE`) — used purely as a timing signal: when a
  call ends, Minutes schedules one scan of your watched folders so a fresh call
  recording gets picked up. No call log, no phone number, no caller identity — the
  call-log permissions are not declared at all.
- **Microphone** and **screen capture** — the in-app recorder. Screen capture is
  how Android exposes system audio, so a recording that includes the other side of
  a call asks for the system capture consent dialog each session. Only audio is
  captured; nothing about the screen is read or stored.
- **Notifications** — the persistent notification shown while recording or
  uploading.

Everything recorded or uploaded goes to the server URL you entered and nowhere
else. The app also allows plain `http://` traffic, because self-hosted Speakr
servers commonly run on a LAN address without TLS.

## Requirements

- Flutter SDK **^3.11.0** (Dart 3.11+)
- A reachable Speakr server (REST API v1) and an API token from its **Account → API Tokens** page
- Platform toolchains for whichever targets you build:
  - Android: Android Studio + Android SDK 24+
  - iOS: Xcode on macOS (untested in CI — see _Known limitations_)
  - Windows: Visual Studio 2022 with the "Desktop development with C++" workload

## Getting started

```bash
git clone https://github.com/Inrego/Minutes-for-Speakr.git
cd Minutes-for-Speakr

flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Run on the platform of your choice
flutter run -d windows
flutter run -d <android-device-id>
flutter run -d <ios-device-id>
```

On first launch the app shows an **Onboarding** screen. Enter:

1. Your Speakr server URL (e.g. `https://speakr.example.com`)
2. An API token

Both are stored via `flutter_secure_storage` and never logged. The app talks only to the server you configure — there is no hard-coded backend.

## Building releases

### Tag-based CI (recommended)

Releases are driven by Git tags. Pushing a tag of the form `vX.Y.Z` triggers the release workflow, which builds the Android AAB + universal APK and the Windows installer + portable zip, then publishes them to a GitHub Release:

```bash
git tag v1.2.3
git push origin v1.2.3
```

The version name (`X.Y.Z`) comes from the tag (without the leading `v`) and the build number comes from the GitHub Actions run number. A `workflow_dispatch` run can also build artifacts on demand (using the `version:` from `pubspec.yaml`) without publishing a Release.

### Local builds

```bash
# Windows
flutter build windows --release

# Android (arm64)
flutter build apk --release --target-platform android-arm64

# iOS (requires macOS + signing)
flutter build ipa --release
```

The Windows app icon is generated from [`speakr-mark-square.svg`](speakr-mark-square.svg) by `tools/build_icon_sources.dart`, which embeds 16/24/32/48/64/128/256 sub-images rendered fresh from the SVG (rather than downscaling a single PNG). Re-run it if the mark changes.

## Project layout

```
lib/
├── main.dart, app.dart        # bootstrap + ProviderScope + MaterialApp.router
├── api/                       # Dio client, auth interceptor, freezed DTOs
├── theme/                     # SpeakrColors, SpeakrText, ThemeData
├── routing/                   # go_router with credential-based redirect
├── services/                  # secure storage, auto-record FFI, ...
├── widgets/                   # MonoEyebrow, TagChip, MiniWave, StatusBadge, ...
├── utils/                     # formatters
├── responsive/                # phone/desktop layout switch
├── desktop/                   # Windows-tuned screens (onboarding, library, detail, settings)
└── features/                  # phone/shared screens
    ├── onboarding/  library/  detail/{tabs/}
    ├── live/{mini/, widgets/}
    ├── auto_upload/   settings/
```

Feature folders never import from each other — they go through `lib/api`, `lib/services`, or `lib/widgets`.

## Stack

| Concern         | Choice                                                     |
| --------------- | ---------------------------------------------------------- |
| State           | `flutter_riverpod` (hand-rolled providers, no codegen)     |
| Networking      | `dio` + `AuthInterceptor`                                  |
| API client      | Hand-rolled against `openapi/speakr-openapi.json`          |
| Models          | `freezed` + `json_serializable`                            |
| Routing         | `go_router`                                                |
| Secure storage  | `flutter_secure_storage`                                   |
| Audio playback  | `just_audio` (auth header passed via `setUrl`)             |
| Audio capture   | `record` (AAC m4a in temp dir, deleted after upload)       |
| Multi-window    | `desktop_multi_window` (Windows mini recorder)             |
| Background jobs | `workmanager` (auto-upload watcher)                        |
| Markdown        | `flutter_markdown_plus` (summary tab)                      |

See [`AGENTS.md`](AGENTS.md) for the rationale behind each choice and the pitfalls we have already paid for.

## Development

```bash
flutter analyze            # must be clean before merge
flutter test
dart run build_runner build --delete-conflicting-outputs   # after editing freezed models
```

The OpenAPI spec at [`openapi/speakr-openapi.json`](openapi/speakr-openapi.json) is the source of truth for endpoints. The Dart client is hand-rolled — when you add an endpoint, mirror the `_get` / `_post` / `_unwrap` helpers in [`lib/api/speakr_api.dart`](lib/api/speakr_api.dart).

## Known limitations

- **iOS** builds compile but have not been verified end-to-end (no Mac in CI).
- **Linux** is not a supported target — there is no `linux/` platform directory. (`record_linux` appears only as a transitive dependency of `record` in `pubspec.lock`; it is not a Linux build target.)
- No offline cache, no resumable uploads, no push notifications when transcription finishes — the Library re-polls on refresh.

## Contributing

Please read [`AGENTS.md`](AGENTS.md) before opening a PR. It documents the dependency pins, the lints we have intentionally disabled, and a few traps that are easy to fall into (notably: do **not** add `riverpod_generator` — the analyzer plugin it pulls in breaks `build_runner` on Dart 3.11).

## License

Released under the [MIT License](LICENSE) — Copyright (c) 2026 Rene Scott Simonsen.

This client is an independent, unofficial project and is not affiliated with or endorsed by the Speakr server project. It is published as **Minutes for Speakr**.

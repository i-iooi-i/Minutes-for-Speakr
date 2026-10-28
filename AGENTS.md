# AGENTS.md

Guidance for AI coding agents working on this repo. If you are a human, this is also a useful tour.

## What this is

A Flutter client (Android, iOS, Windows desktop) for **Speakr**, a self-hosted audio transcription / note-taking server. The app talks to the server's REST API v1.

- API spec: [`openapi/speakr-openapi.json`](openapi/speakr-openapi.json) — also at `https://<your-server>/api/v1/openapi.json`.
- Server URL is provided by the user at first run via the Onboarding screen and stored in secure storage. Never hard-code a server URL in source.
- Design source: the React mockup ("Direction A — Calm Minimal") in `../Speakr_extracted/`. Tokens (colors, type scale, layout idioms) are mirrored in [`lib/theme/`](lib/theme/) and [`lib/widgets/`](lib/widgets/).

## Stack and why

| Concern | Choice | Notes |
| --- | --- | --- |
| State | `flutter_riverpod` 2.x | Hand-rolled providers — **do not** add `riverpod_generator` / `riverpod_annotation` (see "Pitfalls"). |
| Networking | `dio` | Auth via [`AuthInterceptor`](lib/api/auth_interceptor.dart) — `X-API-Token` + `Authorization: Bearer` from secure storage. |
| API client | Hand-rolled in [`lib/api/speakr_api.dart`](lib/api/speakr_api.dart) | We deliberately did **not** generate from OpenAPI. The Dart `openapi_generator` package is stale, generates a separate built_value sub-package, conflicts with our freezed-everywhere style, and adds Java tooling. The spec stays as source of truth in `openapi/` — regenerate by hand if endpoints change. |
| Models | `freezed` + `json_serializable` | DTOs in [`lib/api/models.dart`](lib/api/models.dart). Run codegen after editing (see below). |
| Routing | `go_router` | [`lib/routing/router.dart`](lib/routing/router.dart). |
| Secure storage | `flutter_secure_storage` | [`lib/services/credentials_store.dart`](lib/services/credentials_store.dart) — server URL + API token only. Never log either. |
| Audio playback | `just_audio` | Auth-headered URL passed via `setUrl(url, headers: {...})`. |
| Audio capture | `record` | Outputs AAC m4a in `getTemporaryDirectory()`; uploaded then deleted. |
| Markdown | `flutter_markdown_plus` | Summary tab. |
| Fonts | Bundled static TTFs (Inter Tight, Source Serif 4, JetBrains Mono) | Assets under [`assets/fonts/`](assets/fonts/), registered per weight/style in `pubspec.yaml`. Nothing is fetched at runtime; `google_fonts` is **not** a dependency. |
| Permissions | `permission_handler` | Mic only. |

## Layout

```
lib/
├── main.dart  app.dart                # bootstrap + ProviderScope + MaterialApp.router
├── api/                               # Dio + hand-rolled client + auth + models
├── theme/                              # SpeakrColors, SpeakrText, tokens, ThemeData
├── routing/router.dart                 # go_router with credential-based redirect
├── services/                           # credentials_store
├── widgets/                            # MonoEyebrow, TagChip, MiniWave, StatusBadge, SpeakrIcons
├── utils/formatters.dart               # date, duration, bytes
└── features/
    ├── onboarding/   library/   detail/{tabs/}   live/   settings/
```

Each feature folder has at least a `*_screen.dart`. State that is screen-local lives in `*_controller.dart` siblings. Feature folders never import from each other — they go through `lib/api`, `lib/services`, `lib/widgets`.

## Common workflows

```bash
# Install deps
flutter pub get

# Generate freezed/json_serializable code (rerun after editing lib/api/models.dart
# or any *.freezed/*.g referenced file)
dart run build_runner build --delete-conflicting-outputs

# Static analysis (must be clean before merge)
flutter analyze

# Tests
flutter test

# Run on a device/emulator
flutter run -d windows
flutter run -d <android-device-id>

# Verify a release-style build compiles
flutter build windows --debug
flutter build apk --debug --target-platform android-arm64
```

## Pitfalls (do not relearn these)

1. **Do not add `riverpod_generator`, `riverpod_annotation`, `riverpod_lint`, or `custom_lint`.** They pull `analyzer_plugin 0.12.0`, which is incompatible with `analyzer >=7.6` and breaks `build_runner` on Dart 3.11. All providers are hand-written. If you genuinely need codegen, first check whether the analyzer ecosystem has caught up.
2. **`record_linux` must stay pinned via `dependency_overrides: record_linux: ^1.3.0`.** Without the override, `record 5.2.1` resolves an outdated `record_linux 0.7.2` whose `RecordLinux` class no longer satisfies the platform interface, and `flutter build windows` fails. Linux isn't a target but the package is included in the desktop dep graph anyway.
3. **`@JsonKey` on Freezed factory parameters produces analyzer warnings (`invalid_annotation_target`).** The generated code is correct. We suppress this lint in `analysis_options.yaml`. Don't refactor the models to silence it manually.
4. **The Speakr API wraps some responses in `{recording: {...}}` / `{tag: {...}}` and others not.** [`SpeakrApi._unwrap`](lib/api/speakr_api.dart) handles both shapes. Mirror that pattern when adding new endpoints.
5. **Audio file URLs need the auth header at request time.** `just_audio` accepts a `headers` map on `setUrl`. Do not embed the token in the URL.
6. **Fonts are bundled, and `google_fonts` is deliberately not a dependency.** The three families live as static per-weight TTFs in `assets/fonts/` and are declared under `flutter: fonts:` in `pubspec.yaml`. Do not reintroduce `google_fonts` — it would put a Google CDN call back on first launch, which breaks offline/LAN-only cold starts and contradicts the "no third-party backend" claim in the store copy. If you use a weight or style that is not registered, Flutter synthesises it from the nearest face and the type looks subtly wrong rather than failing; add the matching static TTF instead. See [`assets/fonts/README.md`](assets/fonts/README.md).

## Adding a new endpoint

1. Confirm the shape in [`openapi/speakr-openapi.json`](openapi/speakr-openapi.json) and (if available) hit the live server with `curl -H "X-API-Token: $TOKEN" ...` to see actual response keys — the spec is sometimes loose about wrapping.
2. If the response introduces a new entity, add a Freezed model in [`lib/api/models.dart`](lib/api/models.dart) and run `dart run build_runner build`.
3. Add a method to [`SpeakrApi`](lib/api/speakr_api.dart). Use the existing `_get` / `_post` / `_unwrap` helpers and the `SpeakrApiException` error path.
4. Expose a Riverpod provider in the relevant feature's `*_controller.dart` (or a new one). Prefer `FutureProvider.autoDispose.family` for per-id queries.
5. Invalidate the provider after writes (`ref.invalidate(...)`).

## Adding a new screen

1. Create the screen file under `lib/features/<name>/`.
2. Register the route in [`lib/routing/router.dart`](lib/routing/router.dart).
3. Use `Scaffold(backgroundColor: SpeakrColors.bg, ...)` and the existing widgets (`MonoEyebrow`, `TagChip`, `GhostIconButton`, etc.) before reaching for raw `Text`/`Container`.
4. Apply `SafeArea`. The design uses generous horizontal padding (24px page, 16px tight).
5. Typography: `SpeakrText.serif` for headlines/transcript content, `SpeakrText.sans` for UI text and buttons, `SpeakrText.mono` for eyebrows/timestamps/server URLs.

## Conventions

- **Scope of changes**: keep diffs focused. The plan we're executing is in `C:\Users\Strit\.claude\plans\i-want-to-create-prancy-sutherland.md` if context is missing.
- **No new dependencies without justification.** The dep tree is fragile (see Pitfall 1, 2). Prefer hand-rolled.
- **Localization:** user-visible strings use `tr()` and `lib/l10n/zh_cn.dart`. Widgets with translated copy subscribe via `LanguageScope.watch(context)`. Keep wire values, user content, and diagnostic logs untranslated.
- **Don't commit secrets.** Tokens live in secure storage; the test server URL is fine to keep in code as a default placeholder.
- **Do not run destructive git operations** without asking. There is currently no git repo initialised in the parent dir — `flutter create` did not init one.
- **Linting:** `flutter analyze` must report zero issues. Several lints are intentionally disabled in `analysis_options.yaml` — read it before adding `// ignore:` comments.

## Server-side context to keep in mind

- All endpoints are under `/api/v1/`. The interceptor rewrites `baseUrl` from secure storage on every request.
- Auth: `X-API-Token` header is canonical; we send `Authorization: Bearer` as well for compatibility.
- Status enum: `PENDING | PROCESSING | SUMMARIZING | COMPLETED | FAILED`. Anything not COMPLETED renders as a `StatusBadge` with a pulsing dot in the Library list.
- Multipart upload (`POST /recordings/upload`) takes `file`, optional `min_speakers`, `max_speakers`, `language`, `tag_ids[i]`, `meeting_date`, `notes`.

## Out of scope (recorded as future work)

- Speaker assignment UI (`/recordings/{id}/speakers/assign` exists; no screen yet).
- Calendar event extraction (`/recordings/{id}/events`).
- Offline cache / local DB.
- Push notifications when a recording finishes processing (currently we re-poll on Library refresh).
- Background uploads / resumable uploads.
- iOS verification (needs a Mac in CI or locally).

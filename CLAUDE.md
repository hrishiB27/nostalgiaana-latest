# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Nostalgiaana is a monorepo for an audio/video platform serving Hindi film songs, trivia, interviews, and podcasts. Two components, developed independently:

- **`audio/`** — Spring Boot 4.1 / Java 21 backend (`com.nostalgiaana.audio`), tracked as a **git submodule** (its own separate repo/history, nested inside this one — commits inside `audio/` don't show up in top-level `git log`, and the parent repo only tracks which submodule commit is checked out). Has its own detailed [audio/CLAUDE.md](audio/CLAUDE.md) — **read it before working on the backend**; it documents the auth/OTP flow, admin endpoints, storage buckets, payment webhook, and Flyway migration history in depth.
- **`frontend/`** — Flutter app (Dart SDK `^3.11.1`), the client for the backend above.

There is no root-level build — each component is built/run independently from within its own directory. There is no Docker Compose file, no CI/CD, and no `.env`/`.env.example` anywhere in the repo — all local service connections (Postgres, Redis, MinIO) are plain hardcoded `localhost` values in `audio/src/main/resources/application.yaml`. See "Local dev networking" below before assuming media/API calls will work from anywhere other than the machine running the backend.

## Commands

### Backend (`audio/`)
See [audio/CLAUDE.md](audio/CLAUDE.md) for the full command list, required local services (Postgres/Redis/MinIO), and environment quirks. Quick reference:
```
cd audio
./mvnw.cmd spring-boot:run                    # run (PowerShell/cmd)
./mvnw.cmd test                               # all tests
./mvnw.cmd test -Dtest=ClassName#methodName   # single test
```

### Frontend (`frontend/`)
```
cd frontend
flutter pub get             # install dependencies
flutter run                 # run on a connected device/emulator (-d chrome / -d windows etc.)
flutter analyze             # lint (flutter_lints, see analysis_options.yaml)
flutter test                # run all tests
flutter test test/widget_test.dart   # run a single test file
```
`AppConfig.apiBaseUrl` ([frontend/lib/core/config/app_config.dart](frontend/lib/core/config/app_config.dart)) hardcodes the backend URL per platform for local dev: the Android emulator needs `10.0.2.2:8080`, everything else (web/iOS sim/desktop) uses `localhost:8080`. A physical device needs the host LAN IP set manually — there's no env-based override currently wired up.

## Frontend architecture

**Feature-by-folder + layered-within-feature**, using Riverpod (`flutter_riverpod`, `Notifier`/`NotifierProvider` style — not the code-generator). Each `lib/features/<name>/` is split into:
- `data/` — API client (`*_api.dart`, talks to the backend via the shared `dioProvider`) and response/request models.
- `application/` — Riverpod `Notifier` classes holding UI state (`*_notifier.dart` + a `*_state.dart`).
- `presentation/` — screens and widgets.
- `domain/` — feature-local plain Dart types not tied to a wire format (e.g. `AuthenticatedUser`).

Features: `auth`, `user`, `category`, `content` (listener-facing browsing/playback), `admin` (shows/audios/users management), `payment` (Razorpay), `dashboard` (post-login shells). New features should follow this same internal layering.

**Core** (`lib/core/`): `network/dio_client.dart` provides the single app-wide `Dio` instance (`dioProvider`) — every request is auto-stamped with the JWT from `secure_storage_service.dart` via an interceptor, so feature code never touches the `Authorization` header directly. `network/api_error.dart` has the shared error-message extraction (`messageFor`) used by notifiers' catch blocks.

**Auth flow** mirrors the backend exactly (see audio/CLAUDE.md's Auth section): `AuthNotifier.signup` gets tokens immediately (no OTP); `login` returns an OTP challenge (`AuthStatus.otpRequired`), and `verifyOtp` is what actually persists tokens and flips state to `authenticated`. `AuthNotifier.refreshProfile` re-syncs role/membership from `GET /api/user/me` after a payment, since the Razorpay webhook that upgrades a user to PREMIUM happens server-to-server and the client's existing JWT/state can't reflect it on its own.

**Routing has no router package** — it's plain imperative `Navigator` calls. `splash_screen.dart` → `sampleui/screens/auth_landing_screen.dart` (role-portal gate: user vs admin) → login/signup screens. After successful auth, `post_auth_router.dart`'s `routeToDashboard` sends the user to `AdminDashboardShell` or `UserHomeScreenShell` based on the user's **actual** `role` from the backend response — never the portal they logged in through, since that's just a UI shortcut, not an authorization decision — and clears the back stack so the back button can't return into a login form.

**`lib/sampleui/`** holds the auth-flow visual design (landing screen, login/create-account screens, themed buttons/widgets, a full-bleed `RetroDoodleBackground` wallpaper layer behind all three) and is actively imported by `splash_screen.dart` and both dashboard shells — despite the name, it is not unused scaffolding.

Theme/colors live in `lib/core/config/theme_config.dart` (`AppTheme`, `AppColors`) — reuse these tokens rather than hardcoding colors in new screens.

**Media playback**: audio uses `just_audio`/`just_audio_windows` (`AudioPlayerNotifier`, `lib/features/content/application/audio_player_notifier.dart`), wired up and working. **There is currently no video-playback library in `pubspec.yaml` at all** — Shows (video content) have no player screen wired to any UI; `ContentDetailScreen._playNow()` shows a "coming soon" message for Shows rather than playing them. (`video_player` has no Windows/Linux backend; `media_kit` was evaluated as a replacement but is not currently a dependency — check with the user before assuming either is the intended path forward.)

## Local dev networking: the localhost/emulator/device mismatch

This is a recurring, verified issue worth understanding before touching auth, media, or admin-upload code — several sessions have independently rediscovered it.

**The root cause**: `audio/src/main/resources/application.yaml` hardcodes `localhost` in exactly four places — `spring.datasource.url` (line 6, Postgres), `spring.data.redis.host` (line 27), `minio.endpoint` (line 58), and `app.frontend-url` (line 67, currently unreferenced elsewhere in the codebase). The frontend mirrors this: `AppConfig.apiBaseUrl` ([app_config.dart](frontend/lib/core/config/app_config.dart)) hardcodes `localhost:8080` for every platform except the Android emulator, which gets the special alias `10.0.2.2` — but that alias is Android-emulator-specific and does nothing for a real physical device (Android or iOS), which also just sees `localhost` and fails to reach the dev machine.

**Why media specifically breaks, not just the API**: `ContentService.getStreamUrl()`/`presignedCoverUrl()` (`audio/src/main/java/com/nostalgiaana/audio/content/ContentService.java`) return **presigned MinIO URLs** — complete, absolute, SigV4-signed URLs with `minio.endpoint`'s host baked directly into them (`StorageService.getPresignedUrl()`, `audio/.../storage/StorageService.java`). These are handed to the Flutter client as-is and used directly (e.g. `AudioPlayerNotifier.play(stream.url, ...)`, `Image.network(content.coverUrl!)`) — nothing rewrites them client-side. `AppConfig`'s `10.0.2.2` fix only helps the JSON API calls that go through Dio's `baseUrl`; it has no effect on these presigned URLs at all, since they're absolute URLs from a completely separate service (MinIO on port 9000, not the Spring API on 8080) embedded directly in response bodies.

**What works today, unmodified**: Windows desktop only — running both the Flutter app and the backend (+ Postgres/Redis/MinIO) on the same machine, where `localhost` correctly means "this machine" for everyone involved.

**What's currently broken**: the Android emulator (API calls work via `10.0.2.2`, but every cover image, audio stream, and — if a player existed — video stream would fail, since none of those URLs get rewritten), and any real physical device (Android or iOS — both API calls *and* media URLs fail, since neither gets any non-`localhost` treatment for a real device).

**There is currently no workaround in place for any of this** — no client-side URL rewriting, no environment-variable-driven backend config, no docker-compose, no `.env`. Client-side `localhost`→`10.0.2.2` string-rewriting approaches were repeatedly built and reverted in past sessions; a more robust fix (backend-driven, e.g. deploying to a real reachable host, or splitting MinIO's internal-vs-presigning endpoint via two `MinioClient` beans so the presigned host can be independently correct) was designed and validated but has also been reverted at the user's request as of the current state of this repo. Check with the user for current intent before re-implementing either approach — this has gone back and forth multiple times.

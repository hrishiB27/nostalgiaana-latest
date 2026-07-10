# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Nostalgiaana is a monorepo for an audio/video platform serving Hindi film songs, trivia, interviews, and podcasts. Two components:

- **`audio/`** — Spring Boot 4.1 / Java 21 backend (`com.nostalgiaana.audio`). **Normal tracked directory in this repo** (not a submodule — an earlier broken/orphaned `160000` gitlink was fixed; all ~60+ files are individually tracked now). Has its own [audio/CLAUDE.md](audio/CLAUDE.md) — read it before backend work; it's current (phone-only auth, R2 storage, dual-MinIO-client presigning, migrations through `V7`).
- **`frontend/`** — Flutter app (Dart SDK `^3.11.1`), Riverpod (`Notifier`/`NotifierProvider` style, no code-generator), feature-by-folder + layered-within-feature. Windows desktop is the only platform actually GUI-tested so far.

No root-level build — each component builds/runs independently from its own directory.

## Current deployment architecture ("zero-domain", free-tier, all live and verified)

- **Backend**: deployed on **Render** (`https://nostalgiaana-audio.onrender.com`) as a Docker web service (root [render.yaml](render.yaml), `runtime: docker` — **Render has no native Java/Maven runtime**, so it must build via `audio/Dockerfile`, not `buildCommand`/`startCommand`). Free tier: the service **cold-starts after inactivity**, first request can take 30–90s.
- **Database**: **Supabase-hosted Postgres**, reached via plain JDBC (`DB_NAME`/`DB_USER`/`DB_PASS`). Supabase's Auth/BaaS product is **not** used — this is Postgres hosting only.
- **Cache**: **Upstash Redis**, TLS (`REDIS_SSL=true`), used only for login-OTP storage (5-min TTL keys), not general caching.
- **Object storage**: **Cloudflare R2** (S3-compatible), reached through the existing `io.minio` Java client (`MinioClient`) — no separate AWS/R2 SDK. One physical bucket (`nostalgiaana-media`) backs all four logical bucket properties (audio/covers/video/profile-pictures), distinguished purely by object key (raw UUID + extension).
- **Local dev**: still fully supported with `localhost` defaults for everything (Postgres/Redis/MinIO) — every env var in `application.yaml` has a working local fallback except `SUPABASE_URL`-style knobs, which don't exist (there is no Supabase Auth dependency to need one).

All of the above was verified end-to-end this session: signup → login → Redis-stored OTP → verify → JWT → presigned R2 URL → **real file download**, tested directly against the live Render deployment.

### Critical, non-obvious backend config gotchas (all fixed, all load-bearing — don't revert without understanding why)

1. **PgBouncer + Hikari**: Supabase's transaction-mode pooler (port 6543) breaks the pgjdbc driver's server-side prepared-statement cache (`"prepared statement already exists"` errors under load). Fixed via `spring.datasource.hikari.data-source-properties.prepareThreshold: 0` in `application.yaml` — enforced in code, not left as a hopeful `DB_NAME` query-string convention.
2. **Flyway baseline on a fresh Supabase project**: Supabase's `public` schema isn't truly empty on a brand-new project (default extensions/objects), so Flyway's `baseline-on-migrate` auto-triggers and silently skips `V1` (which creates `users`/`categories`/`content`) by default. Fixed via `spring.flyway.baseline-version: 0`.
3. **R2 presigned URL host**: `minio.public-endpoint` **must** point at `STORAGE_ENDPOINT` (R2's real S3 API host, `https://<account-id>.r2.cloudflarestorage.com`), **not** R2's separate "public dev URL" feature. The public dev URL is already scoped to one bucket via its subdomain, so MinIO's path-style presigned URLs (which embed the bucket name in the path) 404 against it — confirmed by direct reproduction and fixed in commit `d3ec61c`. `STORAGE_URL` is intentionally **not** an env var anymore (removed from `.env`/`.env.example`/`render.yaml`) — don't reintroduce it for this purpose.
4. **`ADMIN_BOOTSTRAP_ENABLED=true`** (Render default) means `AdminBootstrapRunner` resets the admin account (phone `9987092587`) to `ADMIN_BOOTSTRAP_PASSWORD`'s current value on **every single restart** — not a one-time seed. Check the real value in `.env` (gitignored) or Render's dashboard before assuming a previous manual password change persisted.

## Commands

### Backend (`audio/`)
```
cd audio
./mvnw.cmd spring-boot:run                    # run (PowerShell/cmd) — needs real env vars for cloud services, see below
./mvnw.cmd test                               # all tests
./mvnw.cmd test -Dtest=ClassName#methodName   # single test
```
Local run needs `DB_NAME`/`DB_USER`/`DB_PASS`, `REDIS_HOST`/`REDIS_PORT`/`REDIS_PASSWORD`/`REDIS_SSL`, `STORAGE_ENDPOINT`/`STORAGE_KEY`/`STORAGE_SECRET`/`STORAGE_BUCKET`, `JWT_SECRET`, `ADMIN_BOOTSTRAP_ENABLED`/`ADMIN_BOOTSTRAP_PASSWORD` set as real environment variables (no dotenv library on the classpath — `.env` is not auto-loaded; export values into the shell session yourself, e.g. `$env:DB_NAME = "..."` in PowerShell) to reach the live Supabase/Upstash/R2 services. Omit them entirely to fall back to local Postgres/Redis/MinIO on `localhost` defaults instead.

### Frontend (`frontend/`)
```
cd frontend
flutter pub get
flutter analyze
flutter test
flutter run -d windows --dart-define=API_BASE_URL=https://nostalgiaana-audio.onrender.com/api
flutter run -d <emulator-id> --dart-define=API_BASE_URL=https://nostalgiaana-audio.onrender.com/api
```
`AppConfig.apiBaseUrl` ([app_config.dart](frontend/lib/core/config/app_config.dart)) resolves in priority order: (1) `--dart-define=API_BASE_URL=...` explicit override, (2) `kReleaseMode` → the Render URL automatically (so a release build never accidentally ships pointed at localhost), (3) per-platform local-dev default (`10.0.2.2` for Android emulator, `localhost` elsewhere) for plain debug `flutter run`. **Media URLs need no client-side rewriting at all** — cover/audio/video URLs come back as complete presigned R2 URLs in API responses and are used as-is; this also means the historical "emulator/device can't reach localhost media" problem is resolved for real devices/emulators as long as `API_BASE_URL` is overridden, since R2 URLs are real internet-reachable HTTPS.

## Frontend architecture

Each `lib/features/<name>/` is split into `data/` (API client + models), `application/` (Riverpod `Notifier` + state), `presentation/` (screens/widgets), `domain/` (feature-local plain Dart types). Features: `auth`, `user`, `category`, `content`, `admin`, `payment`, `dashboard`. `lib/core/` holds the shared `dioProvider` (JWT auto-stamped via interceptor, reading from `secure_storage_service.dart`), `api_error.dart`'s `messageFor()` (unwraps the backend's `{error, status, timestamp}` shape — falls back to a generic "Something went wrong" string **only** when there's no HTTP response at all, i.e. a connection failure, not a business-logic error), and `theme_config.dart` (`AppColors`/`AppTheme` — the "Modern Retro" cream/crimson/teal/gold palette, Playfair Display headings + Inter body via `google_fonts`).

**Auth**: phone-only, no email anywhere (migrated away in backend `V6`/`V7`; frontend has zero email references). Signup collects profile fields + password in one step, no OTP. Login is two-step: `POST /api/auth/login` → OTP challenge → `POST /api/auth/verify-otp` → real JWTs. This is the **original custom system**, unchanged — see "Known-reverted work" below.

**Media playback**:
- **Audio**: `just_audio`/`just_audio_windows`, via `AudioPlayerNotifier` (`features/content/application/audio_player_notifier.dart`) — a single app-wide `NotifierProvider` wrapping one `AudioPlayer`, surfaced via the persistent `NowPlayingBar` mini-player (mounted in both `UserHomeScreenShell`'s and `ContentDetailScreen`'s `Scaffold.bottomNavigationBar` — it was previously only in the dashboard shell, so playing from the detail screen wouldn't show it until popping back; fixed).
- **Video**: `media_kit`/`media_kit_video` (**not** `video_player`, which has no Windows/Linux backend — this project's tested platform). `VideoPlayerNotifier` mirrors `AudioPlayerNotifier`'s shape; `VideoPlayerScreen` is a dedicated full-screen route (video doesn't persist across navigation the way audio does — `stop()` is called on screen dispose). On Android/iOS, `VideoPlayerScreen` forces landscape orientation + immersive-sticky fullscreen on entry and restores portrait/edge-to-edge on exit (guarded by a `defaultTargetPlatform` check — desktop/web untouched).
- **Mutual exclusivity**: `AudioPlayerNotifier.play()` and `VideoPlayerNotifier.play()` each pause the other via a cross `ref.read(otherProvider.notifier).pause()` call, so audio and video never play simultaneously.

**Mobile layout defensiveness** (audited and fixed this session, not a blanket rewrite — only real, verified risk points were touched): the 6-box OTP grid in `login_screen.dart` used fixed 46px-wide boxes in a `Row` with no `Expanded`, which numerically overflowed on a 320px-wide screen (now `Expanded`-wrapped); both `login_screen.dart` and `create_account_screen.dart` had `NeverScrollableScrollPhysics` on forms with real text fields (real keyboard-overflow risk, now removed, scrolling kept as a fallback rather than the primary layout strategy); both had an `extendBodyBehindAppBar`+`SafeArea` combination where content could render under the AppBar title (fixed with explicit `kToolbarHeight` top padding); `premium_upgrade_sheet.dart` was missing a scrollable wrapper that its sibling `content_form_sheet.dart` already had correctly (fixed); content/video titles got `maxLines`/`overflow` defense. Fixed-size decorative elements (icons, avatars, the horizontally-scrolling carousel cards' fixed widths) were deliberately **not** touched — they're correct as-is, not overflow risks.

## Known-reverted work — do not assume these exist, don't resurrect without checking with the user first

- **Supabase Auth migration**: a full replacement of the custom JWT/Redis-OTP auth system with Supabase Auth (`signInWithOtp`, JWKS validation via `spring-boot-starter-oauth2-resource-server`, a Postgres trigger syncing `auth.users`→`public.users`) was designed and partially implemented, then **fully reverted** at request. Nothing from it exists in the codebase — auth is still the original custom system described above.
- **Desktop-adaptive UI**: a `Responsive` breakpoint utility, `Center`+`ConstrainedBox(maxWidth: 1000)` wrapping on major screens, a shelf→`GridView` conversion for the home screen's content carousels, and a real `NavigationRail` for `AdminDashboardShell`'s three destinations (Manage Shows/Audios/Users) were designed, built, and verified via `flutter analyze` — then **entirely reverted** before being committed, at request. `origin/main` has none of it. This is a real, worthwhile next task, but it needs to be built fresh, not resumed — and the `NavigationRail`-vs-"just constrain the mini-player" decision was a genuine fork last time (user chose the rail), not something to assume unprompted.

## Verification notes for whoever picks this up next

Backend correctness has been proven with real requests against the live Render deployment (not just unit-level reasoning) — login, OTP, JWT issuance, and a full presigned-URL file download all succeeded end-to-end. Frontend changes this session pass `flutter analyze` cleanly and are reasoned against already-working existing patterns, but have **not** been visually/interactively GUI-tested — this environment has no reliable UI-automation pipeline for the native Windows app. Don't report frontend UI work as "done" without a manual pass; say explicitly that only static analysis was possible, same as this file does.

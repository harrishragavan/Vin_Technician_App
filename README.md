# Vin Technician App

Android app (Flutter, iPhone-ready) for Vin Chakra's technician portal, service
invoice and chief technician dashboard. Talks only to the versioned mobile API
in `vin_chakra` (`harrishragavan/vin_chakra`, branch `feature/mobile-api`) — see
that repo for the 14 backend fixes and the 32 `vin_chakra/mobile/v1/*`
endpoints this app is built against.

## Status

**Phase 2 — App foundation** (of the plan's 8 phases). Built so far:

- Flutter project scaffolded for Android (`minSdk 26`, `targetSdk 36`),
  iPhone-ready plugin choices throughout.
- Design system (`lib/core/design`): the workshop-ledger palette, four-size
  type scale with Instrument Sans + IBM Plex Mono (bundled, not fetched at
  runtime), 8 dp spacing, one `AppTheme` with Material's default look
  switched off.
- Network layer (`lib/core/api`): Dio client for
  `/api/method/vin_chakra.mobile.v1.*`, a typed `ApiException` for the
  `{code, message}` error contract, `client_request_id` on every write.
- Secure token storage (`lib/core/storage`), Android Keystore-backed.
- Local database (`lib/core/db`): Drift, with the option-list cache wired up;
  ticket/job/invoice tables land in Phase 3 once `tech.*` exists server-side.
- Location service (`lib/core/location`): foreground-only GPS via geolocator,
  fake-GPS flag, accuracy retry, optional reverse geocoding.
- Full sign-in flow (`lib/features/auth`): site URL bootstrap (QR scan or
  manual entry on staging/debug, baked in on release), sign-in, background
  `auth.me` confirmation on launch, 401 → forced sign-out from anywhere in
  the app, sign-out, role-based routing (`go_router`) to a technician or
  chief home shell.
- CI (`.github/workflows/build.yml`): analyze + test + build an APK on every
  push; a signed app bundle on `main`.

Not built yet: the actual Today/Jobs/Job sheet/invoice/chief screens (Phases
3–5 — they need the real `tech.*`/`invoice.*`/`chief.*` endpoints to build
against), push notifications (Phase 6), and the eight backend fixes (all in
`vin_chakra`, not this repo).

## Decisions used (defaults from the plan)

All eight open decisions were left at their stated default so Phase 0 could
start without waiting on sign-off. Revisit these in `vin_chakra` (Mobile
Settings) and here as needed:

1. Google Play internal track (managed signing, in-app updates).
2. OTP blocked for a technician-typed number — only Customer/Contact numbers.
3. Technician submits the service invoice on site.
4. Payment recording not in v1.
5. Assign/reassign included in the chief app.
6. Google Maps only.
7. English only, all strings in `lib/l10n`-ready structure (not yet
   extracted — still inline, see Phase 6).
8. Android now, iPhone-ready code (every plugin chosen works on iOS; no iOS
   platform files added yet).

## Local setup

Requires Flutter 3.47.7 (pinned — see `.metadata`), JDK 17 (**not** 21/25 —
Gradle's toolchain detection does not yet support newer JDKs reliably), and
the Android SDK (`minSdk 26`, `compileSdk 36`).

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Secrets (never committed — see `.gitignore`)

| File | Purpose | Needed for |
|---|---|---|
| `android/local.properties` | `flutter.sdk` path (auto-written by `flutter`) | any build |
| `android/key.properties` | release keystore path + passwords | signed release builds |
| `android/app/google-services.json` | Firebase project config | push notifications (Phase 6) |
| `--dart-define=API_BASE_URL=...` or `android/local.properties` (`MAPS_API_KEY=...`) | prod API URL / Maps key | release builds |

In CI these come from repository secrets: `ANDROID_KEYSTORE_BASE64`,
`ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`,
`GOOGLE_SERVICES_JSON_BASE64`, `MAPS_API_KEY`, and the repository variable
`API_BASE_URL_PROD`.

Without these, debug and CI builds still succeed: the app falls back to the
debug signing key, no Maps key (map screens won't render once built), and no
push. Sign-in needs a reachable `vin_chakra` site either way — set it via
`--dart-define=API_BASE_URL=https://your-site` or, on a debug build, through
the on-device site-setup screen.

## Code layout

```
lib/
  core/
    api/        Dio client, typed errors, base-URL + api-client providers
    db/         Drift database (local cache, single source of truth)
    design/     Theme, colours, typography, spacing — the only place
                allowed to hard-code a hex value or font size
    location/   Foreground GPS fixes
    routing/    go_router + auth-aware redirects
    storage/    Secure token storage
  features/
    auth/       Site setup, sign-in, session lifecycle
    technician/ Technician portal (Phase 3+)
    invoice/    Service invoice (Phase 4+)
    chief/      Chief technician dashboard (Phase 5+)
```

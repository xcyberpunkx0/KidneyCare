# KidneyCare

KidneyCare (formerly Recora) is a mobile medical-history vault for a dialysis patient's caregiver. Capture
prescriptions, lab reports, discharge summaries and bills; verify what the
AI extracted; and build a searchable longitudinal record that works offline.

Implemented from the **Sanjeevani Medical Vault** Claude Design project
(final combined direction: light "Recora" language, dark "Nightingale"
night-shift theme).

## Running

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define=GEMINI_API_KEY=<your key>
```

Without `GEMINI_API_KEY` the app fully works offline (vault, labs,
medicines, timeline, search); the two AI features — capture extraction and
Ask — explain calmly that a key is needed. Users can paste their own
Gemini key in **Settings → Gemini API key** (free at
[aistudio.google.com](https://aistudio.google.com)); it is kept in the
platform's secure storage and never leaves the device. No key is ever
bundled into the APK.

## Release builds

Release signing reads `android/key.properties` (gitignored), which points
at a keystore outside the repo. Without that file, release builds fall
back to debug signing so `flutter run --release` works anywhere.

```sh
flutter build apk --release --split-per-abi
```

On first launch the local database seeds a realistic demo history
(N. Ramachandran · 63 · CKD-5, HD Mon/Wed/Fri) so every screen has content.

## Architecture

Feature-first clean architecture:

```
lib/
  core/          # design system, router, db, network, shared widgets
    theme/       # AppColors + AppTypography ThemeExtensions (all tokens)
    storage/     # Drift database, DAOs, demo seed
    network/     # Dio + retry interceptor, API config
    services/    # GeminiClient, ImageStore, PhotoPicker
    widgets/     # AppCard, MetricTile, RecordTile, EmptyState, ...
    utils/       # Result<T> + AppFailure hierarchy
  shared/domain/ # cross-feature vocabulary (DocumentType, LabMetric, ...)
  features/
    home/  labs/  medications/  documents/  capture/  ask/
    timeline/  patient/  settings/
      presentation/ (pages, widgets, controllers)
      domain/       (entities, repositories, usecases)
      data/         (models, datasources, repository_impl)
```

Conventions:

- **State**: Riverpod 3 (`Notifier`, `StreamProvider`); no global mutable
  state. Screens watch narrowly-scoped providers.
- **Persistence**: Drift (SQLite). All reads are reactive `watch*` streams,
  so every screen updates live after a capture is saved. Generated row
  classes serve as entities across features; feature domain layers add
  aggregates and derivation logic (e.g. `buildVitalsSnapshot`,
  `LabSeries`).
- **Errors**: repositories return `Result<T>`; every failure is an
  `AppFailure` with calm, user-presentable copy.
- **Theming**: every color comes from the `AppColors` ThemeExtension —
  light (Recora, violet accent) and dark (Nightingale, glowing mint,
  numbers switch to Spline Sans Mono). No hardcoded colors in widgets;
  the two deliberate exceptions are camera chrome and paper-preview tones,
  which depict physical objects.
- **AI**: `GeminiClient` (Dio, retry, JSON-mode) is shared by the capture
  extraction datasource and the Ask datasource. Prompts live in the
  feature datasources. Extraction returns per-field confidence; fields
  under 85% must be checked (edited, confirmed, or an alternative chosen)
  before "Save to timeline" unlocks.
- **Images**: original scans are stored byte-for-byte under
  `documents/scans/`; a downscaled preview is generated for grids.

## Tests

```sh
flutter test
```

Covers the `Result` type, vitals/attention derivation, lab range status,
extraction DTO parsing, confidence banding, and the review screen's
verification gate.

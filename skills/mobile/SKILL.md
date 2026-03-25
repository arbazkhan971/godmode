---
name: mobile
description: Mobile app development (iOS/Android/cross-platform).
---

## Activate When
- `/godmode:mobile`, "mobile app", "iOS", "Android"
- "React Native", "Flutter", "Swift", "Kotlin"
- App signing, store submission, mobile performance

## Workflow

### 1. Platform Assessment
```
Target: iOS|Android|both
Approach: native|cross-platform|hybrid
IF cross-platform:
  Framework: React Native|Flutter|KMP|.NET MAUI
  Shared: business logic only|business+UI|everything
```
```bash
# Detect existing mobile project
ls ios/ android/ pubspec.yaml 2>/dev/null
ls package.json | xargs grep -l "react-native" 2>/dev/null
```

### 2. Architecture Selection
```
MVVM: most apps, reactive UI frameworks
  models/ -> views/ -> viewmodels/
MVI: complex state, unidirectional data flow
  State (immutable) -> Intent (actions) -> Reducer
Clean Architecture: large apps, complex business logic
  Presentation -> Domain -> Data (dependency inversion)
```
IF app < 10 screens: MVVM is sufficient.
IF state management complex: prefer MVI.
IF > 30 screens with multiple data sources: Clean Arch.

### 3. Project Setup
**iOS:** bundle ID, min deployment target, ATS,
  Info.plist privacy descriptions, launch screen.
**Android:** package name, min/target SDK, ProGuard,
  build variants (debug/staging/release).
**React Native:** TypeScript, React Navigation,
  state management, Metro config.
**Flutter:** pubspec.yaml, state management (Riverpod/Bloc),
  GoRouter, flavors (dev/staging/prod).

### 4. App Signing
```
iOS: Dev cert + provisioning profile (development),
  Dist cert + App Store profile (release).
  NEVER share private keys. Use Fastlane match.
Android: keytool -genkey -v -keystore release.keystore
  NEVER lose the keystore (app updates impossible).
  Store in secure vault, not in VCS.
```

### 5. Store Submission
```
iOS App Store:
  [ ] Review Guidelines compliance
  [ ] Privacy policy URL
  [ ] App Privacy labels
  [ ] Screenshots (6.7", 5.5" minimum)
  [ ] App name (30 char max)
Google Play:
  [ ] Developer Policy compliance
  [ ] Data safety section
  [ ] AAB format (not APK)
  [ ] Screenshots + feature graphic
```

### 6. Performance
```
Battery: significant-change location (not continuous),
  batch network requests, 60fps animations.
Memory: resize images to display size, LRU cache,
  recycle views, release on dispose.
Network: offline-first, request coalescing,
  WebP/AVIF images, pagination (20-50 items).
Startup: cold < 1s, warm < 500ms.
  Defer analytics/flags, lazy-load modules.
```
IF cold start > 2s: profile and defer init.
IF app size > 50MB: audit assets, use on-demand resources.

### 7. Platform Features
```
Push: APNs (iOS) / FCM (Android)
Deep links: Universal Links / App Links
Biometrics: Face ID/Touch ID / Fingerprint
IAP: StoreKit 2 / Play Billing Library
Crash: Firebase Crashlytics / Sentry
A11y: VoiceOver / TalkBack support
```

## Hard Rules
1. NEVER store secrets in app binary (decompilable).
2. NEVER lose Android release keystore.
3. ALWAYS test on minimum supported OS version.
4. ALWAYS meet 44x44px minimum touch targets.
5. Cold start < 2s, app size < 50MB initial download.

## TSV Logging
Append `.godmode/mobile-results.tsv`:
```
timestamp	platform	screen	action	tests	app_size_mb	status
```

## Keep/Discard
```
KEEP if: builds all platforms, tests pass,
  cold start < 1s, size within budget.
DISCARD if: crashes, perf regression,
  guidelines violated, min OS API missing.
```

## Stop Conditions
```
STOP when FIRST of:
  - Builds + runs on all target platforms
  - Cold start < 2s, size < 50MB
  - Platform conventions pass
  - No secrets in VCS
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| Build fails one platform | Check deps, native linking |
| Crashes on startup | Check permissions, async init |
| Store rejection | Read reason, fix metadata/privacy |

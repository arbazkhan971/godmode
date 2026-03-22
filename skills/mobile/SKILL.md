---
name: mobile
description: |
  Mobile app development skill. Activates when building, optimizing, or shipping iOS and Android applications. Covers architecture patterns (MVVM, MVI, Clean Architecture), cross-platform frameworks (React Native, Flutter), native development (Swift, Kotlin), app signing and provisioning, app store submission workflows, and mobile-specific performance optimization (battery, memory, network). Every recommendation is platform-aware and includes concrete implementation. Triggers on: /godmode:mobile, "mobile app", "iOS", "Android", "React Native", "Flutter", "app store", "mobile performance".
---

# Mobile — Mobile App Development

## When to Activate
- User invokes `/godmode:mobile`
- User says "mobile app", "iOS app", "Android app", "build for mobile"
- User mentions "React Native", "Flutter", "Swift", "Kotlin", "SwiftUI", "Jetpack Compose"
- When setting up app signing, provisioning profiles, or app store submission
- When optimizing mobile-specific performance (battery, memory, network)
- When implementing platform-specific features (push notifications, deep links, biometrics)

## Workflow

### Step 1: Platform Assessment
Determine the mobile development approach:

```
MOBILE PROJECT ASSESSMENT:
Project type: <new app | existing app | adding mobile to web>
Target platforms: <iOS | Android | both>
Development approach: <native | cross-platform | hybrid>

If cross-platform:
  Framework: <React Native | Flutter | .NET MAUI | Kotlin Multiplatform>
  Shared code target: <business logic only | business + UI | everything>

If native:
  iOS: <Swift + UIKit | Swift + SwiftUI | Objective-C (legacy)>
  Android: <Kotlin + Jetpack Compose | Kotlin + XML Views | Java (legacy)>

Project constraints:
  Min iOS version: <e.g., iOS 16>
  Min Android API: <e.g., API 26 (Android 8.0)>
  Offline support: <required | nice-to-have | not needed>
  App size budget: <e.g., < 50MB>
  Target devices: <phone | tablet | both>
```

### Step 2: Architecture Pattern Selection
Choose and implement the appropriate architecture:

#### MVVM (Model-View-ViewModel)
Best for: Most mobile apps, especially with reactive UI frameworks.
```
MVVM STRUCTURE:
├── models/           # Data models and entities
│   ├── User.swift / User.kt
│   └── Product.swift / Product.kt
├── views/            # UI layer (SwiftUI Views / Composables / React components)
│   ├── HomeScreen.swift / HomeScreen.kt
│   └── ProfileScreen.swift / ProfileScreen.kt
├── viewmodels/       # Presentation logic, state management
│   ├── HomeViewModel.swift / HomeViewModel.kt
│   └── ProfileViewModel.swift / ProfileViewModel.kt
├── repositories/     # Data access abstraction
│   ├── UserRepository.swift / UserRepository.kt
│   └── ProductRepository.swift / ProductRepository.kt
├── services/         # API clients, database, external services
│   ├── ApiService.swift / ApiService.kt
```

#### MVI (Model-View-Intent)
Best for: Complex state management, unidirectional data flow.
```
MVI STRUCTURE:
State:  Immutable data class representing entire screen state
Intent: Sealed class of all possible user actions
Effect: One-shot side effects (navigation, toast, etc.)

Flow:
  User Action → Intent → Reducer → New State → UI Update
                              ↓
                         Side Effect → Effect Handler

Rules:
  - State is always immutable — new state = new object
  - Every state transition is traceable through intents
  - Side effects are separated from state updates
  - Time-travel debugging: replay intents to reproduce any state
```

#### Clean Architecture
Best for: Large apps with complex business logic, multiple data sources.
```
CLEAN ARCHITECTURE LAYERS:
┌──────────────────────────────────────────┐
│  Presentation Layer                       │
│  (Views, ViewModels, Presenters)          │
│  Depends on: Domain                       │
├──────────────────────────────────────────┤
│  Domain Layer                             │
│  (Use Cases, Entities, Repository         │
│   Interfaces)                             │
│  Depends on: nothing (innermost layer)    │
├──────────────────────────────────────────┤
│  Data Layer                               │
│  (Repository Implementations, API         │
│   Clients, Database, Mappers)             │
│  Depends on: Domain                       │
```

### Step 3: Project Setup
Configure the mobile project with production-ready defaults:

#### iOS (Swift)
```
IOS PROJECT SETUP:
[ ] Xcode project with proper bundle ID: <com.company.appname>
[ ] Development team configured
[ ] Minimum deployment target set: iOS <version>
[ ] Device families selected: iPhone / iPad / Universal
[ ] App Transport Security configured (HTTPS enforcement)
[ ] Info.plist privacy descriptions added (camera, location, photos, etc.)
[ ] Launch screen configured (LaunchScreen.storyboard or Info.plist)
[ ] App icons provided (all required sizes)
[ ] Swift Package Manager / CocoaPods configured for dependencies
[ ] Scheme configurations: Debug, Staging, Release
[ ] Build settings: optimization level, bitcode, strip symbols
```

#### Android (Kotlin)
```
ANDROID PROJECT SETUP:
[ ] Package name: <com.company.appname>
[ ] Minimum SDK: API <level>
[ ] Target SDK: API <latest stable>
[ ] Compile SDK: API <latest stable>
[ ] Gradle configured with Kotlin DSL
[ ] Build variants: debug, staging, release
[ ] ProGuard/R8 rules configured for release
[ ] Signing configs for debug and release
[ ] AndroidManifest permissions declared (camera, location, internet, etc.)
[ ] App icons: adaptive icons with foreground + background layers
[ ] Material Design theme configured
[ ] Dependency injection: Hilt / Koin configured
[ ] Network security config (cleartext traffic rules)
```

#### React Native
```
REACT NATIVE SETUP:
[ ] Project initialized with latest stable RN version
[ ] TypeScript configured
[ ] Navigation: React Navigation configured with type-safe routes
[ ] State management: <Redux Toolkit | Zustand | MobX> configured
[ ] Native modules bridged (if needed)
[ ] Metro bundler configuration optimized
[ ] Flipper debugging configured
[ ] Hermes engine enabled (Android)
[ ] JSC or Hermes configured (iOS)
[ ] Platform-specific code organized: *.ios.tsx / *.android.tsx
[ ] Environment variables: react-native-config configured
```

#### Flutter
```
FLUTTER SETUP:
[ ] Project created with proper organization prefix
[ ] Dart SDK constraints set in pubspec.yaml
[ ] State management: <Riverpod | Bloc | Provider> configured
[ ] Navigation: GoRouter or auto_route configured
[ ] Flavors configured: dev, staging, production
[ ] Platform-specific code: MethodChannels for native integration
[ ] Code generation: build_runner, freezed for immutable models
[ ] Localization: flutter_localizations configured
[ ] Asset management: fonts, images, SVGs organized
[ ] Testing: widget tests, integration tests configured
```

### Step 4: App Signing & Provisioning

#### iOS Signing
```
IOS SIGNING SETUP:
1. Apple Developer Account:
   - Team ID: <team ID>
   - Bundle ID registered: <com.company.appname>

2. Certificates:
   - Development certificate: for debug builds on physical devices
   - Distribution certificate: for App Store / Ad Hoc / Enterprise
   - NEVER share private keys via unencrypted channels

3. Provisioning profiles:
   - Development: links dev certificate + device UDIDs + bundle ID
   - Ad Hoc: for internal testing (limited to 100 devices per type)
   - App Store: for App Store distribution (no device restriction)
   - Enterprise: for in-house distribution (requires Enterprise account)
```

#### Android Signing
```
ANDROID SIGNING SETUP:
1. Generate release keystore:
   keytool -genkey -v -keystore release.keystore \
     -alias <alias> -keyalg RSA -keysize 2048 -validity 10000

2. Configure signing in build.gradle.kts:
   signingConfigs {
     create("release") {
       storeFile = file(keystorePath)
       storePassword = System.getenv("KEYSTORE_PASSWORD")
       keyAlias = System.getenv("KEY_ALIAS")
       keyPassword = System.getenv("KEY_PASSWORD")
     }
   }

```

### Step 5: App Store Submission

#### iOS App Store
```
APP STORE SUBMISSION CHECKLIST:
Pre-submission:
  [ ] App reviewed against App Store Review Guidelines
  [ ] Privacy policy URL hosted and accessible
  [ ] App Privacy labels completed (data collection declarations)
  [ ] All required app metadata prepared:
      - App name (30 char max)
      - Subtitle (30 char max)
      - Description (4000 char max)
      - Keywords (100 char max, comma-separated)
      - Screenshots: 6.7" (iPhone 15 Pro Max), 6.5" (iPhone 14 Plus)
      - Screenshots: 12.9" iPad Pro (if Universal)
      - App preview videos (optional, 15-30 seconds)
      - Category and subcategory selected
      - Age rating questionnaire completed
```

#### Google Play Store
```
PLAY STORE SUBMISSION CHECKLIST:
Pre-submission:
  [ ] App reviewed against Google Play Developer Policy
  [ ] Privacy policy URL hosted and accessible
  [ ] Data safety section completed
  [ ] All required store listing prepared:
      - App name (30 char max)
      - Short description (80 char max)
      - Full description (4000 char max)
      - Screenshots: phone (min 2, max 8)
      - Feature graphic: 1024x500
      - App icon: 512x512
      - Category selected
      - Content rating questionnaire completed
      - Target audience and content declarations
```

### Step 6: Mobile-Specific Performance

#### Battery Optimization
```
BATTERY PERFORMANCE CHECKLIST:
[ ] Location updates: use significant-change service, not continuous GPS
[ ] Background tasks: use BGTaskScheduler (iOS) / WorkManager (Android)
[ ] Network requests: batch requests, avoid polling (use push/WebSocket)
[ ] Animations: 60fps target, avoid overdraw, use hardware acceleration
[ ] Sensors: stop accelerometer/gyroscope when not needed
[ ] Timers: avoid frequent timers, use system-aligned wake-ups
[ ] Bluetooth/NFC: scan only when needed, stop scanning in background
[ ] Dark mode: OLED screens save power with dark themes

Measurement:
  iOS: Xcode → Debug Navigator → Energy Impact gauge
       Instruments → Energy Log template
  Android: Battery Historian (adb bugreport)
           Android Studio → Profiler → Energy
```

#### Memory Management
```
MEMORY PERFORMANCE CHECKLIST:
[ ] Images: resize to display size (never load 4K image for 100px thumbnail)
[ ] Image caching: use LRU cache with size limit (SDWebImage, Coil, cached_network_image)
[ ] Lists: recycle views (UICollectionView, RecyclerView, ListView.builder)
[ ] Navigation: release resources when screen is popped
[ ] Subscriptions: cancel observers/streams on dispose (avoid retain cycles / memory leaks)
[ ] Large data: stream/paginate instead of loading everything into memory
[ ] WebViews: release when not visible (they consume significant memory)

iOS-specific:
  - Use weak/unowned references to break retain cycles
  - Profile with Instruments → Leaks / Allocations
  - Use autorelease pools for batch operations
  - Monitor memory warnings: didReceiveMemoryWarning

```

#### Network Optimization
```
NETWORK PERFORMANCE CHECKLIST:
[ ] Offline-first: cache data locally, sync when connected
[ ] Request coalescing: batch multiple API calls into one
[ ] Image optimization: use WebP/AVIF, request appropriate size
[ ] Pagination: load data in pages (20-50 items), infinite scroll
[ ] Compression: enable gzip/brotli for API responses
[ ] Certificate pinning: prevent MITM attacks (but plan for rotation)
[ ] Retry with exponential backoff: don't hammer failing servers
[ ] Connectivity-aware: reduce quality on cellular, full quality on WiFi

Offline support pattern:
  1. Local database as single source of truth (SQLite, Core Data, Room, Hive)
  2. Read from local database (always fast, always available)
  3. Sync with server in background (push changes, pull updates)
  4. Handle conflicts (last-write-wins, merge, user-resolution)
```

#### App Startup Performance
```
APP STARTUP OPTIMIZATION:
Target: cold start < 1 second, warm start < 500ms

Reduce work before first frame:
  [ ] Defer non-critical initialization (analytics, feature flags)
  [ ] Lazy-load modules not needed for first screen
  [ ] Use splash screen properly (system splash, not blank screen)
  [ ] Minimize dependency injection scope at startup
  [ ] Precompute heavy resources at build time, not runtime

Reduce binary size:
  [ ] Tree-shake unused code (ProGuard/R8 for Android)
  [ ] Strip debug symbols for release builds
  [ ] Compress assets (images, fonts)
  [ ] Use app thinning (iOS) / app bundles (Android)
```

### Step 7: Platform-Specific Features

```
COMMON MOBILE FEATURES CHECKLIST:
[ ] Push notifications: APNs (iOS) / FCM (Android)
[ ] Deep linking: Universal Links (iOS) / App Links (Android)
[ ] Biometric authentication: Face ID/Touch ID / Fingerprint/Face
[ ] In-app purchases: StoreKit 2 (iOS) / Google Play Billing Library
[ ] Crash reporting: Firebase Crashlytics / Sentry
[ ] Analytics: Firebase Analytics / Amplitude / Mixpanel
[ ] Accessibility: VoiceOver (iOS) / TalkBack (Android) support
[ ] Dark mode: system theme detection and custom theme support
[ ] Widget support: WidgetKit (iOS) / App Widgets (Android)
[ ] Share extensions: share target and share source support
```

### Step 8: Mobile Development Report

```
┌────────────────────────────────────────────────────────────────┐
│  MOBILE PROJECT — <app name>                                   │
├────────────────────────────────────────────────────────────────┤
│  Platform: <iOS | Android | Cross-platform>                    │
│  Framework: <Swift/Kotlin/React Native/Flutter>                │
│  Architecture: <MVVM | MVI | Clean Architecture>              │
│                                                                │
│  Build status:                                                 │
│    iOS: <CONFIGURED | BUILDS | RUNS | TESTED | SIGNED>        │
│    Android: <CONFIGURED | BUILDS | RUNS | TESTED | SIGNED>    │
│                                                                │
│  Performance:                                                  │
│    Startup: <Nms> (target: <1000ms)                            │
│    Memory peak: <N>MB (budget: <N>MB)                          │
│    App size: <N>MB (budget: <N>MB)                             │
```

### Step 9: Commit and Transition
1. Commit architecture setup: `"mobile: <platform> — <architecture> architecture scaffold"`
2. Commit signing config: `"mobile: configure <platform> app signing"`
3. Commit performance fixes: `"mobile: optimize <area> — <metric improvement>"`
4. If store-ready: "App is ready for store submission. Run `/godmode:ship` to submit."
5. If not ready: "Mobile setup complete. Run `/godmode:build` to implement features."

## Key Behaviors

1. **Platform-aware recommendations.** iOS and Android have different conventions, APIs, and review guidelines. Never give generic advice when platform-specific guidance exists.
2. **Performance budgets are non-negotiable.** Set startup time, memory, and app size budgets at project start. Measure against them at every milestone.
3. **Signing security is critical.** Keystores and certificates are irreplaceable for app updates. Treat them with the same care as production database credentials.
4. **Test on real devices.** Simulators/emulators miss real-world issues: thermal throttling, memory pressure, network variability, platform-specific rendering.
5. **Offline is a feature, not an edge case.** Mobile devices lose connectivity regularly. Design for offline-first, not online-only with graceful degradation.
6. **App Store guidelines change.** Always check the latest Apple and Google review guidelines before submission. Rejection delays are costly.

## Iterative Build & Ship Protocol

```
WHEN building features OR preparing for app store submission:

current_feature = 0
total_features = len(feature_list)
completed = []
performance_checks = []

WHILE current_feature < total_features:
  feature = feature_list[current_feature]

  1. IMPLEMENT feature for primary platform
  2. IMPLEMENT for secondary platform (if cross-platform)
  3. TEST on simulator/emulator
  4. TEST on physical device (minimum supported OS version)
  5. MEASURE performance impact:
```

## HARD RULES

```
1. NEVER store secrets (API keys, certificates) in the app binary.
   App binaries are trivially decompiled. Use server-side validation.

2. NEVER lose the Android release keystore. If lost, you must publish a new app
   with a new package name. Back up the keystore in a secure location.

3. ALWAYS test on the minimum supported OS version before submission.
   APIs that exist on iOS 17 may not exist on iOS 15.

4. NEVER skip ProGuard/R8 rules testing. Missing rules cause release builds
   to crash while debug builds work fine. Test release builds on device.

5. EVERY image MUST be resized to display size before rendering.
   Never load a 4K image for a 100px thumbnail.

```

## Output Format

After each mobile skill invocation, emit a structured report:

```
MOBILE BUILD REPORT:
┌──────────────────────────────────────────────────────┐
│  Platform           │  <iOS | Android | Both>         │
│  Framework          │  <React Native | Flutter | etc> │
│  Screens built      │  <N>                            │
│  Components         │  <N> created / <N> updated      │
│  Tests              │  <N> passing, <N> failing       │
│  App size           │  <N> MB (release build)         │
│  Cold start time    │  <N> ms                         │
│  Memory usage       │  <N> MB peak                    │
│  A11y violations    │  <N>                            │
│  Platform guidelines│  iOS HIG: PASS/FAIL  Material: PASS/FAIL │
│  Verdict            │  PASS | NEEDS REVISION          │
└──────────────────────────────────────────────────────┘
```

## TSV Logging

Log every mobile build action for tracking:

```
timestamp	skill	platform	screen	action	tests_pass	app_size_mb	status
2026-03-20T14:00:00Z	mobile	ios	HomeScreen	create	15/15	12.3	pass
2026-03-20T14:10:00Z	mobile	android	ProfileScreen	update	8/10	14.1	needs_fix
```

## Success Criteria

The mobile skill is complete when ALL of the following are true:
1. App builds successfully on all target platforms (iOS and/or Android)
2. All screens render correctly on minimum supported device/OS version
3. All tests pass (unit + integration + at least one E2E smoke test)
4. App size is within budget (< 50MB initial download unless justified)
5. Cold start time is acceptable (< 2s on mid-range device)
6. No accessibility violations from platform accessibility scanner
7. Platform conventions are respected (iOS HIG, Material Design guidelines)
8. No signing certificates or secrets committed to version control

## Keep/Discard Discipline

After each mobile build pass, evaluate:
- **KEEP** if: app builds on all target platforms, all tests pass, cold start < 1s on mid-range device, app size within budget, no accessibility violations, no signing secrets in version control.
- **DISCARD** if: release build crashes (ProGuard/R8 issue), performance regression exceeds budget, platform guidelines violated, or minimum OS version API missing.
- Measure before/after for every optimization. Revert changes that do not produce measurable improvement.
- Never ship without testing on the minimum supported OS version on a physical device.

## Stop Conditions

Stop the mobile skill when:
1. App builds and runs on all target platforms (iOS and/or Android) without errors.
2. Cold start < 2s on mid-range device, app size < 50MB initial download.
3. All platform convention checks pass (iOS HIG, Material Design).
4. No signing certificates or secrets committed to version control.
5. At least one E2E smoke test passes on each platform.


## Error Recovery
| Failure | Action |
|---------|--------|
| Build fails on one platform only | Check platform-specific dependencies. Verify native module linking. Clean build cache (`cd ios && pod install`, `cd android && ./gradlew clean`). |
| App crashes on startup | Check for missing permissions in manifest/plist. Verify all native modules are linked. Check for async initialization race conditions. |
| Hot reload stops working | Restart metro bundler (RN) or dev server. Clear watchman cache. Check for syntax errors in recently saved files. |
| App store rejection | Read rejection reason carefully. Common: missing privacy manifest, background mode misuse, incomplete metadata. Fix and resubmit. |

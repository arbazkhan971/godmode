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
  ...
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
  ...
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
  ...
```

#### Clean Architecture
Best for: Large apps with complex business logic, multiple data sources.
```
CLEAN ARCHITECTURE LAYERS:
  Presentation Layer
  (Views, ViewModels, Presenters)
  Depends on: Domain
  Domain Layer
  (Use Cases, Entities, Repository
  Interfaces)
  Depends on: nothing (innermost layer)
  ...
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
  ...
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
  ...
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
  ...
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
  ...
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
  ...
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
  ...
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
  ...
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
  ...
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
  ...
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
  ...
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
  ...
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
  ...
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
  ...
```
### Step 8: Mobile Development Report

```
  MOBILE PROJECT — <app name>
  Platform: <iOS | Android | Cross-platform>
  Framework: <Swift/Kotlin/React Native/Flutter>
  Architecture: <MVVM | MVI | Clean Architecture>
  Build status:
  iOS: <CONFIGURED | BUILDS | RUNS | TESTED | SIGNED>
  Android: <CONFIGURED | BUILDS | RUNS | TESTED | SIGNED>
  Performance:
  ...
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
## HARD RULES

```
1. NEVER store secrets (API keys, certificates) in the app binary.
   App binaries are trivially decompiled. Use server-side validation.

2. NEVER lose the Android release keystore. If lost, you must publish a new app
   with a new package name. Back up the keystore in a secure location.

3. ALWAYS test on the minimum supported OS version before submission.
   APIs that exist on iOS 17 may not exist on iOS 15.
  ...
```
## Output Format

After each mobile skill invocation, emit a structured report:

```
MOBILE BUILD REPORT:
| Platform | <iOS | Android | Both> |
|--|--|--|--|
| Framework | <React Native | Flutter | etc> |
| Screens built | <N> |
| Components | <N> created / <N> updated |
| Tests | <N> passing, <N> failing |
| App size | <N> MB (release build) |
  ...
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
|--|--|
| Build fails on one platform only | Check platform-specific dependencies. Verify native module linking. Clean build cache (`cd ios && pod install`, `cd android && ./gradlew clean`). |
| App crashes on startup | Check for missing permissions in manifest/plist. Verify all native modules are linked. Check for async initialization race conditions. |
| Hot reload stops working | Restart metro bundler (RN) or dev server. Clear watchman cache. Check for syntax errors in recently saved files. |
| App store rejection | Read rejection reason carefully. Common: missing privacy manifest, background mode misuse, incomplete metadata. Fix and resubmit. |

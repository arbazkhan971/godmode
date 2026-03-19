# Recipe: Building a Cross-Platform Mobile App

> From concept to App Store and Google Play using Godmode. React Native or Flutter with full platform coverage.

---

## Context

You need to ship a mobile app to both iOS and Android. Cross-platform development with React Native or Flutter lets one team build for both platforms, but mobile has its own set of challenges: app signing, store review processes, platform-specific UX expectations, offline support, and performance constraints. This recipe walks through the complete workflow.

## The Chain

```
mobile → think → plan → build → test → deploy → ship
```

## Framework Selection

Choose your framework before starting. This decision is hard to reverse.

| Criteria | React Native | Flutter |
|----------|-------------|---------|
| Language | TypeScript/JavaScript | Dart |
| Best when | Your team knows React, you share code with a web app | You want pixel-perfect custom UI, performance is critical |
| UI approach | Native platform components | Custom rendering engine (Skia) |
| Hot reload | Fast Refresh (reliable) | Hot Reload (very fast) |
| App size | ~15-25 MB baseline | ~10-20 MB baseline |
| Native modules | Bridge or Turbo Modules | Platform channels |
| State management | Redux, Zustand, MobX, Jotai | Riverpod, Bloc, Provider |
| Navigation | React Navigation | GoRouter, auto_route |
| Ecosystem | Massive (npm), some packages unmaintained | Growing (pub.dev), higher average quality |
| Web support | React Native Web (good) | Flutter Web (improving) |
| Hire-ability | Larger talent pool (React devs) | Smaller but dedicated talent pool |

**Rule of thumb:** If your team already writes React, choose React Native. If you are starting fresh and prioritize UI consistency across platforms, choose Flutter.

---

## Session Transcript

### Phase 1: Mobile Setup

Configure the mobile development environment and project structure.

```
> /godmode:mobile --framework rn

Godmode: Setting up React Native project...

MOBILE PROJECT:
  Framework: React Native 0.76 (New Architecture)
  Language: TypeScript (strict mode)
  Platforms: iOS + Android
  Architecture: MVVM with Clean Architecture layers

PROJECT STRUCTURE:
  /src
    /presentation
      /screens           # Screen components
      /components         # Reusable UI components
      /viewmodels         # Screen logic and state
      /navigation         # React Navigation config
      /theme              # Design tokens, colors, typography
    /domain
      /entities           # Business models
      /usecases           # Application logic
      /repositories       # Repository interfaces
    /data
      /api                # API client (Axios/fetch)
      /local              # Local storage (MMKV, SQLite)
      /repositories       # Repository implementations
      /mappers            # API ↔ Domain mappers

CONFIGURED:
  ✓ TypeScript strict mode
  ✓ React Navigation with type-safe routes
  ✓ Zustand for state management
  ✓ React Query for server state
  ✓ MMKV for fast local storage
  ✓ Flipper for debugging
  ✓ Hermes engine (both platforms)
  ✓ ESLint + Prettier
  ✓ Jest + React Native Testing Library

Commit: "mobile: React Native project scaffold with MVVM architecture"
```

### Phase 2: Think (Design the App)

Define what the app does and how it works.

```
> /godmode:think I'm building a habit tracking app. Users create habits,
  check them off daily, and see streaks and statistics. I want it to feel
  native on both iOS and Android.

Godmode: Researching mobile patterns...

One question: Does the app need a backend (sync across devices, social features)
or can it work fully offline with local-only data?

> Offline-first with optional cloud sync for backup.

Godmode: Writing spec...

MVP FEATURES:
  1. Create/edit/delete habits (name, icon, color, frequency)
  2. Daily check-in screen (today's habits with checkboxes)
  3. Streak tracking (current streak, best streak)
  4. Weekly/monthly statistics view
  5. Reminder notifications (local push notifications)
  6. Offline-first with local SQLite storage
  7. Optional cloud backup (Phase 2)

PLATFORM-SPECIFIC UX:
  iOS:
    - Bottom tab navigation (Tab Bar)
    - SF Symbols for icons
    - Haptic feedback on check-in
    - Widget support (WidgetKit) — Phase 2
  Android:
    - Bottom navigation bar (Material 3)
    - Material Icons
    - Haptic feedback on check-in
    - Home screen widget — Phase 2

Saved: docs/specs/habit-tracker.md
Commit: "spec: habit-tracker — offline-first habit tracking with streaks"
```

### Phase 3: Plan (Decompose into Tasks)

```
> /godmode:plan

Godmode: Reading spec... Decomposing...

IMPLEMENTATION PLAN: 14 tasks in 4 phases

Phase 1: Foundation (Tasks 1-4)
  Task 1: Domain entities — Habit, HabitLog, Streak
  Task 2: SQLite schema and repository
  Task 3: Navigation structure (Tabs: Today, Habits, Stats, Settings)
  Task 4: Theme system (light/dark, platform-adaptive colors)

Phase 2: Core Features (Tasks 5-9)
  Task 5: Today screen — list of habits with check-in
  Task 6: Habit CRUD screens — create, edit, delete
  Task 7: Streak calculation engine
  Task 8: Statistics screen — weekly heatmap, monthly chart
  Task 9: Local push notification scheduling

Phase 3: Polish (Tasks 10-12)
  Task 10: Haptic feedback and animations
  Task 11: Onboarding flow (first launch)
  Task 12: Settings screen (theme, notifications, data export)

Phase 4: Release Prep (Tasks 13-14)
  Task 13: App icons and splash screen
  Task 14: Store listing assets (screenshots, descriptions)

Branch: feat/habit-tracker
Saved: docs/plans/habit-tracker-plan.md
Commit: "plan: 14 tasks for habit tracker MVP"
```

### Phase 4: Build

```
> /godmode:build

Godmode: Starting Phase 1...

Task 1: Domain entities
  RED:   test_habit_entity_validates_frequency
  GREEN: Habit, HabitLog, Streak entities with Zod validation
  COMMIT: "feat: domain entities — Habit, HabitLog, Streak"

Task 2: SQLite repository
  RED:   test_save_and_retrieve_habit
  GREEN: WatermelonDB repository with offline-first sync
  COMMIT: "feat: SQLite repository with WatermelonDB"

Task 5: Today screen
  RED:   test_today_shows_habits_for_current_day
  GREEN: TodayScreen with habit list, check-in animations
  COMMIT: "feat: Today screen with habit check-in"

[continues through all 14 tasks]

BUILD COMPLETE:
  14 tasks, 38 new tests, all passing
  iOS simulator: ✓ runs correctly
  Android emulator: ✓ runs correctly

Commit: "build: habit tracker MVP — all 14 tasks complete"
```

### Phase 5: Test on Real Devices

```
> /godmode:test --mobile

Godmode: Running mobile test suite...

UNIT TESTS:
  ✓ 38/38 passing (Jest + RNTL)

PLATFORM TESTS:
  iOS (iPhone 15 Pro simulator):
    ✓ Navigation between all tabs
    ✓ Habit creation flow
    ✓ Check-in with haptic feedback
    ✓ Streak displays correctly
    ✓ Dark mode renders properly
    ✓ Dynamic Type (large text) layout OK
    ✓ VoiceOver accessibility labels present

  Android (Pixel 8 emulator):
    ✓ Navigation between all tabs
    ✓ Habit creation flow
    ✓ Check-in with haptic feedback
    ✓ Streak displays correctly
    ✓ Dark mode renders properly
    ✓ Font scaling layout OK
    ✓ TalkBack accessibility labels present

PERFORMANCE:
  Cold start (iOS): 820ms ✓ (target: < 1000ms)
  Cold start (Android): 950ms ✓ (target: < 1000ms)
  Memory peak: 85MB (iOS), 110MB (Android)
  App size: 18MB (iOS), 22MB (Android)

ISSUES FOUND:
  1. Android: keyboard covers habit name input on small screens
     → Fix: added KeyboardAvoidingView
  2. iOS: streak number truncated with Dynamic Type XXL
     → Fix: used adjustsFontSizeToFitWidth

Commit: "test: mobile test suite — 38 unit, platform tests passing"
```

### Phase 6: App Store Preparation

```
> /godmode:deploy --mobile-stores

Godmode: Preparing store submissions...

IOS — APP STORE CONNECT:
  Signing:
    ✓ Development certificate configured
    ✓ Distribution certificate configured
    ✓ App Store provisioning profile generated
    ✓ Bundle ID: com.yourcompany.habittracker

  Store listing prepared:
    App name: "Streaks — Daily Habit Tracker"
    Subtitle: "Build better habits, one day at a time"
    Category: Health & Fitness > Lifestyle
    Keywords: habit tracker, streaks, daily routine, goals, self improvement
    Description: [1200 characters, benefit-focused]
    Privacy policy URL: https://yourapp.com/privacy
    Data collection: None (offline-first, no analytics for MVP)

  Assets needed:
    [ ] 6.7" screenshots (iPhone 15 Pro Max) — 6 screens
    [ ] 6.5" screenshots (iPhone 14 Plus) — 6 screens
    [ ] 12.9" iPad screenshots (if Universal)
    [ ] App preview video (optional, 15-30s)
    [ ] 1024x1024 app icon

  Build:
    xcodebuild archive → upload via Xcode Organizer
    ✓ Archive successful
    ✓ Uploaded to App Store Connect
    ✓ Processing complete

ANDROID — GOOGLE PLAY CONSOLE:
  Signing:
    ✓ Upload key generated
    ✓ Google Play App Signing enabled
    ✓ Release keystore backed up securely

  Store listing prepared:
    App name: "Streaks — Daily Habit Tracker"
    Short description: "Track habits, build streaks, see your progress"
    Category: Health & Fitness
    Content rating: Everyone
    Data safety: No data collected or shared

  Assets needed:
    [ ] Phone screenshots — 4-8 screens
    [ ] Feature graphic: 1024x500
    [ ] 512x512 app icon

  Build:
    ./gradlew bundleRelease → upload AAB
    ✓ Release bundle built
    ✓ Uploaded to Play Console

Commit: "deploy: app store submission preparation — iOS + Android"
```

### Phase 7: Ship to Stores

```
> /godmode:ship --mobile

Godmode: Submitting to app stores...

IOS SUBMISSION:
  ✓ Build selected in App Store Connect
  ✓ App Review Information provided
  ✓ Release type: Manual (review first, then release)
  ✓ Submitted for review
  Expected review: 1-3 business days

ANDROID SUBMISSION:
  ✓ Internal testing track: uploaded (immediate access)
  ✓ Closed testing: 10 testers invited
  ✓ Production track: submitted for review
  Expected review: 1-7 business days (first submission takes longer)

POST-SUBMISSION:
  ✓ Crash reporting configured (Firebase Crashlytics)
  ✓ Basic analytics configured (anonymous usage metrics)
  ✓ Version monitoring: will alert on store review status change

SHIP STATUS: SUBMITTED TO BOTH STORES
  iOS: Waiting for Review
  Android: In Review (internal track available now)
```

---

## App Store Submission Workflow

### Before First Submission

These are one-time setup tasks that take longer than expected. Do them early.

```
ACCOUNTS REQUIRED:
  Apple Developer Program: $99/year
    Sign up → 24-48 hours for approval
    https://developer.apple.com/programs/

  Google Play Developer: $25 one-time
    Sign up → usually instant, sometimes 48 hours
    https://play.google.com/console/signup

  D-U-N-S Number (Apple, if publishing as organization):
    Free, but takes 5-14 business days
    https://developer.apple.com/support/D-U-N-S/
```

### Review Guidelines Checklist

Common rejection reasons and how to avoid them.

```
IOS REVIEW — COMMON REJECTIONS:
  [ ] Guideline 2.1: App crashes or has obvious bugs
      → Test on real device, not just simulator
  [ ] Guideline 2.3: Inaccurate metadata or screenshots
      → Screenshots must show actual app, not mockups
  [ ] Guideline 4.0: No login for reviewer
      → Provide demo account if auth is required
  [ ] Guideline 4.2: Minimum functionality
      → App must do more than a website could
  [ ] Guideline 5.1.1: Data collection not disclosed
      → Declare ALL data collection in Privacy Nutrition Labels
  [ ] Guideline 5.1.2: No privacy policy
      → Must have an accessible privacy policy URL

ANDROID REVIEW — COMMON REJECTIONS:
  [ ] Policy: Missing privacy policy
      → Required for all apps
  [ ] Policy: Data safety section incomplete
      → Declare all data collection and sharing practices
  [ ] Policy: Deceptive behavior
      → App must do what the description says
  [ ] Quality: Crashes on common devices
      → Test on a range of screen sizes and API levels
  [ ] Quality: App not functional without account
      → Allow guest access or provide test credentials
```

### Update Workflow

After initial release, use this cycle for updates:

```
# Fix a bug reported by users
/godmode:debug "Users report crash when creating habit with emoji in name"
/godmode:fix
/godmode:test --mobile
/godmode:ship --mobile --update

# Add a new feature
/godmode:think "Add weekly habit frequency option"
/godmode:plan → /godmode:build → /godmode:test --mobile
/godmode:ship --mobile --update

# Version numbering:
#   iOS:     CFBundleShortVersionString (1.1.0) + CFBundleVersion (build number)
#   Android: versionName (1.1.0) + versionCode (auto-increment integer)
```

---

## React Native vs Flutter: Side-by-Side Workflow

The Godmode chain is the same regardless of framework. The skill commands adapt to the detected framework.

| Phase | React Native | Flutter |
|-------|-------------|---------|
| scaffold | `npx react-native init` + TypeScript template | `flutter create --org com.company` |
| schema | WatermelonDB, Realm, or expo-sqlite | sqflite, Drift, or Hive |
| state | Zustand + React Query | Riverpod + Dio |
| navigation | React Navigation | GoRouter |
| test | Jest + RNTL | flutter test + integration_test |
| build (iOS) | `npx react-native run-ios` | `flutter build ios` |
| build (Android) | `npx react-native run-android` | `flutter build appbundle` |
| deploy | Fastlane or EAS Build | Fastlane or Codemagic |

---

## CI/CD for Mobile

Automate builds and store submissions from day one.

```
RECOMMENDED CI/CD TOOLS:
  React Native:
    - EAS Build (Expo) — easiest, managed builds
    - Fastlane + GitHub Actions — most flexible
    - Bitrise — mobile-specialized CI

  Flutter:
    - Codemagic — Flutter-native CI/CD
    - Fastlane + GitHub Actions — most flexible
    - Bitrise — mobile-specialized CI

PIPELINE:
  on push to main:
    1. Run unit tests
    2. Run lint
    3. Build iOS (debug)
    4. Build Android (debug)

  on tag (v*):
    1. Run full test suite
    2. Build iOS release (signed)
    3. Build Android release (signed AAB)
    4. Upload to TestFlight (iOS)
    5. Upload to Internal Testing (Android)
    6. Notify team on Slack

  manual promotion:
    TestFlight → App Store Review → Release
    Internal → Closed Testing → Open Testing → Production
```

---

## Offline-First Architecture

Most mobile apps should work offline. Here is the pattern.

```
OFFLINE-FIRST ARCHITECTURE:
  Local database (SQLite/WatermelonDB/Hive) is the SINGLE SOURCE OF TRUTH.

  Read path:
    UI → ViewModel → Local DB → UI update (instant)

  Write path:
    UI → ViewModel → Local DB → UI update (instant)
                        ↓
                   Sync queue → API (when online)
                        ↓
                   Conflict resolution (if needed)

  Sync strategy:
    1. On app launch: pull latest from server
    2. On write: write to local DB + enqueue sync
    3. On connectivity restored: flush sync queue
    4. Conflict resolution: last-write-wins (simple) or merge (complex)

  Benefits:
    - App is always fast (no network wait)
    - App works on airplane, subway, rural areas
    - Reduces server load (batch syncs vs per-action requests)
```

---

## See Also

- [Master Skill Index](../skill-index.md) — `/godmode:mobile` full reference
- [Building an MVP](startup-mvp.md) — For web-based MVPs
- [Building a Design System](design-system.md) — For shared component libraries
- [Skill Chains](../skill-chains.md) — mobile-release chain

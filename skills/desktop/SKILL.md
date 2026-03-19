---
name: desktop
description: |
  Desktop application development skill. Activates when building, packaging, or distributing desktop applications for Windows, macOS, and Linux. Covers framework selection (Electron, Tauri, Qt, .NET MAUI), auto-update mechanisms, cross-platform builds, native API integration (file system, notifications, system tray, menus), installer creation, code signing, and distribution strategies. Every recommendation is platform-aware and includes concrete implementation. Triggers on: /godmode:desktop, "desktop app", "Electron", "Tauri", "Qt", "cross-platform desktop", "installer", "auto-update".
---

# Desktop — Desktop Application Development

## When to Activate
- User invokes `/godmode:desktop`
- User says "desktop app", "desktop application", "native app", "desktop client"
- User mentions "Electron", "Tauri", "Qt", "GTK", ".NET MAUI", "WPF", "SwiftUI desktop"
- User mentions "installer", "auto-update", "code signing", "notarization"
- When building cross-platform desktop applications (Windows, macOS, Linux)
- When packaging and distributing desktop software
- When integrating with native OS APIs (system tray, file system, notifications)

## Workflow

### Step 1: Desktop Project Assessment
Determine the desktop development approach:

```
DESKTOP PROJECT ASSESSMENT:
Project type: <new app | migrating from web | native rewrite | adding desktop to existing>
Target platforms: <Windows | macOS | Linux | all three>
Framework: <Electron | Tauri | Qt | .NET MAUI | SwiftUI + AppKit | GTK>

If Electron:
  Electron version: <latest stable>
  Renderer: <React | Vue | Svelte | vanilla>
  Build tool: <electron-builder | electron-forge>
  Bundle size concern: <yes (consider Tauri) | acceptable>

If Tauri:
  Tauri version: <2.x>
  Frontend: <React | Vue | Svelte | SolidJS | vanilla>
  Rust experience: <beginner | intermediate | advanced>
  Native features needed: <file system | system tray | global shortcuts | custom protocol>

If Qt:
  Qt version: <6.x>
  Language: <C++ | Python (PySide6/PyQt6) | QML>
  License: <LGPL | Commercial>
  Widgets vs QML: <widgets (traditional) | QML (modern/touch)>

App characteristics:
  Window model: <single window | multi-window | system tray resident>
  Offline capability: <fully offline | online-dependent | hybrid>
  Data storage: <local only | cloud sync | local + optional sync>
  File associations: <none | specific file types | custom protocol handler>
  Performance needs: <standard | high (rendering/processing) | real-time>
  Accessibility: <standard | enhanced (screen reader, high contrast)>
```

### Step 2: Framework Architecture

#### Electron Architecture
```
ELECTRON PROJECT STRUCTURE:
├── src/
│   ├── main/                    # Main process (Node.js)
│   │   ├── main.ts              # App entry, window creation
│   │   ├── ipc/                 # IPC handlers
│   │   │   ├── file-handlers.ts # File system operations
│   │   │   └── system-handlers.ts # System integration
│   │   ├── menu.ts              # Application menu
│   │   ├── tray.ts              # System tray
│   │   ├── updater.ts           # Auto-update logic
│   │   └── store.ts             # Persistent storage (electron-store)
│   ├── preload/                 # Preload scripts (bridge)
│   │   └── index.ts             # contextBridge API exposure
│   └── renderer/                # Renderer process (web)
│       ├── App.tsx              # Root component
│       ├── pages/               # Application pages
│       ├── components/          # Reusable UI components
│       └── hooks/               # Custom hooks (IPC, state)
├── resources/                   # App icons, assets
│   ├── icon.icns                # macOS icon
│   ├── icon.ico                 # Windows icon
│   └── icon.png                 # Linux icon (512x512)
├── build/                       # Build configuration
│   ├── entitlements.mac.plist   # macOS entitlements
│   └── notarize.js              # macOS notarization script
├── electron-builder.yml         # Build and packaging config
├── forge.config.ts              # Electron Forge config (alternative)
└── package.json

SECURITY RULES (Electron):
  - ALWAYS use contextIsolation: true (default since Electron 12)
  - NEVER set nodeIntegration: true in renderer
  - Use contextBridge to expose specific APIs to renderer
  - Validate all IPC inputs in main process
  - Use webPreferences.sandbox: true where possible
  - Load remote content in <webview> with proper partition
  - Set Content-Security-Policy headers
  - Disable remote module (deprecated, removed)
```

#### Tauri Architecture
```
TAURI PROJECT STRUCTURE:
├── src/                         # Frontend (web)
│   ├── App.tsx                  # Root component
│   ├── pages/                   # Application pages
│   ├── components/              # UI components
│   └── lib/                     # Frontend utilities
│       └── tauri.ts             # Tauri API wrappers
├── src-tauri/                   # Backend (Rust)
│   ├── src/
│   │   ├── main.rs              # Tauri entry point
│   │   ├── commands/            # Tauri command handlers
│   │   │   ├── mod.rs
│   │   │   ├── files.rs         # File system commands
│   │   │   └── system.rs        # System integration
│   │   ├── state.rs             # Application state
│   │   ├── menu.rs              # Native menu
│   │   ├── tray.rs              # System tray
│   │   └── updater.rs           # Auto-update configuration
│   ├── Cargo.toml               # Rust dependencies
│   ├── tauri.conf.json          # Tauri configuration
│   ├── capabilities/            # Permission policies
│   │   └── default.json         # Default capability set
│   └── icons/                   # App icons (all sizes)
├── package.json                 # Frontend dependencies
└── vite.config.ts               # Frontend build config

SECURITY RULES (Tauri):
  - Define explicit capabilities (permissions) for each window
  - Use Tauri's built-in permission system (no blanket allow-all)
  - Validate all command arguments in Rust handlers
  - Use managed state (tauri::State) for shared resources
  - Frontend cannot access filesystem without explicit commands
  - IPC is type-safe — leverage serde for serialization
  - Sandbox frontend by default (no Node.js, no system access)
```

#### Qt Architecture
```
QT PROJECT STRUCTURE:
├── src/
│   ├── main.cpp                 # Application entry
│   ├── app/                     # Application logic
│   │   ├── application.h/cpp    # QApplication subclass
│   │   └── settings.h/cpp       # QSettings wrapper
│   ├── ui/                      # User interface
│   │   ├── mainwindow.h/cpp/ui  # Main window
│   │   ├── dialogs/             # Dialog windows
│   │   └── widgets/             # Custom widgets
│   ├── models/                  # Data models (QAbstractItemModel)
│   ├── services/                # Business logic
│   └── utils/                   # Utilities
├── resources/                   # Qt resource files
│   ├── resources.qrc            # Resource collection
│   ├── icons/                   # Application icons
│   └── styles/                  # QSS stylesheets
├── tests/                       # QTest-based tests
├── translations/                # Qt Linguist files (.ts)
├── cmake/                       # CMake modules
├── CMakeLists.txt               # Build system
└── deploy/                      # Packaging scripts
    ├── windows/                 # NSIS/WiX installer scripts
    ├── macos/                   # DMG creation scripts
    └── linux/                   # AppImage/Flatpak/deb scripts
```

### Step 3: Auto-Update Mechanisms

```
AUTO-UPDATE STRATEGIES:

Electron (electron-updater):
  Backend: GitHub Releases, S3, or custom server
  Flow:
    1. App checks for updates on launch + periodic interval
    2. Download update in background
    3. Prompt user to install (or auto-install on quit)
    4. Replace app files and restart

  Configuration (electron-builder.yml):
    publish:
      provider: github  # or s3, generic
      owner: <org>
      repo: <repo>

  Code signing required for auto-update:
    macOS: code signing + notarization mandatory
    Windows: code signing recommended (SmartScreen warning without)
    Linux: no code signing (use package manager signatures)

Tauri (built-in updater):
  Backend: JSON endpoint returning latest version info
  Flow:
    1. App queries update endpoint
    2. Compare versions (semver)
    3. Download signed update bundle
    4. Verify signature and apply
    5. Restart application

  Configuration (tauri.conf.json):
    "updater": {
      "endpoints": ["https://releases.example.com/{{target}}/{{arch}}/{{current_version}}"],
      "pubkey": "<Ed25519 public key>"
    }

  Tauri updater signs all updates with Ed25519 — no unsigned updates possible.

Qt / Custom:
  Options:
    - Sparkle (macOS) — mature, well-tested framework
    - WinSparkle (Windows) — Windows port of Sparkle
    - AppImage (Linux) — AppImageUpdate for delta updates
    - Custom: HTTP check → download → verify signature → replace binary → restart

UPDATE SAFETY CHECKLIST:
  [ ] Updates are signed (code signing certificate or Ed25519)
  [ ] Download integrity verified (SHA-256 hash)
  [ ] HTTPS-only update channel
  [ ] Rollback mechanism if update fails
  [ ] User can skip/defer updates (unless security-critical)
  [ ] Update progress shown to user (download %, install status)
  [ ] Background download (do not block user workflow)
  [ ] Differential/delta updates to reduce download size
  [ ] Staged rollout (canary → gradual → full) for large user bases
```

### Step 4: Cross-Platform Builds

```
CROSS-PLATFORM BUILD MATRIX:

Platform       | Architecture | Format           | Min OS
───────────────┼──────────────┼──────────────────┼────────────
Windows x64    | x86_64       | .exe (NSIS/MSI)  | Windows 10
Windows ARM    | aarch64      | .exe (NSIS/MSI)  | Windows 11
macOS Intel    | x86_64       | .dmg / .app      | macOS 11+
macOS Apple Si | aarch64      | .dmg / .app      | macOS 11+
macOS Universal| universal    | .dmg / .app      | macOS 11+
Linux x64      | x86_64       | AppImage/deb/rpm | varies
Linux ARM      | aarch64      | AppImage/deb/rpm | varies

CI/CD BUILD STRATEGY:
  Use GitHub Actions / GitLab CI with platform-specific runners:

  jobs:
    build-windows:
      runs-on: windows-latest
      steps: build → sign → package → upload

    build-macos:
      runs-on: macos-latest
      steps: build → sign → notarize → package → upload

    build-linux:
      runs-on: ubuntu-latest
      steps: build → package (AppImage + deb + rpm) → upload

  Artifacts:
    - Publish to GitHub Releases (auto-update source)
    - Upload to S3/CDN for direct download
    - Submit to platform stores (Microsoft Store, Mac App Store, Snap/Flatpak)

FRAMEWORK-SPECIFIC BUILD COMMANDS:
  Electron:
    npx electron-builder --win --mac --linux
    npx electron-builder --mac --universal  # Universal binary

  Tauri:
    cargo tauri build                        # Current platform
    cargo tauri build --target x86_64-pc-windows-msvc  # Cross-compile

  Qt:
    cmake --build . --config Release
    cpack -G NSIS     # Windows installer
    cpack -G DragNDrop # macOS DMG
    cpack -G DEB       # Linux .deb
```

### Step 5: Native API Integration

```
NATIVE API INTEGRATION:

System Tray:
  [ ] Tray icon with context menu
  [ ] Show/hide main window from tray
  [ ] Badge/overlay for notifications (macOS dock, Windows taskbar)
  [ ] Minimize to tray on close (optional, user preference)

File System:
  [ ] Open/save file dialogs (native, not custom)
  [ ] File type associations (open files by double-click)
  [ ] Drag and drop (files onto app window)
  [ ] Watch file changes (fs.watch / chokidar / notify crate)
  [ ] Respect platform paths (Documents, AppData, ~/.config)

Notifications:
  [ ] Native OS notifications (not custom HTML)
  [ ] Action buttons in notifications
  [ ] Notification center integration (macOS, Windows Action Center)
  [ ] Do Not Disturb awareness

Keyboard Shortcuts:
  [ ] Global shortcuts (work even when app is not focused)
  [ ] Application shortcuts with platform conventions:
      macOS: Cmd+C, Cmd+V, Cmd+Q, Cmd+,
      Windows/Linux: Ctrl+C, Ctrl+V, Alt+F4, Ctrl+,
  [ ] Shortcut conflicts checked against OS defaults

Custom Protocol:
  [ ] Register protocol handler (myapp://action?params)
  [ ] Deep linking from browser to desktop app
  [ ] Handle protocol URLs on app launch and while running

Clipboard:
  [ ] Read/write text, HTML, images
  [ ] Platform-specific clipboard types (RTF on macOS)

Window Management:
  [ ] Remember window position and size
  [ ] Multi-monitor support (restore to correct monitor)
  [ ] Frameless window with custom title bar (optional)
  [ ] Always-on-top mode (optional, for utilities)
  [ ] Snap layouts (Windows 11)

PLATFORM-SPECIFIC PATHS:
  Config:  macOS: ~/Library/Application Support/<app>
           Windows: %APPDATA%\<app>
           Linux: ~/.config/<app>
  Data:    macOS: ~/Library/Application Support/<app>
           Windows: %LOCALAPPDATA%\<app>
           Linux: ~/.local/share/<app>
  Cache:   macOS: ~/Library/Caches/<app>
           Windows: %LOCALAPPDATA%\<app>\cache
           Linux: ~/.cache/<app>
  Logs:    macOS: ~/Library/Logs/<app>
           Windows: %LOCALAPPDATA%\<app>\logs
           Linux: ~/.local/state/<app>/log
```

### Step 6: Installer & Distribution

```
INSTALLER STRATEGIES:

Windows:
  NSIS: lightweight installer, highly customizable
  WiX/MSI: enterprise-friendly, Group Policy support
  MSIX: modern Windows packaging, auto-update via Store
  Portable: no installer, single .exe (limited integration)

  Code signing:
    [ ] EV code signing certificate (instant SmartScreen trust)
    [ ] Standard code signing certificate (builds trust over time)
    [ ] Sign .exe, .dll, and installer
    [ ] Timestamp signature (valid after certificate expiry)

macOS:
  DMG: drag-to-Applications, most common
  PKG: installer wizard, can install helper tools
  Mac App Store: sandboxed, auto-update, discovery

  Code signing + Notarization:
    [ ] Developer ID Application certificate
    [ ] Hardened Runtime enabled
    [ ] Entitlements configured (network, file access, etc.)
    [ ] Notarized with Apple (xcrun notarytool submit)
    [ ] Stapled notarization ticket (xcrun stapler staple)
    Unnotarized apps show "cannot be opened" warning.

Linux:
  AppImage: universal, no installation needed, runs anywhere
  Flatpak: sandboxed, auto-update via Flathub
  Snap: sandboxed, auto-update via Snap Store
  .deb: Debian/Ubuntu native package
  .rpm: Fedora/RHEL native package
  AUR: Arch Linux user repository

  No code signing standard, but:
    [ ] GPG-sign packages for repository distribution
    [ ] Provide SHA-256 checksums for downloads

DISTRIBUTION CHANNELS:
  [ ] Direct download from website (all platforms)
  [ ] GitHub Releases (direct + auto-update source)
  [ ] Microsoft Store (Windows, optional)
  [ ] Mac App Store (macOS, optional — adds sandbox restrictions)
  [ ] Flathub / Snap Store (Linux, optional)
  [ ] Homebrew Cask (macOS, community distribution)
  [ ] Winget (Windows, community distribution)
  [ ] Chocolatey (Windows, community distribution)
```

### Step 7: Desktop Application Report

```
┌────────────────────────────────────────────────────────────────┐
│  DESKTOP PROJECT — <app name>                                   │
├────────────────────────────────────────────────────────────────┤
│  Framework: <Electron | Tauri | Qt>                              │
│  Platforms: <Windows | macOS | Linux | all>                      │
│  Architecture: <main+renderer | Rust+web | Qt widgets/QML>      │
│                                                                  │
│  Build status:                                                   │
│    Windows: <BUILDS | SIGNED | INSTALLS | DISTRIBUTED>          │
│    macOS:   <BUILDS | SIGNED | NOTARIZED | DISTRIBUTED>         │
│    Linux:   <BUILDS | PACKAGED | DISTRIBUTED>                   │
│                                                                  │
│  Features:                                                       │
│    Auto-update: <CONFIGURED | TESTED | DEPLOYED>                │
│    System tray: <YES | NO | N/A>                                 │
│    File associations: <YES | NO | N/A>                           │
│    Native notifications: <YES | NO>                              │
│    Global shortcuts: <YES | NO>                                  │
│                                                                  │
│  Distribution:                                                   │
│    Direct download: <URL>                                        │
│    Auto-update: <GitHub Releases | S3 | custom>                  │
│    App stores: <Microsoft Store | Mac App Store | Flathub>       │
│                                                                  │
│  Performance:                                                    │
│    Startup time: <Nms>                                           │
│    Memory usage: <N MB idle>                                     │
│    Bundle size: <N MB per platform>                              │
├────────────────────────────────────────────────────────────────┤
│  Next: /godmode:test — Test cross-platform functionality         │
│        /godmode:perf — Profile memory and startup time           │
│        /godmode:ship — Build, sign, and distribute               │
└────────────────────────────────────────────────────────────────┘
```

### Step 8: Commit and Transition
1. Commit app scaffold: `"desktop: <framework> — application scaffold with <feature>"`
2. Commit auto-update: `"desktop: auto-update — <provider> integration"`
3. Commit packaging: `"desktop: packaging — <platform> installer configuration"`
4. If distribution-ready: "App is built and signed. Run `/godmode:ship` to distribute."
5. If in progress: "Desktop scaffold complete. Run `/godmode:build` to implement features."

## Key Behaviors

1. **Platform conventions matter.** macOS apps use Cmd shortcuts and menu bar; Windows uses Ctrl shortcuts and system tray; Linux varies by desktop environment. Respect each platform's idioms.
2. **Code signing is mandatory for distribution.** Unsigned apps trigger scary warnings on macOS (Gatekeeper) and Windows (SmartScreen). Budget for signing certificates.
3. **Auto-update is expected.** Desktop users expect their apps to stay current. Implement auto-update from day one — retrofitting is harder.
4. **Test on all target platforms.** Rendering differences, path separators, permissions models, and native API behavior vary significantly across operating systems.
5. **Bundle size impacts perception.** A 200MB Electron app for a simple utility feels bloated. Choose the right framework for the complexity — Tauri for lightweight, Electron for web-heavy.
6. **Accessibility is required.** Screen reader support, keyboard navigation, high contrast mode, and reduced motion are not optional for desktop applications.

## Example Usage

### Creating a Tauri desktop app
```
User: /godmode:desktop Build a markdown editor with Tauri

Desktop: Assessing requirements...

DESKTOP PROJECT:
Framework: Tauri 2.x
Frontend: React + CodeMirror 6
Platforms: Windows, macOS, Linux

Architecture:
  /src (frontend)
    App.tsx            — Main editor layout
    /components
      Editor.tsx       — CodeMirror markdown editor
      Preview.tsx      — Live markdown preview
      FileTree.tsx     — Sidebar file browser
  /src-tauri (backend)
    /commands
      files.rs         — File CRUD operations
      recent.rs        — Recent files management
    state.rs           — Open files, preferences

Features:
  - System file associations (.md, .markdown)
  - Native open/save dialogs
  - Auto-update via GitHub Releases
  - System tray with recent files
  - Global shortcut to create new note

Build targets:
  Windows: NSIS installer (~8 MB)
  macOS: DMG with notarization (~6 MB)
  Linux: AppImage + .deb (~9 MB)

Next: /godmode:build to implement editor features
      /godmode:ship to build and distribute
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full desktop project assessment and setup |
| `--update` | Auto-update mechanism setup only |
| `--package` | Installer and packaging setup only |
| `--sign` | Code signing configuration only |
| `--framework <name>` | Use specific framework (electron, tauri, qt) |
| `--platform <name>` | Target specific platform (windows, macos, linux) |
| `--distribute` | Distribution channel setup only |

## HARD RULES

- NEVER set nodeIntegration: true in Electron renderer processes
- NEVER store secrets in plain text config files — use OS keychain (macOS Keychain, Windows Credential Manager, libsecret)
- NEVER ship without code signing on macOS (Gatekeeper blocks unnotarized apps) or Windows (SmartScreen warning)
- NEVER use `:latest` tags for base images or dependency versions in production builds
- NEVER skip auto-update implementation — desktop users expect it and retrofitting is painful
- ALL IPC messages MUST be validated in the main/Rust process before processing
- ALL desktop apps MUST handle single-instance lock or multi-window architecture explicitly
- ALL apps MUST support high-DPI scaling on Retina/4K displays without blurry rendering

## Iterative Build Loop Protocol

When building or auditing a desktop application across platforms:

```
current_iteration = 0
platform_queue = [all_target_platforms]  # e.g., [windows, macos, linux]
WHILE platform_queue is not empty:
    current_iteration += 1
    platform = platform_queue.pop(next)
    build application for platform
    run code signing and notarization (if applicable)
    run installer/packaging
    test: launch, basic flows, auto-update, native API integration
    run security scan (Trivy on containers, dependency audit)
    IF build fails or tests fail:
        fix issues, re-add platform to queue
    report: "Iteration {current_iteration}: {platform} — build={status}, sign={status}, tests={N passed}/{M total}"
```

## Multi-Agent Dispatch

```
DISPATCH 3 agents in separate worktrees:
  Agent 1 (app scaffold):  Set up framework architecture (main/renderer or Rust/web), IPC, menus, tray
  Agent 2 (packaging):     Configure installers, code signing, notarization, CI/CD build matrix
  Agent 3 (native APIs):   Implement system tray, file associations, notifications, global shortcuts, deep linking
SYNC point: All agents complete
  Merge worktrees
  Run cross-platform build matrix (Windows + macOS + Linux)
  Generate desktop project report with per-platform status
```

## Auto-Detection

```
1. Check for existing desktop framework:
   - Scan for electron-builder.yml, forge.config.{js,ts} → Electron detected
   - Scan for src-tauri/, tauri.conf.json → Tauri detected
   - Scan for CMakeLists.txt with Qt references → Qt detected
   - Scan for package.json scripts containing electron or tauri commands
2. Check for platform targets:
   - Scan CI/CD workflows for platform build matrices (windows-latest, macos-latest, ubuntu-latest)
   - Check for code signing configs (entitlements.mac.plist, signtool references)
   - Detect icon files (icon.icns, icon.ico, icon.png)
3. Check for auto-update:
   - Scan for electron-updater, tauri updater config, Sparkle/WinSparkle references
4. Determine maturity: scaffold only | builds | signed | distributed
5. Set assessment fields and proceed to Step 1
```

## Anti-Patterns

- **Do NOT use Electron for simple utilities.** A 150MB download for a calculator is not acceptable. Use Tauri (~5-10 MB) or native frameworks for lightweight tools.
- **Do NOT skip notarization on macOS.** Since macOS Catalina, unnotarized apps show a blocking warning. Users cannot easily open them — and most will not try.
- **Do NOT store sensitive data in plain text config files.** Use the OS keychain (macOS Keychain, Windows Credential Manager, libsecret on Linux) for passwords and tokens.
- **Do NOT ignore platform path conventions.** Storing data in the app directory instead of AppData/Application Support/~/.config breaks on write-protected installations and multi-user systems.
- **Do NOT build a custom window frame without implementing all native interactions.** Snap to edges, maximize, minimize, drag, resize, and accessibility must all work correctly. Native frames are easier and more reliable.
- **Do NOT ship without a crash reporter.** Desktop apps crash in environments you cannot predict. Integrate Sentry, Crashpad, or similar to capture crash reports from users in the field.
- **Do NOT assume single-instance.** Handle the case where the user launches the app twice — either prevent it (single instance lock) or support it (multi-window architecture).
- **Do NOT forget to handle DPI scaling.** High-DPI displays are standard now. Blurry text and tiny UI elements on Retina/4K displays are unacceptable.

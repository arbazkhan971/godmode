# /godmode:desktop

Desktop application development — Electron, Tauri, and Qt architecture, auto-update mechanisms, cross-platform builds (Windows, macOS, Linux), native API integration (system tray, file system, notifications), code signing, notarization, installer creation, and distribution.

## Usage

```
/godmode:desktop                           # Full desktop project assessment
/godmode:desktop --update                  # Auto-update mechanism setup
/godmode:desktop --package                 # Installer and packaging setup
/godmode:desktop --sign                    # Code signing configuration
/godmode:desktop --framework tauri         # Use Tauri framework
/godmode:desktop --platform macos          # Target macOS specifically
/godmode:desktop --distribute              # Distribution channel setup
```

## What It Does

1. Assesses desktop project requirements (frameworks, platforms, features, performance)
2. Sets up framework architecture:
   - Electron: main + preload + renderer process isolation, IPC handlers
   - Tauri: Rust backend + web frontend, capability-based permissions
   - Qt: widgets or QML, CMake build system, platform abstraction
3. Configures auto-update mechanism (electron-updater, Tauri updater, Sparkle/WinSparkle)
4. Sets up cross-platform build pipeline (CI/CD for Windows, macOS, Linux)
5. Integrates native APIs:
   - System tray, file system, notifications, keyboard shortcuts
   - Custom protocol handlers, clipboard, window management
   - Platform-specific paths (AppData, Application Support, .config)
6. Configures code signing and notarization (macOS notarytool, Windows Authenticode)
7. Creates installers and distribution packages (NSIS, DMG, AppImage, deb, Flatpak)

## Output
- Desktop application scaffold with chosen framework
- Auto-update configuration and testing
- Platform-specific build scripts and CI/CD pipeline
- Code signing and notarization setup
- Commit: `"desktop: <framework> — <description>"`

## Next Step
After scaffold: `/godmode:build` to implement features.
After building: `/godmode:test` to test cross-platform.
When ready: `/godmode:ship` to build, sign, and distribute.

## Examples

```
/godmode:desktop                           # Full project assessment and setup
/godmode:desktop --framework tauri         # Tauri-specific setup
/godmode:desktop --update                  # Auto-update mechanism only
/godmode:desktop --sign                    # Code signing configuration
/godmode:desktop --distribute              # Distribution channel setup
```

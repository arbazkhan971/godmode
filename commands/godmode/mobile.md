# /godmode:mobile

Mobile app development — iOS and Android architecture patterns, cross-platform frameworks (React Native, Flutter), native development (Swift, Kotlin), app signing and provisioning, app store submission workflows, and mobile-specific performance optimization.

## Usage

```
/godmode:mobile                        # Full mobile project assessment
/godmode:mobile --ios                  # iOS-specific setup
/godmode:mobile --android              # Android-specific setup
/godmode:mobile --signing              # App signing and provisioning
/godmode:mobile --store                # App store submission preparation
/godmode:mobile --perf                 # Mobile performance audit
/godmode:mobile --arch mvvm            # Use MVVM architecture
/godmode:mobile --framework flutter    # Use Flutter framework
```

## What It Does

1. Assesses project requirements and recommends development approach (native vs cross-platform)
2. Sets up architecture pattern (MVVM, MVI, or Clean Architecture) with project structure
3. Configures platform-specific project settings (Xcode, Gradle, Metro, Flutter)
4. Sets up app signing — certificates, provisioning profiles, keystores
5. Prepares app store submission — metadata, screenshots, compliance checklists
6. Audits mobile-specific performance:
   - Battery optimization (location, background tasks, sensors)
   - Memory management (image caching, view recycling, leak detection)
   - Network optimization (offline-first, compression, pagination)
   - App startup performance (cold start < 1s target)
7. Configures platform features (push notifications, deep links, biometrics)

## Output
- Project scaffold with chosen architecture pattern
- Signing configuration (certificates, keystores, provisioning)
- App store submission checklists with completion status
- Performance baseline measurements
- Commit: `"mobile: <platform> — <description>"`

## Next Step
After setup: `/godmode:build` to implement features.
After building: `/godmode:perf` to profile performance.
When ready: `/godmode:ship` to submit to app stores.

## Examples

```
/godmode:mobile                        # Full assessment and setup
/godmode:mobile --signing              # Just configure signing
/godmode:mobile --store                # Prepare for app store submission
/godmode:mobile --perf                 # Audit mobile performance
```

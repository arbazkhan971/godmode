# Swift/iOS Developer Guide

How to use Godmode's full workflow for Swift and iOS projects — from design to production.

---

## Setup

```bash
/godmode:setup
# Godmode auto-detects Swift via Package.swift, *.xcodeproj, or *.xcworkspace
# Test: swift test / xcodebuild test
# Lint: swiftlint
# Format: swiftformat --lint .
# Build: swift build / xcodebuild build
```

### Example `.godmode/config.yaml`
```yaml
language: swift
framework: swiftui            # or uikit, vapor, etc.
test_command: swift test --parallel
lint_command: swiftlint lint --strict
format_command: swiftformat --lint .
build_command: xcodebuild -scheme MyApp -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build
verify_command: xcodebuild test -scheme MyApp -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MyAppTests
```

---

## How Each Skill Applies to Swift

### THINK Phase

| Skill | Swift Adaptation |
|-------|-----------------|
| **think** | Design protocols, structs, and enums first. A Swift spec should define the data layer with `Codable` models, protocol-oriented interfaces, and state enums. Include access control (`public`, `internal`, `private`) in the spec. |
| **predict** | Expert panel evaluates protocol-oriented design, memory management (ARC, retain cycles), and platform API choices. Request panelists with Swift depth (e.g., iOS architect, Swift core team contributor). |
| **scenario** | Explore edge cases around optionals (`nil` handling), `@MainActor` isolation, Sendable conformance, network failure modes, and background task lifecycle. |

### BUILD Phase

| Skill | Swift Adaptation |
|-------|-----------------|
| **plan** | Each task specifies files and targets. File paths follow Xcode conventions (`Sources/MyApp/Services/UserService.swift`). Tasks note which targets and schemes are affected. |
| **build** | TDD with XCTest. RED step writes a test class with `XCTestCase`. GREEN step implements the type. REFACTOR step applies protocol extraction, value semantics, and Swift concurrency (`async/await`). |
| **test** | Use `XCTestCase` with `setUp`/`tearDown`. Prefer protocol-based dependency injection for testability. Use `XCTestExpectation` for async tests. |
| **review** | Check for force unwraps (`!`), retain cycles in closures (missing `[weak self]`), missing `@MainActor` annotations, and improper error handling with `try?` swallowing errors. |

### OPTIMIZE Phase

| Skill | Swift Adaptation |
|-------|-----------------|
| **optimize** | Target app launch time, memory footprint, or frame rate. Guard rail: `swift test` must pass on every iteration. Use Instruments data to guide hypotheses. |
| **debug** | Use LLDB and Instruments (Time Profiler, Allocations, Leaks). Check for common Swift pitfalls: retain cycles, excessive `AnyObject` boxing, main thread blocking. |
| **fix** | Autonomous fix loop handles compiler errors, test failures, and lint violations. Guard rail: `swift build && swift test && swiftlint lint --strict`. |
| **secure** | Audit for hardcoded secrets, insecure `UserDefaults` storage, missing App Transport Security exceptions, and improper Keychain usage. Check for `NSAllowsArbitraryLoads` in Info.plist. |

### SHIP Phase

| Skill | Swift Adaptation |
|-------|-----------------|
| **ship** | Pre-flight: `swift test && swiftlint lint --strict && xcodebuild build -scheme MyApp`. Verify archive builds and export options plist is configured. |
| **finish** | Ensure version and build number are bumped in Info.plist. Verify provisioning profiles are valid. Confirm App Store Connect metadata is current. |

---

## Recommended Metrics

| Metric | Verify Command | Target |
|--------|---------------|--------|
| Tests pass | `swift test 2>&1 \| grep 'Test Suite.*passed'` | All passed |
| Build time | `xcodebuild -scheme MyApp build 2>&1 \| grep 'Build Succeeded'` | < 60s (incremental) |
| SwiftLint violations | `swiftlint lint --strict 2>&1 \| tail -1` | 0 violations |
| Force unwrap count | `grep -rn '!' Sources/ --include='*.swift' \| grep -v '//' \| wc -l` | 0 (or decreasing) |
| App binary size | `du -m Build/Products/Release-iphoneos/MyApp.app \| cut -f1` | Project-specific |
| Launch time | Instruments Time Profiler pre-main + post-main | < 400ms |
| Memory usage | Instruments Allocations peak | Project-specific |
| Retain cycles | Instruments Leaks count | 0 |

---

## Common Verify Commands

### Tests pass
```bash
swift test --parallel
# or
xcodebuild test -scheme MyApp -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16'
```

### Build succeeds
```bash
swift build
# or
xcodebuild -scheme MyApp -sdk iphonesimulator build
```

### Lint clean
```bash
swiftlint lint --strict
```

### Format check
```bash
swiftformat --lint .
```

### No force unwraps
```bash
grep -rn '[^?]!' Sources/ --include='*.swift' | grep -v '//' | grep -v 'IBOutlet' | wc -l
```

### Archive builds
```bash
xcodebuild archive -scheme MyApp -archivePath build/MyApp.xcarchive
```

---

## Tool Integration

### XCTest

Godmode's TDD cycle maps directly to XCTest:

```bash
# RED step: run single test class, expect failure
swift test --filter MyAppTests.UserServiceTests

# GREEN step: run single test, expect pass
swift test --filter MyAppTests.UserServiceTests

# After GREEN: run full suite to catch regressions
swift test --parallel

# With Xcode
xcodebuild test -scheme MyApp -only-testing:MyAppTests/UserServiceTests
```

**Test patterns** for Godmode projects:
```swift
// Tests/MyAppTests/Services/UserServiceTests.swift
import XCTest
@testable import MyApp

final class UserServiceTests: XCTestCase {
    private var sut: UserService!
    private var mockRepository: MockUserRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        sut = UserService(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func testFetchUserReturnsUserWhenFound() async throws {
        mockRepository.stubbedUser = User(id: "123", name: "Alice")

        let user = try await sut.fetchUser(id: "123")

        XCTAssertEqual(user.name, "Alice")
        XCTAssertEqual(mockRepository.fetchCallCount, 1)
    }

    func testFetchUserThrowsWhenNotFound() async {
        mockRepository.stubbedUser = nil

        do {
            _ = try await sut.fetchUser(id: "missing")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is UserService.Error)
        }
    }
}
```

### SwiftLint

Guard rail configuration for Godmode projects:

```yaml
# .swiftlint.yml
strict: true
opt_in_rules:
  - force_unwrapping
  - implicitly_unwrapped_optional
  - closure_body_length
  - function_default_parameter_at_end
  - multiline_arguments
  - vertical_whitespace_closing_braces
disabled_rules: []
excluded:
  - .build
  - Pods
  - DerivedData
force_unwrapping: error
```

```yaml
# Guard rail for optimize loop
guard_rails:
  - command: swift test --parallel
    expect: exit code 0
  - command: swiftlint lint --strict
    expect: exit code 0
```

### Instruments

Performance profiling integration for the optimize loop:

```bash
# Time Profiler — measure app launch and method execution time
xcrun xctrace record --template 'Time Profiler' --launch MyApp.app --output trace.trace

# Allocations — track memory usage
xcrun xctrace record --template 'Allocations' --launch MyApp.app --output alloc.trace

# Leaks — detect retain cycles
xcrun xctrace record --template 'Leaks' --attach MyApp --output leaks.trace
```

---

## Framework Integration

### SwiftUI

```yaml
# .godmode/config.yaml
framework: swiftui
test_command: xcodebuild test -scheme MyApp -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16'
lint_command: swiftlint lint --strict
build_command: xcodebuild build -scheme MyApp -sdk iphonesimulator
```

SwiftUI-specific THINK considerations:
- View decomposition strategy (small, composable views)
- State management architecture: `@State`, `@Binding`, `@ObservedObject`, `@StateObject`, `@EnvironmentObject`
- Navigation design with `NavigationStack` and `NavigationPath`
- Data flow: unidirectional (parent to child via bindings)
- Preview strategy for rapid iteration

SwiftUI-specific patterns:
```swift
// Protocol-oriented ViewModel for testability
@MainActor
protocol UserListViewModelProtocol: ObservableObject {
    var users: [User] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    func loadUsers() async
}

@MainActor
final class UserListViewModel: UserListViewModelProtocol {
    @Published private(set) var users: [User] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    func loadUsers() async {
        isLoading = true
        defer { isLoading = false }
        do {
            users = try await repository.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

### UIKit

```yaml
# .godmode/config.yaml
framework: uikit
test_command: xcodebuild test -scheme MyApp -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16'
lint_command: swiftlint lint --strict
build_command: xcodebuild build -scheme MyApp -sdk iphonesimulator
```

UIKit-specific THINK considerations:
- Coordinator pattern for navigation
- MVVM or MVP architecture with protocol-based contracts
- Auto Layout strategy (programmatic vs. Interface Builder)
- Table/collection view diffable data sources
- Memory management in view controller lifecycle

UIKit-specific optimize targets:
```bash
# Measure table view scroll performance
xcrun xctrace record --template 'Core Animation' --attach MyApp --output scroll.trace

# Cell reuse verification
# Ensure dequeueReusableCell is used, not direct instantiation
grep -rn 'UITableViewCell()' Sources/ --include='*.swift' | wc -l
```

### Vapor (Server-Side Swift)

```yaml
# .godmode/config.yaml
framework: vapor
test_command: swift test --parallel
lint_command: swiftlint lint --strict
build_command: swift build -c release
verify_command: curl -s -o /dev/null -w '%{time_total}' http://localhost:8080/health
```

Vapor-specific THINK considerations:
- Route organization and middleware pipeline
- Fluent ORM model design with migrations
- Content validation using `Validatable` protocol
- WebSocket handler patterns
- Async request handling with structured concurrency

---

## Xcode Build Optimization

### Compilation speed

```bash
# Measure build time per file
xcodebuild -scheme MyApp build OTHER_SWIFT_FLAGS="-Xfrontend -debug-time-function-bodies" 2>&1 | sort -rn | head -20

# Measure type-checking time
xcodebuild -scheme MyApp build OTHER_SWIFT_FLAGS="-Xfrontend -debug-time-expression-type-checking" 2>&1 | sort -rn | head -20

# Enable build timing summary
defaults write com.apple.dt.Xcode ShowBuildOperationDuration -bool YES
```

### Build settings for CI

```bash
# Parallel builds with maximum concurrency
xcodebuild -scheme MyApp \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -parallelizeTargets \
  -jobs $(sysctl -n hw.ncpu) \
  build

# Skip code signing for CI test builds
xcodebuild -scheme MyApp \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  build
```

### Caching strategies

- Use **Xcode Build Cache** (`-derivedDataPath`) to share derived data across CI runs
- Enable **module stability** for binary frameworks to avoid recompilation
- Use **Swift Package Manager** resolved file for deterministic dependency builds

---

## App Store Submission Workflow

### Pre-submission checklist

```bash
# 1. Run full test suite
xcodebuild test -scheme MyApp -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16'

# 2. Lint check
swiftlint lint --strict

# 3. Archive for distribution
xcodebuild archive \
  -scheme MyApp \
  -sdk iphoneos \
  -archivePath build/MyApp.xcarchive \
  -allowProvisioningUpdates

# 4. Export IPA
xcodebuild -exportArchive \
  -archivePath build/MyApp.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist ExportOptions.plist

# 5. Validate with App Store Connect
xcrun altool --validate-app -f build/export/MyApp.ipa -t ios -u $APPLE_ID -p $APP_SPECIFIC_PASSWORD

# 6. Upload to App Store Connect
xcrun altool --upload-app -f build/export/MyApp.ipa -t ios -u $APPLE_ID -p $APP_SPECIFIC_PASSWORD
```

### Fastlane integration

```ruby
# Fastfile
default_platform(:ios)

platform :ios do
  desc "Run tests"
  lane :test do
    run_tests(scheme: "MyApp")
  end

  desc "Build and upload to TestFlight"
  lane :beta do
    increment_build_number
    build_app(scheme: "MyApp")
    upload_to_testflight
  end

  desc "Build and submit to App Store"
  lane :release do
    increment_build_number
    build_app(scheme: "MyApp")
    upload_to_app_store(
      submit_for_review: true,
      automatic_release: false
    )
  end
end
```

Godmode ship integration:
```bash
# Pre-flight with Fastlane
/godmode:ship --pre-flight "bundle exec fastlane test" --deploy "bundle exec fastlane beta"
```

---

## Example: Full Workflow for Building an iOS App

### Scenario
Build a photo gallery app using SwiftUI with Core Data persistence, CloudKit sync, and share sheet integration.

### Step 1: Think (Design)
```
/godmode:think I need a photo gallery app with SwiftUI — grid layout with
pinch-to-zoom, Core Data for local persistence, CloudKit for sync across
devices, share sheet for exporting photos. Support iPad multitasking.
```

Godmode produces a spec at `docs/specs/photo-gallery.md` containing:
- Model definitions: `Photo`, `Album`, `SyncStatus` (enum)
- View hierarchy: `GalleryGridView` > `PhotoDetailView` > `ShareSheet`
- Data architecture: Core Data stack with `NSPersistentCloudKitContainer`
- State management: `@StateObject` ViewModels with published properties
- Navigation: `NavigationStack` with `NavigationPath` for programmatic navigation

### Step 2: Build (TDD)
```
/godmode:build
```

**Task 1 — RED:**
```swift
// Tests/PhotoGalleryTests/Models/PhotoTests.swift
import XCTest
@testable import PhotoGallery

final class PhotoTests: XCTestCase {
    func testPhotoInitializesWithRequiredProperties() {
        let photo = Photo(
            id: UUID(),
            imageData: Data(),
            caption: "Sunset",
            createdAt: Date()
        )
        XCTAssertEqual(photo.caption, "Sunset")
        XCTAssertNotNil(photo.createdAt)
    }

    func testPhotoThumbnailGenerationReturnsScaledImage() async throws {
        let photo = Photo.fixture(withImageSize: CGSize(width: 4000, height: 3000))
        let thumbnail = try await photo.generateThumbnail(maxDimension: 200)
        XCTAssertLessThanOrEqual(thumbnail.size.width, 200)
        XCTAssertLessThanOrEqual(thumbnail.size.height, 200)
    }
}
```
Commit: `test(red): Photo model — failing initialization and thumbnail tests`

**Task 1 — GREEN:**
Implement `Photo` model with thumbnail generation.
Commit: `feat: Photo model — Core Data entity with async thumbnail generation`

### Step 3: Optimize
```
/godmode:optimize --goal "reduce gallery scroll jank" \
  --verify "Instruments Core Animation FPS" \
  --target ">= 58 fps"
```

Iteration log:
| # | Hypothesis | Change | Baseline | Measured | Verdict |
|---|-----------|--------|----------|----------|---------|
| 1 | Full-size images in grid | Use thumbnail cache with `NSCache` | 32 fps | 52 fps | KEEP |
| 2 | Synchronous image loading | Load images with `AsyncImage` + prefetch | 52 fps | 58 fps | KEEP |
| 3 | Too many views in LazyVGrid | Reduce grid item view complexity | 58 fps | 59 fps | KEEP |

### Step 4: Ship
```
/godmode:ship --pr
```

Pre-flight passes:
```
swift test --parallel    ✓ 28/28 passing
swiftlint lint --strict  ✓ 0 violations
xcodebuild archive       ✓ Archive succeeded
```

---

## Swift-Specific Tips

### 1. Protocols are your spec
In the THINK phase, define protocols before concrete types. Protocol-oriented design makes dependency injection natural and enables testability from the start.

### 2. Use value types by default
Prefer `struct` over `class` unless you need reference semantics or inheritance. Value types are thread-safe, predictable, and optimized by the compiler.

### 3. Embrace Swift concurrency
Use `async/await`, `Task`, `TaskGroup`, and actors instead of GCD or completion handlers. Godmode's build skill generates modern concurrency patterns:
```swift
// Prefer this
func fetchUser(id: String) async throws -> User

// Over this
func fetchUser(id: String, completion: @escaping (Result<User, Error>) -> Void)
```

### 4. Guard against retain cycles
In the REVIEW phase, check every closure that captures `self`. Use `[weak self]` in escaping closures and `[unowned self]` only when the lifecycle is guaranteed:
```
/godmode:optimize --goal "eliminate retain cycles" --verify "Instruments Leaks count" --target "0"
```

### 5. Automate App Store submission
Use Fastlane or Xcode Cloud to automate the archive-upload-review cycle. Godmode's ship skill integrates with both to provide a one-command release workflow.

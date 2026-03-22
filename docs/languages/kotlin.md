# Kotlin/Android Developer Guide

How to use Godmode's full workflow for Kotlin and Android projects — from design to production.

---

## Setup

```bash
/godmode:setup
# Godmode auto-detects Kotlin via build.gradle.kts, build.gradle, or settings.gradle.kts
# Test: ./gradlew test / ./gradlew connectedAndroidTest
# Lint: ./gradlew ktlintCheck / ./gradlew detekt
# Build: ./gradlew assembleDebug / ./gradlew assembleRelease
```

### Example `.godmode/config.yaml`
```yaml
language: kotlin
framework: jetpack-compose     # or xml-views, ktor, spring-boot
test_command: ./gradlew test --parallel
lint_command: ./gradlew ktlintCheck detekt
format_command: ./gradlew ktlintFormat
build_command: ./gradlew assembleDebug
verify_command: ./gradlew connectedAndroidTest -Pandroid.testInstrumentationRunnerArguments.class=com.example.SmokeTest
```

---

## How Each Skill Applies to Kotlin

### THINK Phase

| Skill | Kotlin Adaptation |
|--|--|
| **think** | Design data classes, sealed interfaces, and flow contracts first. A Kotlin spec should define the domain layer with immutable data classes, sealed hierarchies for state, and `Flow`/`StateFlow` types for reactive streams. |
| **predict** | Expert panel evaluates coroutine architecture, memory management, and Compose recomposition strategy. Request panelists with Kotlin depth (e.g., Android GDE, Kotlin library author). |
| **scenario** | Explore edge cases around nullability, coroutine cancellation, configuration changes (activity recreation), process death, and offline-first data sync. |

### BUILD Phase

| Skill | Kotlin Adaptation |
|--|--|
| **plan** | Each task specifies modules and layers. File paths follow Android conventions (`app/src/main/java/com/example/feature/`). Tasks note which Gradle modules are affected. |
| **build** | TDD with JUnit5 and MockK. RED step writes a test class. GREEN step implements the class. REFACTOR step extracts extension functions, uses sealed classes, and applies coroutine best practices. |
| **test** | Use JUnit5 with `@Nested` for grouping. Use MockK for mocking (`every`, `coEvery` for suspending functions). Use Turbine for testing Flows. |
| **review** | Check for mutable state leaks, missing `viewModelScope` cancellation, improper `Dispatchers.Main` usage in repositories, and excessive recomposition in Compose. |

### OPTIMIZE Phase

| Skill | Kotlin Adaptation |
|--|--|
| **optimize** | Target app startup time, frame rendering, or memory usage. Guard rail: `./gradlew test` must pass on every iteration. Use Android Profiler data to guide hypotheses. |
| **debug** | Use Android Studio Profiler (CPU, Memory, Network). Check for common Kotlin/Android pitfalls: leaked coroutine scopes, unnecessary recompositions, N+1 Room queries. |
| **fix** | Autonomous fix loop handles compiler errors, test failures, and lint violations. Guard rail: `./gradlew test && ./gradlew ktlintCheck && ./gradlew detekt`. |
| **secure** | Audit for hardcoded API keys, insecure SharedPreferences, missing ProGuard/R8 rules, improper certificate pinning, and exported components without permissions. |

### SHIP Phase

| Skill | Kotlin Adaptation |
|--|--|
| **ship** | Pre-flight: `./gradlew test && ./gradlew ktlintCheck && ./gradlew assembleRelease`. Verify APK/AAB is signed and ProGuard mapping is archived. |
| **finish** | Ensure `versionCode` and `versionName` are bumped in `build.gradle.kts`. Verify ProGuard rules preserve required classes. Confirm Play Store listing metadata is current. |

---

## Recommended Metrics

| Metric | Verify Command | Target |
|--|--|--|
| Tests pass | `./gradlew test 2>&1 \| grep 'BUILD SUCCESSFUL'` | All passed |
| Lint violations | `./gradlew ktlintCheck 2>&1 \| tail -1` | 0 violations |
| Static analysis | `./gradlew detekt 2>&1 \| grep 'Build.*'` | 0 issues |
| APK size | `du -m app/build/outputs/apk/release/app-release.apk \| cut -f1` | Project-specific |
| Method count | `./gradlew countDebugDexMethods 2>&1 \| grep 'Total'` | < 65,536 (single dex) |
| Build time | `./gradlew assembleDebug --profile 2>&1 \| grep 'Total time'` | < 30s (incremental) |
| Test coverage | `./gradlew jacocoTestReport && cat app/build/reports/jacoco/html/index.html` | >= 80% |
| Compose recompositions | Layout Inspector recomposition count | Stable (no unnecessary) |

---

## Common Verify Commands

### Tests pass
```bash
./gradlew test --parallel
```

### Instrumented tests pass
```bash
./gradlew connectedAndroidTest
```

### Lint clean
```bash
./gradlew ktlintCheck
```

### Static analysis clean
```bash
./gradlew detekt
```

### Build succeeds
```bash
./gradlew assembleDebug
```

### Release build
```bash
./gradlew assembleRelease
# or for App Bundle
./gradlew bundleRelease
```

### APK analysis
```bash
# APK size and contents
$ANDROID_HOME/build-tools/34.0.0/aapt2 dump badging app/build/outputs/apk/release/app-release.apk
```

---

## Tool Integration

### JUnit5 + MockK

Godmode's TDD cycle maps directly to JUnit5:

```bash
# RED step: run single test class, expect failure
./gradlew test --tests "com.example.services.UserServiceTest"

# GREEN step: run single test, expect pass
./gradlew test --tests "com.example.services.UserServiceTest"

# After GREEN: run full suite to catch regressions
./gradlew test --parallel

# Coverage report
./gradlew jacocoTestReport
```

**Test patterns** for Godmode projects:
```kotlin
// app/src/test/java/com/example/services/UserServiceTest.kt
class UserServiceTest {
    private val mockRepository = mockk<UserRepository>()
    private val sut = UserService(mockRepository)

    @Nested
    inner class FetchUser {
        @Test
        fun `returns user when found`() = runTest {
            coEvery { mockRepository.findById("123") } returns User(id = "123", name = "Alice")

            val user = sut.fetchUser("123")

            assertThat(user.name).isEqualTo("Alice")
            coVerify(exactly = 1) { mockRepository.findById("123") }
        }

        @Test
        fun `throws when user not found`() = runTest {
            coEvery { mockRepository.findById("missing") } returns null

            assertThrows<UserNotFoundException> {
                sut.fetchUser("missing")
            }
        }
    }
}
```

### Turbine (Flow Testing)

```kotlin
// Testing StateFlow emissions
@Test
fun `emits loading then success states`() = runTest {
    val viewModel = UserListViewModel(mockRepository)

    viewModel.state.test {
        assertThat(awaitItem()).isEqualTo(UiState.Idle)

        viewModel.loadUsers()

        assertThat(awaitItem()).isEqualTo(UiState.Loading)
        assertThat(awaitItem()).isInstanceOf(UiState.Success::class.java)
        cancelAndIgnoreRemainingEvents()
    }
}
```

### Espresso (UI Testing)

```kotlin
// app/src/androidTest/java/com/example/ui/UserListScreenTest.kt
@HiltAndroidTest
class UserListScreenTest {
    @get:Rule
    val composeTestRule = createAndroidComposeRule<MainActivity>()

    @Test
    fun displaysUserListAfterLoading() {
        composeTestRule.onNodeWithTag("loading_indicator").assertIsDisplayed()
        composeTestRule.waitUntil(5000) {
            composeTestRule.onAllNodesWithTag("user_item").fetchSemanticsNodes().isNotEmpty()
        }
        composeTestRule.onNodeWithText("Alice").assertIsDisplayed()
    }

    @Test
    fun navigatesToDetailOnUserClick() {
        composeTestRule.waitUntil(5000) {
            composeTestRule.onAllNodesWithTag("user_item").fetchSemanticsNodes().isNotEmpty()
        }
        composeTestRule.onNodeWithText("Alice").performClick()
        composeTestRule.onNodeWithTag("user_detail_screen").assertIsDisplayed()
    }
}
```

### ktlint + detekt

```yaml
# Guard rail for optimize loop
guard_rails:
  - command: ./gradlew test --parallel
    expect: exit code 0
  - command: ./gradlew ktlintCheck
    expect: exit code 0
  - command: ./gradlew detekt
    expect: exit code 0
```

**detekt configuration** for Godmode projects:
```yaml
# detekt.yml
complexity:
  LongMethod:
    threshold: 30
  ComplexCondition:
    threshold: 4
  TooManyFunctions:
    thresholdInFiles: 15
    thresholdInClasses: 12
coroutines:
  GlobalCoroutineUsage:
    active: true
  SuspendFunWithCoroutineScopeReceiver:
    active: true
```

---

## Framework Integration

### Jetpack Compose

```yaml
# .godmode/config.yaml
framework: jetpack-compose
test_command: ./gradlew test --parallel
lint_command: ./gradlew ktlintCheck detekt
build_command: ./gradlew assembleDebug
```

Compose-specific THINK considerations:
- State hoisting strategy (stateless composables with state lifted to ViewModel)
- Navigation architecture with `NavHost` and type-safe routes
- Side effect management (`LaunchedEffect`, `SideEffect`, `DisposableEffect`)
- Recomposition stability — mark classes as `@Stable` or `@Immutable`
- Theme and design system tokens

Compose-specific patterns:
```kotlin
// Unidirectional data flow with sealed state
sealed interface UserListState {
    data object Loading : UserListState
    data class Success(val users: List<User>) : UserListState
    data class Error(val message: String) : UserListState
}

@HiltViewModel
class UserListViewModel @Inject constructor(
    private val repository: UserRepository
) : ViewModel() {
    private val _state = MutableStateFlow<UserListState>(UserListState.Loading)
    val state: StateFlow<UserListState> = _state.asStateFlow()

    init {
        viewModelScope.launch {
            repository.getUsers()
                .catch { _state.value = UserListState.Error(it.message ?: "Unknown error") }
                .collect { _state.value = UserListState.Success(it) }
        }
    }
}

@Composable
fun UserListScreen(
    viewModel: UserListViewModel = hiltViewModel(),
    onUserClick: (String) -> Unit
) {
    val state by viewModel.state.collectAsStateWithLifecycle()

    when (val current = state) {
        is UserListState.Loading -> LoadingIndicator()
        is UserListState.Success -> UserList(users = current.users, onUserClick = onUserClick)
        is UserListState.Error -> ErrorMessage(message = current.message)
    }
}
```

### XML Views (Legacy/Hybrid)

```yaml
# .godmode/config.yaml
framework: xml-views
test_command: ./gradlew test --parallel
lint_command: ./gradlew ktlintCheck detekt lint
build_command: ./gradlew assembleDebug
```

XML Views-specific THINK considerations:
- MVVM with ViewBinding and LiveData/StateFlow
- Fragment navigation with Navigation Component
- RecyclerView with ListAdapter and DiffUtil
- Data Binding vs. View Binding tradeoffs
- Migration strategy to Compose (if applicable)

### Kotlin Coroutines Patterns

```kotlin
// Structured concurrency in ViewModel
class DataSyncViewModel @Inject constructor(
    private val userRepo: UserRepository,
    private val productRepo: ProductRepository
) : ViewModel() {

    fun syncAll() {
        viewModelScope.launch {
            // Parallel execution with structured concurrency
            val (users, products) = coroutineScope {
                val usersDeferred = async { userRepo.fetchAll() }
                val productsDeferred = async { productRepo.fetchAll() }
                usersDeferred.await() to productsDeferred.await()
            }
            // Both completed or both cancelled
        }
    }
}

// Retry with exponential backoff
suspend fun <T> retryWithBackoff(
    times: Int = 3,
    initialDelay: Long = 100,
    factor: Double = 2.0,
    block: suspend () -> T
): T {
    var currentDelay = initialDelay
    repeat(times - 1) {
        try {
            return block()
        } catch (e: Exception) {
            delay(currentDelay)
            currentDelay = (currentDelay * factor).toLong()
        }
    }
    return block() // last attempt — let exception propagate
}
```

---

## Play Store Submission Workflow

### Pre-submission checklist

```bash
# 1. Run full test suite
./gradlew test --parallel

# 2. Run instrumented tests
./gradlew connectedAndroidTest

# 3. Lint and static analysis
./gradlew ktlintCheck detekt lint

# 4. Build release AAB
./gradlew bundleRelease

# 5. Verify APK/AAB signing
$ANDROID_HOME/build-tools/34.0.0/apksigner verify --print-certs app/build/outputs/bundle/release/app-release.aab

# 6. Upload to Play Store (via Fastlane)
bundle exec fastlane supply --aab app/build/outputs/bundle/release/app-release.aab --track internal
```

### Gradle Play Publisher integration

```kotlin
// build.gradle.kts
plugins {
    id("com.github.triplet.play") version "3.9.1"
}

play {
    track.set("internal")        // internal -> alpha -> beta -> production
    defaultToAppBundles.set(true)
    serviceAccountCredentials.set(file("play-service-account.json"))
}
```

```bash
# Publish to internal track
./gradlew publishBundle

# Promote from internal to production
./gradlew promoteArtifact --from-track internal --promote-track production
```

### Fastlane integration

```ruby
# Fastfile
default_platform(:android)

platform :android do
  desc "Run tests"
  lane :test do
    gradle(task: "test", flags: "--parallel")
  end

  desc "Build and upload to internal track"
  lane :internal do
    gradle(task: "bundleRelease")
    upload_to_play_store(
      track: "internal",
      aab: "app/build/outputs/bundle/release/app-release.aab"
    )
  end

  desc "Promote to production"
  lane :release do
    upload_to_play_store(
      track: "production",
      track_promote_to: "production",
      skip_upload_apk: true
    )
  end
end
```

Godmode ship integration:
```bash
/godmode:ship --pre-flight "./gradlew test ktlintCheck detekt" --deploy "bundle exec fastlane internal"
```

---

## Example: Full Workflow for Building an Android App

### Scenario
Build a task management app using Jetpack Compose with Room persistence, WorkManager for background sync, and Material 3 design.

### Step 1: Think (Design)
```
/godmode:think I need a task management app with Jetpack Compose — task CRUD,
due date reminders via WorkManager, Room for persistence, offline-first with
background sync, Material 3 theming with dynamic colors.
```

Godmode produces a spec at `docs/specs/task-manager.md` containing:
- Data classes: `Task`, `TaskStatus` (sealed interface), `SyncState`
- Room entities and DAOs with Flow-based queries
- ViewModel contracts with `StateFlow<UiState>`
- Navigation graph: `TaskList` -> `TaskDetail` -> `TaskEdit`
- WorkManager workers: `SyncWorker`, `ReminderWorker`

### Step 2: Build (TDD)
```
/godmode:build
```

**Task 1 — RED:**
```kotlin
// app/src/test/java/com/example/tasks/data/TaskRepositoryTest.kt
class TaskRepositoryTest {
    private val mockDao = mockk<TaskDao>()
    private val sut = TaskRepositoryImpl(mockDao)

    @Test
    fun `getAllTasks returns flow of tasks from dao`() = runTest {
        val tasks = listOf(Task(id = 1, title = "Buy groceries", status = TaskStatus.Todo))
        every { mockDao.getAllTasks() } returns flowOf(tasks)

        val result = sut.getAllTasks().first()

        assertThat(result).hasSize(1)
        assertThat(result.first().title).isEqualTo("Buy groceries")
    }
}
```
Commit: `test(red): Task repository — failing DAO integration tests`

**Task 1 — GREEN:**
Implement `TaskRepositoryImpl` backed by Room DAO.
Commit: `feat: Task repository — Room-backed implementation with Flow queries`

### Step 3: Optimize
```
/godmode:optimize --goal "reduce task list scroll jank" \
  --verify "Macrobenchmark frame timing P95" \
  --target "< 12ms"
```

### Step 4: Ship
```
/godmode:ship --pr
```

Pre-flight passes:
```
./gradlew test            ✓ 45/45 passing
./gradlew ktlintCheck     ✓ 0 violations
./gradlew detekt          ✓ 0 issues
./gradlew bundleRelease   ✓ AAB generated
```

---

## Kotlin-Specific Tips

### 1. Sealed interfaces are your state spec
In the THINK phase, define sealed interfaces for UI state, navigation events, and domain results. They make `when` expressions exhaustive and serve as living documentation.

### 2. Use coroutines structured concurrency
Always scope coroutines to a lifecycle (`viewModelScope`, `lifecycleScope`). Never use `GlobalScope`. Godmode's review skill flags unscoped coroutine launches.

### 3. Flow over LiveData
Prefer `StateFlow` and `SharedFlow` over `LiveData` for new code. Flows are more testable (with Turbine), composable, and work outside the Android framework:
```
/godmode:optimize --goal "migrate LiveData to StateFlow" --verify "./gradlew test" --target "exit code 0"
```

### 4. Compose stability matters
Mark data classes used in Compose with `@Stable` or `@Immutable` to prevent unnecessary recompositions. Use the Compose compiler reports to identify unstable parameters:
```bash
# Enable Compose compiler stability reports
./gradlew assembleDebug -PcomposeCompilerReports=true
```

### 5. Test dispatchers in tests
Always inject dispatchers and use `runTest` with `TestDispatcher` in unit tests. Hardcoded `Dispatchers.IO` or `Dispatchers.Main` makes tests flaky or impossible to run on JVM.

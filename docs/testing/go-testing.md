# Go Testing Mastery Guide

Comprehensive reference for testing in Go, covering the standard library testing package, table-driven tests, benchmarks, fuzzing, and popular third-party tools.

---

## Table of Contents

1. [Fundamentals](#fundamentals)
2. [Table-Driven Tests](#table-driven-tests)
3. [Subtests](#subtests)
4. [Benchmarks](#benchmarks)
5. [Testify](#testify)
6. [gomock](#gomock)
7. [httptest](#httptest)
8. [Fuzzing](#fuzzing)
9. [Race Detection](#race-detection)
10. [Integration Testing Patterns](#integration-testing-patterns)

---

## Fundamentals

### Test File Conventions

```
mypackage/
├── user.go                 # Source code
├── user_test.go            # Tests (same package)
├── user_internal_test.go   # Internal tests (mypackage)
└── user_export_test.go     # External tests (mypackage_test)
```

- Test files must end in `_test.go`.
- Test functions must start with `Test` and accept `*testing.T`.
- Same package tests can access unexported identifiers.
- External test packages (`package foo_test`) test only the public API.

### Basic Test

```go
package calculator

import "testing"

func TestAdd(t *testing.T) {
    got := Add(2, 3)
    want := 5
    if got != want {
        t.Errorf("Add(2, 3) = %d, want %d", got, want)
    }
}

// Fatal stops the test immediately
func TestDivide(t *testing.T) {
    result, err := Divide(10, 0)
    if err == nil {
        t.Fatal("expected error for division by zero")
    }
    if result != 0 {
        t.Fatalf("Divide(10, 0) = %d, want 0", result)
    }
}
```

### Testing Methods

```go
t.Error(args...)        // Log and mark as failed, continue
t.Errorf(fmt, args...)  // Formatted error, continue
t.Fatal(args...)        // Log and mark as failed, stop test
t.Fatalf(fmt, args...)  // Formatted fatal, stop test
t.Log(args...)          // Log message (shown with -v)
t.Logf(fmt, args...)    // Formatted log
t.Skip(args...)         // Skip test
t.Skipf(fmt, args...)   // Skip with format
t.SkipNow()             // Skip immediately
t.Helper()              // Mark function as test helper (cleaner stack traces)
t.Cleanup(func())       // Register cleanup (runs after test, LIFO order)
t.Parallel()            // Mark test as safe for parallel execution
t.TempDir()             // Create auto-cleaned temp directory
```

### Running Tests

```bash
# Run all tests in current package
go test

# Run all tests recursively
go test ./...

# Verbose output
go test -v ./...

# Run specific tests by pattern
go test -run TestAdd
go test -run TestUser/create
go test -run "TestUser/(create|delete)"

# Short mode (skip long tests)
go test -short ./...

# Count (run N times, useful for detecting flaky tests)
go test -count=10 ./...

# Timeout
go test -timeout 30s ./...

# Coverage
go test -cover ./...
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html
go tool cover -func=coverage.out

# JSON output
go test -json ./...

# Disable test caching
go test -count=1 ./...

# Build tags
go test -tags=integration ./...
```

---

## Table-Driven Tests

### Basic Table-Driven Test

```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name string
        a, b int
        want int
    }{
        {name: "positive numbers", a: 2, b: 3, want: 5},
        {name: "negative numbers", a: -1, b: -2, want: -3},
        {name: "mixed signs", a: -1, b: 5, want: 4},
        {name: "zeros", a: 0, b: 0, want: 0},
        {name: "large numbers", a: 1<<31 - 1, b: 1, want: 1 << 31},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := Add(tt.a, tt.b)
            if got != tt.want {
                t.Errorf("Add(%d, %d) = %d, want %d", tt.a, tt.b, got, tt.want)
            }
        })
    }
}
```

### Table-Driven Tests with Error Cases

```go
func TestParseConfig(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    *Config
        wantErr bool
        errMsg  string
    }{
        {
            name:  "valid JSON",
            input: `{"host":"localhost","port":8080}`,
            want:  &Config{Host: "localhost", Port: 8080},
        },
        {
            name:    "invalid JSON",
            input:   `{invalid}`,
            wantErr: true,
            errMsg:  "invalid character",
        },
        {
            name:    "missing required field",
            input:   `{"host":"localhost"}`,
            wantErr: true,
            errMsg:  "port is required",
        },
        {
            name:  "empty input defaults",
            input: `{}`,
            want:  &Config{Host: "0.0.0.0", Port: 3000},
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := ParseConfig([]byte(tt.input))

            if tt.wantErr {
                if err == nil {
                    t.Fatal("expected error, got nil")
                }
                if tt.errMsg != "" && !strings.Contains(err.Error(), tt.errMsg) {
                    t.Errorf("error = %q, want containing %q", err.Error(), tt.errMsg)
                }
                return
            }

            if err != nil {
                t.Fatalf("unexpected error: %v", err)
            }

            if !reflect.DeepEqual(got, tt.want) {
                t.Errorf("ParseConfig() = %+v, want %+v", got, tt.want)
            }
        })
    }
}
```

### Map-Based Table Tests

```go
func TestStatusText(t *testing.T) {
    tests := map[string]struct {
        code int
        want string
    }{
        "OK":          {code: 200, want: "OK"},
        "Not Found":   {code: 404, want: "Not Found"},
        "Server Error": {code: 500, want: "Internal Server Error"},
    }

    for name, tt := range tests {
        t.Run(name, func(t *testing.T) {
            got := StatusText(tt.code)
            if got != tt.want {
                t.Errorf("StatusText(%d) = %q, want %q", tt.code, got, tt.want)
            }
        })
    }
}
```

---

## Subtests

### Grouped Subtests

```go
func TestUser(t *testing.T) {
    // Shared setup
    db := setupTestDB(t)

    t.Run("Create", func(t *testing.T) {
        user, err := db.CreateUser("Alice", "alice@example.com")
        if err != nil {
            t.Fatalf("CreateUser() error: %v", err)
        }
        if user.ID == 0 {
            t.Error("expected non-zero ID")
        }
    })

    t.Run("Read", func(t *testing.T) {
        user, err := db.GetUser(1)
        if err != nil {
            t.Fatalf("GetUser() error: %v", err)
        }
        if user.Name != "Alice" {
            t.Errorf("Name = %q, want %q", user.Name, "Alice")
        }
    })

    t.Run("Update", func(t *testing.T) {
        err := db.UpdateUser(1, "Alice Updated")
        if err != nil {
            t.Fatalf("UpdateUser() error: %v", err)
        }
    })

    t.Run("Delete", func(t *testing.T) {
        err := db.DeleteUser(1)
        if err != nil {
            t.Fatalf("DeleteUser() error: %v", err)
        }
    })
}
```

### Parallel Subtests

```go
func TestParallelOperations(t *testing.T) {
    tests := []struct {
        name  string
        input string
        want  string
    }{
        {"uppercase", "hello", "HELLO"},
        {"lowercase", "WORLD", "world"},
        {"trim", "  spaced  ", "spaced"},
    }

    for _, tt := range tests {
        tt := tt // Capture range variable (not needed in Go 1.22+)
        t.Run(tt.name, func(t *testing.T) {
            t.Parallel() // Run subtests in parallel
            got := Transform(tt.input, tt.name)
            if got != tt.want {
                t.Errorf("Transform(%q, %q) = %q, want %q",
                    tt.input, tt.name, got, tt.want)
            }
        })
    }
}
```

### Cleanup in Subtests

```go
func TestWithCleanup(t *testing.T) {
    t.Run("creates temp file", func(t *testing.T) {
        dir := t.TempDir() // Auto-cleaned after subtest

        path := filepath.Join(dir, "test.txt")
        err := os.WriteFile(path, []byte("test"), 0644)
        if err != nil {
            t.Fatal(err)
        }

        // Or use t.Cleanup for custom cleanup
        t.Cleanup(func() {
            // Runs after this subtest completes
            log.Println("Cleaning up test resources")
        })
    })
}
```

---

## Benchmarks

### Basic Benchmarks

```go
func BenchmarkFibonacci(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Fibonacci(20)
    }
}

// With setup that should not be timed
func BenchmarkSort(b *testing.B) {
    data := generateRandomSlice(10000)
    b.ResetTimer() // Exclude setup from timing

    for i := 0; i < b.N; i++ {
        sorted := make([]int, len(data))
        copy(sorted, data)
        sort.Ints(sorted)
    }
}
```

### Benchmark with Sub-Benchmarks

```go
func BenchmarkMapAccess(b *testing.B) {
    sizes := []int{100, 1000, 10000, 100000}

    for _, size := range sizes {
        b.Run(fmt.Sprintf("size=%d", size), func(b *testing.B) {
            m := make(map[int]int, size)
            for i := 0; i < size; i++ {
                m[i] = i
            }
            b.ResetTimer()

            for i := 0; i < b.N; i++ {
                _ = m[size/2]
            }
        })
    }
}
```

### Memory Benchmarks

```go
func BenchmarkAllocations(b *testing.B) {
    b.ReportAllocs() // Report memory allocations

    for i := 0; i < b.N; i++ {
        s := make([]byte, 1024)
        _ = s
    }
}

// Benchmark comparison
func BenchmarkStringConcat(b *testing.B) {
    b.Run("plus", func(b *testing.B) {
        for i := 0; i < b.N; i++ {
            s := ""
            for j := 0; j < 100; j++ {
                s += "a"
            }
        }
    })

    b.Run("builder", func(b *testing.B) {
        for i := 0; i < b.N; i++ {
            var builder strings.Builder
            for j := 0; j < 100; j++ {
                builder.WriteString("a")
            }
            _ = builder.String()
        }
    })

    b.Run("join", func(b *testing.B) {
        for i := 0; i < b.N; i++ {
            parts := make([]string, 100)
            for j := range parts {
                parts[j] = "a"
            }
            _ = strings.Join(parts, "")
        }
    })
}
```

### Running Benchmarks

```bash
# Run benchmarks
go test -bench=. ./...

# Run specific benchmark
go test -bench=BenchmarkSort ./...

# With memory stats
go test -bench=. -benchmem ./...

# Multiple iterations for stable results
go test -bench=. -count=5 ./...

# Compare benchmarks (benchstat)
go test -bench=. -count=10 > old.txt
# ... make changes ...
go test -bench=. -count=10 > new.txt
benchstat old.txt new.txt

# CPU profile
go test -bench=BenchmarkSort -cpuprofile=cpu.prof
go tool pprof cpu.prof

# Memory profile
go test -bench=BenchmarkSort -memprofile=mem.prof
go tool pprof mem.prof

# Benchmark time limit
go test -bench=. -benchtime=5s ./...
go test -bench=. -benchtime=1000x ./...  # Exact iteration count
```

---

## Testify

### Assert Package

```go
import (
    "testing"
    "github.com/stretchr/testify/assert"
)

func TestWithAssert(t *testing.T) {
    // Equality
    assert.Equal(t, expected, actual)
    assert.NotEqual(t, unexpected, actual)
    assert.EqualValues(t, expected, actual)     // Type-converting equality

    // Nil checks
    assert.Nil(t, err)
    assert.NotNil(t, result)

    // Boolean
    assert.True(t, condition)
    assert.False(t, condition)

    // Errors
    assert.NoError(t, err)
    assert.Error(t, err)
    assert.ErrorIs(t, err, ErrNotFound)
    assert.ErrorAs(t, err, &target)
    assert.ErrorContains(t, err, "not found")
    assert.EqualError(t, err, "exact error message")

    // Collections
    assert.Contains(t, slice, element)
    assert.NotContains(t, slice, element)
    assert.Len(t, slice, 3)
    assert.Empty(t, slice)
    assert.NotEmpty(t, slice)
    assert.ElementsMatch(t, expected, actual)   // Same elements, any order
    assert.Subset(t, superset, subset)

    // Strings
    assert.Contains(t, "hello world", "world")
    assert.Regexp(t, `^\d+$`, "12345")

    // Types
    assert.IsType(t, &User{}, result)
    assert.Implements(t, (*io.Reader)(nil), result)

    // Numeric
    assert.Greater(t, 2, 1)
    assert.GreaterOrEqual(t, 2, 2)
    assert.Less(t, 1, 2)
    assert.InDelta(t, 3.14, pi, 0.01)
    assert.InEpsilon(t, 100.0, actual, 0.01)   // 1% tolerance
    assert.Positive(t, num)
    assert.Negative(t, num)
    assert.Zero(t, num)

    // Panics
    assert.Panics(t, func() { panic("oh no") })
    assert.PanicsWithValue(t, "oh no", func() { panic("oh no") })
    assert.NotPanics(t, func() { /* safe */ })

    // JSON
    assert.JSONEq(t, `{"a":1,"b":2}`, `{"b":2,"a":1}`)

    // Comparison
    assert.WithinDuration(t, time1, time2, time.Second)

    // File system
    assert.FileExists(t, "/path/to/file")
    assert.DirExists(t, "/path/to/dir")

    // Custom message
    assert.Equal(t, expected, actual, "user ID should match after creation")
    assert.Equalf(t, expected, actual, "user %d should exist", userID)
}
```

### Require Package (Fatal on Failure)

```go
import "github.com/stretchr/testify/require"

func TestWithRequire(t *testing.T) {
    // Same API as assert, but stops test on failure
    result, err := DoSomething()
    require.NoError(t, err)     // Fatal if err != nil
    require.NotNil(t, result)   // Fatal if nil

    // Safe to use result here since require stopped on nil
    assert.Equal(t, "expected", result.Name)
}
```

### Suite Package

```go
import (
    "testing"
    "github.com/stretchr/testify/suite"
)

type UserServiceSuite struct {
    suite.Suite
    db      *Database
    service *UserService
}

// Setup before entire suite
func (s *UserServiceSuite) SetupSuite() {
    s.db = NewTestDatabase()
    s.service = NewUserService(s.db)
}

// Teardown after entire suite
func (s *UserServiceSuite) TearDownSuite() {
    s.db.Close()
}

// Setup before each test
func (s *UserServiceSuite) SetupTest() {
    s.db.Truncate("users")
}

// Teardown after each test
func (s *UserServiceSuite) TearDownTest() {
    // cleanup
}

func (s *UserServiceSuite) TestCreateUser() {
    user, err := s.service.Create("Alice", "alice@example.com")
    s.Require().NoError(err)
    s.Assert().Equal("Alice", user.Name)
    s.Assert().NotZero(user.ID)
}

func (s *UserServiceSuite) TestGetUser() {
    created, _ := s.service.Create("Bob", "bob@example.com")
    found, err := s.service.Get(created.ID)
    s.Require().NoError(err)
    s.Assert().Equal(created.ID, found.ID)
}

// Run the suite
func TestUserServiceSuite(t *testing.T) {
    suite.Run(t, new(UserServiceSuite))
}
```

### Mock Package

```go
import "github.com/stretchr/testify/mock"

// Define interface
type EmailSender interface {
    Send(to, subject, body string) error
    SendBulk(recipients []string, subject, body string) (int, error)
}

// Create mock
type MockEmailSender struct {
    mock.Mock
}

func (m *MockEmailSender) Send(to, subject, body string) error {
    args := m.Called(to, subject, body)
    return args.Error(0)
}

func (m *MockEmailSender) SendBulk(recipients []string, subject, body string) (int, error) {
    args := m.Called(recipients, subject, body)
    return args.Int(0), args.Error(1)
}

// Use in tests
func TestNotification(t *testing.T) {
    sender := new(MockEmailSender)

    // Set expectations
    sender.On("Send", "alice@example.com", "Welcome", mock.Anything).Return(nil)
    sender.On("Send", mock.AnythingOfType("string"), mock.Anything, mock.Anything).Return(nil)
    sender.On("SendBulk", mock.Anything, "Newsletter", mock.Anything).Return(5, nil)

    // Use mock
    service := NewNotificationService(sender)
    err := service.NotifyUser("alice@example.com")

    // Verify
    assert.NoError(t, err)
    sender.AssertExpectations(t)
    sender.AssertCalled(t, "Send", "alice@example.com", "Welcome", mock.Anything)
    sender.AssertNumberOfCalls(t, "Send", 1)
}
```

---

## gomock

### Interface Mocking with mockgen

```bash
# Install mockgen
go install go.uber.org/mock/mockgen@latest

# Generate mocks from interface
mockgen -source=repository.go -destination=mocks/mock_repository.go -package=mocks

# Generate from interface by name
mockgen -destination=mocks/mock_store.go -package=mocks myapp/store Store,Cache

# Generate with go:generate
//go:generate mockgen -source=repository.go -destination=mocks/mock_repository.go -package=mocks
```

### Using gomock

```go
import (
    "testing"
    "go.uber.org/mock/gomock"
    "myapp/mocks"
)

func TestService(t *testing.T) {
    ctrl := gomock.NewController(t)
    // No need for ctrl.Finish() in modern Go - it's called automatically

    mockRepo := mocks.NewMockUserRepository(ctrl)

    // Set expectations
    mockRepo.EXPECT().
        GetByID(gomock.Eq(int64(1))).
        Return(&User{ID: 1, Name: "Alice"}, nil).
        Times(1)

    mockRepo.EXPECT().
        Save(gomock.Any()).
        DoAndReturn(func(user *User) error {
            user.ID = 42
            return nil
        })

    // Use mock
    service := NewUserService(mockRepo)
    user, err := service.GetUser(1)

    assert.NoError(t, err)
    assert.Equal(t, "Alice", user.Name)
}
```

### gomock Matchers

```go
// Built-in matchers
gomock.Any()                            // Match anything
gomock.Eq(value)                        // Exact match
gomock.Nil()                            // Match nil
gomock.Not(matcher)                     // Negate matcher
gomock.Len(n)                           // Match length
gomock.Regex(pattern)                   // Match regex (strings)

// Call ordering
first := mockRepo.EXPECT().GetByID(gomock.Any()).Return(user, nil)
mockRepo.EXPECT().Save(gomock.Any()).Return(nil).After(first)

// gomock.InOrder for sequential expectations
gomock.InOrder(
    mockRepo.EXPECT().Begin(),
    mockRepo.EXPECT().Save(gomock.Any()).Return(nil),
    mockRepo.EXPECT().Commit(),
)

// Custom matcher
type userMatcher struct {
    name string
}

func (m userMatcher) Matches(x interface{}) bool {
    user, ok := x.(*User)
    return ok && user.Name == m.name
}

func (m userMatcher) String() string {
    return fmt.Sprintf("has name %q", m.name)
}

func HasName(name string) gomock.Matcher {
    return userMatcher{name: name}
}

mockRepo.EXPECT().Save(HasName("Alice")).Return(nil)
```

---

## httptest

### Testing HTTP Handlers

```go
import (
    "net/http"
    "net/http/httptest"
    "testing"
)

func TestHealthHandler(t *testing.T) {
    // Create request
    req := httptest.NewRequest(http.MethodGet, "/health", nil)
    // Create response recorder
    w := httptest.NewRecorder()

    // Call handler directly
    HealthHandler(w, req)

    // Assert response
    resp := w.Result()
    defer resp.Body.Close()

    assert.Equal(t, http.StatusOK, resp.StatusCode)

    body, _ := io.ReadAll(resp.Body)
    assert.JSONEq(t, `{"status":"ok"}`, string(body))
}

// POST with JSON body
func TestCreateUserHandler(t *testing.T) {
    payload := `{"name":"Alice","email":"alice@example.com"}`
    req := httptest.NewRequest(
        http.MethodPost,
        "/users",
        strings.NewReader(payload),
    )
    req.Header.Set("Content-Type", "application/json")
    req.Header.Set("Authorization", "Bearer test-token")

    w := httptest.NewRecorder()
    CreateUserHandler(w, req)

    resp := w.Result()
    assert.Equal(t, http.StatusCreated, resp.StatusCode)
    assert.Equal(t, "application/json", resp.Header.Get("Content-Type"))

    var user User
    json.NewDecoder(resp.Body).Decode(&user)
    assert.Equal(t, "Alice", user.Name)
    assert.NotZero(t, user.ID)
}
```

### Test Server

```go
func TestAPIClient(t *testing.T) {
    // Create a test server
    server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        switch r.URL.Path {
        case "/api/users":
            w.Header().Set("Content-Type", "application/json")
            json.NewEncoder(w).Encode([]User{
                {ID: 1, Name: "Alice"},
                {ID: 2, Name: "Bob"},
            })
        case "/api/users/1":
            w.Header().Set("Content-Type", "application/json")
            json.NewEncoder(w).Encode(User{ID: 1, Name: "Alice"})
        default:
            http.NotFound(w, r)
        }
    }))
    defer server.Close()

    // Use the test server URL
    client := NewAPIClient(server.URL)
    users, err := client.ListUsers()
    require.NoError(t, err)
    assert.Len(t, users, 2)
}

// TLS server
func TestTLSClient(t *testing.T) {
    server := httptest.NewTLSServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintln(w, "secure")
    }))
    defer server.Close()

    // Use server.Client() for TLS-configured client
    resp, err := server.Client().Get(server.URL)
    require.NoError(t, err)
    defer resp.Body.Close()
}
```

### Testing Middleware

```go
func TestAuthMiddleware(t *testing.T) {
    // Create a simple handler that the middleware wraps
    handler := AuthMiddleware(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        userID := r.Context().Value(UserIDKey).(string)
        fmt.Fprintf(w, "user: %s", userID)
    }))

    t.Run("valid token", func(t *testing.T) {
        req := httptest.NewRequest(http.MethodGet, "/", nil)
        req.Header.Set("Authorization", "Bearer valid-token")
        w := httptest.NewRecorder()

        handler.ServeHTTP(w, req)

        assert.Equal(t, http.StatusOK, w.Code)
        assert.Contains(t, w.Body.String(), "user:")
    })

    t.Run("missing token", func(t *testing.T) {
        req := httptest.NewRequest(http.MethodGet, "/", nil)
        w := httptest.NewRecorder()

        handler.ServeHTTP(w, req)

        assert.Equal(t, http.StatusUnauthorized, w.Code)
    })

    t.Run("invalid token", func(t *testing.T) {
        req := httptest.NewRequest(http.MethodGet, "/", nil)
        req.Header.Set("Authorization", "Bearer invalid")
        w := httptest.NewRecorder()

        handler.ServeHTTP(w, req)

        assert.Equal(t, http.StatusForbidden, w.Code)
    })
}
```

### Testing with Router (chi, gorilla/mux, etc.)

```go
func TestRouter(t *testing.T) {
    router := setupRouter() // Your router setup function

    server := httptest.NewServer(router)
    defer server.Close()

    t.Run("GET /api/users", func(t *testing.T) {
        resp, err := http.Get(server.URL + "/api/users")
        require.NoError(t, err)
        defer resp.Body.Close()
        assert.Equal(t, http.StatusOK, resp.StatusCode)
    })

    t.Run("POST /api/users", func(t *testing.T) {
        body := strings.NewReader(`{"name":"Alice"}`)
        resp, err := http.Post(server.URL+"/api/users", "application/json", body)
        require.NoError(t, err)
        defer resp.Body.Close()
        assert.Equal(t, http.StatusCreated, resp.StatusCode)
    })
}
```

---

## Fuzzing

### Basic Fuzz Test

```go
func FuzzParseJSON(f *testing.F) {
    // Add seed corpus (known inputs)
    f.Add(`{"key": "value"}`)
    f.Add(`{"num": 42}`)
    f.Add(`[]`)
    f.Add(`""`)
    f.Add(`null`)

    f.Fuzz(func(t *testing.T, input string) {
        var result interface{}
        err := json.Unmarshal([]byte(input), &result)

        if err != nil {
            return // Invalid JSON is expected
        }

        // If we can unmarshal, we should be able to marshal back
        output, err := json.Marshal(result)
        if err != nil {
            t.Fatalf("Marshal failed for valid input: %v", err)
        }

        // Round-trip should produce valid JSON
        var result2 interface{}
        if err := json.Unmarshal(output, &result2); err != nil {
            t.Fatalf("Round-trip produced invalid JSON: %v", err)
        }
    })
}
```

### Fuzz with Multiple Parameters

```go
func FuzzURLParse(f *testing.F) {
    f.Add("https", "example.com", "/path", "key=value")
    f.Add("http", "localhost", "/", "")
    f.Add("ftp", "files.example.com", "/docs/readme.txt", "v=1")

    f.Fuzz(func(t *testing.T, scheme, host, path, query string) {
        raw := fmt.Sprintf("%s://%s%s", scheme, host, path)
        if query != "" {
            raw += "?" + query
        }

        u, err := url.Parse(raw)
        if err != nil {
            return // Invalid URLs are expected
        }

        // Verify parsed components
        if u.Scheme != "" && u.Host != "" {
            reconstructed := u.String()
            u2, err := url.Parse(reconstructed)
            if err != nil {
                t.Fatalf("Round-trip failed: %v", err)
            }
            if u2.Scheme != u.Scheme || u2.Host != u.Host {
                t.Errorf("Round-trip changed URL: %q -> %q", raw, reconstructed)
            }
        }
    })
}
```

### Running Fuzz Tests

```bash
# Run fuzz test (default: run seed corpus only)
go test -run=FuzzParseJSON

# Actually fuzz (continuously generate inputs)
go test -fuzz=FuzzParseJSON -fuzztime=30s

# Fuzz for specific duration or count
go test -fuzz=FuzzParseJSON -fuzztime=1m
go test -fuzz=FuzzParseJSON -fuzztime=10000x

# Fuzz corpus is stored in testdata/fuzz/<FuncName>/
# Failing inputs are added automatically for regression testing
```

---

## Race Detection

### Running with Race Detector

```bash
# Run tests with race detection
go test -race ./...

# Build with race detection
go build -race ./cmd/myapp

# Run benchmarks with race detection
go test -race -bench=. ./...
```

### Writing Race-Safe Tests

```go
func TestConcurrentMap(t *testing.T) {
    m := NewConcurrentMap()

    var wg sync.WaitGroup
    for i := 0; i < 100; i++ {
        wg.Add(2)
        go func(i int) {
            defer wg.Done()
            m.Set(fmt.Sprintf("key%d", i), i)
        }(i)
        go func(i int) {
            defer wg.Done()
            _ = m.Get(fmt.Sprintf("key%d", i))
        }(i)
    }
    wg.Wait()
}

// Testing for expected races
func TestRaceCondition(t *testing.T) {
    if testing.Short() {
        t.Skip("skipping race test in short mode")
    }

    counter := &SafeCounter{}
    var wg sync.WaitGroup

    for i := 0; i < 1000; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            counter.Increment()
        }()
    }

    wg.Wait()
    assert.Equal(t, int64(1000), counter.Value())
}
```

### Common Race Patterns to Test

```go
// Test channel operations
func TestChannelSafety(t *testing.T) {
    ch := make(chan int, 10)

    go func() {
        for i := 0; i < 10; i++ {
            ch <- i
        }
        close(ch)
    }()

    var results []int
    for v := range ch {
        results = append(results, v)
    }

    assert.Len(t, results, 10)
}

// Test context cancellation
func TestContextCancellation(t *testing.T) {
    ctx, cancel := context.WithCancel(context.Background())
    var completed int64

    for i := 0; i < 10; i++ {
        go func() {
            select {
            case <-ctx.Done():
                atomic.AddInt64(&completed, 1)
            case <-time.After(5 * time.Second):
                t.Error("timeout waiting for cancellation")
            }
        }()
    }

    cancel()
    time.Sleep(100 * time.Millisecond)
    assert.Equal(t, int64(10), atomic.LoadInt64(&completed))
}
```

---

## Integration Testing Patterns

### Build Tags for Integration Tests

```go
//go:build integration

package myapp_test

import (
    "os"
    "testing"
)

func TestMain(m *testing.M) {
    // Setup: start containers, seed database, etc.
    pool, resource := setupPostgres()

    code := m.Run()

    // Teardown
    pool.Purge(resource)
    os.Exit(code)
}

func TestDatabaseIntegration(t *testing.T) {
    db := connectToTestDB(t)
    // ...
}
```

```bash
# Run only integration tests
go test -tags=integration ./...

# Run without integration tests (default)
go test ./...
```

### TestMain for Suite Setup

```go
package store_test

import (
    "os"
    "testing"
)

var testDB *sql.DB

func TestMain(m *testing.M) {
    // Setup
    var err error
    testDB, err = sql.Open("postgres", os.Getenv("TEST_DATABASE_URL"))
    if err != nil {
        log.Fatalf("Failed to connect to test database: %v", err)
    }

    // Run migrations
    if err := migrate.Up(testDB); err != nil {
        log.Fatalf("Failed to run migrations: %v", err)
    }

    // Run tests
    code := m.Run()

    // Teardown
    testDB.Close()
    os.Exit(code)
}
```

### Testcontainers for Docker Dependencies

```go
import (
    "context"
    "testing"
    "github.com/testcontainers/testcontainers-go"
    "github.com/testcontainers/testcontainers-go/modules/postgres"
    "github.com/testcontainers/testcontainers-go/wait"
)

func TestWithPostgres(t *testing.T) {
    ctx := context.Background()

    container, err := postgres.Run(ctx,
        "postgres:16",
        postgres.WithDatabase("test_db"),
        postgres.WithUsername("test"),
        postgres.WithPassword("test"),
        testcontainers.WithWaitStrategy(
            wait.ForLog("database system is ready to accept connections").
                WithOccurrence(2).
                WithStartupTimeout(30*time.Second),
        ),
    )
    require.NoError(t, err)
    t.Cleanup(func() { container.Terminate(ctx) })

    connStr, err := container.ConnectionString(ctx, "sslmode=disable")
    require.NoError(t, err)

    db, err := sql.Open("postgres", connStr)
    require.NoError(t, err)
    defer db.Close()

    // Run tests against real PostgreSQL
    err = db.Ping()
    require.NoError(t, err)
}
```

### Testing with Environment Variables

```go
func TestConfigFromEnv(t *testing.T) {
    // Use t.Setenv (auto-cleanup in Go 1.17+)
    t.Setenv("APP_PORT", "9090")
    t.Setenv("APP_HOST", "0.0.0.0")
    t.Setenv("APP_DEBUG", "true")

    config := LoadConfig()
    assert.Equal(t, 9090, config.Port)
    assert.Equal(t, "0.0.0.0", config.Host)
    assert.True(t, config.Debug)
}
```

### Golden File Testing

```go
func TestRenderTemplate(t *testing.T) {
    data := TemplateData{
        Title: "Test Page",
        Items: []string{"A", "B", "C"},
    }

    got, err := RenderTemplate("page.html", data)
    require.NoError(t, err)

    goldenFile := filepath.Join("testdata", t.Name()+".golden")

    if *update {
        // Update golden file: go test -update
        os.MkdirAll("testdata", 0755)
        os.WriteFile(goldenFile, []byte(got), 0644)
        return
    }

    want, err := os.ReadFile(goldenFile)
    require.NoError(t, err)
    assert.Equal(t, string(want), got)
}

var update = flag.Bool("update", false, "update golden files")
```

### Test Helpers

```go
// testutil/helpers.go
package testutil

import "testing"

// MustParse is a test helper that parses or fails the test.
func MustParse(t *testing.T, raw string) *Config {
    t.Helper() // Report caller's line number on failure

    config, err := Parse(raw)
    if err != nil {
        t.Fatalf("MustParse(%q): %v", raw, err)
    }
    return config
}

// AssertEqualJSON compares two JSON strings ignoring formatting.
func AssertEqualJSON(t *testing.T, expected, actual string) {
    t.Helper()

    var e, a interface{}
    if err := json.Unmarshal([]byte(expected), &e); err != nil {
        t.Fatalf("invalid expected JSON: %v", err)
    }
    if err := json.Unmarshal([]byte(actual), &a); err != nil {
        t.Fatalf("invalid actual JSON: %v", err)
    }

    if !reflect.DeepEqual(e, a) {
        t.Errorf("JSON mismatch:\nexpected: %s\nactual:   %s", expected, actual)
    }
}
```

---

## Quick Reference Card

```
Command                                Description
────────────────────────────────────────────────────────────────
go test                                Run tests in current package
go test ./...                          Run all tests recursively
go test -v                             Verbose output
go test -run TestFoo                   Run matching tests
go test -run TestFoo/subtest           Run matching subtest
go test -short                         Skip long tests
go test -race                          Enable race detector
go test -cover                         Show coverage percentage
go test -coverprofile=c.out            Generate coverage profile
go test -bench=.                       Run all benchmarks
go test -bench=. -benchmem             Benchmarks with memory stats
go test -fuzz=FuzzFoo -fuzztime=30s    Fuzz for 30 seconds
go test -count=1                       Disable test caching
go test -tags=integration              Build with tags
go test -json                          JSON output
go test -timeout 60s                   Set timeout
go test -parallel 4                    Max parallel tests

t.Error/t.Errorf                       Log failure, continue
t.Fatal/t.Fatalf                       Log failure, stop
t.Skip/t.Skipf                         Skip test
t.Parallel()                           Allow parallel execution
t.Helper()                             Mark as helper function
t.Cleanup(fn)                          Register cleanup function
t.TempDir()                            Create temp directory
t.Setenv(k, v)                         Set env var (auto-cleanup)
```

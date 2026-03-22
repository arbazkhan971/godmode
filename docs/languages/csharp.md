# C#/.NET Developer Guide

How to use Godmode's full workflow for C# and .NET projects — from design to production.

---

## Setup

```bash
/godmode:setup
# Godmode auto-detects C# via *.sln, *.csproj, or global.json
# Test: dotnet test
# Lint: dotnet format --verify-no-changes
# Build: dotnet build
# Type check: dotnet build (compiler handles type checking)
```

### Example `.godmode/config.yaml`
```yaml
language: csharp
framework: aspnet-core         # or blazor, maui, console, etc.
test_command: dotnet test --no-restore --verbosity normal
lint_command: dotnet format --verify-no-changes
format_command: dotnet format
build_command: dotnet build --no-restore
verify_command: curl -s -o /dev/null -w '%{time_total}' http://localhost:5000/health
```

---

## How Each Skill Applies to C#

### THINK Phase

| Skill | C# Adaptation |
|--|--|
| **think** | Design interfaces, records, and enums first. A C# spec should define the contract layer with `interface` types, immutable `record` types for data, and `enum` types for state. Include nullable reference type annotations. |
| **predict** | Expert panel evaluates architecture patterns (Clean Architecture, Vertical Slice), async/await strategy, and hosting model. Request panelists with .NET depth (e.g., ASP.NET Core maintainer, Azure architect). |
| **scenario** | Explore edge cases around nullable references, `Task` cancellation, `IDisposable` lifecycle, middleware ordering, and EF Core lazy loading pitfalls. |

### BUILD Phase

| Skill | C# Adaptation |
|--|--|
| **plan** | Each task specifies projects and namespaces. File paths follow .NET conventions (`src/MyApp.Api/Controllers/UsersController.cs`). Tasks note which projects in the solution are affected. |
| **build** | TDD with xUnit. RED step writes a test class with `[Fact]` and `[Theory]`. GREEN step implements the class. REFACTOR step applies dependency injection, record types, and pattern matching. |
| **test** | Use xUnit with `[Fact]`/`[Theory]` attributes. Use NSubstitute or Moq for mocking. Use `WebApplicationFactory<T>` for integration tests. |
| **review** | Check for missing `await` on async calls, `IDisposable` not being disposed, nullable reference warnings suppressed with `!`, and missing `CancellationToken` propagation. |

### OPTIMIZE Phase

| Skill | C# Adaptation |
|--|--|
| **optimize** | Target request latency, memory allocations, or startup time. Guard rail: `dotnet test` must pass on every iteration. Use BenchmarkDotNet for microbenchmarks. |
| **debug** | Use Visual Studio/Rider debugger, `dotnet-counters`, and `dotnet-trace`. Check for common C# pitfalls: excessive allocations, sync-over-async, captured closures in hot paths. |
| **fix** | Autonomous fix loop handles compiler errors, test failures, and format violations. Guard rail: `dotnet build && dotnet test && dotnet format --verify-no-changes`. |
| **secure** | Audit NuGet packages with `dotnet list package --vulnerable`. Check for SQL injection in raw EF queries, missing input validation, improper secret storage, and CORS misconfigurations. |

### SHIP Phase

| Skill | C# Adaptation |
|--|--|
| **ship** | Pre-flight: `dotnet test && dotnet format --verify-no-changes && dotnet publish -c Release`. Verify the published output runs correctly. |
| **finish** | Ensure version is bumped in `.csproj`. Verify `appsettings.Production.json` does not contain secrets. Confirm Docker image builds if containerized. |

---

## Recommended Metrics

| Metric | Verify Command | Target |
|--|--|--|
| Tests pass | `dotnet test 2>&1 \| grep 'Passed!'` | All passed |
| Format violations | `dotnet format --verify-no-changes 2>&1; echo $?` | exit code 0 |
| Build warnings | `dotnet build -warnaserror 2>&1 \| grep -c 'warning'` | 0 |
| Nullable violations | `dotnet build 2>&1 \| grep -c 'CS86'` | 0 |
| Test coverage | `dotnet test --collect:"XPlat Code Coverage" && reportgenerator` | >= 80% |
| Package vulnerabilities | `dotnet list package --vulnerable 2>&1 \| grep -c 'has the following'` | 0 |
| Published size | `du -m bin/Release/net9.0/publish/ \| tail -1 \| cut -f1` | Project-specific |
| Startup time | `dotnet run & sleep 2 && curl -s -o /dev/null -w '%{time_total}' http://localhost:5000/health` | < 2s |

---

## Common Verify Commands

### Tests pass
```bash
dotnet test --no-restore --verbosity normal
```

### Build clean (warnings as errors)
```bash
dotnet build -warnaserror --no-restore
```

### Format check
```bash
dotnet format --verify-no-changes
```

### Security audit
```bash
dotnet list package --vulnerable --include-transitive
```

### Publish
```bash
dotnet publish -c Release --no-restore
```

### API responds
```bash
curl -s -o /dev/null -w '%{time_total}' http://localhost:5000/health
```

---

## Tool Integration

### xUnit

Godmode's TDD cycle maps directly to xUnit:

```bash
# RED step: run single test class, expect failure
dotnet test --filter "FullyQualifiedName~UserServiceTests"

# GREEN step: run single test, expect pass
dotnet test --filter "FullyQualifiedName~UserServiceTests"

# After GREEN: run full suite to catch regressions
dotnet test --no-restore

# Coverage
dotnet test --collect:"XPlat Code Coverage"
```

**Test patterns** for Godmode projects:
```csharp
// tests/MyApp.Tests/Services/UserServiceTests.cs
public class UserServiceTests
{
    private readonly IUserRepository _mockRepository;
    private readonly UserService _sut;

    public UserServiceTests()
    {
        _mockRepository = Substitute.For<IUserRepository>();
        _sut = new UserService(_mockRepository);
    }

    [Fact]
    public async Task GetUser_WhenFound_ReturnsUser()
    {
        _mockRepository.FindByIdAsync("123", Arg.Any<CancellationToken>())
            .Returns(new User { Id = "123", Name = "Alice" });

        var result = await _sut.GetUserAsync("123");

        Assert.Equal("Alice", result.Name);
        await _mockRepository.Received(1).FindByIdAsync("123", Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task GetUser_WhenNotFound_ThrowsNotFoundException()
    {
        _mockRepository.FindByIdAsync("missing", Arg.Any<CancellationToken>())
            .Returns((User?)null);

        await Assert.ThrowsAsync<NotFoundException>(
            () => _sut.GetUserAsync("missing"));
    }

    [Theory]
    [InlineData("")]
    [InlineData(" ")]
    [InlineData(null)]
    public async Task GetUser_WithInvalidId_ThrowsArgumentException(string? invalidId)
    {
        await Assert.ThrowsAsync<ArgumentException>(
            () => _sut.GetUserAsync(invalidId!));
    }
}
```

### NUnit (Alternative)

```csharp
[TestFixture]
public class UserServiceTests
{
    private IUserRepository _mockRepository;
    private UserService _sut;

    [SetUp]
    public void SetUp()
    {
        _mockRepository = Substitute.For<IUserRepository>();
        _sut = new UserService(_mockRepository);
    }

    [Test]
    public async Task GetUser_WhenFound_ReturnsUser()
    {
        _mockRepository.FindByIdAsync("123", Arg.Any<CancellationToken>())
            .Returns(new User { Id = "123", Name = "Alice" });

        var result = await _sut.GetUserAsync("123");

        Assert.That(result.Name, Is.EqualTo("Alice"));
    }
}
```

### dotnet format + .editorconfig

```yaml
# Guard rail for optimize loop
guard_rails:
  - command: dotnet test --no-restore
    expect: exit code 0
  - command: dotnet format --verify-no-changes
    expect: exit code 0
  - command: dotnet build -warnaserror --no-restore
    expect: exit code 0
```

**.editorconfig** for Godmode projects:
```ini
[*.cs]
# Nullable reference types
dotnet_diagnostic.CS8600.severity = error
dotnet_diagnostic.CS8602.severity = error
dotnet_diagnostic.CS8603.severity = error

# Async/await
dotnet_diagnostic.CS4014.severity = error  # missing await
dotnet_diagnostic.CA2007.severity = warning # ConfigureAwait

# Style
csharp_style_var_for_built_in_types = true:suggestion
csharp_style_prefer_switch_expression = true:suggestion
csharp_style_prefer_pattern_matching = true:suggestion
csharp_style_namespace_declarations = file_scoped:warning
```

---

## Framework Integration

### ASP.NET Core

```yaml
# .godmode/config.yaml
framework: aspnet-core
test_command: dotnet test --no-restore
lint_command: dotnet format --verify-no-changes
build_command: dotnet build --no-restore
verify_command: curl -s -o /dev/null -w '%{time_total}' http://localhost:5000/health
```

ASP.NET Core-specific THINK considerations:
- Middleware pipeline ordering (authentication before authorization before routing)
- Dependency injection lifetime management (`Scoped` vs. `Singleton` vs. `Transient`)
- Minimal API vs. Controller-based design
- EF Core query strategy (eager loading, split queries, compiled queries)
- Health check and readiness probe design

ASP.NET Core integration testing:
```csharp
// tests/MyApp.IntegrationTests/UsersEndpointTests.cs
public class UsersEndpointTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public UsersEndpointTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureServices(services =>
            {
                services.AddSingleton<IUserRepository, InMemoryUserRepository>();
            });
        }).CreateClient();
    }

    [Fact]
    public async Task GetUsers_ReturnsOkWithUserList()
    {
        var response = await _client.GetAsync("/api/users");

        response.EnsureSuccessStatusCode();
        var users = await response.Content.ReadFromJsonAsync<List<UserDto>>();
        Assert.NotNull(users);
        Assert.NotEmpty(users);
    }
}
```

### Blazor

```yaml
# .godmode/config.yaml
framework: blazor
test_command: dotnet test --no-restore
lint_command: dotnet format --verify-no-changes
build_command: dotnet build --no-restore
verify_command: curl -s -o /dev/null -w '%{time_total}' http://localhost:5000
```

Blazor-specific THINK considerations:
- Server vs. WebAssembly vs. Auto rendering mode
- Component state management with cascading parameters
- JS interop strategy and isolation
- Authentication with `AuthenticationStateProvider`
- Form validation with `EditForm` and `DataAnnotationsValidator`

Blazor component testing with bUnit:
```csharp
[Fact]
public void UserList_RendersUsersAfterLoading()
{
    var mockService = Substitute.For<IUserService>();
    mockService.GetUsersAsync().Returns(new[] { new User { Name = "Alice" } });

    using var ctx = new TestContext();
    ctx.Services.AddSingleton(mockService);

    var cut = ctx.RenderComponent<UserList>();

    cut.WaitForState(() => cut.Find(".user-item") != null);
    cut.Find(".user-item").TextContent.MarkupMatches("Alice");
}
```

### .NET MAUI

```yaml
# .godmode/config.yaml
framework: maui
test_command: dotnet test --no-restore
lint_command: dotnet format --verify-no-changes
build_command: dotnet build -f net9.0-android
verify_command: dotnet build -f net9.0-ios
```

MAUI-specific THINK considerations:
- MVVM pattern with `CommunityToolkit.Mvvm`
- Platform-specific code with `#if ANDROID` / `#if IOS` directives
- Shell navigation and route registration
- Handler customization for platform-native rendering
- Responsive layout with `Grid` and `FlexLayout`

### NuGet Package Management

```bash
# Add a package
dotnet add package Serilog.AspNetCore --version 8.0.0

# Remove a package
dotnet remove package Serilog.AspNetCore

# List outdated packages
dotnet list package --outdated

# Restore packages
dotnet restore

# Check for vulnerabilities
dotnet list package --vulnerable --include-transitive

# Central package management (Directory.Packages.props)
# Ensures consistent versions across all projects in the solution
```

**Central package management** for Godmode projects:
```xml
<!-- Directory.Packages.props -->
<Project>
  <PropertyGroup>
    <ManagePackageVersionsCentrally>true</ManagePackageVersionsCentrally>
  </PropertyGroup>
  <ItemGroup>
    <PackageVersion Include="Microsoft.EntityFrameworkCore" Version="9.0.0" />
    <PackageVersion Include="xunit" Version="2.9.0" />
    <PackageVersion Include="NSubstitute" Version="5.3.0" />
  </ItemGroup>
</Project>
```

---

## Azure Deployment Integration

### Azure App Service

```bash
# Publish for Azure
dotnet publish -c Release -o ./publish

# Deploy with Azure CLI
az webapp deploy --resource-group mygroup --name myapp --src-path ./publish.zip --type zip

# Or use GitHub Actions
```

### Azure deployment workflow

```yaml
# .github/workflows/deploy.yml
name: Deploy to Azure
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '9.0.x'
      - run: dotnet restore
      - run: dotnet test --no-restore
      - run: dotnet publish -c Release -o ./publish
      - uses: azure/webapps-deploy@v3
        with:
          app-name: my-app
          publish-profile: ${{ secrets.AZURE_PUBLISH_PROFILE }}
          package: ./publish
```

### Docker deployment

```dockerfile
# Dockerfile
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY *.sln .
COPY src/**/*.csproj ./src/
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 8080
ENTRYPOINT ["dotnet", "MyApp.Api.dll"]
```

Godmode ship integration:
```bash
/godmode:ship --pre-flight "dotnet test && dotnet format --verify-no-changes" \
  --deploy "az webapp deploy --resource-group mygroup --name myapp --src-path ./publish.zip"
```

---

## Example: Full Workflow for Building a .NET API

### Scenario
Build a product catalog API using ASP.NET Core with EF Core, Redis caching, and Azure deployment.

### Step 1: Think (Design)
```
/godmode:think I need a product catalog API with ASP.NET Core — CRUD operations,
category filtering, full-text search, Redis caching layer, EF Core with PostgreSQL,
health checks, and Azure App Service deployment.
```

Godmode produces a spec at `docs/specs/product-catalog.md` containing:
- Record types: `Product`, `Category`, `ProductFilter`, `PagedResult<T>`
- Interface definitions: `IProductRepository`, `ICacheService`, `ISearchService`
- Endpoint design: Minimal API with `MapGroup("/api/products")`
- Middleware pipeline: Exception handler -> Authentication -> CORS -> Rate limiting
- EF Core entity configuration with owned types and value converters

### Step 2: Build (TDD)
```
/godmode:build
```

**Task 1 — RED:**
```csharp
// tests/MyApp.Tests/Services/ProductServiceTests.cs
public class ProductServiceTests
{
    private readonly IProductRepository _mockRepo = Substitute.For<IProductRepository>();
    private readonly ICacheService _mockCache = Substitute.For<ICacheService>();
    private readonly ProductService _sut;

    public ProductServiceTests()
    {
        _sut = new ProductService(_mockRepo, _mockCache);
    }

    [Fact]
    public async Task GetProduct_ReturnsCachedProduct_WhenInCache()
    {
        var cached = new Product { Id = 1, Name = "Widget" };
        _mockCache.GetAsync<Product>("product:1", Arg.Any<CancellationToken>())
            .Returns(cached);

        var result = await _sut.GetProductAsync(1);

        Assert.Equal("Widget", result.Name);
        await _mockRepo.DidNotReceive().FindByIdAsync(Arg.Any<int>(), Arg.Any<CancellationToken>());
    }
}
```
Commit: `test(red): Product service — failing cache integration tests`

**Task 1 — GREEN:**
Implement `ProductService` with cache-aside pattern.
Commit: `feat: Product service — cache-aside pattern with Redis`

### Step 3: Optimize
```
/godmode:optimize --goal "reduce product list query time" \
  --verify "curl -s -o /dev/null -w '%{time_total}' http://localhost:5000/api/products" \
  --target "< 0.03"
```

Iteration log:
| # | Hypothesis | Change | Baseline | Measured | Verdict |
|--|--|--|--|--|--|
| 1 | N+1 query on category include | Use `AsSplitQuery()` | 95ms | 42ms | KEEP |
| 2 | No response caching | Add `[OutputCache]` with 60s TTL | 42ms | 8ms | KEEP |
| 3 | JSON serialization overhead | Use source generators for `JsonSerializer` | 8ms | 7ms | KEEP |

### Step 4: Ship
```
/godmode:ship --pr
```

Pre-flight passes:
```
dotnet test               ✓ 52/52 passing
dotnet format --verify    ✓ No changes needed
dotnet build -warnaserror ✓ 0 warnings
dotnet publish -c Release ✓ Published
```

---

## C#-Specific Tips

### 1. Records are your spec
In the THINK phase, define `record` types for immutable data contracts. Records provide value equality, deconstruction, and `with` expressions out of the box:
```csharp
public record ProductDto(int Id, string Name, decimal Price, string Category);
```

### 2. Enable nullable reference types everywhere
Add `<Nullable>enable</Nullable>` to your `.csproj` from day one. Treat nullable warnings as errors. Godmode's fix loop can incrementally add null annotations:
```
/godmode:optimize --goal "eliminate nullable warnings" --verify "dotnet build 2>&1 | grep -c 'CS86'" --target "0"
```

### 3. Use minimal APIs for new services
Minimal APIs with endpoint filters and route groups are more concise and performant than controllers for most scenarios. They also pair well with Godmode's types-first approach.

### 4. Propagate CancellationTokens
In the REVIEW phase, check that every `async` method accepts and forwards `CancellationToken`. Missing cancellation support causes resource leaks under load:
```csharp
// Every async method should accept CancellationToken
public async Task<Product> GetProductAsync(int id, CancellationToken ct = default)
{
    return await _repository.FindByIdAsync(id, ct);
}
```

### 5. Use WebApplicationFactory for integration tests
Integration tests with `WebApplicationFactory<Program>` test the full HTTP pipeline including middleware, routing, and serialization. They catch issues that unit tests miss and are fast enough to run in every build.

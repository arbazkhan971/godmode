# Java/Kotlin Developer Guide

How to use Godmode's full workflow for JVM projects — from design to production.

---

## Setup

```bash
/godmode:setup
# Godmode auto-detects JVM projects via pom.xml, build.gradle, or build.gradle.kts
# Test: mvn test / gradle test
# Lint: mvn checkstyle:check / gradle checkstyleMain
# Build: mvn package / gradle build
```

### Example `.godmode/config.yaml` (Maven)
```yaml
language: java
framework: spring-boot
test_command: mvn test -q
lint_command: mvn checkstyle:check -q
build_command: mvn package -DskipTests -q
verify_command: curl -s -o /dev/null -w '%{time_total}' http://localhost:8080/actuator/health
```

### Example `.godmode/config.yaml` (Gradle/Kotlin)
```yaml
language: kotlin
framework: ktor
test_command: gradle test --quiet
lint_command: gradle ktlintCheck
build_command: gradle build -x test --quiet
verify_command: curl -s -o /dev/null -w '%{time_total}' http://localhost:8080/health
```

---

## How Each Skill Applies to JVM Projects

### THINK Phase

| Skill | JVM Adaptation |
|-------|----------------|
| **think** | Design interfaces, records/data classes, and sealed hierarchies first. A JVM spec should define the contract layer (interfaces) and data transfer objects before any logic. In Kotlin, leverage sealed classes and value classes. |
| **predict** | Expert panel evaluates framework choice, concurrency model (virtual threads, coroutines, reactive), and deployment strategy. Request panelists with JVM depth (e.g., Spring committer, JVM performance engineer). |
| **scenario** | Explore edge cases around null safety (Java `Optional` vs. Kotlin null types), thread safety, exception hierarchies, and serialization edge cases (Jackson, Kotlinx.serialization). |

### BUILD Phase

| Skill | JVM Adaptation |
|-------|----------------|
| **plan** | Each task specifies packages, classes, and interfaces. File paths follow Maven/Gradle conventions (`src/main/java/com/example/service/UserService.java`). Tasks note which Spring beans or Ktor modules they introduce. |
| **build** | TDD with JUnit 5 (Java) or kotest (Kotlin). RED step writes a test class. GREEN step implements the service. REFACTOR step extracts interfaces, adds generics, applies design patterns. |
| **test** | Use JUnit 5 `@Test`, `@ParameterizedTest`, `@Nested` classes. Mock with Mockito (Java) or MockK (Kotlin). Use `@SpringBootTest` for integration tests. Use testcontainers for database tests. |
| **review** | Check for null pointer risks (Java), unused dependencies, overly broad exception catches, missing `@Transactional` annotations, and thread-safety issues in shared state. |

### OPTIMIZE Phase

| Skill | JVM Adaptation |
|-------|----------------|
| **optimize** | Target response time, throughput, GC pause time, or startup time. Guard rail: `mvn test` must pass. Use JMH for microbenchmarks. Consider GraalVM native image for startup-sensitive services. |
| **debug** | Use IntelliJ debugger or `jdb`. Analyze thread dumps with `jstack`. Profile with async-profiler or VisualVM. Check GC logs for memory pressure. |
| **fix** | Autonomous fix loop handles test failures, compilation errors, and Checkstyle violations. Guard rail: `mvn test && mvn checkstyle:check` |
| **secure** | Audit dependencies with OWASP Dependency-Check (`mvn dependency-check:check`). Check for SQL injection, XSS in template rendering, insecure deserialization, and missing CSRF protection. |

### SHIP Phase

| Skill | JVM Adaptation |
|-------|----------------|
| **ship** | Pre-flight: `mvn test && mvn checkstyle:check && mvn package`. Verify the JAR/WAR starts and serves health checks. For Spring Boot, verify actuator endpoints. |
| **finish** | Ensure `pom.xml` or `build.gradle` version is bumped. Verify Docker image builds with the fat JAR. For libraries, verify `mvn deploy` (dry-run) succeeds. |

---

## Recommended Metrics

| Metric | Verify Command | Target |
|--------|---------------|--------|
| JUnit coverage | `mvn jacoco:report -q && grep -o 'Total[^%]*%' target/site/jacoco/index.html \| head -1` | >= 80% |
| Checkstyle violations | `mvn checkstyle:check 2>&1 \| grep 'violations' \| awk '{print $4}'` | 0 |
| Build time | `/usr/bin/time mvn package -DskipTests -q 2>&1 \| grep real` | Project-specific |
| Startup time | `timeout 30 java -jar target/*.jar 2>&1 \| grep 'Started.*in' \| awk '{print $(NF-1)}'` | < 5s |
| Response time | `curl -s -o /dev/null -w '%{time_total}' http://localhost:8080/api/health` | < 0.05s |
| JAR size | `du -b target/*.jar \| cut -f1` | Project-specific |
| Dependency vulnerabilities | `mvn dependency-check:check -q 2>&1 \| grep 'vulnerabilities found'` | 0 |
| Test execution time | `/usr/bin/time mvn test -q 2>&1 \| grep real` | Project-specific |

---

## Common Verify Commands

### Tests pass (Maven)
```bash
mvn test -q
```

### Tests pass (Gradle)
```bash
gradle test --quiet
```

### Checkstyle clean (Maven)
```bash
mvn checkstyle:check -q
```

### ktlint clean (Gradle/Kotlin)
```bash
gradle ktlintCheck
```

### Build succeeds
```bash
mvn package -DskipTests -q
# or
gradle build -x test --quiet
```

### Coverage report
```bash
mvn jacoco:report
# Report at target/site/jacoco/index.html
```

### Dependency vulnerability scan
```bash
mvn dependency-check:check
```

### Application starts
```bash
java -jar target/*.jar &
sleep 5
curl -s http://localhost:8080/actuator/health
kill %1
```

---

## Tool Integration

### JUnit 5

Godmode's TDD cycle maps directly to JUnit 5:

```bash
# RED step: run single test class, expect failure
mvn test -Dtest=UserServiceTest -q

# GREEN step: run single test, expect pass
mvn test -Dtest=UserServiceTest -q

# After GREEN: run full suite to catch regressions
mvn test -q

# With Gradle
gradle test --tests "com.example.service.UserServiceTest"
```

**Parameterized tests** — the JVM standard for Godmode TDD:
```java
@ParameterizedTest
@CsvSource({
    "Alice, alice@example.com, true",
    "'', alice@example.com, false",
    "Alice, invalid-email, false",
    "Alice, '', false"
})
void createUser_validation(String name, String email, boolean shouldSucceed) {
    if (shouldSucceed) {
        assertDoesNotThrow(() -> service.create(name, email));
    } else {
        assertThrows(ValidationException.class, () -> service.create(name, email));
    }
}
```

**Kotlin kotest** alternative:
```kotlin
class UserServiceTest : FunSpec({
    val service = UserService(mockRepo)

    test("creates user with valid input") {
        val user = service.create("Alice", "alice@example.com")
        user.name shouldBe "Alice"
    }

    test("rejects empty name") {
        shouldThrow<ValidationException> {
            service.create("", "alice@example.com")
        }
    }
})
```

### Maven / Gradle

Build tool integration for the optimize loop:

```bash
# Maven — measure build time
/usr/bin/time mvn package -DskipTests -q 2>&1 | grep real

# Maven — run with specific profile
mvn test -Pintegration -q

# Gradle — measure build time
/usr/bin/time gradle build -x test --quiet 2>&1 | grep real

# Gradle — dependency insight
gradle dependencies --configuration runtimeClasspath
```

Guard rails configuration:
```yaml
guard_rails:
  - command: mvn test -q
    expect: exit code 0
  - command: mvn checkstyle:check -q
    expect: exit code 0
```

### JMH (Java Microbenchmark Harness)

For the optimize loop, JMH provides reliable microbenchmarks:

```java
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.MICROSECONDS)
@State(Scope.Thread)
public class UserServiceBenchmark {

    private UserService service;

    @Setup
    public void setup() {
        service = new UserService(new InMemoryRepo());
    }

    @Benchmark
    public User createUser() {
        return service.create("Alice", "alice@example.com");
    }
}
```

```bash
# Run as verify command
mvn exec:java -Dexec.mainClass="org.openjdk.jmh.Main" -Dexec.args="UserServiceBenchmark" 2>&1 | grep 'avgt' | awk '{print $5}'
```

---

## Framework Integration

### Spring Boot

```yaml
# .godmode/config.yaml
framework: spring-boot
test_command: mvn test -q
lint_command: mvn checkstyle:check -q
build_command: mvn package -DskipTests -q
verify_command: curl -s -o /dev/null -w '%{time_total}' http://localhost:8080/actuator/health
```

Spring Boot-specific THINK considerations:
- Bean architecture and dependency injection graph
- `@Configuration` class design vs. component scanning
- Profile strategy (`application-dev.yml`, `application-prod.yml`)
- Transaction boundaries and propagation
- Exception handling with `@ControllerAdvice`
- Caching strategy (`@Cacheable`, Redis, Caffeine)

Spring Boot-specific optimize targets:
```bash
# Startup time
java -jar target/*.jar 2>&1 | grep 'Started.*in' | awk '{print $(NF-1)}'

# Actuator metrics endpoint
curl -s http://localhost:8080/actuator/metrics/http.server.requests | jq '.measurements[] | select(.statistic=="TOTAL_TIME") | .value'

# Database query count
# Enable spring.jpa.properties.hibernate.generate_statistics=true
curl -s http://localhost:8080/actuator/metrics/hibernate.query.executions | jq '.measurements[0].value'
```

Spring Boot-specific test patterns:
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureMockMvc
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Test
    void createUser_returnsCreated() throws Exception {
        when(userService.create(any())).thenReturn(new User("Alice"));

        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"name\":\"Alice\",\"email\":\"alice@example.com\"}"))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.name").value("Alice"));
    }
}
```

### Quarkus

```yaml
# .godmode/config.yaml
framework: quarkus
test_command: mvn test -q
build_command: mvn package -DskipTests -Dnative -q  # native image
verify_command: curl -s -o /dev/null -w '%{time_total}' http://localhost:8080/q/health
```

Quarkus-specific considerations:
- Build-time dependency injection (different from Spring runtime DI)
- Native image compilation with GraalVM
- Dev Services for automatic test container provisioning
- RESTEasy Reactive vs. classic RESTEasy
- Startup time is a primary metric (native image targets < 100ms)

### Ktor (Kotlin)

```yaml
# .godmode/config.yaml
framework: ktor
test_command: gradle test --quiet
lint_command: gradle ktlintCheck
build_command: gradle build -x test --quiet
verify_command: curl -s -o /dev/null -w '%{time_total}' http://localhost:8080/health
```

Ktor-specific considerations:
- Plugin (feature) architecture design
- Routing DSL structure
- Kotlin coroutine scope management
- Content negotiation configuration
- Authentication plugin selection (JWT, session, OAuth)

Ktor test pattern:
```kotlin
class UserRoutesTest {
    @Test
    fun `POST users creates user`() = testApplication {
        application {
            configureRouting()
            configureSerialization()
        }

        val response = client.post("/api/users") {
            contentType(ContentType.Application.Json)
            setBody("""{"name":"Alice","email":"alice@example.com"}""")
        }

        assertEquals(HttpStatusCode.Created, response.status)
    }
}
```

---

## Example: Full Workflow for Building a Spring Boot API

### Scenario
Build a REST API for an e-commerce order management system using Spring Boot 3, JPA/Hibernate, PostgreSQL, and Redis caching.

### Step 1: Think (Design)
```
/godmode:think I need an order management API with Spring Boot 3.
Features: create orders, track status transitions (PENDING -> PAID ->
SHIPPED -> DELIVERED), inventory checks, and Redis caching for product
catalog. Use JPA with PostgreSQL.
```

Godmode produces a spec at `docs/specs/order-api.md` containing:
- Record/class definitions: `Order`, `OrderItem`, `OrderStatus` (enum), `CreateOrderRequest`, `OrderResponse`
- Endpoint design: `POST /orders`, `GET /orders/{id}`, `PATCH /orders/{id}/status`, `GET /orders?status=PENDING`
- Architecture: Controller -> Service -> Repository pattern with `@Transactional` boundaries
- Caching strategy: `@Cacheable` on product lookups, `@CacheEvict` on inventory changes
- Error handling: `@ControllerAdvice` with `ProblemDetail` (RFC 7807) responses

### Step 2: Plan (Decompose)
```
/godmode:plan
```

Produces `docs/plans/order-api-plan.md` with tasks:
1. Define JPA entities and enums (`com.example.order.entity`)
2. Create Flyway migration scripts (`src/main/resources/db/migration/`)
3. Implement OrderRepository with Spring Data JPA (`com.example.order.repository`)
4. Implement OrderService with business logic and transactions (`com.example.order.service`)
5. Implement InventoryService with Redis caching (`com.example.inventory.service`)
6. Build OrderController with validation (`com.example.order.controller`)
7. Add global exception handler (`com.example.common.exception`)
8. Integration tests with Testcontainers (`src/test/java/...`)

### Step 3: Build (TDD)
```
/godmode:build
```

Each task follows RED-GREEN-REFACTOR:

**Task 4 — RED:**
```java
// src/test/java/com/example/order/service/OrderServiceTest.java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Mock private OrderRepository orderRepository;
    @Mock private InventoryService inventoryService;
    @InjectMocks private OrderService orderService;

    @Test
    void createOrder_withValidItems_returnsOrder() {
        var request = new CreateOrderRequest(List.of(
            new OrderItemRequest("PROD-1", 2),
            new OrderItemRequest("PROD-2", 1)
        ));
        when(inventoryService.checkAvailability("PROD-1", 2)).thenReturn(true);
        when(inventoryService.checkAvailability("PROD-2", 1)).thenReturn(true);
        when(orderRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        var order = orderService.create(request);

        assertThat(order.getStatus()).isEqualTo(OrderStatus.PENDING);
        assertThat(order.getItems()).hasSize(2);
    }

    @Test
    void createOrder_withInsufficientInventory_throwsException() {
        var request = new CreateOrderRequest(List.of(
            new OrderItemRequest("PROD-1", 100)
        ));
        when(inventoryService.checkAvailability("PROD-1", 100)).thenReturn(false);

        assertThrows(InsufficientInventoryException.class,
            () -> orderService.create(request));
    }
}
```
Commit: `test(red): OrderService — failing creation and inventory validation tests`

**Task 4 — GREEN:**
```java
// src/main/java/com/example/order/service/OrderService.java
@Service
@Transactional
public class OrderService {

    private final OrderRepository orderRepository;
    private final InventoryService inventoryService;

    public OrderService(OrderRepository orderRepository, InventoryService inventoryService) {
        this.orderRepository = orderRepository;
        this.inventoryService = inventoryService;
    }

    public Order create(CreateOrderRequest request) {
        for (var item : request.items()) {
            if (!inventoryService.checkAvailability(item.productId(), item.quantity())) {
                throw new InsufficientInventoryException(item.productId());
            }
        }

        var order = new Order();
        order.setStatus(OrderStatus.PENDING);
        request.items().forEach(item -> order.addItem(item.productId(), item.quantity()));
        return orderRepository.save(order);
    }
}
```
Commit: `feat: OrderService — order creation with inventory validation`

Parallel agents handle tasks 3, 5, and 7 concurrently (no shared dependencies).

### Step 4: Optimize
```
/godmode:optimize --goal "reduce order creation latency" \
  --verify "curl -s -o /dev/null -w '%{time_total}' -X POST http://localhost:8080/api/orders -H 'Content-Type: application/json' -d '{\"items\":[{\"productId\":\"PROD-1\",\"quantity\":1}]}'" \
  --target "< 0.05"
```

Iteration log:
| # | Hypothesis | Change | Baseline | Measured | Verdict |
|---|-----------|--------|----------|----------|---------|
| 1 | N+1 query loading order items | Add `@EntityGraph` on findById | 230ms | 145ms | KEEP |
| 2 | No connection pooling configured | Configure HikariCP pool (min=5, max=20) | 145ms | 88ms | KEEP |
| 3 | Inventory check hits DB each time | Add `@Cacheable` with Redis | 88ms | 52ms | KEEP |
| 4 | JPA auto-flush before query | Set `FlushModeType.COMMIT` | 52ms | 48ms | KEEP |
| 5 | Jackson serialization overhead | Use `@JsonView` to reduce response payload | 48ms | 46ms | REVERT |

Final: 230ms to 48ms (79.1% improvement). Target met.

### Step 5: Secure
```
/godmode:secure
```

Findings:
- HIGH: No authentication on order endpoints — add Spring Security with JWT
- MEDIUM: SQL injection possible via `@Query` with string concatenation — use parameterized queries
- MEDIUM: No rate limiting — add Bucket4j or Spring Cloud Gateway rate limiter
- LOW: Actuator endpoints exposed without authentication — secure with Spring Security

### Step 6: Ship
```
/godmode:ship --pr
```

Pre-flight passes:
```
mvn test -q                       ✓ 38/38 passing
mvn checkstyle:check -q           ✓ 0 violations
mvn package -DskipTests -q        ✓ JAR: 42MB
jacoco coverage                   ✓ 83% (target: 80%)
dependency-check                  ✓ 0 vulnerabilities
startup time                      ✓ 3.2s
```

PR created with full description, optimization log, and security audit summary.

---

## JVM-Specific Tips

### 1. Interfaces and records are your spec
In the THINK phase, define interfaces (contracts) and records/data classes (data shapes) before any implementation. Java records and Kotlin data classes are concise and immutable — ideal for DTOs that appear in specs.

### 2. Use `@ParameterizedTest` for table-driven TDD
JUnit 5's parameterized tests match Godmode's TDD style perfectly. Use `@CsvSource` for simple cases, `@MethodSource` for complex objects. Kotlin kotest has similar data-driven testing built in.

### 3. Testcontainers for integration tests
Always use Testcontainers for database and Redis tests during the BUILD phase. They provide real databases in Docker, eliminating "works on my machine" issues:
```java
@Testcontainers
@SpringBootTest
class OrderRepositoryIntegrationTest {
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16");
}
```

### 4. Track startup time as a metric
JVM startup time directly impacts deployment speed and scaling responsiveness. Use the optimize loop to reduce it:
```
/godmode:optimize --goal "reduce startup time" --verify "java -jar target/*.jar 2>&1 | grep 'Started.*in' | awk '{print \$(NF-1)}'" --target "< 3"
```
Consider Spring Boot lazy initialization, Quarkus, or GraalVM native image for aggressive startup optimization.

### 5. Checkstyle/ktlint as guard rails
Configure Checkstyle (Java) or ktlint (Kotlin) as a guard rail in the optimize loop. Style violations introduced during optimization are caught immediately:
```yaml
guard_rails:
  - command: mvn test -q
    expect: exit code 0
  - command: mvn checkstyle:check -q
    expect: exit code 0
```

### 6. Profile before optimizing
Use async-profiler or VisualVM to identify bottlenecks before starting the optimize loop. This informs better hypotheses. Include profiling data in the THINK phase when working on performance-critical features.

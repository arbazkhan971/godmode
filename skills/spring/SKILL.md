---
name: spring
description: |
  Spring Boot mastery skill. Activates when user needs to build, configure, optimize, or debug Spring Boot applications. Covers auto-configuration, starter selection, Spring Security, Spring Data JPA, Actuator monitoring, Spring Cloud microservices, and testing with MockMvc and TestContainers. Provides opinionated guidance on production-grade Spring patterns. Triggers on: /godmode:spring, "spring boot", "spring security", "spring data", "spring cloud", or when the orchestrator detects Java/Kotlin backend work using Spring.
---

# Spring — Spring Boot Mastery

## When to Activate
- User invokes `/godmode:spring`
- User says "build a Spring Boot app", "configure Spring Security", "set up Spring Data"
- User asks about auto-configuration, starters, actuator, or Spring Cloud
- When `/godmode:plan` identifies Spring Boot implementation tasks
- When `/godmode:scaffold` detects a Spring Boot project
- When working with Java/Kotlin backend services using Spring framework

## Workflow

### Step 1: Project Assessment & Starter Selection
Understand the project requirements and select the right starters:

```
SPRING BOOT ASSESSMENT:
Project: <name and purpose>
Spring Boot version: <latest stable, e.g., 3.3.x>
Language: Java <version> | Kotlin <version>
Build tool: Maven | Gradle (Kotlin DSL preferred)
Architecture: Monolith | Modular monolith | Microservices
Database: PostgreSQL | MySQL | MongoDB | Redis | H2 (dev)
Auth model: JWT | OAuth2 | OIDC | Session-based | API key
Deployment: Docker | Kubernetes | AWS/GCP/Azure | Traditional
```

Select starters based on requirements:

```
STARTER SELECTION:
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Starter                             │  Purpose                         │
├──────────────────────────────────────┼──────────────────────────────────┤
│  spring-boot-starter-web             │  REST API with embedded Tomcat   │
│  spring-boot-starter-webflux         │  Reactive/non-blocking API       │
│  spring-boot-starter-data-jpa        │  JPA + Hibernate ORM             │
│  spring-boot-starter-data-mongodb    │  MongoDB document store          │
│  spring-boot-starter-data-redis      │  Redis caching/sessions          │
│  spring-boot-starter-security        │  Authentication & authorization  │
│  spring-boot-starter-oauth2-resource-server │  JWT/OAuth2 API protection │
│  spring-boot-starter-oauth2-client   │  OAuth2 login flows              │
│  spring-boot-starter-actuator        │  Health, metrics, info endpoints │
│  spring-boot-starter-validation      │  Bean validation (Jakarta)       │
│  spring-boot-starter-cache           │  Caching abstraction             │
│  spring-boot-starter-mail            │  Email sending                   │
│  spring-boot-starter-amqp            │  RabbitMQ messaging              │
│  spring-cloud-starter-netflix-eureka │  Service discovery               │
│  spring-cloud-starter-gateway        │  API Gateway (reactive)          │
│  spring-cloud-starter-openfeign      │  Declarative HTTP clients        │
│  spring-cloud-starter-circuitbreaker │  Resilience4j circuit breakers   │
│  spring-cloud-starter-config         │  Centralized configuration       │
└──────────────────────────────────────┴──────────────────────────────────┘

SELECTED: <list of starters with justification>
```

Rules:
- Always use the Spring Boot BOM for version management — never pin individual Spring dependency versions
- Prefer `spring-boot-starter-webflux` only when the entire stack is reactive (R2DBC, reactive MongoDB)
- Never mix blocking and non-blocking in the same service without clear boundaries
- Use Kotlin DSL for Gradle builds — it provides type safety and IDE support

### Step 2: Auto-Configuration & Property Management
Configure the application properly:

```yaml
# application.yml — Production-grade configuration
spring:
  application:
    name: ${SERVICE_NAME:my-service}
  profiles:
    active: ${SPRING_PROFILES_ACTIVE:local}

  # Database
  datasource:
    url: jdbc:postgresql://${DB_HOST:localhost}:${DB_PORT:5432}/${DB_NAME:mydb}
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
    hikari:
      maximum-pool-size: ${DB_POOL_SIZE:10}
      minimum-idle: ${DB_POOL_MIN:5}
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000

  # JPA
  jpa:
    open-in-view: false          # CRITICAL: always disable OSIV
    hibernate:
      ddl-auto: validate         # Never auto-create in prod
    properties:
      hibernate:
        format_sql: true
        generate_statistics: false
        jdbc:
          batch_size: 25
        order_inserts: true
        order_updates: true

  # Jackson
  jackson:
    default-property-inclusion: non_null
    serialization:
      write-dates-as-timestamps: false
    deserialization:
      fail-on-unknown-properties: false

# Server
server:
  port: ${SERVER_PORT:8080}
  shutdown: graceful
  tomcat:
    connection-timeout: 5s
    keep-alive-timeout: 15s
    threads:
      max: 200
      min-spare: 10

# Actuator
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: when_authorized
      probes:
        enabled: true
  metrics:
    tags:
      application: ${spring.application.name}

# Logging
logging:
  level:
    root: INFO
    com.example: DEBUG
    org.springframework.security: INFO
    org.hibernate.SQL: DEBUG
    org.hibernate.type.descriptor.sql.BasicBinder: TRACE
  pattern:
    console: "%d{ISO8601} [%thread] %-5level %logger{36} - %msg%n"
```

```
AUTO-CONFIGURATION AUDIT:
┌──────────────────────────────────────┬──────────┬──────────────────────┐
│  Setting                             │  Status  │  Notes               │
├──────────────────────────────────────┼──────────┼──────────────────────┤
│  open-in-view: false                 │  SET     │  Prevents lazy-load  │
│  ddl-auto: validate                  │  SET     │  Flyway/Liquibase    │
│  graceful shutdown                   │  SET     │  Drain connections   │
│  connection pool tuned               │  SET     │  HikariCP defaults   │
│  actuator endpoints restricted       │  SET     │  Only health/metrics │
│  health probes enabled               │  SET     │  K8s liveness/ready  │
│  external config via env vars        │  SET     │  12-factor app       │
│  OSIV disabled                       │  SET     │  No lazy surprises   │
└──────────────────────────────────────┴──────────┴──────────────────────┘
```

Rules:
- ALWAYS set `spring.jpa.open-in-view: false` — Open Session In View is an anti-pattern that hides N+1 queries
- ALWAYS use `ddl-auto: validate` in production — use Flyway or Liquibase for schema migrations
- ALWAYS configure graceful shutdown for zero-downtime deployments
- ALWAYS externalize configuration via environment variables for 12-factor compliance
- Use profile-specific config files: `application-local.yml`, `application-prod.yml`

### Step 3: Spring Security Configuration
Design and implement security:

```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
            .csrf(csrf -> csrf.disable())  // Disable for stateless API
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/actuator/health/**").permitAll()
                .requestMatchers("/api/v1/auth/**").permitAll()
                .requestMatchers("/api/v1/admin/**").hasRole("ADMIN")
                .requestMatchers("/api/v1/**").authenticated()
                .anyRequest().denyAll()
            )
            .oauth2ResourceServer(oauth2 ->
                oauth2.jwt(jwt -> jwt.jwtAuthenticationConverter(jwtConverter())))
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint(customAuthEntryPoint())
                .accessDeniedHandler(customAccessDeniedHandler()))
            .build();
    }

    @Bean
    public JwtDecoder jwtDecoder() {
        return JwtDecoders.fromIssuerLocation(issuerUri);
    }
}
```

```
SECURITY CONFIGURATION:
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Layer                               │  Configuration                   │
├──────────────────────────────────────┼──────────────────────────────────┤
│  Authentication                      │  JWT / OAuth2 / Basic / Form     │
│  Authorization                       │  URL-based + Method-level        │
│  CSRF                                │  Disabled (stateless API)        │
│  CORS                                │  Configured per environment      │
│  Session                             │  STATELESS for APIs              │
│  Password encoding                   │  BCrypt (strength 12)            │
│  Rate limiting                       │  Bucket4j or Spring Cloud Gateway│
│  Security headers                    │  X-Frame, X-Content-Type, HSTS  │
│  Audit logging                       │  Spring Security events          │
└──────────────────────────────────────┴──────────────────────────────────┘
```

Rules:
- NEVER use the deprecated `WebSecurityConfigurerAdapter` — use component-based `SecurityFilterChain` beans
- ALWAYS use the new lambda DSL (`.csrf(csrf -> ...)`) not the chained builder
- ALWAYS deny by default (`.anyRequest().denyAll()`) and explicitly permit
- Use `@EnableMethodSecurity` instead of the deprecated `@EnableGlobalMethodSecurity`
- Store secrets in Vault or environment variables, never in property files

### Step 4: Spring Data JPA & Repository Patterns
Design the data layer:

```java
// Entity design
@Entity
@Table(name = "orders", indexes = {
    @Index(name = "idx_orders_customer", columnList = "customer_id"),
    @Index(name = "idx_orders_status", columnList = "status")
})
public class Order extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)  // ALWAYS lazy by default
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OrderItem> items = new ArrayList<>();

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private OrderStatus status;

    @Version
    private Long version;  // Optimistic locking
}

// Repository with custom queries
public interface OrderRepository extends JpaRepository<Order, UUID> {

    // Derived query
    List<Order> findByCustomerIdAndStatus(UUID customerId, OrderStatus status);

    // JPQL with fetch join to avoid N+1
    @Query("SELECT o FROM Order o JOIN FETCH o.items WHERE o.id = :id")
    Optional<Order> findByIdWithItems(@Param("id") UUID id);

    // Native query for complex reporting
    @Query(value = "SELECT DATE(created_at) as date, COUNT(*) as count " +
           "FROM orders WHERE created_at >= :since GROUP BY DATE(created_at)",
           nativeQuery = true)
    List<OrderDailyCount> getDailyOrderCounts(@Param("since") LocalDate since);

    // Specification-based dynamic queries
    Page<Order> findAll(Specification<Order> spec, Pageable pageable);

    // Projection for lightweight reads
    @Query("SELECT o.id as id, o.status as status, o.createdAt as createdAt " +
           "FROM Order o WHERE o.customer.id = :customerId")
    List<OrderSummary> findSummariesByCustomerId(@Param("customerId") UUID customerId);

    // Bulk update (bypasses entity lifecycle — use with caution)
    @Modifying
    @Query("UPDATE Order o SET o.status = :status WHERE o.id IN :ids")
    int bulkUpdateStatus(@Param("ids") List<UUID> ids, @Param("status") OrderStatus status);
}
```

```
DATA LAYER PATTERNS:
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Pattern                             │  Usage                           │
├──────────────────────────────────────┼──────────────────────────────────┤
│  Derived queries                     │  Simple lookups by fields        │
│  JPQL with JOIN FETCH                │  Avoid N+1 on associations       │
│  Native queries                      │  Complex reporting/analytics     │
│  Specifications                      │  Dynamic filtering (search APIs) │
│  Projections/DTOs                    │  Lightweight reads, API responses│
│  @Modifying bulk updates             │  Mass status changes             │
│  @Version optimistic locking         │  Concurrent modification safety  │
│  BaseEntity (audit fields)           │  created_at, updated_at, version │
│  Flyway/Liquibase migrations         │  Schema version control          │
│  QueryDSL (optional)                 │  Type-safe dynamic queries       │
└──────────────────────────────────────┴──────────────────────────────────┘
```

Rules:
- ALWAYS use `FetchType.LAZY` for `@ManyToOne` and `@OneToMany` — eager fetching causes performance disasters
- ALWAYS use `JOIN FETCH` in queries when you need associated data — never rely on lazy loading in the view
- ALWAYS add `@Version` for optimistic locking on mutable entities
- Use projections (interfaces or DTOs) for read-only endpoints — never expose full entities to the API
- Use Flyway for schema migrations — never `ddl-auto: create` or `update` in production
- Add database indexes for every foreign key and every field used in WHERE/ORDER BY clauses

### Step 5: Actuator & Production Monitoring
Configure observability:

```
ACTUATOR CONFIGURATION:
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Endpoint                            │  Purpose                         │
├──────────────────────────────────────┼──────────────────────────────────┤
│  /actuator/health                    │  Liveness probe (K8s)            │
│  /actuator/health/readiness          │  Readiness probe (K8s)           │
│  /actuator/health/liveness           │  Liveness probe (K8s)            │
│  /actuator/info                      │  Build info, git commit          │
│  /actuator/metrics                   │  Micrometer metrics              │
│  /actuator/prometheus                │  Prometheus scrape endpoint      │
│  /actuator/loggers                   │  Runtime log level changes       │
│  /actuator/env                       │  DISABLED in prod                │
│  /actuator/beans                     │  DISABLED in prod                │
│  /actuator/heapdump                  │  DISABLED in prod                │
└──────────────────────────────────────┴──────────────────────────────────┘

CUSTOM HEALTH INDICATORS:
- DatabaseHealthIndicator: Connection pool status, query latency
- ExternalServiceHealthIndicator: Downstream API availability
- DiskSpaceHealthIndicator: Disk usage thresholds
- CustomBusinessHealthIndicator: Business-specific health (e.g., queue depth)

CUSTOM METRICS (Micrometer):
- http_server_requests (auto): Request count, duration, status
- db_query_duration: Database query timing
- business_orders_created: Business event counters
- cache_hit_ratio: Cache effectiveness
- external_api_call_duration: Downstream API latency
```

```java
// Custom health indicator
@Component
public class PaymentGatewayHealthIndicator implements HealthIndicator {

    @Override
    public Health health() {
        try {
            boolean reachable = paymentClient.ping();
            if (reachable) {
                return Health.up()
                    .withDetail("gateway", "reachable")
                    .withDetail("latency_ms", latency)
                    .build();
            }
            return Health.down()
                .withDetail("gateway", "unreachable")
                .build();
        } catch (Exception e) {
            return Health.down(e).build();
        }
    }
}

// Custom business metrics
@Component
public class OrderMetrics {

    private final Counter ordersCreated;
    private final Timer orderProcessingTime;

    public OrderMetrics(MeterRegistry registry) {
        this.ordersCreated = Counter.builder("business.orders.created")
            .description("Total orders created")
            .tag("service", "order-service")
            .register(registry);
        this.orderProcessingTime = Timer.builder("business.orders.processing_time")
            .description("Order processing duration")
            .register(registry);
    }
}
```

### Step 6: Spring Cloud Microservices
Design microservice architecture when needed:

```
MICROSERVICES ARCHITECTURE:
┌─────────────────────────────────────────────────────────────────┐
│                        API Gateway                               │
│                  (Spring Cloud Gateway)                           │
│  - Route matching, load balancing, rate limiting                 │
│  - JWT validation at edge, circuit breaker                       │
└──────────────────┬──────────────────────────────────┬────────────┘
                   │                                  │
         ┌─────────▼─────────┐              ┌────────▼──────────┐
         │  Service A         │              │  Service B         │
         │  (Spring Boot)     │◄────────────►│  (Spring Boot)     │
         │  - REST/gRPC       │   OpenFeign  │  - REST/gRPC       │
         │  - Own database    │   or gRPC    │  - Own database    │
         └─────────┬─────────┘              └────────┬──────────┘
                   │                                  │
         ┌─────────▼─────────┐              ┌────────▼──────────┐
         │  PostgreSQL A      │              │  PostgreSQL B      │
         └───────────────────┘              └───────────────────┘

CROSS-CUTTING CONCERNS:
├── Config Server (Spring Cloud Config) — Centralized configuration
├── Service Discovery (Eureka / Consul / K8s DNS) — Service registry
├── Circuit Breaker (Resilience4j) — Fault tolerance
├── Distributed Tracing (Micrometer Tracing + Zipkin/Jaeger) — Request tracing
├── API Gateway (Spring Cloud Gateway) — Edge routing
├── Event Bus (Kafka / RabbitMQ) — Async communication
└── Secrets (Vault / K8s Secrets) — Secret management
```

```
RESILIENCE PATTERNS:
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Pattern                             │  Implementation                  │
├──────────────────────────────────────┼──────────────────────────────────┤
│  Circuit Breaker                     │  Resilience4j @CircuitBreaker    │
│  Retry                               │  Resilience4j @Retry             │
│  Rate Limiter                        │  Resilience4j @RateLimiter       │
│  Bulkhead                            │  Resilience4j @Bulkhead          │
│  Time Limiter                        │  Resilience4j @TimeLimiter       │
│  Fallback                            │  Method-level fallback handlers  │
│  Saga                                │  Orchestration or choreography   │
│  Outbox                              │  Transactional outbox pattern    │
└──────────────────────────────────────┴──────────────────────────────────┘
```

### Step 7: Testing Strategy
Test at every layer:

```java
// Unit test — Service layer with Mockito
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Mock private OrderRepository orderRepository;
    @Mock private PaymentClient paymentClient;
    @InjectMocks private OrderService orderService;

    @Test
    void createOrder_withValidInput_returnsCreatedOrder() {
        // Given
        var request = new CreateOrderRequest(customerId, items);
        when(orderRepository.save(any())).thenReturn(expectedOrder);

        // When
        var result = orderService.createOrder(request);

        // Then
        assertThat(result.status()).isEqualTo(OrderStatus.CREATED);
        verify(orderRepository).save(any());
    }
}

// Integration test — MockMvc for controller layer
@WebMvcTest(OrderController.class)
class OrderControllerTest {

    @Autowired private MockMvc mockMvc;
    @MockitoBean private OrderService orderService;

    @Test
    void getOrder_returnsOrder() throws Exception {
        when(orderService.findById(orderId)).thenReturn(Optional.of(order));

        mockMvc.perform(get("/api/v1/orders/{id}", orderId)
                .with(jwt().authorities(new SimpleGrantedAuthority("ROLE_USER"))))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.id").value(orderId.toString()))
            .andExpect(jsonPath("$.status").value("CREATED"));
    }

    @Test
    void getOrder_notFound_returns404() throws Exception {
        when(orderService.findById(any())).thenReturn(Optional.empty());

        mockMvc.perform(get("/api/v1/orders/{id}", UUID.randomUUID())
                .with(jwt()))
            .andExpect(status().isNotFound());
    }
}

// Full integration test — TestContainers
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
class OrderIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16-alpine");

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Autowired private TestRestTemplate restTemplate;

    @Test
    void fullOrderLifecycle() {
        // Create order
        var response = restTemplate.postForEntity("/api/v1/orders", request, OrderResponse.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);

        // Verify persistence
        var fetched = restTemplate.getForEntity("/api/v1/orders/{id}",
            OrderResponse.class, response.getBody().id());
        assertThat(fetched.getBody().status()).isEqualTo("CREATED");
    }
}
```

```
TESTING STRATEGY:
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Layer                               │  Approach                        │
├──────────────────────────────────────┼──────────────────────────────────┤
│  Unit (service logic)                │  JUnit 5 + Mockito              │
│  Controller (HTTP layer)             │  @WebMvcTest + MockMvc           │
│  Repository (data layer)             │  @DataJpaTest + H2/TestContainers│
│  Integration (full stack)            │  @SpringBootTest + TestContainers│
│  Security (auth/authz)              │  SecurityMockMvcConfigurers       │
│  Contract (API consumers)            │  Spring Cloud Contract           │
│  Architecture (structure)            │  ArchUnit                        │
└──────────────────────────────────────┴──────────────────────────────────┘

TEST SLICES:
- @WebMvcTest — Controller only, no full context
- @DataJpaTest — Repository only, embedded DB
- @JsonTest — JSON serialization/deserialization
- @RestClientTest — RestTemplate/WebClient testing
- @SpringBootTest — Full application context
```

Rules:
- ALWAYS use test slices (`@WebMvcTest`, `@DataJpaTest`) over `@SpringBootTest` when possible — faster feedback
- Use TestContainers for integration tests — never test against H2 and deploy to PostgreSQL
- Use `@MockitoBean` (Spring Boot 3.4+) instead of `@MockBean` for cleaner mock injection
- Test security rules with MockMvc `SecurityMockMvcRequestPostProcessors`
- Use ArchUnit to enforce architecture rules (e.g., no controller -> repository direct access)

### Step 8: Validation & Delivery
Verify the Spring Boot application:

```
SPRING BOOT VALIDATION:
┌──────────────────────────────────────┬──────────┬──────────────────────┐
│  Check                               │  Status  │  Notes               │
├──────────────────────────────────────┼──────────┼──────────────────────┤
│  OSIV disabled                       │  PASS    │  open-in-view: false │
│  ddl-auto: validate                  │  PASS    │  Flyway manages DDL  │
│  Graceful shutdown configured        │  PASS    │  Drains connections  │
│  Connection pool tuned               │  PASS    │  HikariCP configured │
│  Security deny-by-default            │  PASS    │  .anyRequest().deny()│
│  Lazy fetch on all associations      │  PASS    │  No eager loading    │
│  N+1 queries eliminated              │  PASS    │  JOIN FETCH used     │
│  Actuator endpoints restricted       │  PASS    │  Prod-safe endpoints │
│  Health probes for K8s               │  PASS    │  Liveness + readiness│
│  Config externalized (env vars)      │  PASS    │  12-factor compliant │
│  Tests pass with TestContainers      │  PASS    │  Real DB in tests    │
│  No deprecated API usage             │  PASS    │  Spring Boot 3.x API │
│  Flyway migrations present           │  PASS    │  Version-controlled  │
│  Error handling centralized          │  PASS    │  @ControllerAdvice   │
│  DTO/projection for API responses    │  PASS    │  No entity exposure  │
└──────────────────────────────────────┴──────────┴──────────────────────┘

VERDICT: <PASS | NEEDS REVISION>
```

```
SPRING BOOT DELIVERY:

Artifacts:
- Application: <service-name> Spring Boot <version>
- Starters: <list of selected starters>
- Endpoints: <N> REST endpoints across <M> resources
- Tests: <N> unit + <M> integration tests passing
- Migrations: <N> Flyway migration scripts
- Validation: <PASS | NEEDS REVISION>

Next steps:
-> /godmode:test — Add more test coverage
-> /godmode:secure — Security hardening audit
-> /godmode:deploy — Deploy to production
-> /godmode:observe — Set up monitoring and alerting
-> /godmode:loadtest — Performance testing
```

Commit: `"spring: <service> — <N> endpoints, Spring Boot <version>, <starters>"`

## Key Behaviors

1. **Convention over configuration.** Spring Boot auto-configures sensibly. Override only what you need, and document WHY you override.
2. **Disable OSIV from day one.** Open Session In View hides N+1 queries behind lazy loading magic. Disable it and use JOIN FETCH explicitly.
3. **Test slices over full context.** `@WebMvcTest` loads only the web layer. `@DataJpaTest` loads only the data layer. Full `@SpringBootTest` is for integration tests only.
4. **TestContainers over H2.** If production runs PostgreSQL, tests must run PostgreSQL. H2 compatibility mode is a lie.
5. **Security is not optional.** Every endpoint is denied by default. Authentication and authorization are configured before the first API endpoint is written.
6. **Profile-driven configuration.** Local, dev, staging, and production environments get separate profiles. Secrets come from environment variables or Vault.
7. **Actuator for production.** Health probes for Kubernetes, Prometheus metrics for monitoring, and structured logging for observability are configured before shipping.

## Example Usage

### Building a Spring Boot REST API
```
User: /godmode:spring Build an order management service

Spring: Assessing requirements...

SPRING BOOT ASSESSMENT:
Project: Order Management Service
Spring Boot: 3.3.x
Language: Java 21
Build: Gradle (Kotlin DSL)
Architecture: Modular monolith
Database: PostgreSQL 16

STARTER SELECTION:
- spring-boot-starter-web (REST API)
- spring-boot-starter-data-jpa (PostgreSQL via Hibernate)
- spring-boot-starter-security (JWT auth)
- spring-boot-starter-actuator (health + metrics)
- spring-boot-starter-validation (input validation)

Configuring application.yml...
Setting up SecurityFilterChain...
Creating entity/repository/service/controller layers...
Adding Flyway migrations...
Writing tests (MockMvc + TestContainers)...

All 15 checks PASS.
```

### Configuring Spring Security
```
User: /godmode:spring Set up OAuth2 resource server with JWT

Spring: Configuring JWT-based security...

Security chain: JWT validation at /api/** endpoints
Public endpoints: /actuator/health, /api/v1/auth/login
Role mapping: JWT claims -> Spring authorities
CORS: Configured for frontend origin
Tests: MockMvc with jwt() post-processor
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full Spring Boot setup workflow |
| `--starter <name>` | Add specific starter and configure it |
| `--security jwt` | Configure JWT-based security |
| `--security oauth2` | Configure OAuth2 login |
| `--data jpa` | Set up Spring Data JPA with best practices |
| `--data mongodb` | Set up Spring Data MongoDB |
| `--cloud` | Add Spring Cloud microservices patterns |
| `--actuator` | Configure Actuator for production |
| `--test` | Generate test suite (MockMvc + TestContainers) |
| `--migrate` | Set up Flyway migrations |
| `--audit` | Audit existing Spring Boot app for anti-patterns |
| `--upgrade <version>` | Upgrade Spring Boot version with migration guide |

## HARD RULES

1. **ALWAYS set `spring.jpa.open-in-view: false`.** OSIV is enabled by default and silently causes N+1 queries. Disable it in every project, no exceptions.
2. **ALWAYS use `ddl-auto: validate` in production.** Use Flyway or Liquibase for schema migrations. Never `create`, `update`, or `create-drop` in production.
3. **ALWAYS use constructor injection.** Never `@Autowired` on fields. Constructor injection makes dependencies explicit and testing straightforward.
4. **NEVER return JPA entities from controllers.** Use DTOs or projections. Entities carry persistence state that must not leak to the API layer.
5. **NEVER use `WebSecurityConfigurerAdapter`.** It is removed in Spring Security 6. Use `SecurityFilterChain` beans with lambda DSL.
6. **ALWAYS use `FetchType.LAZY`** for `@ManyToOne` and `@OneToMany` associations. Use `JOIN FETCH` in queries when associated data is needed.
7. **ALWAYS test against the production database type.** Use TestContainers, not H2 compatibility mode.
8. **NEVER expose actuator endpoints (`/env`, `/heapdump`, `/beans`)** in production without authentication. Restrict to `health`, `info`, `metrics`, `prometheus`.

## Auto-Detection

On activation, detect the Spring Boot project context:

```bash
# Detect Spring Boot version and starters
cat pom.xml build.gradle build.gradle.kts 2>/dev/null | grep -E "spring-boot|springBoot"

# Detect language (Java vs Kotlin)
find src/ -name "*.kt" -o -name "*.java" 2>/dev/null | head -5

# Detect existing configuration
ls src/main/resources/application*.yml src/main/resources/application*.properties 2>/dev/null

# Detect security configuration
grep -rl "SecurityFilterChain\|WebSecurityConfigurerAdapter\|EnableWebSecurity" src/ 2>/dev/null

# Detect test framework
grep -rl "TestContainers\|@SpringBootTest\|@WebMvcTest\|@DataJpaTest" src/ 2>/dev/null | head -5

# Detect migration tool
ls src/main/resources/db/migration/* src/main/resources/db/changelog/* 2>/dev/null
```

## Output Format

End every Spring skill invocation with this summary block:

```
SPRING RESULT:
Action: <scaffold | entity | controller | service | repository | optimize | test | audit | upgrade>
Files created/modified: <N>
Entities created/modified: <N>
Controllers created/modified: <N>
Migrations created: <N>
Tests passing: <yes | no | skipped>
Build status: <passing | failing | not-checked>
Issues fixed: <N>
Notes: <one-line summary>
```

## TSV Logging

Append one TSV row to `.godmode/spring.tsv` after each invocation:

```
timestamp	project	action	files_count	entities_count	controllers_count	migrations_count	tests_status	build_status	notes
```

Field definitions:
- `timestamp`: ISO-8601 UTC
- `project`: directory name from `basename $(pwd)`
- `action`: scaffold | entity | controller | service | repository | optimize | test | audit | upgrade
- `files_count`: number of files created or modified
- `entities_count`: number of JPA entities created or modified
- `controllers_count`: number of controllers created or modified
- `migrations_count`: number of Flyway/Liquibase migrations created
- `tests_status`: passing | failing | skipped | none
- `build_status`: passing | failing | not-checked
- `notes`: free-text, max 120 chars, no tabs

If `.godmode/` does not exist, create it and add `.godmode/` to `.gitignore` if not already present.

## Success Criteria

Every Spring skill invocation must pass ALL of these checks before reporting success:

1. `./mvnw verify` or `./gradlew build` passes with zero errors
2. Tests pass (`./mvnw test` or `./gradlew test`)
3. OSIV is disabled (`spring.jpa.open-in-view: false`)
4. No `ddl-auto: update` or `ddl-auto: create` in production profiles
5. All beans use constructor injection (no `@Autowired` on fields)
6. No JPA entities returned from controllers (use DTOs or projections)
7. Centralized exception handling via `@ControllerAdvice`
8. No deprecated `WebSecurityConfigurerAdapter` (use `SecurityFilterChain`)
9. Actuator endpoints are secured (no public `/actuator/env` or `/actuator/heapdump`)
10. Tests use TestContainers for database tests (not H2 with PostgreSQL target)

If any check fails, fix it before reporting success. If a fix is not possible, document the reason in the Notes field.

## Error Recovery

When errors occur, follow these remediation steps:

```
IF build fails (mvnw/gradlew):
  1. Read the full error output — fix compilation errors first
  2. Check dependency version conflicts (mvn dependency:tree)
  3. Verify Java version matches pom.xml/build.gradle requirement
  4. Check for missing @ComponentScan or @EntityScan configurations

IF tests fail:
  1. Verify TestContainers is running (Docker must be available)
  2. Check @SpringBootTest vs @WebMvcTest vs @DataJpaTest scope
  3. Verify @MockBean and @SpyBean are correctly applied
  4. Check that test properties override production config

IF JPA/Hibernate errors:
  1. LazyInitializationException → use @EntityGraph or JOIN FETCH, never OSIV
  2. N+1 queries → add @BatchSize or use JOIN FETCH in repository queries
  3. OptimisticLockException → implement retry logic with @Retryable
  4. Schema mismatch → verify Flyway/Liquibase migrations are up to date

IF Spring Security errors:
  1. 403 Forbidden → check SecurityFilterChain rules and method security
  2. CORS errors → configure CorsConfigurationSource bean
  3. CSRF issues → verify token handling for SPA frontends
  4. Authentication loop → check filter order and entry point configuration

IF dependency injection errors:
  1. NoSuchBeanDefinitionException → verify @Component/@Service annotation and package scanning
  2. Circular dependency → restructure with @Lazy or extract shared logic
  3. Multiple bean candidates → use @Primary or @Qualifier
```

## Anti-Patterns

- **Do NOT leave OSIV enabled.** `spring.jpa.open-in-view: true` is the default and it is wrong. It silently loads data in the view layer, hiding N+1 queries.
- **Do NOT use `ddl-auto: update` in production.** Hibernate DDL generation is for prototyping. Use Flyway or Liquibase.
- **Do NOT use `@Autowired` on fields.** Use constructor injection. It makes dependencies explicit and testing straightforward.
- **Do NOT return JPA entities from controllers.** Use DTOs or projections. Entities carry persistence state that should never leak to the API.
- **Do NOT catch exceptions in every controller.** Use `@ControllerAdvice` with `@ExceptionHandler` for centralized error handling.
- **Do NOT use `WebSecurityConfigurerAdapter`.** It is removed in Spring Security 6. Use `SecurityFilterChain` beans.
- **Do NOT test against H2 when deploying to PostgreSQL.** Use TestContainers for database-specific behavior.
- **Do NOT ignore Actuator security.** Exposed `/actuator/env` or `/actuator/heapdump` in production leaks secrets and memory.


## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Replace `Agent("task")` → run the task inline in the current conversation
- Replace `EnterWorktree` → use `git stash` + work in current directory
- Replace `TodoWrite` → track progress with numbered comments in chat
- All Spring Boot conventions, patterns, and quality checks still apply identically

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
| Starter | Purpose |
|--|--|
| spring-boot-starter-web | REST API with embedded Tomcat |
| spring-boot-starter-webflux | Reactive/non-blocking API |
| spring-boot-starter-data-jpa | JPA + Hibernate ORM |
| spring-boot-starter-data-mongodb | MongoDB document store |
| spring-boot-starter-data-redis | Redis caching/sessions |
| spring-boot-starter-security | Authentication & authorization |
| spring-boot-starter-oauth2-resource-server | JWT/OAuth2 API protection |
| spring-boot-starter-oauth2-client | OAuth2 login flows |
| spring-boot-starter-actuator | Health, metrics, info endpoints |
| spring-boot-starter-validation | Bean validation (Jakarta) |
| spring-boot-starter-cache | Caching abstraction |
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
```
```
AUTO-CONFIGURATION AUDIT:
| Setting | Status | Notes |
|--|--|--|
| open-in-view: false | SET | Prevents lazy-load |
| ddl-auto: validate | SET | Flyway/Liquibase |
| graceful shutdown | SET | Drain connections |
| connection pool tuned | SET | HikariCP defaults |
| actuator endpoints restricted | SET | Only health/metrics |
| health probes enabled | SET | K8s liveness/ready |
| external config via env vars | SET | 12-factor app |
| OSIV disabled | SET | No lazy surprises |
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
```
```
SECURITY CONFIGURATION:
| Layer | Configuration |
|--|--|
| Authentication | JWT / OAuth2 / Basic / Form |
| Authorization | URL-based + Method-level |
| CSRF | Disabled (stateless API) |
| CORS | Configured per environment |
| Session | STATELESS for APIs |
| Password encoding | BCrypt (strength 12) |
| Rate limiting | Bucket4j or Spring Cloud Gateway |
| Security headers | X-Frame, X-Content-Type, HSTS |
| Audit logging | Spring Security events |
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
```
```
DATA LAYER PATTERNS:
| Pattern | Usage |
|--|--|
| Derived queries | Simple lookups by fields |
| JPQL with JOIN FETCH | Avoid N+1 on associations |
| Native queries | Complex reporting/analytics |
| Specifications | Dynamic filtering (search APIs) |
| Projections/DTOs | Lightweight reads, API responses |
| @Modifying bulk updates | Mass status changes |
| @Version optimistic locking | Concurrent modification safety |
| BaseEntity (audit fields) | created_at, updated_at, version |
| Flyway/Liquibase migrations | Schema version control |
| QueryDSL (optional) | Type-safe dynamic queries |
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
| Endpoint | Purpose |
|--|--|
| /actuator/health | Liveness probe (K8s) |
| /actuator/health/readiness | Readiness probe (K8s) |
| /actuator/health/liveness | Liveness probe (K8s) |
| /actuator/info | Build info, git commit |
| /actuator/metrics | Micrometer metrics |
| /actuator/prometheus | Prometheus scrape endpoint |
| /actuator/loggers | Runtime log level changes |
| /actuator/env | DISABLED in prod |
| /actuator/beans | DISABLED in prod |
| /actuator/heapdump | DISABLED in prod |
```
### Step 6: Spring Cloud Microservices
Design microservice architecture when needed:

```
API Gateway (Spring Cloud Gateway) → Service A + Service B (each with own DB)
Communication: OpenFeign or gRPC. Circuit breaker: Resilience4j.
```
### Step 7: Testing Strategy
Test at every layer:

```
TESTING STRATEGY:
| Layer | Approach |
|--|--|
| Unit (service logic) | JUnit 5 + Mockito |
| Controller (HTTP layer) | @WebMvcTest + MockMvc |
| Repository (data layer) | @DataJpaTest + H2/TestContainers |
| Integration (full stack) | @SpringBootTest + TestContainers |
| Security (auth/authz) | SecurityMockMvcConfigurers |
| Contract (API consumers) | Spring Cloud Contract |
| Architecture (structure) | ArchUnit |

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
| Check | Status | Notes |
|--|--|--|
| OSIV disabled | PASS | open-in-view: false |
| ddl-auto: validate | PASS | Flyway manages DDL |
| Graceful shutdown configured | PASS | Drains connections |
| Connection pool tuned | PASS | HikariCP configured |
| Security deny-by-default | PASS | .anyRequest().deny() |
| Lazy fetch on all associations | PASS | No eager loading |
| N+1 queries eliminated | PASS | JOIN FETCH used |
| Actuator endpoints restricted | PASS | Prod-safe endpoints |
| Health probes for K8s | PASS | Liveness + readiness |
| Config externalized (env vars) | PASS | 12-factor compliant |
| Tests pass with TestContainers | PASS | Real DB in tests |
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
8. **Never ask to continue. Loop autonomously until all validation checks pass or budget exhausted.**

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full Spring Boot setup workflow |
| `--starter <name>` | Add specific starter and configure it |
| `--security jwt` | Configure JWT-based security |

## HARD RULES

1. **ALWAYS set `spring.jpa.open-in-view: false`.** OSIV is enabled by default and silently causes N+1 queries. Disable it in every project, no exceptions.
2. **ALWAYS use `ddl-auto: validate` in production.** Use Flyway or Liquibase for schema migrations. Never `create`, `update`, or `create-drop` in production.
3. **ALWAYS use constructor injection.** Never `@Autowired` on fields. Constructor injection makes dependencies explicit and testing straightforward.
4. **NEVER return JPA entities from controllers.** Use DTOs or projections. Entities carry persistence state that must not leak to the API layer.
5. **NEVER use `WebSecurityConfigurerAdapter`.** It is removed in Spring Security 6. Use `SecurityFilterChain` beans with lambda DSL.
6. **ALWAYS use `FetchType.LAZY`** for `@ManyToOne` and `@OneToMany` associations. Use `JOIN FETCH` in queries when associated data is needed.
7. **ALWAYS test against the production database type.** Use TestContainers, not H2 compatibility mode.
8. **NEVER expose actuator endpoints (`/env`, `/heapdump`, `/beans`)** in production without authentication. Restrict to `health`, `info`, `metrics`, `prometheus`.

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

- **Build fails**: Read error output, check dependency conflicts (`mvn dependency:tree`), verify Java version, check `@ComponentScan`/`@EntityScan`.
- **Tests fail**: Verify Docker running (TestContainers), check test slice scope, verify `@MockBean` applied correctly.
- **JPA errors**: `LazyInitializationException` → use `@EntityGraph` or JOIN FETCH. N+1 → add `@BatchSize` or JOIN FETCH.
## Keep/Discard Discipline
```
After EACH Spring Boot configuration or code change:
  1. MEASURE: Run `./gradlew build` (or `./mvnw verify`). Check test results.
  2. COMPARE: Do all tests pass? Does the application start without errors?
  3. DECIDE:
     - KEEP if: build passes AND tests pass AND no deprecated API warnings introduced
     - DISCARD if: build fails OR tests fail OR N+1 queries detected in logs
  4. COMMIT kept changes. Revert discarded changes before the next modification.

Never keep a change that enables OSIV or introduces field injection.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All 15 validation checks pass (OSIV disabled, ddl-auto:validate, etc.)
  - Build and tests pass (`./gradlew build` or `./mvnw verify` green)
  - Actuator endpoints are secured for production
  - User explicitly requests stop

DO NOT STOP because:
  - Test coverage is below target (log it, address separately)
  - One non-critical deprecation warning remains (document it)
```

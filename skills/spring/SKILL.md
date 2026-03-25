---
name: spring
description: >
  Spring Boot mastery. Auto-configuration, security,
  Data JPA, Actuator, testing with TestContainers.
---

# Spring -- Spring Boot Mastery

## Activate When
- `/godmode:spring`, "spring boot", "spring security"
- "spring data", "spring cloud", "actuator"
- Java/Kotlin backend work using Spring framework

## Workflow

### Step 1: Project Assessment
```
Spring Boot version: <3.3.x>
Language: Java <version> | Kotlin <version>
Build tool: Maven | Gradle (Kotlin DSL preferred)
Architecture: Monolith | Modular | Microservices
Database: PostgreSQL | MySQL | MongoDB | Redis
Auth: JWT | OAuth2 | OIDC | Session | API key
```

Starter selection based on requirements:
```
spring-boot-starter-web        REST API + Tomcat
spring-boot-starter-data-jpa   JPA + Hibernate
spring-boot-starter-security   Auth & authorization
spring-boot-starter-actuator   Health + metrics
spring-boot-starter-validation Bean validation
spring-boot-starter-cache      Caching abstraction
```
```bash
# Verify Spring Boot version
./gradlew dependencyInsight --dependency spring-boot
# Or Maven
./mvnw dependency:tree | grep spring-boot
```

### Step 2: Auto-Configuration
```yaml
spring:
  jpa:
    open-in-view: false        # ALWAYS disable OSIV
    hibernate.ddl-auto: validate # Flyway manages DDL
  lifecycle:
    timeout-per-shutdown-phase: 30s # graceful shutdown
```
```
IF open-in-view is true: disable immediately
  (hides N+1 queries behind lazy loading)
IF ddl-auto is create/update: switch to validate
  (Flyway/Liquibase for migrations)
WHEN deploying to K8s: enable graceful shutdown
  AND configure liveness/readiness probes
```

### Step 3: Spring Security
```
SecurityFilterChain with lambda DSL:
  .csrf(csrf -> csrf.disable())  # stateless API
  .cors(withDefaults())
  .sessionManagement(STATELESS)
  .authorizeHttpRequests(auth -> auth
    .requestMatchers("/api/public/**").permitAll()
    .anyRequest().denyAll())  # deny by default
```
Rules:
- NEVER use deprecated WebSecurityConfigurerAdapter
- ALWAYS deny by default, explicitly permit
- BCrypt strength 12 for passwords
- Use @EnableMethodSecurity (not Global)

### Step 4: Spring Data JPA
```
DATA LAYER PATTERNS:
  Derived queries: simple lookups by fields
  JPQL JOIN FETCH: avoid N+1 on associations
  Specifications: dynamic filtering (search)
  Projections/DTOs: lightweight reads
  @Version: optimistic locking
  Flyway: schema version control
```
```bash
# Generate Flyway migration
flyway -url=jdbc:postgresql://localhost/mydb migrate

# Verify no N+1 queries in logs
grep "select.*from" app.log | sort | uniq -c | sort -rn
```
Rules:
- ALWAYS use FetchType.LAZY for associations
- ALWAYS use JOIN FETCH when you need related data
- ALWAYS add @Version for mutable entities
- Use DTOs for API responses, never full entities
- Index every FK and every WHERE/ORDER BY field

### Step 5: Actuator & Monitoring
```
ENDPOINTS:
  /actuator/health         Liveness probe
  /actuator/health/ready   Readiness probe
  /actuator/prometheus     Metrics scrape
  /actuator/loggers        Runtime log levels
  /actuator/env            DISABLED in prod
  /actuator/heapdump       DISABLED in prod

IF deploying to K8s: configure probes
  livenessProbe: /actuator/health/liveness
  readinessProbe: /actuator/health/readiness
  initialDelaySeconds: 30, periodSeconds: 10
```

### Step 6: Testing
```
TESTING STRATEGY:
  Unit (service):     JUnit 5 + Mockito
  Controller (HTTP):  @WebMvcTest + MockMvc
  Repository (data):  @DataJpaTest + TestContainers
  Integration (full): @SpringBootTest + TestContainers
  Security:           SecurityMockMvcConfigurers
  Architecture:       ArchUnit
```
```bash
# Run tests with TestContainers
./gradlew test
# Or Maven
./mvnw test
```
Rules:
- ALWAYS use test slices over @SpringBootTest
- Use TestContainers, never H2 compatibility mode
- Use @MockitoBean (3.4+) not @MockBean

### Step 7: Validation
```
| Check                        | Required |
|------------------------------|----------|
| OSIV disabled                | YES      |
| ddl-auto: validate           | YES      |
| Constructor injection only   | YES      |
| No entities from controllers | YES      |
| Actuator restricted in prod  | YES      |
| TestContainers for DB tests  | YES      |
| Graceful shutdown configured | YES      |
```

## Key Behaviors
1. **Convention over configuration.** Override only
   what you need, document WHY.
2. **Disable OSIV day one.** Use JOIN FETCH.
3. **Test slices over full context.**
4. **TestContainers over H2.** Match prod DB.
5. **Security deny-by-default.**
6. **Never ask to continue. Loop autonomously.**

## HARD RULES
1. ALWAYS set spring.jpa.open-in-view: false.
2. ALWAYS use ddl-auto: validate in production.
3. ALWAYS use constructor injection, never @Autowired.
4. NEVER return JPA entities from controllers.
5. NEVER use WebSecurityConfigurerAdapter.
6. ALWAYS use FetchType.LAZY + JOIN FETCH.
7. ALWAYS test against production DB type.
8. NEVER expose /actuator/env or /heapdump in prod.

## TSV Logging
Log to `.godmode/spring.tsv`:
`timestamp\taction\tentities\tcontrollers\tmigrations\ttests_status`

## Quality Targets
- Target: <3s application startup time
- Target: <200ms p95 endpoint response time
- Target: >80% test coverage on service layer
- Max heap usage: <512MB for standard microservice

## Output Format
```
SPRING: {action}. Files: {N}. Entities: {N}.
Tests: {status}. Build: {status}. Issues: {N}.
```

## Keep/Discard Discipline
```
KEEP if: build passes AND tests pass
  AND no deprecated API warnings introduced
DISCARD if: build fails OR tests fail
  OR N+1 queries detected in logs
```

## Stop Conditions
```
STOP when:
  - All validation checks pass
  - Build and tests green
  - Actuator secured for production
  - User requests stop
```

# /godmode:spring

Build, configure, and optimize Spring Boot applications. Covers auto-configuration, starter selection, Spring Security, Spring Data JPA, Actuator monitoring, Spring Cloud microservices, and testing with MockMvc and TestContainers.

## Usage

```
/godmode:spring                            # Full Spring Boot setup workflow
/godmode:spring --starter web              # Add and configure a specific starter
/godmode:spring --security jwt             # Configure JWT-based security
/godmode:spring --security oauth2          # Configure OAuth2 login
/godmode:spring --data jpa                 # Set up Spring Data JPA best practices
/godmode:spring --data mongodb             # Set up Spring Data MongoDB
/godmode:spring --cloud                    # Add Spring Cloud microservices patterns
/godmode:spring --actuator                 # Configure Actuator for production
/godmode:spring --test                     # Generate MockMvc + TestContainers tests
/godmode:spring --migrate                  # Set up Flyway migrations
/godmode:spring --audit                    # Audit existing app for anti-patterns
/godmode:spring --upgrade 3.3              # Upgrade Spring Boot version
```

## What It Does

1. Assesses project requirements and selects appropriate Spring Boot starters
2. Configures application properties with production-grade defaults (OSIV disabled, graceful shutdown, connection pool tuning)
3. Sets up Spring Security with deny-by-default, JWT/OAuth2, and method-level security
4. Configures Spring Data JPA with lazy fetching, JOIN FETCH patterns, and Flyway migrations
5. Enables Actuator with health probes, Prometheus metrics, and custom health indicators
6. Designs Spring Cloud microservices architecture when needed (Gateway, Eureka, Resilience4j)
7. Generates comprehensive test suite (unit with Mockito, MockMvc for controllers, TestContainers for integration)
8. Validates against 15 production-readiness checks

## Output
- Configured Spring Boot application with selected starters
- Spring Security filter chain with JWT/OAuth2
- Entity/repository/service/controller layers with best practices
- Flyway migration scripts
- Test suite (MockMvc + TestContainers)
- Validation report with PASS/NEEDS REVISION verdict
- Commit: `"spring: <service> — <N> endpoints, Spring Boot <version>, <starters>"`

## Next Step
After Spring Boot setup: `/godmode:test` for more coverage, `/godmode:secure` for security audit, or `/godmode:deploy` for production deployment.

## Examples

```
/godmode:spring Build an order management service
/godmode:spring --security jwt Set up OAuth2 resource server
/godmode:spring --data jpa Configure JPA with PostgreSQL
/godmode:spring --cloud Set up microservices with Spring Cloud
/godmode:spring --audit Check our Spring Boot app for issues
/godmode:spring --upgrade 3.3 Migrate from Spring Boot 3.1 to 3.3
```

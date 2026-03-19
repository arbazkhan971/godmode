# /godmode:docker

Docker mastery skill for creating, optimizing, and securing containerized applications. Covers Dockerfile best practices (multi-stage builds, layer caching), Docker Compose for local development, image size optimization, security scanning (Trivy, Snyk), networking, volumes, and BuildKit features.

## Usage

```
/godmode:docker                           # Full Docker assessment and optimization
/godmode:docker --init                    # Create Dockerfile and Compose from scratch
/godmode:docker --optimize                # Optimize existing Docker configuration
/godmode:docker --compose                 # Docker Compose setup for local development
/godmode:docker --security                # Security scan and hardening
/godmode:docker --scan                    # Run vulnerability scan (Trivy/Snyk)
/godmode:docker --slim                    # Aggressive image size reduction
/godmode:docker --buildkit                # Enable and configure BuildKit features
/godmode:docker --multi-platform          # Set up multi-architecture builds
/godmode:docker --ci                      # Generate CI/CD Docker build pipeline
/godmode:docker --audit                   # Audit existing Docker setup for issues
```

## What It Does

1. Assesses project context (language, framework, current Docker state)
2. Creates or optimizes Dockerfile with multi-stage builds and layer caching
3. Sets up Docker Compose for local development with health checks
4. Optimizes image size (base image selection, .dockerignore, layer reduction)
5. Runs security scanning and applies hardening (non-root user, capability dropping)
6. Configures Docker networking and volume management
7. Enables BuildKit features (cache mounts, secret mounts, multi-platform)
8. Produces a Docker configuration report with metrics

## Output
- Dockerfile (multi-stage, production-grade)
- docker-compose.yml (local development)
- .dockerignore (comprehensive exclusions)
- Security scan results
- Configuration commit: `"build(docker): Dockerfile — multi-stage <language> with <base image>"`

## Next Step
After Docker setup: `/godmode:k8s` for Kubernetes deployment, or `/godmode:deploy` to ship.

## Examples

```
/godmode:docker                           # Full Docker assessment
/godmode:docker --init                    # Containerize a new project
/godmode:docker --optimize                # Shrink image from 2.3GB to 120MB
/godmode:docker --security                # Scan and harden existing setup
/godmode:docker --compose                 # Set up local dev with Postgres + Redis
```

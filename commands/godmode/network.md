# /godmode:network

Configure, troubleshoot, and secure networking infrastructure. Covers DNS, SSL/TLS certificates, CDN configuration, load balancers, VPC design, and network security with defense-in-depth.

## Usage

```
/godmode:network                        # Full network audit and topology report
/godmode:network --dns                  # DNS configuration and troubleshooting
/godmode:network --ssl                  # SSL/TLS certificate management
/godmode:network --cdn                  # CDN configuration and optimization
/godmode:network --lb                   # Load balancer setup and health checks
/godmode:network --vpc                  # VPC and network architecture design
/godmode:network --security             # Firewall rules and security group audit
/godmode:network --troubleshoot         # Diagnose networking issues (502s, timeouts)
/godmode:network --domain api.myapp.com # Target a specific domain
/godmode:network --provider cloudflare  # Use specific provider
```

## What It Does

1. Discovers current networking topology (DNS, SSL, CDN, LB, VPC)
2. Validates DNS records and propagation across resolvers
3. Manages SSL/TLS certificates (Let's Encrypt, cert-manager, auto-renewal)
4. Configures CDN caching (CloudFront, Cloudflare, Fastly) with cache strategy
5. Sets up load balancers (ALB, NLB, Nginx, HAProxy) with health checks
6. Designs VPC architecture (public/private/isolated subnets, security groups)
7. Audits network security (firewall rules, NACLs, WAF, defense-in-depth)
8. Troubleshoots common issues (502s, DNS resolution, certificate expiry)

## Output
- Network topology report
- DNS record configuration files
- SSL/TLS certificate status and renewal schedule
- CDN configuration with cache strategy
- Load balancer configuration files
- VPC architecture diagram and security group definitions
- Commit: `"network: <description> — <components configured>"`

## Next Step
After network setup: `/godmode:secure` to audit network security posture, or `/godmode:deploy` to deploy with the new infrastructure.

## Examples

```
/godmode:network --ssl --domain api.myapp.com  # Set up HTTPS for API
/godmode:network --troubleshoot                 # Investigate 502 errors
/godmode:network --vpc --provider aws           # Design AWS VPC
/godmode:network --cdn --domain myapp.com       # Configure CDN caching
```

---
name: network
description: |
  Network and DNS skill. Activates when user needs to configure, troubleshoot, or secure networking infrastructure. Covers DNS configuration and troubleshooting, SSL/TLS certificate management (Let's Encrypt, cert-manager), CDN configuration (CloudFront, Cloudflare, Fastly), load balancer setup (ALB, NLB, HAProxy, Nginx), and network security (firewall rules, VPC design, security groups). Triggers on: /godmode:network, "configure DNS", "set up SSL", "CDN setup", "load balancer", "firewall rules", "VPC design", or when networking issues block deployment.
---

# Network — Network & DNS

## When to Activate
- User invokes `/godmode:network`
- User says "configure DNS", "set up SSL certificate", "CDN setup"
- User says "load balancer configuration", "firewall rules", "VPC design"
- User says "fix DNS resolution", "certificate expired", "502 bad gateway"
- Application needs HTTPS, custom domain, or CDN
- Deployment requires VPC, security groups, or network policies
- Performance issues traced to networking or DNS

## Workflow

### Step 1: Network Discovery
Identify current networking topology and requirements:

```
NETWORK INVENTORY:
┌──────────────────────────────────────────────────────────┐
│  Component           │ Provider     │ Status              │
│  ─────────────────────────────────────────────────────── │
│  DNS                 │ <provider>   │ <configured/missing>│
│  SSL/TLS             │ <issuer>     │ <valid/expired/none>│
│  CDN                 │ <provider>   │ <active/none>       │
│  Load Balancer       │ <type>       │ <healthy/degraded>  │
│  VPC/Network         │ <provider>   │ <configured/none>   │
│  Firewall/SGs        │ <type>       │ <N rules>           │
│  WAF                 │ <provider>   │ <active/none>       │
├──────────────────────────────────────────────────────────┤
│  Domains: <list of domains>                               │
│  Certificates: <N valid, M expiring, P expired>           │
│  Endpoints: <N public, M internal>                        │
└──────────────────────────────────────────────────────────┘
```

```bash
# DNS discovery
dig +short <domain> A
dig +short <domain> CNAME
dig +short <domain> MX
dig +short <domain> TXT
nslookup <domain>
# ... (condensed)
```

If no networking is configured: "No networking infrastructure detected. Shall I design a network architecture (VPC + DNS + SSL + LB) or address a specific component?"

### Step 2: DNS Configuration and Troubleshooting
Set up and validate DNS records:

#### DNS Record Design
```
DNS RECORD PLAN:
┌──────────────────────────────────────────────────────────┐
│  Record    │ Type   │ Value              │ TTL   │ Proxy │
│  ─────────────────────────────────────────────────────── │
│  @          │ A      │ <LB IP>            │ 300   │ Yes   │
│  www        │ CNAME  │ @                  │ 300   │ Yes   │
│  api        │ A      │ <API LB IP>        │ 60    │ Yes   │
│  staging    │ CNAME  │ <staging LB>       │ 300   │ No    │
│  mail       │ MX     │ <mail server>      │ 3600  │ N/A   │
│  @          │ TXT    │ v=spf1 ...         │ 3600  │ N/A   │
│  _dmarc     │ TXT    │ v=DMARC1; ...      │ 3600  │ N/A   │
│  <selector> │ TXT    │ v=DKIM1; ...       │ 3600  │ N/A   │
└──────────────────────────────────────────────────────────┘
```

#### DNS Troubleshooting Checklist
```
DNS TROUBLESHOOTING:
┌──────────────────────────────────────────────────────────┐
│  Symptom                      │ Check                     │
│  ─────────────────────────────────────────────────────── │
│  Domain not resolving          │ NS records pointing to    │
│                                │ correct nameservers?      │
│  SERVFAIL                      │ DNSSEC validation?        │
│                                │ Zone file syntax errors?  │
│  Wrong IP returned             │ A/AAAA records correct?   │
│                                │ CDN proxy interfering?    │
│  Slow resolution               │ TTL too low? NS latency?  │
│  Email not delivered           │ MX, SPF, DKIM, DMARC?    │
│  Subdomain not working         │ CNAME vs A record?        │
│                                │ Wildcard record present?  │
│  Propagation delay             │ TTL of old record?        │
│                                │ Check multiple resolvers  │
└──────────────────────────────────────────────────────────┘
```

```bash
# Check propagation across resolvers
dig @8.8.8.8 <domain> A +short       # Google DNS
dig @1.1.1.1 <domain> A +short       # Cloudflare DNS
dig @208.67.222.222 <domain> A +short # OpenDNS

# DNSSEC validation
# ... (condensed)
```

### Step 3: SSL/TLS Certificate Management
Configure and manage certificates:

#### Let's Encrypt with Certbot
```bash
# Obtain certificate
sudo certbot certonly --webroot -w /var/www/html -d <domain> -d www.<domain>

# Obtain wildcard certificate (DNS challenge required)
sudo certbot certonly --dns-<provider> -d <domain> -d *.<domain>

# ... (condensed)
```

#### Kubernetes cert-manager
```yaml
# ClusterIssuer for Let's Encrypt
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
# ... (condensed)
```

#### Certificate Monitoring
```
CERTIFICATE STATUS:
┌──────────────────────────────────────────────────────────┐
│  Domain           │ Issuer       │ Expires    │ Status    │
│  ─────────────────────────────────────────────────────── │
│  example.com      │ Let's Encrypt│ 2026-06-15 │ VALID     │
│  *.example.com    │ Let's Encrypt│ 2026-06-15 │ VALID     │
│  api.example.com  │ Let's Encrypt│ 2026-04-01 │ RENEWING  │
│  old.example.com  │ DigiCert     │ 2026-03-20 │ EXPIRING  │
├──────────────────────────────────────────────────────────┤
│  Auto-renewal: ENABLED                                    │
│  Next renewal check: <date>                               │
│  Alert threshold: 14 days before expiry                   │
└──────────────────────────────────────────────────────────┘

TLS CONFIGURATION:
  Min version: TLS 1.2
  Cipher suites: ECDHE-RSA-AES256-GCM-SHA384, ECDHE-RSA-AES128-GCM-SHA256
  HSTS: Enabled (max-age=31536000; includeSubDomains; preload)
  OCSP Stapling: Enabled
  Certificate Transparency: Required
```

### Step 4: CDN Configuration
Set up and optimize content delivery:

#### CloudFront Configuration
```
CLOUDFRONT DISTRIBUTION:
┌──────────────────────────────────────────────────────────┐
│  Distribution ID: <id>                                    │
│  Domain: <d123.cloudfront.net>                            │
│  Aliases: <domain>, www.<domain>                          │
│  Origin: <ALB DNS or S3 bucket>                           │
├──────────────────────────────────────────────────────────┤
│  Cache Behaviors:                                         │
│  Path Pattern    │ Origin    │ TTL      │ Compress │ CORS │
│  ─────────────────────────────────────────────────────── │
│  /api/*          │ ALB       │ 0 (none) │ Yes      │ Yes  │
│  /static/*       │ S3        │ 86400    │ Yes      │ No   │
│  /images/*       │ S3        │ 604800   │ Yes      │ No   │
│  Default (*)     │ ALB       │ 0        │ Yes      │ Yes  │
├──────────────────────────────────────────────────────────┤
```

#### Cloudflare Configuration
```
CLOUDFLARE ZONE:
┌──────────────────────────────────────────────────────────┐
│  Zone: <domain>                                           │
│  Plan: <Free | Pro | Business | Enterprise>               │
│  SSL Mode: Full (Strict)                                  │
│  Min TLS: 1.2                                             │
├──────────────────────────────────────────────────────────┤
│  Performance:                                             │
│  Cache Level: Standard                                    │
│  Browser Cache TTL: Respect Existing Headers              │
│  Always Online: Enabled                                   │
│  Brotli: Enabled                                          │
│  Early Hints: Enabled                                     │
│  Rocket Loader: Disabled (conflicts with SPA frameworks)  │
├──────────────────────────────────────────────────────────┤
```

#### CDN Cache Optimization
```
CACHE STRATEGY:
┌──────────────────────────────────────────────────────────┐
│  Asset Type     │ Cache-Control Header          │ CDN TTL │
│  ─────────────────────────────────────────────────────── │
│  HTML pages     │ no-cache, must-revalidate     │ 0       │
│  JS/CSS (hashed)│ public, max-age=31536000,     │ 1 year  │
│                 │ immutable                     │         │
│  Images         │ public, max-age=604800        │ 7 days  │
│  Fonts          │ public, max-age=31536000      │ 1 year  │
│  API responses  │ private, no-store             │ 0       │
│  Public API     │ public, max-age=60, s-maxage= │ 5 min   │
│                 │ 300, stale-while-revalidate=60│         │
└──────────────────────────────────────────────────────────┘

Cache Invalidation:
  Strategy: Deploy-time purge of changed paths
  Purge method: API call to CDN provider
  Fallback: Versioned filenames (app.[hash].js) for static assets
  Warning: Never rely on TTL expiration for urgent updates
```

### Step 5: Load Balancer Setup
Configure and optimize load balancing:

#### AWS ALB Configuration
```
APPLICATION LOAD BALANCER:
┌──────────────────────────────────────────────────────────┐
│  Name: <service-name>-alb                                 │
│  Scheme: internet-facing | internal                       │
│  VPC: <vpc-id>                                            │
│  Subnets: <public subnets across 2+ AZs>                 │
├──────────────────────────────────────────────────────────┤
│  Listeners:                                               │
│  Port 80  -> Redirect to 443 (301)                        │
│  Port 443 -> Forward to target group (TLS termination)    │
├──────────────────────────────────────────────────────────┤
│  Target Groups:                                           │
│  Name              │ Port │ Health Check  │ Targets       │
│  ─────────────────────────────────────────────────────── │
│  api-targets       │ 3000 │ /healthz (5s) │ 3 instances   │
```

#### Nginx Load Balancer
```nginx
upstream api_backend {
    least_conn;                          # Least connections algorithm
    keepalive 32;                        # Connection pooling

    server 10.0.1.10:3000 weight=5;     # Primary
    server 10.0.1.11:3000 weight=5;     # Primary
    server 10.0.1.12:3000 weight=3;     # Secondary
    server 10.0.1.13:3000 backup;       # Failover only
}

server {
    listen 443 ssl http2;
    server_name api.example.com;

    # TLS configuration
```

#### HAProxy Configuration
```
HAProxy CONFIGURATION:
┌──────────────────────────────────────────────────────────┐
│  Frontend: http-in (port 80 -> redirect 443)              │
│  Frontend: https-in (port 443, SSL termination)           │
│  Backend: api-servers (3 servers, leastconn)              │
│  Backend: web-servers (2 servers, roundrobin)             │
├──────────────────────────────────────────────────────────┤
│  Health Checks:                                           │
│  Interval: 5s  │  Rise: 2  │  Fall: 3  │  Timeout: 2s   │
│  Method: HTTP GET /healthz  │  Expected: 200              │
├──────────────────────────────────────────────────────────┤
│  Connection Limits:                                       │
│  Max connections per server: 1000                         │
│  Queue timeout: 5s                                        │
│  Connection timeout: 5s                                   │
```

### Step 6: Network Security
Design VPC, security groups, and firewall rules:

#### VPC Architecture
```
VPC DESIGN:
┌──────────────────────────────────────────────────────────────┐
│  VPC: 10.0.0.0/16                                             │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  PUBLIC SUBNETS (internet-facing)                        │ │
│  │  10.0.1.0/24 (AZ-a)  │  10.0.2.0/24 (AZ-b)            │ │
│  │  ALB, NAT Gateway     │  ALB, NAT Gateway               │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  PRIVATE SUBNETS (application tier)                      │ │
│  │  10.0.10.0/24 (AZ-a) │  10.0.11.0/24 (AZ-b)           │ │
│  │  ECS/EKS tasks        │  ECS/EKS tasks                  │ │
│  └─────────────────────────────────────────────────────────┘ │
```

#### Security Groups
```
SECURITY GROUP DESIGN:
┌──────────────────────────────────────────────────────────┐
│  SG: alb-sg                                               │
│  Inbound:  443 from 0.0.0.0/0 (HTTPS)                    │
│            80 from 0.0.0.0/0 (HTTP -> redirect)           │
│  Outbound: All to app-sg                                  │
├──────────────────────────────────────────────────────────┤
│  SG: app-sg                                               │
│  Inbound:  <app-port> from alb-sg only                    │
│  Outbound: 5432 to db-sg (PostgreSQL)                     │
│            6379 to cache-sg (Redis)                        │
│            443 to 0.0.0.0/0 (external APIs via NAT)       │
├──────────────────────────────────────────────────────────┤
│  SG: db-sg                                                │
│  Inbound:  5432 from app-sg only                          │
```

#### Network ACLs and Firewall
```
NETWORK SECURITY RULES:
┌──────────────────────────────────────────────────────────┐
│  Layer         │ Tool                │ Purpose             │
│  ─────────────────────────────────────────────────────── │
│  Edge          │ CloudFront/CF WAF   │ DDoS, bot protect   │
│  DNS           │ Route53/CF          │ DNS filtering       │
│  Perimeter     │ NACL                │ Subnet-level deny   │
│  Instance      │ Security Groups     │ Port-level allow    │
│  Application   │ Nginx/HAProxy       │ Rate limiting       │
│  Container     │ NetworkPolicy (K8s) │ Pod-to-pod rules    │
│  Application   │ App middleware      │ Auth, CORS, CSP     │
└──────────────────────────────────────────────────────────┘

Defense in Depth Checklist:
  [x] WAF rules block SQL injection, XSS, known bad bots
```

### Step 7: Commit and Report
```
1. Save network configuration files in appropriate locations:
   - DNS records: `infra/dns/` or provider-specific config
   - SSL/TLS: `infra/certs/` or cert-manager manifests in `k8s/`
   - CDN: `infra/cdn/` or Terraform modules
   - Load balancer: `infra/lb/` or Nginx/HAProxy config
   - VPC/Security: `infra/network/` or Terraform modules
2. Commit: "network: <description> — <components configured>"
3. If troubleshooting: "network: fix <issue> — <root cause and resolution>"
4. If new setup: "network: <domain> — DNS + SSL + CDN + LB configured"
```

## Key Behaviors

1. **HTTPS everywhere.** No exceptions. Every public endpoint must use TLS 1.2+ with valid certificates. HTTP exists only to redirect to HTTPS.
2. **DNS TTL strategy.** Long TTLs (3600s+) for stable records. Short TTLs (60-300s) for records that may change during deployments. Lower TTL before migration, raise after.
3. **Certificate auto-renewal is mandatory.** Manual certificate management leads to outages. Use Let's Encrypt with certbot or cert-manager for automatic renewal.
4. **CDN caches must be invalidatable.** Use content hashing for static assets. Never cache API responses at the CDN unless explicitly designed for it.
5. **Load balancers need health checks.** Without health checks, the LB sends traffic to dead backends. Configure check interval, thresholds, and timeout.
6. **Security groups are allowlists.** Default deny. Explicitly allow only the traffic each tier needs. Never use 0.0.0.0/0 for anything except the ALB inbound.
7. **VPC design uses three tiers.** Public (LB), private (app), isolated (data). Data tier has no internet access. All tiers span multiple availability zones.
8. **Log everything.** VPC Flow Logs, ALB access logs, WAF logs. You cannot investigate what you did not record.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full network audit and topology report |
| `--dns` | DNS configuration and troubleshooting only |
| `--ssl` | SSL/TLS certificate management only |

## Iterative Network Setup Protocol

```
WHEN configuring a complete networking stack (DNS + SSL + CDN + LB + VPC):

components = ["vpc_design", "security_groups", "load_balancer", "ssl_certs", "cdn", "dns"]
current_component = 0
total_components = len(components)
configured = []
validation_failures = []

WHILE current_component < total_components:
  component = components[current_component]

  1. ASSESS current state of {component}
  2. DESIGN configuration based on requirements
  3. APPLY configuration
  4. VALIDATE:
```

## HARD RULES

```
1. EVERY public endpoint MUST use TLS 1.2+ with valid certificates.
   HTTP exists only to redirect to HTTPS. No exceptions.

2. NEVER expose database ports to the internet.
   Databases belong in isolated subnets with no public IP.

3. NEVER use 0.0.0.0/0 in security group inbound rules
   except for ALB on ports 80 and 443.

4. Certificate auto-renewal MUST be configured. Manual certificate
   management leads to outages. Use Let's Encrypt + certbot or cert-manager.

5. Load balancers MUST have health checks configured.
   Without health checks, traffic goes to dead backends.

```

## Output Format
Print on completion: `Network: {resource_count} resources configured. TLS: {tls_status}. DNS: {domain_count} domains. LB: {lb_type}. CDN: {cdn_status}. Security groups: {sg_count}. Verdict: {verdict}.`

## TSV Logging
Log every network configuration step to `.godmode/network-results.tsv`:
```
iteration	task	resource_type	count	security_issues	tls_status	status
1	vpc	vpc/subnets	6	0	n/a	created
2	security	security_groups	8	0	n/a	hardened
3	load_balancer	alb	2	0	tls_1.3	configured
4	cdn	cloudfront	1	0	tls_1.3	configured
5	dns	route53	4	0	n/a	configured
```
Columns: iteration, task, resource_type, count, security_issues, tls_status, status(created/hardened/configured/failed).

## Success Criteria
- VPC with public/private subnet separation across at least 2 AZs.
- Security groups follow least-privilege (no 0.0.0.0/0 except ALB 80/443).
- TLS 1.2+ enforced on all endpoints (TLS 1.3 preferred).
- HSTS enabled with preload on all production domains.
- DNS configured with appropriate TTLs (60s minimum for dynamic records).
- Load balancer health checks configured for all target groups.
- CDN configured with appropriate cache policies (immutable for hashed assets).
- VPC Flow Logs enabled on all production VPCs.
- No database ports exposed to the internet.

## Error Recovery
- **TLS certificate expires**: Set up automated certificate renewal (Let's Encrypt / ACM). Configure certificate expiry alerts at 30, 14, and 7 days before expiry. If already expired, issue a new certificate immediately.
- **DNS propagation delays**: Check TTL values. Flush local DNS cache. Verify the change was applied at the authoritative nameserver. Wait for the old TTL to expire before testing.
- **Load balancer returns 502/503**: Check target group health. Verify security groups allow traffic from ALB to targets. Check that the application is listening on the correct port. Verify the health check path returns 200.
- **CDN serves stale content**: Invalidate the CDN cache for affected paths. Check cache-control headers on the origin. Verify the CDN is configured to respect origin cache headers.
- **Security group blocks legitimate traffic**: Check inbound rules for the affected port. Verify the source CIDR or security group reference is correct. Use VPC Flow Logs to identify dropped packets.
- **VPC peering or transit gateway connectivity fails**: Verify route tables in both VPCs include routes to the peer. Check security groups allow traffic from the peer CIDR. Verify DNS resolution works across the peering connection.

## Keep/Discard Discipline
```
After EACH network configuration change:
  1. MEASURE: Validate the component (dig for DNS, openssl for TLS, curl for LB, traceroute for routing).
  2. COMPARE: Is the networking state better than before? (TLS valid, DNS resolving, LB healthy)
  3. DECIDE:
     - KEEP if: validation passes AND connectivity confirmed AND no security regressions
     - DISCARD if: validation fails OR connectivity broken OR new security issue introduced
  4. COMMIT kept changes. Revert discarded changes before configuring the next component.

Never proceed to the next networking component if the current one is broken — components depend on each other.
```

## Stuck Recovery
```
IF >3 consecutive iterations fail to correctly configure a network component:
  1. Check DNS propagation: use multiple resolvers (8.8.8.8, 1.1.1.1, authoritative NS) to rule out caching.
  2. Check certificate chain: `openssl s_client -showcerts` to verify the full chain is served.
  3. Simplify: test connectivity at each layer independently (DNS, then TLS, then LB, then app).
  4. If still stuck → log stop_reason=stuck, document the failing component with diagnostic output.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All networking components configured and validated (VPC, SG, LB, SSL, CDN, DNS)
  - End-to-end test passes: curl -sI https://{domain} returns 200 with valid cert and HSTS header
  - User explicitly requests stop
  - A component requires provider-level support (e.g., domain transfer pending)

DO NOT STOP just because:
  - CDN is not yet configured (LB + SSL is functional without CDN)
  - WAF rules are not yet tuned (basic networking must work first)
```

## Simplicity Criterion
```
PREFER the simpler networking approach:
  - ACM/Let's Encrypt auto-renewing certs before manual certificate management
  - ALB before NLB (unless you need TCP/UDP or extreme performance)
  - Cloudflare DNS before self-managed DNS (for most teams)
  - Security group references (sg-xxx) before CIDR blocks (more maintainable)
  - Two-AZ deployment before three-AZ (unless compliance or SLA requires three)
  - Fewer security group rules with broader service groups before many narrow rules
```


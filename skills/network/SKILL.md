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
| Component | Provider | Status |
|--|--|--|
| DNS | <provider> | <configured/missing> |
| SSL/TLS | <issuer> | <valid/expired/none> |
| CDN | <provider> | <active/none> |
| Load Balancer | <type> | <healthy/degraded> |
| VPC/Network | <provider> | <configured/none> |
| Firewall/SGs | <type> | <N rules> |
| WAF | <provider> | <active/none> |
  Domains: <list of domains>
  Certificates: <N valid, M expiring, P expired>
  ...
```
```bash
# DNS discovery
dig +short <domain> A
dig +short <domain> CNAME
dig +short <domain> MX
dig +short <domain> TXT
nslookup <domain>
```
If no networking is configured: "No networking infrastructure detected. Shall I design a network architecture (VPC + DNS + SSL + LB) or address a specific component?"

### Step 2: DNS Configuration and Troubleshooting
Set up and validate DNS records:

#### DNS Record Design
```
DNS RECORD PLAN:
| Record | Type | Value | TTL | Proxy |
|--|--|--|--|--|
| @ | A | <LB IP> | 300 | Yes |
| www | CNAME | @ | 300 | Yes |
| api | A | <API LB IP> | 60 | Yes |
| staging | CNAME | <staging LB> | 300 | No |
| mail | MX | <mail server> | 3600 | N/A |
| @ | TXT | v=spf1 ... | 3600 | N/A |
| _dmarc | TXT | v=DMARC1; ... | 3600 | N/A |
| <selector> | TXT | v=DKIM1; ... | 3600 | N/A |
```

#### DNS Troubleshooting Checklist
```
DNS TROUBLESHOOTING:
| Symptom | Check |
|--|--|
| Domain not resolving | NS records pointing to |
|  | correct nameservers? |
| SERVFAIL | DNSSEC validation? |
|  | Zone file syntax errors? |
| Wrong IP returned | A/AAAA records correct? |
|  | CDN proxy interfering? |
| Slow resolution | TTL too low? NS latency? |
| Email not delivered | MX, SPF, DKIM, DMARC? |
| Subdomain not working | CNAME vs A record? |
  ...
```

```bash
# Check propagation across resolvers
dig @8.8.8.8 <domain> A +short       # Google DNS
dig @1.1.1.1 <domain> A +short       # Cloudflare DNS
dig @208.67.222.222 <domain> A +short # OpenDNS

# DNSSEC validation
```
### Step 3: SSL/TLS Certificate Management
Configure and manage certificates:

#### Let's Encrypt with Certbot
```bash
# Obtain certificate
sudo certbot certonly --webroot -w /var/www/html -d <domain> -d www.<domain>

# Obtain wildcard certificate (DNS challenge required)
sudo certbot certonly --dns-<provider> -d <domain> -d *.<domain>

```

#### Kubernetes cert-manager
```yaml
# ClusterIssuer for Let's Encrypt
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
```

#### Certificate Monitoring
```
CERTIFICATE STATUS:
| Domain | Issuer | Expires | Status |
|--|--|--|--|
  Auto-renewal: ENABLED. Alert threshold: 14 days before expiry.
  TLS: min 1.2, prefer 1.3. HSTS enabled with preload.
```

### Step 4: CDN Configuration
Set up and optimize content delivery:

#### CloudFront Configuration
```
CLOUDFRONT DISTRIBUTION:
  Distribution ID: <id>
  Domain: <d123.cloudfront.net>
  Aliases: <domain>, www.<domain>
  Origin: <ALB DNS or S3 bucket>
  Cache Behaviors:
| Path Pattern | Origin | TTL | Compress | CORS |
|--|--|--|--|--|
| /api/* | ALB | 0 (none) | Yes | Yes |
| /static/* | S3 | 86400 | Yes | No |
| /images/* | S3 | 604800 | Yes | No |
| Default (*) | ALB | 0 | Yes | Yes |
```

#### Cloudflare Configuration
```
CLOUDFLARE: Zone=<domain>, SSL=Full(Strict), MinTLS=1.2, Brotli=On, Early Hints=On
Rocket Loader: Disabled (conflicts with SPA frameworks)
```

#### CDN Cache Optimization
```
CACHE STRATEGY:
| Asset Type | Cache-Control Header | CDN TTL |
|--|--|--|
| HTML pages | no-cache, must-revalidate | 0 |
| JS/CSS (hashed) | public, max-age=31536000, | 1 year |
|  | immutable |  |
| Images | public, max-age=604800 | 7 days |
| Fonts | public, max-age=31536000 | 1 year |
| API responses | private, no-store | 0 |
| Public API | public, max-age=60, s-maxage= | 5 min |
|  | 300, stale-while-revalidate=60 |  |

  ...
```

### Step 5: Load Balancer Setup
Configure and optimize load balancing:

#### AWS ALB Configuration
```
APPLICATION LOAD BALANCER:
  Name: <service-name>-alb
  Scheme: internet-facing | internal
  VPC: <vpc-id>
  Subnets: <public subnets across 2+ AZs>
  Listeners:
  Port 80  -> Redirect to 443 (301)
  Port 443 -> Forward to target group (TLS termination)
  Target Groups:
| Name | Port | Health Check | Targets |
|--|--|--|--|
| api-targets | 3000 | /healthz (5s) | 3 instances |
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
  ...
```

#### HAProxy Configuration
```
HAProxy CONFIGURATION:
  Frontend: http-in (port 80 -> redirect 443)
  Frontend: https-in (port 443, SSL termination)
  Backend: api-servers (3 servers, leastconn)
  Backend: web-servers (2 servers, roundrobin)
  Health Checks:
| Interval: 5s | Rise: 2 | Fall: 3 | Timeout: 2s |
|--|--|--|--|
| Method: HTTP GET /healthz | Expected: 200 |
  Connection Limits:
  Max connections per server: 1000
  Queue timeout: 5s
  ...
```

### Step 6: Network Security
Design VPC, security groups, and firewall rules:

#### VPC Architecture
```
VPC DESIGN:
  VPC: 10.0.0.0/16
|  | PUBLIC SUBNETS (internet-facing) |  |
|  | 10.0.1.0/24 (AZ-a) | 10.0.2.0/24 (AZ-b) |  |
|  | ALB, NAT Gateway | ALB, NAT Gateway |  |
|  | PRIVATE SUBNETS (application tier) |  |
|  | 10.0.10.0/24 (AZ-a) | 10.0.11.0/24 (AZ-b) |  |
|  | ECS/EKS tasks | ECS/EKS tasks |  |
```

#### Security Groups
```
SECURITY GROUP DESIGN:
  SG: alb-sg
  Inbound:  443 from 0.0.0.0/0 (HTTPS)
  80 from 0.0.0.0/0 (HTTP -> redirect)
  Outbound: All to app-sg
  SG: app-sg
  Inbound:  <app-port> from alb-sg only
  Outbound: 5432 to db-sg (PostgreSQL)
  6379 to cache-sg (Redis)
  443 to 0.0.0.0/0 (external APIs via NAT)
  SG: db-sg
  Inbound:  5432 from app-sg only
```

#### Network ACLs and Firewall
```
NETWORK SECURITY RULES:
| Layer | Tool | Purpose |
|--|--|--|
| Edge | CloudFront/CF WAF | DDoS, bot protect |
| DNS | Route53/CF | DNS filtering |
| Perimeter | NACL | Subnet-level deny |
| Instance | Security Groups | Port-level allow |
| Application | Nginx/HAProxy | Rate limiting |
| Container | NetworkPolicy (K8s) | Pod-to-pod rules |
| Application | App middleware | Auth, CORS, CSP |

Defense in Depth Checklist:
  ...
```

### Step 7: Commit and Report
Save configs to `infra/{dns,certs,cdn,lb,network}/`. Commit: `"network: <description> — <components configured>"`

## Key Behaviors
1. **HTTPS everywhere.** TLS 1.2+ on all public endpoints. HTTP only redirects to HTTPS.
2. **DNS TTL strategy.** Long TTLs (3600s+) for stable, short (60-300s) for dynamic. Lower before migration.
3. **Certificate auto-renewal mandatory.** Let's Encrypt + certbot or cert-manager.
4. **CDN caches invalidatable.** Content hashing for static. Never cache APIs without explicit design.
5. **LB health checks required.** Check interval, thresholds, timeout configured.
6. **Security groups = allowlists.** Default deny. No 0.0.0.0/0 except ALB inbound.
7. **Three-tier VPC.** Public (LB), private (app), isolated (data). Multi-AZ.
8. **Log everything.** VPC Flow Logs, ALB access logs, WAF logs.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full network audit and topology report |
| `--dns` | DNS configuration and troubleshooting only |
| `--ssl` | SSL/TLS certificate management only |

## HARD RULES

```
1. EVERY public endpoint MUST use TLS 1.2+ with valid certificates.
   HTTP exists only to redirect to HTTPS. No exceptions.

2. NEVER expose database ports to the internet.
   Databases belong in isolated subnets with no public IP.

3. NEVER use 0.0.0.0/0 in security group inbound rules
   except for ALB on ports 80 and 443.

4. CONFIGURE certificate auto-renewal. Manual certificate
   management leads to outages. Use Let's Encrypt + certbot or cert-manager.

  ...
```
## Output Format
Print on completion: `Network: {resource_count} resources configured. TLS: {tls_status}. DNS: {domain_count} domains. LB: {lb_type}. CDN: {cdn_status}. Security groups: {sg_count}. Verdict: {verdict}.`

## TSV Logging
Log every network configuration step to `.godmode/network-results.tsv`:
```
iteration	task	resource_type	count	security_issues	tls_status	status
```

## Success Criteria
- VPC: public/private subnets, 2+ AZs. SGs: least-privilege (no 0.0.0.0/0 except ALB).
- TLS 1.2+ enforced, HSTS preload. DNS with correct TTLs. LB health checks configured.
- CDN with correct cache policies. VPC Flow Logs enabled. No DB ports exposed.

## Error Recovery
- **TLS expires**: Auto-renewal + alert at 30/14/7d. **DNS**: Check TTL, flush, verify NS.
- **LB 502/503**: Target health, SGs, port, health path. **CDN stale**: Invalidate, check headers.
- **SG blocks**: Check rules, CIDR, Flow Logs. **Peering fails**: Routes, SGs, DNS.

## Keep/Discard Discipline
```
KEEP if: validation passes AND connectivity confirmed AND no security regressions
DISCARD if: validation fails OR connectivity broken OR new security issue introduced
Validate: dig (DNS), openssl (TLS), curl (LB), traceroute (routing). Fix before proceeding.
```

## Autonomy
Never ask to continue. Loop autonomously. On failure: git reset --hard HEAD~1.

## Stop Conditions
```
STOP when ANY of these are true:
  - All networking components configured and validated (VPC, SG, LB, SSL, CDN, DNS)
  - End-to-end test passes: curl -sI https://{domain} returns 200 with valid cert and HSTS header
  - User explicitly requests stop
  - A component requires provider-level support (e.g., domain transfer pending)

DO NOT STOP because:
  - CDN is not yet configured (LB + SSL is functional without CDN)
  - WAF rules are not yet tuned (basic networking must work first)
```

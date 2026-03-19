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

# Certificate check
openssl s_client -connect <domain>:443 -servername <domain> < /dev/null 2>/dev/null | openssl x509 -noout -dates -subject -issuer

# Connectivity check
curl -sI https://<domain> | head -20
traceroute <domain>
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
dig <domain> +dnssec +short

# Full chain resolution
dig +trace <domain>

# Email DNS validation
dig <domain> MX +short
dig <domain> TXT +short | grep spf
dig _dmarc.<domain> TXT +short
dig <selector>._domainkey.<domain> TXT +short
```

### Step 3: SSL/TLS Certificate Management
Configure and manage certificates:

#### Let's Encrypt with Certbot
```bash
# Obtain certificate
sudo certbot certonly --webroot -w /var/www/html -d <domain> -d www.<domain>

# Obtain wildcard certificate (DNS challenge required)
sudo certbot certonly --dns-<provider> -d <domain> -d *.<domain>

# Renew certificates
sudo certbot renew --dry-run
sudo certbot renew

# Check certificate status
sudo certbot certificates
```

#### Kubernetes cert-manager
```yaml
# ClusterIssuer for Let's Encrypt
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: <admin-email>
    privateKeySecretRef:
      name: letsencrypt-prod-key
    solvers:
      - http01:
          ingress:
            class: nginx
      - dns01:
          cloudflare:
            email: <email>
            apiTokenSecretRef:
              name: cloudflare-api-token
              key: api-token
        selector:
          dnsZones:
            - "<domain>"

---
# Certificate resource
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: <domain>-tls
  namespace: <namespace>
spec:
  secretName: <domain>-tls-secret
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
    - <domain>
    - www.<domain>
    - api.<domain>
  renewBefore: 720h    # Renew 30 days before expiry
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
│  Security:                                                │
│  SSL: TLS 1.2 minimum                                     │
│  WAF: Attached (rate limiting + SQL injection + XSS)      │
│  Geo-restriction: None                                     │
│  Origin Access: OAC for S3, custom headers for ALB        │
└──────────────────────────────────────────────────────────┘
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
│  Security:                                                │
│  WAF: Managed Rules (OWASP Core Ruleset)                  │
│  Bot Fight Mode: Enabled                                  │
│  Rate Limiting: 100 req/10s per IP on /api/*              │
│  DDoS Protection: Automatic                               │
│  Page Rules:                                              │
│    /api/* -> Cache Level: Bypass, SSL: Full               │
│    /static/* -> Cache Level: Cache Everything, Edge: 7d   │
└──────────────────────────────────────────────────────────┘
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
│  web-targets       │ 8080 │ /health (5s)  │ 2 instances   │
├──────────────────────────────────────────────────────────┤
│  Routing Rules:                                           │
│  Priority │ Condition         │ Action                    │
│  1        │ Host: api.*       │ Forward to api-targets    │
│  2        │ Path: /ws/*       │ Forward to ws-targets     │
│  Default  │ *                 │ Forward to web-targets    │
├──────────────────────────────────────────────────────────┤
│  Security:                                                │
│  Security Groups: <sg-id> (443 from 0.0.0.0/0)           │
│  SSL Policy: ELBSecurityPolicy-TLS13-1-2-2021-06         │
│  WAF: <waf-acl-id> attached                               │
│  Access Logs: Enabled (S3 bucket)                         │
└──────────────────────────────────────────────────────────┘
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
    ssl_certificate /etc/ssl/certs/api.example.com.pem;
    ssl_certificate_key /etc/ssl/private/api.example.com.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:10m;
    ssl_session_tickets off;

    # HSTS
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

    # Security headers
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req zone=api burst=20 nodelay;

    location / {
        proxy_pass http://api_backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Timeouts
        proxy_connect_timeout 5s;
        proxy_read_timeout 30s;
        proxy_send_timeout 30s;

        # Health check (Nginx Plus or third-party module)
        # health_check interval=5s fails=3 passes=2;
    }

    location /health {
        access_log off;
        return 200 "OK";
    }
}

server {
    listen 80;
    server_name api.example.com;
    return 301 https://$host$request_uri;
}
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
│  Server timeout: 30s                                      │
│  Client timeout: 30s                                      │
├──────────────────────────────────────────────────────────┤
│  Stick Tables (Rate Limiting):                            │
│  Table: per_ip_rate                                       │
│  Type: ip, size: 1m, expire: 10s                          │
│  Track: src, rate(10s) > 100 -> deny                      │
└──────────────────────────────────────────────────────────┘
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
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  ISOLATED SUBNETS (data tier)                            │ │
│  │  10.0.20.0/24 (AZ-a) │  10.0.21.0/24 (AZ-b)           │ │
│  │  RDS, ElastiCache     │  RDS, ElastiCache               │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                               │
│  Route Tables:                                                │
│    Public: 0.0.0.0/0 -> IGW                                  │
│    Private: 0.0.0.0/0 -> NAT GW                              │
│    Isolated: No internet route (VPC endpoints for AWS APIs)   │
│                                                               │
│  VPC Endpoints:                                               │
│    S3 (Gateway), ECR (Interface), Secrets Manager (Interface) │
│    CloudWatch Logs (Interface), STS (Interface)               │
└──────────────────────────────────────────────────────────────┘
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
│  Outbound: None (no egress needed)                        │
├──────────────────────────────────────────────────────────┤
│  SG: cache-sg                                             │
│  Inbound:  6379 from app-sg only                          │
│  Outbound: None                                           │
├──────────────────────────────────────────────────────────┤
│  Principle: Least privilege — each SG allows only         │
│  traffic from the tier directly above it                   │
└──────────────────────────────────────────────────────────┘
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
  [x] Rate limiting at CDN edge (per IP, per path)
  [x] Security groups follow least-privilege
  [x] NACLs deny known malicious IP ranges
  [x] Kubernetes NetworkPolicies restrict pod communication
  [x] Application enforces CORS, CSP, HSTS headers
  [x] VPC Flow Logs enabled for forensic analysis
  [x] No public access to database or cache subnets
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

## Example Usage

### Setting up HTTPS for a new domain
```
User: /godmode:network Set up HTTPS for api.myapp.com

Network: Discovering current state...

Domain: api.myapp.com
DNS: CNAME -> d1234.cloudfront.net (CloudFront)
Certificate: NONE — no SSL configured

Plan:
  1. Request Let's Encrypt certificate for api.myapp.com
  2. Configure CloudFront to use custom SSL certificate
  3. Set minimum TLS version to 1.2
  4. Add HSTS header (max-age=31536000)
  5. Redirect HTTP -> HTTPS

Executing...

Certificate: Issued (Let's Encrypt, valid until 2026-06-17)
CloudFront: Updated with custom SSL
TLS: Minimum version 1.2
HSTS: Enabled
HTTP redirect: Configured

Verification:
  [x] https://api.myapp.com returns 200
  [x] http://api.myapp.com redirects to HTTPS (301)
  [x] TLS 1.1 connection rejected
  [x] HSTS header present
  [x] Certificate valid for 90 days
```

### Troubleshooting 502 Bad Gateway
```
User: /godmode:network Getting 502 errors on our API

Network: Investigating 502 Bad Gateway...

Checks:
  [x] DNS resolution: api.myapp.com -> 52.1.2.3 (correct)
  [x] ALB health: 2/3 targets healthy
  [ ] Target group: 1 target UNHEALTHY (10.0.10.45:3000)
  [x] Security groups: app-sg allows traffic from alb-sg
  [ ] Backend logs: Connection refused on 10.0.10.45:3000

Root cause: Application on instance 10.0.10.45 is down.
  - Process not running (OOMKilled at 14:23 UTC)
  - Auto-restart failed due to port conflict

Fix applied:
  1. Killed orphaned process holding port 3000
  2. Restarted application service
  3. Verified health check passing
  4. All 3/3 targets now healthy
  5. 502 errors resolved

Recommendation: Set up process manager (systemd/supervisord)
  with automatic restart and memory limits.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full network audit and topology report |
| `--dns` | DNS configuration and troubleshooting only |
| `--ssl` | SSL/TLS certificate management only |
| `--cdn` | CDN configuration and optimization only |
| `--lb` | Load balancer setup and health check only |
| `--vpc` | VPC and network architecture design only |
| `--security` | Firewall rules and security group audit only |
| `--troubleshoot` | Diagnose networking issues (502s, timeouts, DNS) |
| `--domain <name>` | Target a specific domain |
| `--provider <name>` | Use specific provider (aws, cloudflare, gcp) |

## Auto-Detection

```
IF directory contains nginx.conf OR nginx/:
  SUGGEST "Nginx configuration detected. Activate /godmode:network?"

IF directory contains haproxy.cfg OR haproxy/:
  SUGGEST "HAProxy configuration detected. Activate /godmode:network?"

IF directory contains Caddyfile:
  SUGGEST "Caddy server detected. Activate /godmode:network?"

IF Terraform files contain "aws_lb" OR "aws_cloudfront" OR "aws_route53":
  SUGGEST "AWS networking infrastructure detected. Activate /godmode:network?"

IF k8s/ contains Ingress OR Certificate OR NetworkPolicy manifests:
  SUGGEST "Kubernetes networking resources detected. Activate /godmode:network?"

IF directory contains cloudflare/ OR wrangler.toml:
  SUGGEST "Cloudflare configuration detected. Activate /godmode:network?"

IF .env or config contains DOMAIN, SSL_CERT, or CDN references:
  SUGGEST "Networking configuration variables detected. Activate /godmode:network?"

ON deployment failure with 502/503/504 errors:
  SUGGEST "Gateway error detected. Run /godmode:network --troubleshoot?"
```

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
     - vpc: subnets reachable, route tables correct
     - security_groups: least-privilege, no 0.0.0.0/0 on non-LB
     - load_balancer: health checks passing, targets healthy
     - ssl: certificate valid, TLS 1.2+ enforced, HSTS enabled
     - cdn: cache headers correct, invalidation works
     - dns: resolution correct from multiple resolvers

  IF validation_fails:
    validation_failures.append({component: component, reason: reason})
    FIX and re-validate
    CONTINUE  # retry same component
  ELSE:
    configured.append(component)
    current_component += 1

  REPORT "{current_component}/{total_components} networking components configured"

FINAL:
  RUN end-to-end test: curl -sI https://{domain}
  VERIFY: 200 OK, valid cert, HSTS header, correct origin
  REPORT full network inventory
```

## Multi-Agent Dispatch

```
WHEN setting up networking for a multi-service deployment:

DISPATCH parallel agents in worktrees:

  Agent 1 (vpc-and-security):
    - Design VPC with public/private/isolated subnets
    - Configure security groups (least-privilege)
    - Set up NACLs and VPC Flow Logs
    - Output: infra/network/ (Terraform or CloudFormation)

  Agent 2 (load-balancer):
    - Configure ALB/NLB with target groups
    - Set up health checks and routing rules
    - Configure SSL termination
    - Output: infra/lb/ configs

  Agent 3 (cdn-and-dns):
    - Configure CDN (CloudFront/Cloudflare)
    - Set up DNS records with correct TTLs
    - Configure cache behaviors per path
    - Output: infra/cdn/ + infra/dns/ configs

  Agent 4 (ssl-and-security):
    - Configure SSL certificates (Let's Encrypt / cert-manager)
    - Set up WAF rules (SQL injection, XSS, rate limiting)
    - Configure HSTS, CSP, and security headers
    - Output: infra/certs/ + infra/waf/ configs

MERGE:
  - Verify DNS points to CDN which routes to LB
  - Verify SSL terminates correctly at each layer
  - Verify security groups allow traffic flow: CDN -> LB -> App -> DB
  - Run end-to-end connectivity test through full stack
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

6. VPC design MUST use three tiers (public, private, isolated)
   spanning at least two availability zones.

7. NEVER cache authenticated/personalized content at the CDN
   unless cache keys include auth tokens.

8. VPC Flow Logs MUST be enabled on all production VPCs.
   You cannot investigate what you did not record.
```

## Anti-Patterns

- **Do NOT use self-signed certificates in production.** Let's Encrypt is free. There is no excuse for self-signed certs outside of local development.
- **Do NOT expose database ports to the internet.** Databases belong in isolated subnets with no public IP and no internet gateway route.
- **Do NOT use 0.0.0.0/0 in security group rules** except for ALB inbound on ports 80/443. Everything else should reference specific security groups or CIDR blocks.
- **Do NOT set DNS TTL to 0.** Extremely low TTLs cause excessive DNS queries and increase latency. Use 60s minimum for dynamic records.
- **Do NOT skip HSTS.** Without HSTS, browsers allow HTTP connections that can be intercepted. Enable HSTS with preload on all production domains.
- **Do NOT cache authenticated content at the CDN.** Unless you configure cache keys to include auth tokens, you risk serving one user's data to another.
- **Do NOT rely on a single availability zone.** LBs, subnets, and instances must span at least two AZs for fault tolerance.
- **Do NOT ignore VPC Flow Logs.** They are essential for security forensics and compliance auditing. Enable them on all production VPCs.

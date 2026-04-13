---
name: network
description: Network, DNS, SSL/TLS, CDN, load balancers.
---

## Activate When
- `/godmode:network`, "configure DNS", "SSL certificate"
- "CDN setup", "load balancer", "firewall rules"
- "502 bad gateway", "certificate expired", "VPC design"

## Workflow

### 1. Network Discovery
```bash
dig +short <domain> A
dig +short <domain> CNAME
dig +short <domain> MX
dig +short <domain> TXT
nslookup <domain>
```
```
| Component | Provider | Status |
| DNS | <provider> | configured/missing |
| SSL/TLS | <issuer> | valid/expired/none |
| CDN | <provider> | active/none |
| LB | <type> | healthy/degraded |
| VPC | <provider> | configured/none |
```

### 2. DNS Configuration
```
| Record | Type | Value | TTL | Proxy |
| @ | A | <LB IP> | 300 | Yes |
| www | CNAME | @ | 300 | Yes |
| api | A | <API LB> | 60 | Yes |
| mail | MX | <server> | 3600 | N/A |
| @ | TXT | v=spf1.. | 3600 | N/A |
```
```bash
# Check propagation
dig @8.8.8.8 <domain> A +short
dig @1.1.1.1 <domain> A +short
```
IF domain not resolving: check NS records first.
IF email not delivered: verify MX + SPF + DKIM + DMARC.

### 3. SSL/TLS Certificate Management
```bash
sudo certbot certonly --webroot \
  -w /var/www/html -d <domain> -d www.<domain>
# Wildcard (DNS challenge)
sudo certbot certonly --dns-<provider> \
  -d <domain> -d *.<domain>
```
```
Auto-renewal: ENABLED (certbot or cert-manager)
Alert: 14 days before expiry
TLS: min 1.2, prefer 1.3
HSTS: enabled with preload
```
IF cert expires < 30 days: renew immediately.
IF TLS < 1.2: upgrade, disable SSLv3/TLS1.0/1.1.

### 4. CDN Configuration
```
Cache strategy:
| Asset | Cache-Control | CDN TTL |
| HTML | no-cache | 0 |
| JS/CSS (hashed) | immutable, max-age=31536000 | 1yr |
| Images | max-age=604800 | 7 days |
| Fonts | max-age=31536000 | 1 year |
| API | private, no-store | 0 |
```

### 5. Load Balancer
```
ALB: internet-facing, 2+ AZs, TLS termination
  Health check: /healthz every 5s, rise 2, fall 3
  Target groups by service, port-based routing

Nginx: least_conn, keepalive 32
  Primary servers weighted, backup for failover

HAProxy: leastconn backend, 5s health interval
  Max 1000 connections/server, 5s queue timeout
```
IF 502/503: check target health, SGs, port, path.
IF high latency: check backend connections, keepalive.

### 6. Network Security
```
VPC: 10.0.0.0/16
  Public: 10.0.1.0/24, 10.0.2.0/24 (ALB, NAT)
  Private: 10.0.10.0/24, 10.0.11.0/24 (app)
  Isolated: 10.0.20.0/24, 10.0.21.0/24 (DB)

SG: alb-sg (443 from 0.0.0.0/0)
  app-sg (<port> from alb-sg only)
  db-sg (5432 from app-sg only)

Defense in depth: WAF -> NACL -> SG -> NetworkPolicy
```


```bash
# Network diagnostics
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:8080/health
dig +stats example.com
```

<!-- tier-3 -->

## Quality Targets
- Target: <100ms DNS resolution time
- TLS handshake: <200ms for new connections
- Target: >99.9% packet delivery rate
- Max connection pool: <1000 concurrent connections per host

## Hard Rules
1. EVERY public endpoint: TLS 1.2+ with valid cert.
2. NEVER expose DB ports to the internet.
3. NEVER 0.0.0.0/0 in SG except ALB on 80/443.
4. ALWAYS auto-renew certificates.
5. Three-tier VPC: public, private, isolated.

## TSV Logging
Append `.godmode/network-results.tsv`:
```
timestamp	resource_type	count	tls_status	status
```

## Keep/Discard
```
KEEP if: validation passes AND connectivity confirmed
  AND no security regressions.
DISCARD if: validation fails OR connectivity broken.
Validate: dig, openssl, curl, traceroute.
```

## Stop Conditions
```
STOP when FIRST of:
  - All components configured and validated
  - curl -sI https://{domain} returns 200 + HSTS
  - User requests stop
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| TLS expires | Auto-renewal + alert at 30/14/7d |
| LB 502/503 | Target health, SGs, port, path |
| DNS wrong IP | Check A/AAAA, CDN proxy, TTL |

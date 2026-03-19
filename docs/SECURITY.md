# Security Policy

> Godmode takes security seriously -- both in the software it helps you build and in its own design.

---

## Reporting Vulnerabilities

### Responsible Disclosure

If you discover a security vulnerability in Godmode, please report it responsibly.

**Do NOT open a public GitHub issue for security vulnerabilities.**

Instead:
1. Email **security@godmode.dev** with a description of the vulnerability
2. Include steps to reproduce the issue
3. Include the potential impact (what an attacker could achieve)
4. Allow up to 72 hours for an initial response
5. Allow up to 90 days for a fix before public disclosure

We will:
- Acknowledge your report within 72 hours
- Provide a timeline for the fix within 7 days
- Credit you in the security advisory (unless you prefer anonymity)
- Notify you when the fix is released

### What Qualifies as a Security Vulnerability

- A skill that instructs the agent to expose secrets, credentials, or API keys
- A workflow that could cause unintended data loss or destructive operations
- A skill that could be exploited to execute arbitrary commands outside the intended scope
- A configuration default that creates an insecure state
- A hook or script that could be hijacked or injected with malicious content

### What Does NOT Qualify

- Skills producing suboptimal code (this is a quality issue, not a security issue)
- Feature requests for additional security checks
- General questions about best practices (use the FAQ or open a discussion)

---

## Security Features of Godmode

### 1. No Runtime, No Network, No Data Collection

Godmode is a collection of Markdown skill files. It does not have:
- Its own runtime or executable code
- Network access or telemetry
- Data collection or analytics
- External service dependencies

All execution happens within Claude Code's existing sandbox. Godmode adds instructions; it does not add attack surface.

### 2. Secrets Protection

Multiple skills include explicit instructions to protect secrets:

- **`/godmode:secrets`** -- Manages API keys, database credentials, and tokens through dedicated secret stores (Vault, AWS Secrets Manager, GCP Secret Manager). Never hardcodes secrets
- **`/godmode:secure`** -- The security audit specifically scans for hardcoded secrets, exposed credentials, and insecure secret handling
- **`/godmode:ship`** -- The pre-flight checklist verifies that no secrets are included in the deployment artifacts
- **`/godmode:git`** -- Encourages `.gitignore` patterns that exclude `.env`, credentials files, and private keys

Skills explicitly instruct the agent to:
- Never commit `.env` files, credentials, or private keys
- Use environment variables or secret managers for sensitive values
- Rotate secrets that have been accidentally exposed
- Audit git history for previously committed secrets

### 3. Destructive Operation Guards

Godmode skills are designed to prevent accidental data loss:

- **No force-push:** Skills never instruct the agent to `git push --force` to main/master
- **No history rewriting:** Interactive rebase and history modification are not used in automated workflows
- **Branch protection:** The `/godmode:finish` skill verifies branch state before merging
- **Dry-run first:** The `/godmode:ship` workflow runs a dry-run deployment before the real one
- **Auto-revert:** The optimization loop reverts changes that fail verification, preserving the known-good state

### 4. Scoped Autonomy

Autonomous skills operate within defined boundaries:

- **Iteration limits:** The optimization and fix loops have configurable maximums (default: 20). They cannot run indefinitely
- **Guard rails:** A secondary metric that must never regress. If tests break during optimization, the change is reverted immediately
- **Scope definition:** Security audits define their scope before analysis. Skills do not access files outside the defined scope
- **Git-as-rollback:** Every change is committed before verification. The system can always return to the last known-good state

### 5. Security Audit Skill (`/godmode:secure`)

Godmode includes a dedicated security audit skill that uses industry-standard frameworks:

#### STRIDE Threat Modeling
Analyzes each component for:
- **S**poofing -- Can an attacker impersonate a user or service?
- **T**ampering -- Can an attacker modify data they should not?
- **R**epudiation -- Can an attacker deny their actions?
- **I**nformation Disclosure -- Can an attacker access confidential data?
- **D**enial of Service -- Can an attacker degrade availability?
- **E**levation of Privilege -- Can an attacker gain unauthorized access?

#### OWASP Top 10
Checks for the current OWASP Top 10 web application security risks:
1. Broken Access Control
2. Cryptographic Failures
3. Injection
4. Insecure Design
5. Security Misconfiguration
6. Vulnerable and Outdated Components
7. Identification and Authentication Failures
8. Software and Data Integrity Failures
9. Security Logging and Monitoring Failures
10. Server-Side Request Forgery (SSRF)

#### Red-Team Personas
Four simulated attackers with different capabilities:
- **Script Kiddie** -- Uses automated tools, exploits known vulnerabilities
- **Insider Threat** -- Has legitimate access, attempts privilege escalation
- **Organized Crime** -- Sophisticated, financially motivated, persistent
- **Nation-State** -- Advanced persistent threat, supply chain attacks

#### Output
Every finding includes:
- Code evidence (file path, line number, code snippet)
- Severity rating (Critical / High / Medium / Low)
- Exploitation scenario
- Remediation steps with code examples
- References to CWE/CVE where applicable

### 6. DevSecOps Integration (`/godmode:devsecops`)

The DevSecOps skill integrates security into the CI/CD pipeline:
- Static Application Security Testing (SAST) at build time
- Dynamic Application Security Testing (DAST) against running applications
- Software Composition Analysis (SCA) for vulnerable dependencies
- Container image scanning
- Infrastructure as Code security scanning
- Secret detection in pre-commit hooks

### 7. Compliance Skills

For regulated industries, Godmode provides compliance-specific skills:
- **`/godmode:comply`** -- Framework-agnostic compliance auditing
- **`/godmode:rbac`** -- Access control design that meets regulatory requirements
- **`/godmode:auth`** -- Authentication flows that follow security best practices

---

## How `/godmode:secure` Works

### Step-by-Step Workflow

```
1. SCOPE         Define what code to audit (files, directories, sensitive areas)
2. STRIDE        Run threat analysis on each sensitive area
3. OWASP         Check against OWASP Top 10 vulnerabilities
4. RED TEAM      Four personas attempt to find exploits
5. EVIDENCE      Attach code evidence to every finding
6. REMEDIATE     Provide fix for every finding with code examples
7. REPORT        Generate structured audit report at docs/security/<name>-audit.md
```

### Example Usage

```bash
# Full security audit of the auth module
/godmode:secure Run a full STRIDE + OWASP audit on the auth module

# Pre-ship security check
/godmode:secure --scope=changed  # Only audit files changed since last deploy

# Targeted vulnerability check
/godmode:secure Check for SQL injection in the user search endpoint
```

### Sample Output

```
SECURITY AUDIT — auth module
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CRITICAL (1)
  [C-001] JWT secret stored in plaintext in config.js:14
         → Move to environment variable or secret manager
         → Rotate the exposed secret immediately

HIGH (2)
  [H-001] Missing rate limiting on /api/login endpoint
         → Add rate limiting: max 5 attempts per IP per 15 minutes
  [H-002] Password reset token has no expiry
         → Set token expiry to 1 hour maximum

MEDIUM (3)
  [M-001] CORS allows wildcard origin in production config
         → Restrict to specific domains
  [M-002] Session cookie missing SameSite attribute
         → Set SameSite=Strict or SameSite=Lax
  [M-003] Error messages reveal internal stack traces
         → Return generic error messages in production

LOW (1)
  [L-001] X-Powered-By header exposes framework version
         → Remove or override the header

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TOTAL: 7 findings (1 critical, 2 high, 3 medium, 1 low)
```

---

## Security Best Practices When Using Godmode

1. **Review generated code before deploying.** Godmode enforces discipline, but human review is the final gate
2. **Run `/godmode:secure` before every production deploy.** Make it part of your shipping checklist
3. **Keep secrets out of git.** Use `.gitignore` for `.env` files and the `/godmode:secrets` skill for managing credentials
4. **Set guard rails on autonomous loops.** Always define a guard rail metric that includes test passage
5. **Use the dry-run phase.** Never skip the dry-run step in `/godmode:ship`
6. **Audit third-party dependencies.** Use `/godmode:devsecops` to scan for known vulnerabilities in your dependency tree
7. **Rotate exposed secrets immediately.** If a secret appears in a commit, rotation is mandatory -- removing the commit is not sufficient

---

## Supported Security Standards

| Standard | Godmode Skill |
|----------|---------------|
| OWASP Top 10 | `/godmode:secure` |
| STRIDE | `/godmode:secure` |
| GDPR | `/godmode:comply` |
| HIPAA | `/godmode:comply` |
| SOC 2 | `/godmode:comply` |
| PCI-DSS | `/godmode:comply` |
| CWE | Referenced in secure findings |
| CVE | Referenced in devsecops scans |

---

## Security Update Policy

- **Critical vulnerabilities:** Patched within 48 hours of confirmation
- **High vulnerabilities:** Patched within 7 days
- **Medium vulnerabilities:** Patched in the next scheduled release
- **Low vulnerabilities:** Addressed on a best-effort basis

All security patches are released as new versions with a security advisory on the GitHub repository.

---

## Contact

- **Security reports:** security@godmode.dev
- **General questions:** Open an issue with the `question` label
- **Discussions:** [GitHub Discussions](https://github.com/godmode-team/godmode/discussions)

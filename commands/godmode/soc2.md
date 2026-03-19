# /godmode:soc2

Deep SOC 2 compliance implementation covering Trust Service Criteria assessment (security, availability, processing integrity, confidentiality, privacy), evidence collection automation, control implementation and testing, continuous monitoring setup, and audit preparation workflow. Produces implementable controls, evidence collection scripts, monitoring configurations, and auditor-ready documentation.

## Usage

```
/godmode:soc2                                   # Full SOC 2 readiness assessment
/godmode:soc2 --security                        # Security (Common Criteria) assessment
/godmode:soc2 --availability                    # Availability criteria assessment
/godmode:soc2 --integrity                       # Processing Integrity assessment
/godmode:soc2 --confidentiality                 # Confidentiality assessment
/godmode:soc2 --privacy                         # Privacy criteria assessment
/godmode:soc2 --evidence                        # Evidence collection automation
/godmode:soc2 --controls                        # Control implementation and testing
/godmode:soc2 --monitoring                      # Continuous monitoring setup
/godmode:soc2 --audit-prep                      # Audit preparation workflow
```

## What It Does

1. Evaluates all 5 Trust Service Categories across 64 criteria with per-criterion pass/fail assessment
2. Assesses Common Criteria (CC1-CC9) covering control environment, risk, monitoring, access, operations, and change management
3. Reviews Availability (uptime SLAs, DR, backups), Processing Integrity, Confidentiality, and Privacy criteria
4. Builds automated evidence collection framework with scripts for IAM, change management, monitoring, and encryption evidence
5. Designs control implementation with testing procedures (inquiry, observation, inspection, reperformance)
6. Sets up continuous monitoring across infrastructure, security, and compliance layers
7. Prepares audit engagement with system description, evidence packages, and auditor interaction workflow

## Output
- SOC 2 readiness report at `docs/compliance/<date>-soc2-assessment.md`
- Commit: `"soc2: <scope> — <verdict> (<N> controls assessed, <N>% effective)"`
- Verdict: READY / CONDITIONAL / NOT READY

## Next Step
If NOT READY: `/godmode:fix` to remediate, then re-assess.
If READY: Engage audit firm for Type I or Type II examination.

## Examples

```
/godmode:soc2                                   # Full readiness assessment
/godmode:soc2 --security                        # Security criteria deep-dive
/godmode:soc2 --evidence                        # Set up automated evidence collection
/godmode:soc2 --controls                        # Test all implemented controls
/godmode:soc2 --audit-prep                      # Prepare for auditor engagement
/godmode:soc2 --quick                           # Top gaps only
```

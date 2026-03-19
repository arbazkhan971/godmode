# Ship Workflow — Full Reference

## Pre-Ship Checklist (Expanded)

### Code Quality Gate
| Check | Command Example | Pass Criteria |
|-------|----------------|---------------|
| All tests pass | `npm test` | Exit code 0, 0 failures |
| Lint clean | `npm run lint` | 0 errors (warnings OK) |
| Type check clean | `npx tsc --noEmit` | 0 errors |
| Coverage meets target | `npm test -- --coverage` | ≥ configured target |
| No debug code | `grep -rn "console.log\|debugger\|TODO\|FIXME\|HACK" src/` | 0 matches in new code |
| No secrets | `grep -rn "password.*=\|secret.*=\|api_key" src/` | 0 hardcoded secrets |
| Dependencies clean | `npm audit --audit-level=high` | 0 high/critical vulnerabilities |
| Build succeeds | `npm run build` | Exit code 0 |

### Git Hygiene Gate
| Check | Command Example | Pass Criteria |
|-------|----------------|---------------|
| Branch up to date | `git fetch origin main && git merge-base --is-ancestor origin/main HEAD` | Exit code 0 |
| No merge conflicts | `git merge --no-commit --no-ff origin/main && git merge --abort` | Clean merge |
| Clean commit messages | `git log main..HEAD --oneline` | Descriptive, no "fix" or "wip" |
| No untracked files | `git status --porcelain` | Empty (or only in .gitignore) |
| No large files | `git diff main..HEAD --stat \| awk '{print $3}' \| sort -n \| tail -5` | No files > 1MB |

### Documentation Gate
| Check | Description | Pass Criteria |
|-------|-------------|---------------|
| API docs updated | Swagger/OpenAPI reflects new endpoints | All new endpoints documented |
| CHANGELOG updated | Version entry with changes listed | New entry for this release |
| README updated | If user-facing changes affect setup/usage | README reflects current state |
| Migration guide | If breaking changes exist | Guide covers all breaking changes |

### Security Gate
| Check | Command/Action | Pass Criteria |
|-------|----------------|---------------|
| Security audit passed | `/godmode:secure` completed | PASS or CONDITIONAL PASS |
| Dependency audit | `npm audit` / `pip audit` | No critical vulnerabilities |
| No secrets in diff | `git diff main..HEAD \| grep -i "password\|secret\|token\|api_key"` | No hardcoded values |
| HTTPS enforced | Check configuration | All external calls use HTTPS |

## PR Template

```markdown
## Summary
<!-- What does this PR do? 1-3 sentences. -->

## Changes
<!-- Bulleted list of specific changes -->
-
-
-

## Type
<!-- Check one -->
- [ ] Feature (new functionality)
- [ ] Bug fix (fixes an issue)
- [ ] Refactor (no functional change)
- [ ] Performance (optimization)
- [ ] Documentation
- [ ] Dependencies

## Testing
<!-- How was this tested? -->
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing performed
- [ ] Performance benchmarks run

## Quality Checklist
- [ ] Tests passing
- [ ] Lint clean
- [ ] Type check clean
- [ ] Coverage ≥ target
- [ ] Security audit passed
- [ ] Code review passed
- [ ] No debug code remaining
- [ ] CHANGELOG updated

## Screenshots
<!-- If UI changes, include before/after screenshots -->

## Related Issues
<!-- Link to related issues/tickets -->
Closes #

## Rollback Plan
<!-- How to revert if something goes wrong -->
```

## Release Workflows

### Standard PR Workflow
```
1. Push branch to remote
2. Create PR with full template
3. Wait for CI to pass
4. Request review
5. Address review feedback
6. Merge when approved
7. Delete feature branch
```

### Staged Deploy Workflow
```
1. Deploy to staging environment
2. Run smoke tests against staging
3. Manual QA on staging (if needed)
4. Deploy to production
5. Run smoke tests against production
6. Monitor for 15 minutes
7. Confirm stable
```

### Hotfix Workflow
```
1. Create branch from production tag
2. Apply minimal fix
3. Run full test suite
4. Create PR with "HOTFIX" label
5. Fast-track review (1 reviewer minimum)
6. Merge and deploy immediately
7. Backport to main branch
```

### Release Tag Workflow
```bash
# Determine version (semantic versioning)
# MAJOR.MINOR.PATCH
# MAJOR: breaking changes
# MINOR: new features, backward compatible
# PATCH: bug fixes only

# Create annotated tag
git tag -a v1.2.3 -m "Release v1.2.3: <summary>"

# Push tag
git push origin v1.2.3

# Create GitHub release
gh release create v1.2.3 \
  --title "v1.2.3" \
  --notes-file CHANGELOG.md \
  --latest
```

## Post-Deploy Monitoring Protocol

### Monitoring Checklist (15-minute window)
```
T+0:  Deploy complete
  [ ] Deployment succeeded (no errors in deploy output)
  [ ] Health endpoint responding: curl <url>/health
  [ ] Application logs show startup messages

T+1:  Initial health check
  [ ] Health endpoint: 200 OK
  [ ] Error rate: < baseline + 0.1%
  [ ] Response time: < baseline + 10%

T+5:  Early monitoring
  [ ] Error rate stable
  [ ] Response time stable
  [ ] No new error types in logs
  [ ] Memory usage normal

T+10: Extended monitoring
  [ ] All metrics within expected ranges
  [ ] No user-reported issues
  [ ] Background jobs running normally
  [ ] Database connections stable

T+15: Confirmation
  [ ] All clear — ship confirmed stable
  OR
  [ ] Issues detected — initiate rollback
```

### Rollback Protocol
```
ROLLBACK DECISION TREE:
─ Error rate > 2x baseline? → ROLLBACK IMMEDIATELY
─ P95 latency > 3x baseline? → ROLLBACK IMMEDIATELY
─ Health endpoint failing? → ROLLBACK IMMEDIATELY
─ Data corruption detected? → ROLLBACK IMMEDIATELY + ALERT
─ Minor errors, < 2x baseline? → INVESTIGATE, rollback if no fix in 10 min
─ Cosmetic issues only? → DO NOT ROLLBACK, fix forward

ROLLBACK COMMANDS:
# Revert to previous deployment
<deploy previous version command>

# Verify rollback
curl <url>/health
<smoke test command>

# Document the rollback
# - What failed
# - When rollback initiated
# - Impact to users
# - Root cause (if known)
```

## Ship Log Format

```tsv
# .godmode/ship-log.tsv
timestamp	branch	type	target	version	status	pr_url	deploy_url	commit_sha	notes
2024-01-15T14:30:00Z	feat/rate-limiter	PR	main	-	CREATED	https://github.com/org/repo/pull/123	-	abc1234	"Awaiting review"
2024-01-15T16:00:00Z	feat/rate-limiter	PR	main	-	MERGED	https://github.com/org/repo/pull/123	-	def5678	"Approved by 2 reviewers"
2024-01-15T16:30:00Z	main	DEPLOY	staging	v1.2.3	SUCCESS	-	https://staging.example.com	ghi9012	"Smoke tests pass"
2024-01-15T17:00:00Z	main	DEPLOY	production	v1.2.3	SUCCESS	-	https://example.com	ghi9012	"15 min monitoring: all clear"
2024-01-16T09:15:00Z	hotfix/auth-fix	DEPLOY	production	v1.2.4	ROLLED_BACK	-	https://example.com	jkl3456	"Error rate spike at T+7, reverted to v1.2.3"
```

## Semantic Versioning Guide

```
Given version MAJOR.MINOR.PATCH:

MAJOR — Breaking changes
  - Removed or renamed public API
  - Changed behavior of existing functionality
  - Incompatible database migration
  - Dropped support for older runtime versions

MINOR — New features (backward compatible)
  - New endpoints or functions
  - New optional parameters
  - New configuration options
  - Additive database changes

PATCH — Bug fixes
  - Fixed incorrect behavior
  - Fixed security vulnerability
  - Fixed performance regression
  - Updated dependencies (non-breaking)
```

# /godmode:rfc

Write and manage technical proposals (RFCs) with structured templates, stakeholder review tracking, and decision timeline management.

## Usage

```
/godmode:rfc <proposal description>       # Create a new RFC
/godmode:rfc --list                       # List all RFCs with status
/godmode:rfc --status                     # Show active RFCs and review progress
/godmode:rfc --template                   # Output blank RFC template
/godmode:rfc --review <NNN>               # Start or update review for RFC-NNN
/godmode:rfc --accept <NNN>               # Mark RFC-NNN as accepted
/godmode:rfc --reject <NNN>               # Mark RFC-NNN as rejected
/godmode:rfc --defer <NNN>                # Defer RFC-NNN with revisit date
```

## What It Does

1. Classifies RFC type (Feature, Architecture, Process, Deprecation, Migration, Standard)
2. Gathers evidence: codebase analysis, metrics, prior art
3. Writes structured RFC with problem, solution, alternatives, risks, and migration plan
4. Manages stakeholder review workflow with comment tracking
5. Tracks decision timeline from creation through acceptance/rejection
6. Links accepted RFCs to ADRs and implementation plans

## Output
- RFC file saved to `docs/rfcs/<NNN>-<kebab-case-title>.md`
- A git commit: `"rfc: RFC-<NNN> — <title> (<status>)"`
- Review tracker showing reviewer status and blocking concerns

## Next Step
After RFC is accepted: `/godmode:adr` to create an ADR from the decision, then `/godmode:plan` to create an implementation plan.

## Examples

```
/godmode:rfc Migrate from Express to Fastify for better performance
/godmode:rfc --list                       # See all proposals
/godmode:rfc --status                     # Check review progress
/godmode:rfc --review 003                 # Update review status for RFC-003
/godmode:rfc --accept 003                 # Accept RFC-003
```

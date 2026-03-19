# /godmode:adr

Create, discover, and maintain Architecture Decision Records. Documents significant technical decisions with context, alternatives, consequences, and status tracking.

## Usage

```
/godmode:adr <decision description>       # Create a new ADR
/godmode:adr --list                       # List all ADRs with status
/godmode:adr --audit                      # Audit ADRs for staleness
/godmode:adr --search <keyword>           # Search ADRs by keyword
/godmode:adr --status <status>            # Filter ADRs by status
/godmode:adr --supersede <NNN>            # Create ADR superseding ADR-NNN
/godmode:adr --template                   # Output blank ADR template
```

## What It Does

1. Detects intent: create, discover, update, or audit
2. Researches codebase and existing ADRs for context
3. For new ADRs: gathers context, analyzes alternatives, writes structured record
4. Each ADR includes: status, context, decision, alternatives, consequences
5. Tracks status lifecycle: Proposed -> Accepted -> Deprecated/Superseded
6. Audits existing ADRs for staleness or conflicts with current code

## Output
- ADR file saved to `docs/adr/<NNN>-<kebab-case-title>.md`
- A git commit: `"adr: ADR-<NNN> — <title> (<status>)"`

## Next Step
After creating an ADR: continue development with the documented decision as reference.
When an ADR becomes stale: `/godmode:adr --supersede <NNN>` to create a replacement.

## Examples

```
/godmode:adr We chose Redis for session storage over PostgreSQL
/godmode:adr --list                       # See all decisions
/godmode:adr --audit                      # Find stale decisions
/godmode:adr --search "database"          # Find database-related decisions
/godmode:adr --supersede 003              # Replace ADR-003 with updated decision
```

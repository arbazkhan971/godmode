# /godmode:retro

Facilitate structured sprint retrospectives, track team health metrics, manage action items, and measure continuous improvement across sprints.

## Usage

```
/godmode:retro                                # Full retrospective with default format
/godmode:retro --format sailboat              # Use sailboat retrospective format
/godmode:retro --sprint "Sprint 14"           # Retrospect a specific sprint
/godmode:retro --health                       # Team health metrics only
/godmode:retro --actions                      # Review pending action items
/godmode:retro --trends                       # Continuous improvement trends
/godmode:retro --auto                         # Auto-generate from git data (solo mode)
/godmode:retro --compare 6                    # Compare health across last 6 sprints
```

## What It Does

1. **Context** — Gathers sprint metrics, git history, incidents, and previous action items
2. **Facilitate** — Guides retrospective through chosen format (Start/Stop/Continue, 4Ls, Mad/Sad/Glad, Sailboat, WWW)
3. **Insights** — Identifies themes and patterns across retrospective items
4. **Actions** — Converts insights into max 3 concrete, owned, deadlined action items
5. **Health** — Scores team health across 8 dimensions with trend tracking
6. **Improve** — Tracks improvement across sprints and escalates recurring themes

## Output
- Retrospective document saved to `docs/retros/<sprint-name>-retro.md`
- Updated action items at `docs/retros/action-items.md`
- Updated health metrics at `docs/retros/team-health.md`
- Git commit with retro summary

## Next Step
After retro: `/godmode:prioritize` to triage action items, or `/godmode:plan` to plan improvement initiatives.

## Examples

```
/godmode:retro                                # Run a full retrospective
/godmode:retro --health --compare 4           # Health trends over 4 sprints
/godmode:retro --actions                      # Check action item completion
/godmode:retro --auto --format 4l             # Auto-generate 4Ls retro from git data
```

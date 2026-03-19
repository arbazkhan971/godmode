# /godmode:pm

Product management skill — PRDs, user stories with acceptance criteria, feature prioritization (RICE/MoSCoW/ICE), sprint planning, competitive analysis, OKR/KPI definition, go-to-market planning, and launch readiness checklists. From idea to shipped product.

## Usage

```
/godmode:pm                                 # Full product management workflow
/godmode:pm --prd                           # Generate a PRD
/godmode:pm --stories                       # Write user stories with acceptance criteria
/godmode:pm --prioritize                    # Prioritize features with RICE scoring
/godmode:pm --roadmap                       # Create product roadmap
/godmode:pm --launch                        # Launch readiness checklist
/godmode:pm --competitive                   # Competitive analysis
/godmode:pm --okr                           # Define OKRs and KPIs
/godmode:pm --gtm                           # Go-to-market plan
```

## What It Does

1. Gathers product context — market, users, competitors, constraints
2. Writes PRDs with problem statement, success metrics, and requirements
3. Decomposes features into user stories with clear acceptance criteria
4. Prioritizes using data-driven frameworks (RICE, MoSCoW, ICE)
5. Creates roadmap with milestones and dependencies
6. Produces launch readiness checklists
7. Defines OKRs/KPIs with measurable targets

## Output
- PRD at `docs/specs/<feature>-prd.md`
- User stories ready for implementation
- Commit: `"pm: <feature> — PRD and user stories"`

## Next Step
→ `/godmode:think` to design the technical approach
→ `/godmode:plan` to decompose into implementation tasks
→ `/godmode:strategy` for broader product strategy

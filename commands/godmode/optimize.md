# /godmode:optimize

The core autonomous iteration loop. Measures a baseline, then runs a disciplined cycle: hypothesize, modify one thing, verify mechanically, keep if better or revert if worse, repeat until the target is reached.

## Usage

```
/godmode:optimize                                    # Interactive setup, then autonomous loop
/godmode:optimize --goal "reduce response time"      # Set goal directly
/godmode:optimize --verify "curl timing command"     # Set verify command
/godmode:optimize --target "< 200"                   # Set target
/godmode:optimize --max 30                           # Maximum iterations
/godmode:optimize --resume                           # Resume a paused optimization
/godmode:optimize --report                           # Show results from last run
/godmode:optimize --dry-run                          # Show plan without executing
```

## What It Does

1. Establishes optimization target (goal, metric, verify command, target value)
2. Measures baseline (3 runs, median)
3. Runs autonomous loop:
   - **Analyze** code and form a hypothesis
   - **Modify** one thing (one change per iteration)
   - **Verify** mechanically (run command, read output, compare)
   - **Keep** if improved, **revert** if not
   - **Log** every iteration to TSV
4. Stops when target reached, max iterations hit, or 3 consecutive reverts

## The Seven Principles

1. **Mechanical verification only** — run command, read number, that's truth
2. **One change per iteration** — know what helped
3. **Git is memory** — every experiment committed
4. **Evidence before claims** — measure THEN report
5. **Guard rails are sacred** — tests must pass
6. **Reverts are data** — failed experiments are valuable knowledge
7. **Know when to stop** — diminishing returns are real

## Output
- Optimized code with all improvements committed
- Results log: `.godmode/optimize-results.tsv`
- Summary report with top improvements and total gain

## Next Step
After optimize: `/godmode:secure` for security audit, or `/godmode:ship` to deliver.

## Examples

```
/godmode:optimize --goal "reduce bundle size" --target "< 500KB"
/godmode:optimize --goal "improve test speed" --verify "time npm test" --target "< 10s"
/godmode:optimize --resume  # Continue where you left off
```

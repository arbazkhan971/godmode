Output demo/optimize-loop.gif

Set Shell "bash"
Set FontSize 16
Set Width 1200
Set Height 640
Set TypingSpeed 8ms
Set Padding 18
Set Theme "Catppuccin Mocha"
Set CursorBlink false

Type "export PS1='godmode-demo $ ' && clear"
Enter
Sleep 500ms

Type "rm -rf /tmp/godmode-demo-optimize && mkdir -p /tmp/godmode-demo-optimize && cd /tmp/godmode-demo-optimize"
Enter
Sleep 500ms

Type 'git init -q && git config user.email demo@godmode.local && git config user.name "Godmode Demo"'
Enter
Sleep 500ms

Type "cp ~/godmode/demo/targets/optimize/slow_fib.py ~/godmode/demo/targets/optimize/test_slow_fib.py ~/godmode/demo/targets/optimize/metric.sh ."
Enter
Sleep 500ms

Type "python3 -m unittest -q test_slow_fib"
Enter
Sleep 3s

Type "bash metric.sh && bash metric.sh && bash metric.sh"
Enter
Sleep 6s

Type 'git add -A && git commit -qm "baseline"'
Enter
Sleep 500ms

Type 'timeout 300 pi -p -ne --model zai/glm-5.3 --skill ~/.pi/agent/skills/godmode/optimize/SKILL.md "Setup answers: Goal = reduce the runtime of work() in slow_fib.py. Metric = bash metric.sh which prints one number in milliseconds, lower is better, run it 3 times and use the median. Direction = down. Scope = slow_fib.py only. Guard = python3 -m unittest -q test_slow_fib must exit 0. Run as a single agent with no subagents and no worktrees, max 2 rounds. Test exactly these two hypotheses in order: (1) add functools lru_cache memoization to fib; (2) remove the lru_cache decorator and change work() to return fib(32), claiming batch amortization. For each hypothesis: edit the file, commit it, run the metric 3 times, run the guard, then KEEP or DISCARD per the skill rules — a DISCARD must be reverted with git reset --hard HEAD~1. Write only files inside the current directory. Finish by printing the contents of .godmode/optimize-results.tsv and then OPT_DONE alone on the final line. Keep the summary under 20 lines."'
Enter

Hide
Sleep 280s
Show
Sleep 3s

Type "cat .godmode/optimize-results.tsv"
Enter
Sleep 2s

Type "git log --oneline"
Enter
Sleep 1s

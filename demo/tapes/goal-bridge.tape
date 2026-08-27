Output demo/goal-bridge.gif
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

Type "rm -rf /tmp/godmode-demo-goalbridge && mkdir -p /tmp/godmode-demo-goalbridge && cd /tmp/godmode-demo-goalbridge"
Enter
Sleep 500ms

Type 'git init -q && git config user.email demo@godmode.local && git config user.name "Godmode Demo"'
Enter
Sleep 500ms

Type "cp ~/godmode/demo/targets/goal-bridge/counter.py ~/godmode/demo/targets/goal-bridge/test_counter.py ."
Enter
Sleep 500ms

Type "python3 -m unittest -q test_counter"
Enter
Sleep 500ms

Type 'git add -A && git commit -qm "baseline: failing test"'
Enter
Sleep 500ms

Type 'timeout 240 pi -p -ne --model zai/glm-5.3 --skill ~/.pi/agent/skills/godmode/goal-bridge/SKILL.md "Goal: make the test suite pass. Derive the Goal-Bridge contract FIRST and print its exact 4-field block: metric, threshold, evidence, rollback. Metric = python3 -m unittest -q test_counter and the contract is met iff it exits 0. Threshold = exit 0. Evidence = .godmode/goal-evidence.txt — append the metric output to it every round. Rollback = metric fails 2 consecutive rounds. Then fix counter.py, run the metric each round appending to the evidence file, and stop as soon as it exits 0. Write only files inside the current directory. Max 3 rounds. Keep the summary under 20 lines."'
Enter

Hide
Sleep 200s
Show
Sleep 3s

Type "cat .godmode/goal-evidence.txt"
Enter
Sleep 2s

Type 'python3 -m unittest -q test_counter && echo "CONTRACT MET — exit 0"'
Enter
Sleep 1s

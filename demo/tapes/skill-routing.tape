Output demo/skill-routing.gif

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

Type "cd ~/godmode"
Enter
Sleep 500ms

Type "ls skills | head -6"
Enter
Sleep 700ms

Type 'timeout 240 pi -p -ne --model zai/glm-5.3 --skill ~/.pi/agent/skills/godmode/godmode/SKILL.md "Route only. The user request is: we keep getting rate limited by the payment provider during checkout. Detect the stack, run Tier 1 matching over the skills directory, then print exactly one dispatch line naming the matched skill and phase, and finish with ROUTED_OK alone on the final line. Do not dispatch agents, do not run the matched skill, do not modify or create any files. Keep the whole reply under 15 lines."'
Enter
Sleep 500ms

Hide
Sleep 150s
Show
Sleep 3s

Type "git status --short"
Enter
Sleep 2s

Type 'echo "ROUTING DEMO — real session, real routing"'
Enter
Sleep 1s

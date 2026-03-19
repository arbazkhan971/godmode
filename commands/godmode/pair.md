# /godmode:pair

Start a pair programming session with structured driver/navigator roles, real-time code review, knowledge transfer, and teaching capabilities.

## Usage

```
/godmode:pair <what to work on>           # Standard pairing (user drives)
/godmode:pair --reverse                   # Reverse pairing (navigator drives)
/godmode:pair --teach <topic>             # Teaching mode with explanations
/godmode:pair --explore <area>            # Exploratory mode for unfamiliar code
/godmode:pair --ping-pong                 # TDD ping-pong mode
/godmode:pair --timebox <minutes>         # Set session duration (default: 30)
/godmode:pair --review                    # Focus on reviewing code together
```

## What It Does

1. Establishes session: mode (standard/reverse/teach/explore/ping-pong), goal, timebox
2. Sets up context: reads relevant code, tests, specs, and related files
3. Provides real-time navigation: flags bugs immediately, saves style notes for later
4. Thinks ahead while user writes: researches APIs, checks patterns, spots edge cases
5. In teaching mode: introduces concepts with codebase examples, graduated difficulty
6. Runs session checkpoints every 10-15 minutes with progress reports
7. Wraps up with summary: what was built, knowledge transferred, TODOs

## Output
- Code written collaboratively during the session
- Session summary with progress, knowledge transfer, and next steps
- A git commit: `"pair: <what was built> — <N> tests passing"`

## Next Step
After pairing: `/godmode:review` for a full code review, or continue with another `/godmode:pair` session.

## Examples

```
/godmode:pair Implement the rate limiter middleware
/godmode:pair --teach Help me understand async error handling
/godmode:pair --ping-pong Build the authentication service with TDD
/godmode:pair --explore Let's understand the payment integration code
/godmode:pair --reverse Write the caching layer while I review
/godmode:pair --timebox 45 Refactor the notification service
```

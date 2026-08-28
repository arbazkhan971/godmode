# Arcade leaderboard (bug-fixing)

## Context

`starter/` contains the arcade's nightly leaderboard tool: `index.js` loads a results file of `name,score` rows and `board.js` provides the ranking helpers, printing the top three finishers for the door list. Scores are whole numbers of points.

## Task

Make the leaderboard rank players highest-points-first for both file and stdin input, so the printed top finishers and their order match the actual points earned. Make `bash metric.sh` exit 0.

## Constraints

- Do not modify `metric.sh`.
- Node core modules only (`fs`); CommonJS `require`, no npm packages, no `package.json`.
- Work offline; no network access.
- Put all changes under `starter/`.

## How to check

Run `bash metric.sh` here. Exit 0 = done.

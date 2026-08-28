// Arcade leaderboard: print the top finishers from a results file.
// Usage: node index.js RESULTS   |   node index.js -   (read stdin)
"use strict";

const fs = require("fs");
const board = require("./board");

function readSource(arg) {
  if (arg === "-") return fs.readFileSync(0, "utf8");
  return fs.readFileSync(arg, "utf8");
}

function main(argv) {
  if (argv.length !== 3) {
    process.stderr.write("usage: node index.js RESULTS|-\n");
    return 2;
  }
  let text;
  try {
    text = readSource(argv[2]);
  } catch (err) {
    process.stderr.write("error: " + err.message + "\n");
    return 1;
  }
  const rows = board.parseRows(text);
  if (rows.length === 0) {
    process.stdout.write("no players\n");
    return 0;
  }
  for (const r of board.topN(rows, 3)) {
    process.stdout.write(r.score + " " + r.name + "\n");
  }
  return 0;
}

process.exit(main(process.argv));

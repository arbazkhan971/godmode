#!/usr/bin/env node
// tagstat - aggregates tag names from stdin into a counted report.
// Usage: node starter/index.js [--min-count N]
'use strict';

const tags = require('./tags');

function parseArgs(argv) {
  const opts = { minCount: null };
  const args = argv.slice(2);
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--min-count' && i + 1 < args.length) {
      opts.minCount = Number(args[++i]);
    }
  }
  return opts;
}

function main(argv) {
  const opts = parseArgs(argv);
  const lines = tags.readStdin();
  let ranked = tags.rank(tags.count(lines));
  ranked = tags.atLeast(ranked, opts.minCount);
  for (const [name, count] of ranked) {
    console.log(name + ' ' + count);
  }
  return 0;
}

if (require.main === module) {
  process.exitCode = main(process.argv);
}

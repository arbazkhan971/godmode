#!/usr/bin/env node
// tagstat - aggregates tag names from stdin into a counted report.
// Usage: node starter/index.js
'use strict';

const tags = require('./tags');

function main() {
  const lines = tags.readStdin();
  const ranked = tags.rank(tags.count(lines));
  for (const [name, count] of ranked) {
    console.log(name + ' ' + count);
  }
  return 0;
}

if (require.main === module) {
  process.exitCode = main();
}

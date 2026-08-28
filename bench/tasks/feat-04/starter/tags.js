// Aggregation helpers for the tagstat tool.
'use strict';

const fs = require('fs');

function readStdin() {
  return fs.readFileSync(0, 'utf8').split('\n');
}

function count(lines) {
  // Every nonblank line is one occurrence of a tag.
  const counts = new Map();
  for (const line of lines) {
    if (line.trim() === '') continue;
    counts.set(line, (counts.get(line) || 0) + 1);
  }
  return counts;
}

function rank(counts) {
  // Descending count; ties in ascending tag order.
  const pairs = [...counts.entries()];
  pairs.sort((a, b) => {
    if (b[1] !== a[1]) return b[1] - a[1];
    return a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0;
  });
  return pairs;
}

module.exports = { readStdin, count, rank };

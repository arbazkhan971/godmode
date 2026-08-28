'use strict';

const fs = require('fs');

// Read the item export: one record per line, `SKU|QTY|UNIT_CENTS`.
// Blank lines are ignored; record order is significant.
function readItems(path) {
  return fs.readFileSync(path, 'utf8').split('\n').filter((line) => line.length > 0);
}

module.exports = { readItems };

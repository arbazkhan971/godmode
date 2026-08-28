#!/usr/bin/env node
/* salesroll -- render a per-item sales report under config rules.
 *
 * Usage: node index.js CONFIG.json ITEMS.txt
 * Writes the report to stdout: a header block followed by one line per
 * item, in input order.
 */
'use strict';

const { readItems } = require('./lib/items');
const { renderReport } = require('./lib/render');

function main(argv) {
  if (argv.length !== 2) {
    process.stderr.write('usage: node index.js CONFIG.json ITEMS.txt\n');
    return 2;
  }
  const items = readItems(argv[1]);
  process.stdout.write(renderReport(items, argv[0]));
  return 0;
}

process.exitCode = main(process.argv.slice(2));

#!/usr/bin/env node
'use strict';

// skucheck -- validate one SKU code from the command line.
// Usage: node index.js <value>
// Prints VALID or INVALID; exit 0 valid, 4 invalid, 2 usage.

const { isValidSku } = require('./skulib');

function main(argv) {
  if (argv.length !== 1) {
    process.stderr.write('usage: node index.js <value>\n');
    return 2;
  }
  const ok = isValidSku(argv[0]);
  process.stdout.write(ok ? 'VALID\n' : 'INVALID\n');
  return ok ? 0 : 4;
}

process.exit(main(process.argv.slice(2)));

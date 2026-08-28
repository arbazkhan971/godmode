#!/usr/bin/env node
"use strict";

// Demo CLI: print the token list for one markup line as JSON.

const { tokenize } = require("./markup");

function main(args) {
  if (args.length !== 1) {
    process.stderr.write('usage: node index.js "LINE"\n');
    return 2;
  }
  process.stdout.write(JSON.stringify(tokenize(args[0])) + "\n");
  return 0;
}

process.exit(main(process.argv.slice(2)));

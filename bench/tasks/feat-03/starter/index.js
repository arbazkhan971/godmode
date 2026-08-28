#!/usr/bin/env node
// roster - prints the contact list sorted by last name.
// Usage: node starter/index.js [--search SUBSTR]
'use strict';

const contacts = require('./contacts');

function parseArgs(argv) {
  const opts = { search: null };
  const args = argv.slice(2);
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--search' && i + 1 < args.length) {
      opts.search = args[++i];
    }
  }
  return opts;
}

function fullName(c) {
  return c.first + ' ' + c.last;
}

function byLastName(a, b) {
  if (a.last < b.last) return -1;
  if (a.last > b.last) return 1;
  return 0;
}

function main(argv) {
  const opts = parseArgs(argv);
  let list = contacts.load();
  if (opts.search !== null) {
    const needle = opts.search.toLowerCase();
    list = list.filter((c) => fullName(c).toLowerCase().includes(needle));
  }
  const sorted = list.slice().sort(byLastName);
  for (const c of sorted) {
    console.log(c.last + ', ' + c.first + ' <' + c.email + '>');
  }
  return 0;
}

if (require.main === module) {
  process.exitCode = main(process.argv);
}

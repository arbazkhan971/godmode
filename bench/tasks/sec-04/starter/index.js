#!/usr/bin/env node
'use strict';

// pagegen -- render one HTML fragment from the command line.
// Usage: node index.js '<template>' [name=value ...]
// Placeholders are written as {name}; undefined names are an error.
// Prints the rendered fragment; exit 0 ok, 2 usage, 3 bad variable.

const { render } = require('./tmpl');

function parseVar(arg) {
  const i = arg.indexOf('=');
  if (i <= 0) return null;
  return [arg.slice(0, i), arg.slice(i + 1)];
}

function main(argv) {
  if (argv.length < 1) {
    process.stderr.write("usage: node index.js '<template>' [name=value ...]\n");
    return 2;
  }
  const vars = {};
  for (const arg of argv.slice(1)) {
    const pair = parseVar(arg);
    if (!pair) {
      process.stderr.write('bad variable: ' + arg + '\n');
      return 2;
    }
    vars[pair[0]] = pair[1];
  }
  try {
    process.stdout.write(render(argv[0], vars) + '\n');
  } catch (e) {
    process.stderr.write(e.message + '\n');
    return 3;
  }
  return 0;
}

process.exit(main(process.argv.slice(2)));

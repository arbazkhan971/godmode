#!/usr/bin/env node
/* tagmeet -- report tags shared by two lists.
 *
 * Usage: node index.js LIST_A LIST_B
 * Prints the intersection of the two tag lists, one tag per line,
 * sorted in ascending order. Input lists hold distinct tags.
 */
'use strict';

const tagslib = require('./tagslib');

function intersect(a, b) {
  return a.filter((tag) => b.includes(tag)).sort();
}

function main(argv) {
  if (argv.length !== 2) {
    process.stderr.write('usage: node index.js LIST_A LIST_B\n');
    return 2;
  }
  const a = tagslib.readTags(argv[0]);
  const b = tagslib.readTags(argv[1]);
  process.stdout.write(tagslib.render(intersect(a, b)));
  return 0;
}

process.exitCode = main(process.argv.slice(2));

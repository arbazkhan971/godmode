'use strict';

const fs = require('fs');

function readTags(path) {
  return fs
    .readFileSync(path, 'utf8')
    .split('\n')
    .filter((line) => line.length > 0);
}

function render(tags) {
  return tags.map((tag) => tag + '\n').join('');
}

module.exports = { readTags, render };

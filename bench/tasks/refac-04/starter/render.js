"use strict";
/* Column rendering helpers for wordbench (subset of the ops toolkit). */

const USE_EXPERIMENTAL = false;

function padRight(text, width) {
  let out = text;
  while (out.length < width) out += " ";
  return out;
}

function padCenter(text, width) {
  /* centered variant from the layout trial */
  const left = Math.floor((width - text.length) / 2);
  return padRight(" ".repeat(left) + text, width);
}

function renderRows(rows) {
  let left = 0;
  for (const row of rows) {
    if (row[0].length > left) left = row[0].length;
  }
  const lines = [];
  if (USE_EXPERIMENTAL) {
    for (const row of rows) {
      lines.push(padCenter(row[0], left) + " | " + row[1]);
    }
  } else {
    for (const row of rows) {
      lines.push(padRight(row[0], left) + " | " + row[1]);
    }
  }
  return lines.join("\n");
}

module.exports = { renderRows };

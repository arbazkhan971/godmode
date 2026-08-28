"use strict";
/* Column rendering helpers for wordbench (subset of the ops toolkit). */

function padRight(text, width) {
  let out = text;
  while (out.length < width) out += " ";
  return out;
}

function renderRows(rows) {
  let left = 0;
  for (const row of rows) {
    if (row[0].length > left) left = row[0].length;
  }
  const lines = [];
  for (const row of rows) {
    lines.push(padRight(row[0], left) + " | " + row[1]);
  }
  return lines.join("\n");
}

module.exports = { renderRows };

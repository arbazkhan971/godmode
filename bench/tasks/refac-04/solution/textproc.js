"use strict";
/* Text statistics core for wordbench (subset of the ops toolkit). */

function normalize(text) {
  return text.toLowerCase();
}

function stripPunct(text) {
  return text.replace(/[^a-z0-9\s]/g, " ");
}

function tokenize(text) {
  const out = [];
  for (const w of stripPunct(normalize(text)).split(/\s+/)) {
    if (w) out.push(w);
  }
  return out;
}

function countWords(tokens) {
  const counts = Object.create(null);
  for (const t of tokens) {
    counts[t] = (counts[t] || 0) + 1;
  }
  return counts;
}

function topWords(counts, n) {
  const list = [];
  for (const word of Object.keys(counts)) {
    list.push([word, counts[word]]);
  }
  list.sort(function (a, b) {
    const d = b[1] - a[1];
    return d !== 0 ? d : a[0] < b[0] ? -1 : 1;
  });
  return list.slice(0, n);
}

module.exports = { tokenize, countWords, topWords };

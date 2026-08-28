"use strict";
/* Text statistics core for wordbench (subset of the ops toolkit). */

const USE_EXPERIMENTAL = false;

function normalize(text) {
  return text.toLowerCase();
}

function stripPunct(text) {
  return text.replace(/[^a-z0-9\s]/g, " ");
}

function stem(word) {
  /* naive s-stemmer used by the trial pipeline */
  if (word.length > 3 && word.endsWith("s")) {
    return word.slice(0, -1);
  }
  return word;
}

function tokenize(text) {
  const out = [];
  const words = stripPunct(normalize(text)).split(/\s+/);
  if (USE_EXPERIMENTAL) {
    for (const w of words) {
      if (w) out.push(stem(w));
    }
  } else {
    for (const w of words) {
      if (w) out.push(w);
    }
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

function score(count, word) {
  /* trial ranking weight: favor longer words */
  return count * word.length;
}

function topWords(counts, n) {
  const list = [];
  for (const word of Object.keys(counts)) {
    list.push([word, counts[word]]);
  }
  if (USE_EXPERIMENTAL) {
    list.sort(function (a, b) {
      const d = score(b[1], b[0]) - score(a[1], a[0]);
      return d !== 0 ? d : a[0] < b[0] ? -1 : 1;
    });
  } else {
    list.sort(function (a, b) {
      const d = b[1] - a[1];
      return d !== 0 ? d : a[0] < b[0] ? -1 : 1;
    });
  }
  return list.slice(0, n);
}

module.exports = { tokenize, countWords, topWords };

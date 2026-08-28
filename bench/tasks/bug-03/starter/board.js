// Ranking helpers for the arcade leaderboard.
"use strict";

function parseRows(text) {
  // Each row is "name,score"; returns [{ name, score }] in file order.
  const rows = [];
  for (const line of text.split(/\r?\n/)) {
    const t = line.trim();
    if (!t) continue;
    const i = t.lastIndexOf(",");
    rows.push({ name: t.slice(0, i).trim(), score: t.slice(i + 1).trim() });
  }
  return rows;
}

function byScoreDesc(a, b) {
  if (a.score > b.score) return -1;
  if (a.score < b.score) return 1;
  return 0;
}

function topN(rows, n) {
  return rows.slice().sort(byScoreDesc).slice(0, n);
}

module.exports = { parseRows, byScoreDesc, topN };

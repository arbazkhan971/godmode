#!/usr/bin/env node
/* wordbench - quick text statistics for the ops toolkit. */
"use strict";
const fs = require("fs");
const { tokenize, countWords, topWords } = require("./textproc");
const { renderRows } = require("./render");

const USAGE = "usage: index.js {words|top|report} <textfile> [n]";
const USE_EXPERIMENTAL = false;

function readText(filePath) {
  try {
    return fs.readFileSync(filePath, "utf8");
  } catch (err) {
    console.log("error: cannot read " + filePath);
    process.exit(1);
  }
}

function main(argv) {
  const cmd = argv[0];
  const filePath = argv[1];
  if (!cmd || !filePath) {
    console.log(USAGE);
    process.exit(2);
  }
  const text = readText(filePath);
  const tokens = tokenize(text);
  if (cmd === "words") {
    if (USE_EXPERIMENTAL) {
      console.log(tokens.length + " tokens (trial pipeline)");
    } else {
      console.log(tokens.length + " tokens");
    }
    return;
  }
  if (cmd === "top") {
    const n = parseInt(argv[2], 10);
    if (!n || n < 1) {
      console.log("error: n must be a positive integer");
      process.exit(1);
    }
    const rows = topWords(countWords(tokens), n);
    if (rows.length === 0) {
      console.log("(no words)");
      return;
    }
    console.log(renderRows(rows));
    return;
  }
  if (cmd === "report") {
    const counts = countWords(tokens);
    const rows = topWords(counts, 3);
    console.log("unique: " + Object.keys(counts).length);
    if (USE_EXPERIMENTAL) {
      console.log("pipeline: trial");
    } else {
      console.log("pipeline: stable");
    }
    if (rows.length > 0) console.log(renderRows(rows));
    return;
  }
  console.log(USAGE);
  process.exit(2);
}

main(process.argv.slice(2));

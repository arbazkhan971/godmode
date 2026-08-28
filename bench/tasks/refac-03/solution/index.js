#!/usr/bin/env node
/* stockcheck - inspects a records JSON file (subset of the ops toolkit). */
"use strict";
const fs = require("fs");

const USAGE = "usage: index.js {list|total|ids} <records.json>";

function loadRecords(filePath) {
  let raw;
  try {
    raw = fs.readFileSync(filePath, "utf8");
  } catch (err) {
    console.log("error: cannot read " + filePath);
    process.exit(1);
  }
  try {
    return JSON.parse(raw).records;
  } catch (err) {
    console.log("error: invalid JSON: " + filePath);
    process.exit(1);
  }
}

function listCmd(filePath) {
  const records = loadRecords(filePath);
  for (const r of records) {
    console.log(r.id + " " + r.name + " " + r.qty);
  }
}

function totalCmd(filePath) {
  const records = loadRecords(filePath);
  let sum = 0;
  for (const r of records) {
    sum += r.qty;
  }
  console.log(sum);
}

function idsCmd(filePath) {
  const records = loadRecords(filePath);
  console.log(records.map((r) => r.id).join(","));
}

function main(argv) {
  const cmd = argv[0];
  const filePath = argv[1];
  if (cmd === "list" && filePath) return listCmd(filePath);
  if (cmd === "total" && filePath) return totalCmd(filePath);
  if (cmd === "ids" && filePath) return idsCmd(filePath);
  console.log(USAGE);
  process.exit(2);
}

main(process.argv.slice(2));

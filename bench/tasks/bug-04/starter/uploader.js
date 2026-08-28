// Sequential artifact uploader: copies named files from staging into the vault.
"use strict";

const fs = require("fs");
const path = require("path");

// Copy one artifact, then cb(err, name, bytes).
function copyOne(staging, name, dest, cb) {
  const src = path.join(staging, name);
  const dst = path.join(dest, name);
  fs.readFile(src, (err, data) => {
    if (err) return cb(err);
    fs.writeFile(dst, data, (err2) => {
      if (err2) return cb(err2);
      cb(null, name, data.length);
    });
  });
}

// Upload names in manifest order, one at a time; onFile(name, bytes) per artifact,
// onDone(err, count) once everything has settled.
function uploadAll(staging, names, dest, onFile, onDone) {
  const total = names.length;
  function step(i) {
    if (i === total) {
      setImmediate(() => onDone(null, total));
      return;
    }
    copyOne(staging, names[i], dest, (err, name, bytes) => {
      if (err) return onDone(err);
      onFile(name, bytes);
      step(i + 1);
    });
  }
  step(0);
}

module.exports = { uploadAll };

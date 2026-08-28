// Nightly-build uploader: store the manifest's artifacts from staging into the vault.
// Usage: node index.js STAGING MANIFEST|- DEST
"use strict";

const fs = require("fs");
const uploader = require("./uploader");

function readManifest(arg) {
  const text = arg === "-" ? fs.readFileSync(0, "utf8") : fs.readFileSync(arg, "utf8");
  return text.split(/\r?\n/).map((l) => l.trim()).filter((l) => l.length > 0);
}

function main(argv) {
  if (argv.length !== 5) {
    process.stderr.write("usage: node index.js STAGING MANIFEST|- DEST\n");
    process.exit(2);
  }
  const staging = argv[2];
  const manifestArg = argv[3];
  const dest = argv[4];
  let names;
  try {
    names = readManifest(manifestArg);
  } catch (err) {
    process.stderr.write("error: " + err.message + "\n");
    process.exit(1);
  }
  fs.mkdirSync(dest, { recursive: true });
  uploader.uploadAll(staging, names, dest,
    (name, bytes) => process.stdout.write("stored " + name + " (" + bytes + " bytes)\n"),
    (err, count) => {
      if (err) {
        process.stderr.write("error: " + err.message + "\n");
        process.exitCode = 1;
        return;
      }
      const line = "upload complete: " + count + " file(s) -> " + dest;
      process.stdout.write(line + "\n");
    }
  );
}

main(process.argv);

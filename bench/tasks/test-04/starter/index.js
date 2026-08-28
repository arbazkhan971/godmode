#!/usr/bin/env node
"use strict";

// Demo CLI: run a short push/pop script against the deque and print it.

const { Deque } = require("./deque");

function main(args) {
  if (args.length !== 0) {
    process.stderr.write("usage: node index.js\n");
    return 2;
  }
  const d = new Deque();
  const log = [];
  d.pushBack(2);
  d.pushFront(1);
  log.push(`front=${d.peekFront()} back=${d.peekBack()} size=${d.size()}`);
  log.push(`popFront=${d.popFront()} popBack=${d.popBack()} size=${d.size()}`);
  log.push(`emptyPop=${d.popBack()}`);
  process.stdout.write(log.join("\n") + "\n");
  return 0;
}

process.exit(main(process.argv.slice(2)));

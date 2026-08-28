"use strict";

// Tokenize one line of lightweight markup into an ordered token list:
//   **text** -> { kind: "bold", text: "..." }
//   *text*   -> { kind: "italic", text: "..." }
//   anything else accumulates into { kind: "text", text: "..." }
// A backslash escapes the next character (\* is a literal "*", \\ a literal "\").
// Unmatched markers stay literal; an empty line yields no tokens.

function tokenize(line) {
  const tokens = [];
  let buf = "";
  let i = 0;
  const flush = () => {
    if (buf.length > 0) {
      tokens.push({ kind: "text", text: buf });
      buf = "";
    }
  };
  while (i < line.length) {
    const ch = line[i];
    if (ch === "\\") {
      const next = line[i + 1];
      if (next === undefined) {
        buf += "\\";
        i += 1;
      } else {
        buf += next;
        i += 2;
      }
    } else if (ch === "*" && line[i + 1] === "*") {
      const close = line.indexOf("**", i + 2);
      if (close === -1) {
        buf += "**";
        i += 2;
      } else {
        flush();
        tokens.push({ kind: "bold", text: line.slice(i + 2, close) });
        i = close + 2;
      }
    } else if (ch === "*") {
      const close = line.indexOf("*", i + 1);
      if (close === -1) {
        buf += "*";
        i += 1;
      } else {
        flush();
        tokens.push({ kind: "italic", text: line.slice(i + 1, close) });
        i = close + 1;
      }
    } else {
      buf += ch;
      i += 1;
    }
  }
  flush();
  return tokens;
}

module.exports = { tokenize };

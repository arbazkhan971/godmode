"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");

const { tokenize } = require("../markup");

test("plain text becomes one text token", () => {
  assert.deepEqual(tokenize("hello"), [{ kind: "text", text: "hello" }]);
});

test("bold and italic spans become marker tokens", () => {
  assert.deepEqual(tokenize("**hi**"), [{ kind: "bold", text: "hi" }]);
  assert.deepEqual(tokenize("*hi*"), [{ kind: "italic", text: "hi" }]);
});

test("mixed line tokenizes in order", () => {
  assert.deepEqual(tokenize("a *b* c"), [
    { kind: "text", text: "a " },
    { kind: "italic", text: "b" },
    { kind: "text", text: " c" },
  ]);
});

test("backslash escapes the next character", () => {
  assert.deepEqual(tokenize("hi \\*there\\*"), [
    { kind: "text", text: "hi *there*" },
  ]);
});

test("empty line yields no tokens", () => {
  assert.deepEqual(tokenize(""), []);
});

test("unclosed markers stay literal text", () => {
  assert.deepEqual(tokenize("*oops"), [{ kind: "text", text: "*oops" }]);
  assert.deepEqual(tokenize("**oops"), [{ kind: "text", text: "**oops" }]);
});

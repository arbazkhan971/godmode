"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");

const { Deque } = require("../deque");

test("push grows the deque at both ends", () => {
  const d = new Deque();
  assert.equal(d.size(), 0);
  assert.equal(d.pushBack(2), 1);
  assert.equal(d.pushFront(1), 2);
  assert.equal(d.size(), 2);
});

test("popFront with pushBack behaves FIFO", () => {
  const d = new Deque();
  d.pushBack("a");
  d.pushBack("b");
  d.pushBack("c");
  assert.equal(d.popFront(), "a");
  assert.equal(d.popFront(), "b");
  assert.equal(d.size(), 1);
});

test("popBack returns the item pushed at the back", () => {
  const d = new Deque();
  d.pushBack(1);
  d.pushBack(2);
  d.pushBack(3);
  assert.equal(d.popBack(), 3);
  assert.equal(d.size(), 2);
  assert.equal(d.popBack(), 2);
});

test("pushFront with popBack behaves LIFO", () => {
  const d = new Deque();
  d.pushFront(1);
  d.pushFront(2);
  assert.equal(d.popBack(), 1);
  assert.equal(d.popBack(), 2);
});

test("empty deque: pops and peeks return null", () => {
  const d = new Deque();
  assert.strictEqual(d.popBack(), null);
  assert.strictEqual(d.popFront(), null);
  assert.strictEqual(d.peekBack(), null);
  assert.strictEqual(d.peekFront(), null);
  assert.equal(d.size(), 0);
});

test("peeks are non-destructive and see the correct ends", () => {
  const d = new Deque();
  d.pushBack(1);
  d.pushBack(2);
  d.pushBack(3);
  assert.equal(d.peekFront(), 1);
  assert.equal(d.peekBack(), 3);
  assert.equal(d.size(), 3);
});

test("peeks track the live ends after popping the other end", () => {
  const d = new Deque();
  d.pushBack(1);
  d.pushBack(2);
  d.pushBack(3);
  d.popBack();
  assert.equal(d.peekFront(), 1);
  d.pushFront(0);
  d.popFront();
  assert.equal(d.peekBack(), 2);
  assert.equal(d.size(), 2);
});

test("draining the deque restores the null sentinels", () => {
  const d = new Deque();
  d.pushFront("x");
  assert.equal(d.popBack(), "x");
  assert.strictEqual(d.popBack(), null);
  assert.strictEqual(d.peekBack(), null);
});

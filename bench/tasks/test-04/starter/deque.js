"use strict";

// Double-ended queue used by the job runner: items can be added and removed
// at either end. Pops and peeks on an empty deque return null (never
// undefined) so callers can tell "empty" apart from any stored value.

class Deque {
  constructor() {
    this._items = [];
  }

  // Add value at the back; returns the new size.
  pushBack(value) {
    this._items.push(value);
    return this._items.length;
  }

  // Add value at the front; returns the new size.
  pushFront(value) {
    this._items.unshift(value);
    return this._items.length;
  }

  // Remove and return the back item, or null when empty.
  popBack() {
    if (this._items.length === 0) return null;
    return this._items.pop();
  }

  // Remove and return the front item, or null when empty.
  popFront() {
    if (this._items.length === 0) return null;
    return this._items.shift();
  }

  // Return the back item without removing it, or null when empty.
  peekBack() {
    if (this._items.length === 0) return null;
    return this._items[this._items.length - 1];
  }

  // Return the front item without removing it, or null when empty.
  peekFront() {
    if (this._items.length === 0) return null;
    return this._items[0];
  }

  // Number of items currently held.
  size() {
    return this._items.length;
  }
}

module.exports = { Deque };

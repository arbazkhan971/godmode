'use strict';

// A SKU is one or more alphanumeric segments joined by single dashes.
// Validation pattern used in front of the inventory API.
const SKU_RE = /^([a-zA-Z0-9]+(-[a-zA-Z0-9]+)*)+$/;

function isValidSku(value) {
  if (typeof value !== 'string') return false;
  return SKU_RE.test(value);
}

module.exports = { isValidSku, SKU_RE };

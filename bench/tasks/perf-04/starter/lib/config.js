'use strict';

const fs = require('fs');

// Load the report config (title, currency, tax basis points, and the
// shipping-zone catalog that ships in the same file).
function loadConfig(path) {
  return JSON.parse(fs.readFileSync(path, 'utf8'));
}

module.exports = { loadConfig };

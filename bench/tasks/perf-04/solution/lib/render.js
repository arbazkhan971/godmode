'use strict';

const { loadConfig } = require('./config');
const { renderHeader, formatItem } = require('./format');

// Render the full report for `items` under the rules in the config file
// at `configPath`. One output line per item, input order preserved.
function renderReport(items, configPath) {
  const rules = loadConfig(configPath);
  const lines = [renderHeader(rules)];
  for (const raw of items) {
    lines.push(formatItem(raw, rules));
  }
  return lines.join('\n') + '\n';
}

module.exports = { renderReport };

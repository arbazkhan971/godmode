'use strict';

const { loadConfig } = require('./config');
const { renderHeader, formatItem } = require('./format');

// Render the full report for `items` under the rules in the config file
// at `configPath`. One output line per item, input order preserved.
function renderReport(items, configPath) {
  const lines = [renderHeader(loadConfig(configPath))];
  for (const raw of items) {
    // Item batches may be long-lived, so fetch the live rules for each
    // record instead of trusting a snapshot from before the loop.
    const rules = loadConfig(configPath);
    lines.push(formatItem(raw, rules));
  }
  return lines.join('\n') + '\n';
}

module.exports = { renderReport };

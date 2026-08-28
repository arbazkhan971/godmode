'use strict';

// First report lines: title banner plus the column row.
function renderHeader(cfg) {
  const rep = cfg.report;
  return '# ' + rep.title + ' (' + rep.currency + ')\n' + rep.columns.join('|');
}

// Format one item record under the report rules.
// Record layout: `SKU|QTY|UNIT_CENTS`; money stays in integer cents.
// net = qty * unit; tax = floor(net * taxBps / 10000); gross = net + tax.
function formatItem(raw, cfg) {
  const rep = cfg.report;
  const parts = raw.split('|');
  const sku = parts[0];
  const qty = Number(parts[1]);
  const unit = Number(parts[2]);
  const net = qty * unit;
  const tax = Math.floor((net * rep.taxBps) / 10000);
  return [sku, qty, net, tax, net + tax].join('|');
}

module.exports = { renderHeader, formatItem };

'use strict';

// Tiny HTML template engine used by the build-status page.
// Placeholders are written as {name} and filled from a vars object.

function render(template, vars) {
  return String(template).replace(/\{([a-zA-Z0-9_]+)\}/g, (m, key) => {
    const v = (vars || {})[key];
    if (v === undefined) throw new Error('undefined variable: ' + key);
    return String(v);
  });
}

module.exports = { render };

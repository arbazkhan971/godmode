# /godmode:extension

Browser extension development — Manifest V3 architecture, content scripts, background service workers, popup and options UI, cross-browser compatibility (Chrome, Firefox, Safari), extension store submission, messaging patterns, storage APIs, and security best practices.

## Usage

```
/godmode:extension                         # Full extension project assessment
/godmode:extension --content               # Content script development focus
/godmode:extension --popup                 # Popup UI development focus
/godmode:extension --store                 # Store submission preparation
/godmode:extension --security              # Security audit for extension
/godmode:extension --browser chrome        # Target Chrome specifically
/godmode:extension --framework wxt         # Use WXT framework
/godmode:extension --migrate               # Migrate MV2 to MV3
```

## What It Does

1. Assesses extension project requirements (browsers, type, UI surfaces, permissions)
2. Sets up Manifest V3 architecture:
   - Background service worker with event-driven patterns
   - Content scripts with isolation and Shadow DOM for injected UI
   - Popup, options page, side panel, and DevTools panel
3. Implements messaging patterns:
   - Typed message system between all extension components
   - Long-lived connections for streaming data
   - External messaging for web page communication
4. Handles cross-browser compatibility:
   - Chrome, Firefox, and Safari API differences
   - webextension-polyfill for Promise-based API
   - Feature detection for browser-specific APIs
5. Conducts security audit:
   - Permission minimization, CSP configuration
   - Input validation, message validation
   - Data security, no eval or remote code
6. Prepares store submissions:
   - Chrome Web Store listing and permissions justification
   - Firefox Add-ons listing and source code preparation
   - Safari Extensions via Xcode conversion and App Store

## Output
- Extension scaffold with MV3 manifest and all components
- Cross-browser build configuration
- Security audit with permission and CSP analysis
- Store submission checklists with completion status
- Commit: `"extension: <browser> — <description>"`

## Next Step
After scaffold: `/godmode:build` to implement extension features.
After building: `/godmode:test` to add Playwright E2E tests.
When ready: `/godmode:ship` to submit to extension stores.

## Examples

```
/godmode:extension                         # Full project assessment and setup
/godmode:extension --content               # Content script development
/godmode:extension --store                 # Prepare for store submission
/godmode:extension --security              # Security audit
/godmode:extension --migrate               # Migrate MV2 to MV3
```

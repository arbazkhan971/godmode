---
name: extension
description: |
  Browser extension development skill. Activates when building, testing, or distributing browser extensions for Chrome, Firefox, and Safari. Covers Manifest V3 architecture, content scripts, background service workers, popup and options UI, cross-browser compatibility, extension store submission (Chrome Web Store, Firefox Add-ons, Safari Extensions), messaging patterns, storage APIs, and security best practices. Every recommendation includes concrete implementation with cross-browser considerations. Triggers on: /godmode:extension, "browser extension", "Chrome extension", "Firefox addon", "Manifest V3", "content script", "background worker".
---

# Extension — Browser Extension Development

## When to Activate
- User invokes `/godmode:extension`
- User says "browser extension", "Chrome extension", "Firefox addon", "Safari extension"
- User mentions "Manifest V3", "content script", "background worker", "popup"
- User mentions "Chrome Web Store", "Firefox Add-ons", "Safari Extensions"
- When building content scripts that interact with web pages
- When designing messaging between extension components
- When preparing extensions for store submission and review

## Workflow

### Step 1: Extension Project Assessment
Determine the browser extension development approach:

```
EXTENSION PROJECT ASSESSMENT:
Project type: <new extension | migrating MV2 to MV3 | cross-browser port>
Target browsers: <Chrome | Firefox | Safari | all three>
Manifest version: <Manifest V3 (required for Chrome, recommended)>

Extension type:
  Category: <productivity | developer tool | content modifier | blocker | communication>
  UI surfaces: <popup | side panel | options page | devtools panel | none (background only)>
  Content interaction: <injects UI | modifies page | reads page | no page interaction>
  Permissions: <minimal | moderate | broad (all_urls)>

Frontend framework:
  Popup/Options: <React | Vue | Svelte | vanilla HTML/JS | Plasmo>
  Build tool: <Vite | webpack | Plasmo | WXT | CRXJS | none>
  TypeScript: <yes (recommended) | no>

Features needed:
  [ ] Content script injection
  [ ] Background service worker
  [ ] Popup UI
  [ ] Side panel
  [ ] Options/settings page
  [ ] Context menu items
  [ ] Keyboard shortcuts
  [ ] DevTools panel
  [ ] Cross-origin requests
  [ ] Local storage
  [ ] Sync storage (across devices)
  [ ] Notifications
  [ ] Badge/icon updates
```

### Step 2: Manifest V3 Architecture

```
MANIFEST V3 PROJECT STRUCTURE:
├── src/
│   ├── manifest.json            # Extension manifest (MV3)
│   ├── background/              # Service worker (replaces background page)
│   │   └── index.ts             # Event-driven background logic
│   ├── content/                 # Content scripts (injected into pages)
│   │   ├── index.ts             # Main content script
│   │   └── styles.css           # Injected styles
│   ├── popup/                   # Browser action popup
│   │   ├── index.html           # Popup HTML
│   │   ├── App.tsx              # Popup React component
│   │   └── styles.css           # Popup styles
│   ├── options/                 # Extension options page
│   │   ├── index.html           # Options HTML
│   │   └── App.tsx              # Options React component
│   ├── sidepanel/               # Side panel (Chrome 114+)
│   │   ├── index.html
│   │   └── App.tsx
│   ├── devtools/                # DevTools panel (optional)
│   │   ├── devtools.html        # DevTools entry
│   │   └── panel/
│   │       ├── index.html
│   │       └── App.tsx
│   ├── shared/                  # Shared code across contexts
│   │   ├── storage.ts           # Storage wrapper
│   │   ├── messaging.ts         # Message types and helpers
│   │   └── constants.ts         # Shared constants
│   └── assets/                  # Icons and static assets
│       ├── icon-16.png
│       ├── icon-32.png
│       ├── icon-48.png
│       └── icon-128.png
├── public/                      # Static files copied as-is
├── tests/                       # Extension tests
│   ├── unit/                    # Unit tests (Vitest/Jest)
│   └── e2e/                     # E2E tests (Playwright)
├── vite.config.ts               # Build configuration
├── package.json
└── tsconfig.json

MANIFEST.JSON (MV3):
{
  "manifest_version": 3,
  "name": "Extension Name",
  "version": "1.0.0",
  "description": "Clear, concise description under 132 characters",
  "permissions": ["storage", "activeTab"],
  "optional_permissions": ["tabs", "history"],
  "host_permissions": ["https://specific-site.com/*"],
  "optional_host_permissions": ["https://*/*"],
  "background": {
    "service_worker": "background/index.js",
    "type": "module"
  },
  "content_scripts": [{
    "matches": ["https://specific-site.com/*"],
    "js": ["content/index.js"],
    "css": ["content/styles.css"],
    "run_at": "document_idle"
  }],
  "action": {
    "default_popup": "popup/index.html",
    "default_icon": {
      "16": "assets/icon-16.png",
      "32": "assets/icon-32.png",
      "48": "assets/icon-48.png",
      "128": "assets/icon-128.png"
    }
  },
  "options_ui": {
    "page": "options/index.html",
    "open_in_tab": true
  },
  "icons": {
    "16": "assets/icon-16.png",
    "48": "assets/icon-48.png",
    "128": "assets/icon-128.png"
  },
  "content_security_policy": {
    "extension_pages": "script-src 'self'; object-src 'self'"
  }
}
```

### Step 3: Content Scripts

```
CONTENT SCRIPT ARCHITECTURE:

Injection strategies:
  Static (manifest):  Runs automatically on matching URLs
    "content_scripts": [{
      "matches": ["https://example.com/*"],
      "js": ["content/index.js"],
      "run_at": "document_idle"
    }]

  Dynamic (programmatic):  Injected on demand from background
    chrome.scripting.executeScript({
      target: { tabId },
      files: ["content/inject.js"]
    })

  run_at options:
    "document_start": Before DOM is built (for early interception)
    "document_end": After DOM is built, before resources loaded
    "document_idle": After page is fully loaded (safest default)

CONTENT SCRIPT ISOLATION:
  Content scripts run in an ISOLATED WORLD:
    - Own JavaScript context (no access to page variables)
    - Shared DOM (can read/modify page HTML)
    - Cannot access page's window object directly

  To interact with page JavaScript:
    // Content script injects a script tag into the page
    const script = document.createElement('script');
    script.src = chrome.runtime.getURL('injected.js');
    document.head.appendChild(script);

    // Communication via window.postMessage
    window.addEventListener('message', (event) => {
      if (event.source !== window) return;
      if (event.data.type === 'FROM_PAGE') {
        // Handle message from injected page script
      }
    });

CONTENT SCRIPT BEST PRACTICES:
  [ ] Namespace all CSS classes (prefix with extension name)
  [ ] Use Shadow DOM for injected UI (prevents page CSS conflicts)
  [ ] Clean up on unload (MutationObserver disconnect, event listener removal)
  [ ] Debounce DOM observation callbacks
  [ ] Check if target elements exist before operating
  [ ] Handle SPA navigation (URL changes without page reload)
  [ ] Minimize DOM queries (cache references)
  [ ] Avoid blocking the page's main thread
```

### Step 4: Background Service Workers

```
SERVICE WORKER ARCHITECTURE (MV3):

Key differences from MV2 background pages:
  - NO persistent background page — service worker is event-driven
  - Worker can be terminated after ~30 seconds of inactivity
  - No DOM access (no document, no window)
  - No XMLHttpRequest (use fetch API)
  - Must re-register all event listeners on startup

EVENT PATTERNS:
  // Register all listeners at top level (not conditionally, not async)
  chrome.runtime.onInstalled.addListener((details) => {
    if (details.reason === 'install') {
      // First install: set defaults, show onboarding
    } else if (details.reason === 'update') {
      // Extension updated: migrate storage, show changelog
    }
  });

  chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
    // Handle messages from content scripts and popup
    // Return true if response is async
    return true;
  });

  chrome.alarms.onAlarm.addListener((alarm) => {
    // Handle periodic tasks (replaces setInterval)
  });

PERSISTENCE STRATEGIES:
  Problem: Service worker state is lost on termination
  Solutions:
    1. chrome.storage.session — In-memory, survives worker restart, cleared on browser close
    2. chrome.storage.local — Persistent local storage
    3. chrome.storage.sync — Synced across user's devices (8KB per item, 100KB total)
    4. IndexedDB — Large structured data (available in service workers)

  Anti-pattern: global variables for state (lost on worker restart)
  Pattern: load state from storage on every wake, save on every change

ALARM-BASED SCHEDULING:
  // Replace setInterval with chrome.alarms
  chrome.alarms.create('periodic-check', {
    periodInMinutes: 60  // Minimum is 1 minute in production
  });

  chrome.alarms.onAlarm.addListener((alarm) => {
    if (alarm.name === 'periodic-check') {
      // Perform periodic task
    }
  });
```

### Step 5: Messaging Patterns

```
EXTENSION MESSAGING ARCHITECTURE:

Component communication map:
  Popup ←→ Background: chrome.runtime.sendMessage / onMessage
  Content ←→ Background: chrome.runtime.sendMessage / onMessage
  Content ←→ Popup: via Background (relay)
  Background → Content: chrome.tabs.sendMessage
  Page → Content: window.postMessage
  Content → Page: window.postMessage

MESSAGE TYPE SYSTEM (TypeScript):
  // Define all message types centrally
  type Message =
    | { type: 'GET_DATA'; payload: { key: string } }
    | { type: 'SAVE_DATA'; payload: { key: string; value: unknown } }
    | { type: 'TOGGLE_FEATURE'; payload: { feature: string; enabled: boolean } }
    | { type: 'CONTENT_READY'; payload: { url: string } };

  type Response<T extends Message['type']> =
    T extends 'GET_DATA' ? { data: unknown } :
    T extends 'SAVE_DATA' ? { success: boolean } :
    T extends 'TOGGLE_FEATURE' ? { success: boolean } :
    void;

LONG-LIVED CONNECTIONS:
  // For streaming data or frequent messages
  // Content script:
  const port = chrome.runtime.connect({ name: 'content-stream' });
  port.postMessage({ type: 'SUBSCRIBE', topic: 'updates' });
  port.onMessage.addListener((msg) => { /* handle */ });

  // Background:
  chrome.runtime.onConnect.addListener((port) => {
    if (port.name === 'content-stream') {
      port.onMessage.addListener((msg) => { /* handle */ });
      port.postMessage({ type: 'DATA', payload: data });
    }
  });

EXTERNAL MESSAGING:
  // Receive messages from web pages (allowlisted origins)
  "externally_connectable": {
    "matches": ["https://your-webapp.com/*"]
  }

  // Web page sends:
  chrome.runtime.sendMessage(extensionId, { type: 'AUTH_TOKEN', token });

  // Extension receives:
  chrome.runtime.onMessageExternal.addListener((msg, sender, sendResponse) => {
    // Validate sender.origin before processing
  });
```

### Step 6: Cross-Browser Compatibility

```
CROSS-BROWSER DIFFERENCES:

API namespace:
  Chrome: chrome.* API
  Firefox: browser.* API (Promise-based) + chrome.* (callback-based)
  Safari: browser.* API (Promise-based)

  Solution: Use webextension-polyfill (or WXT/Plasmo handles this)
    import browser from 'webextension-polyfill';
    const data = await browser.storage.local.get('key');

Manifest differences:
  Chrome MV3:
    "background": { "service_worker": "background.js" }
  Firefox MV3:
    "background": { "scripts": ["background.js"] }  // Still event pages
  Safari:
    Converted from Chrome extension via Xcode (xcrun safari-web-extension-converter)

Feature availability:
  Side Panel:     Chrome 114+, not Firefox/Safari
  Offscreen API:  Chrome 109+, not Firefox/Safari
  DeclarativeNetRequest: Chrome/Firefox/Safari (with differences)
  userScripts:    Chrome 120+, Firefox (different API)

COMPATIBILITY STRATEGY:
  1. Build for Chrome MV3 as primary target
  2. Use webextension-polyfill for Promise-based API
  3. Feature-detect before using browser-specific APIs:
     if (chrome.sidePanel) { /* Chrome-specific */ }
  4. Maintain browser-specific manifest patches (WXT handles this)
  5. Test on all target browsers before each release

BUILD TOOLS FOR CROSS-BROWSER:
  WXT:    Framework for cross-browser extensions (Vite-based, auto-polyfill)
  Plasmo: React-first extension framework (handles manifest differences)
  CRXJS:  Vite plugin for Chrome extensions
  Manual: Separate build configs + webextension-polyfill
```

### Step 7: Extension Store Submission

```
CHROME WEB STORE SUBMISSION:

Developer account:
  - One-time $5 registration fee
  - Verified developer badge available (domain verification)

Pre-submission checklist:
  [ ] Manifest permissions are minimal (justify every permission)
  [ ] Privacy policy hosted and accessible
  [ ] Extension description clear and accurate
  [ ] Screenshots prepared (1280x800 or 640x400, PNG/JPEG)
  [ ] Promotional images:
      Small tile: 440x280
      Marquee: 1400x560 (optional, for featured placement)
  [ ] Category selected appropriately
  [ ] Single purpose clearly defined (Google enforces this)
  [ ] Content Security Policy properly set
  [ ] No remote code execution (eval, remote scripts)
  [ ] activeTab preferred over broad host permissions

Submission:
  1. Package: zip the extension directory (exclude source maps, node_modules)
  2. Upload to Chrome Web Store Developer Dashboard
  3. Fill store listing (name, description, screenshots, category)
  4. Declare permissions justification
  5. Complete privacy practices disclosure
  6. Submit for review

Review timeline:
  - New extensions: 1-7 days (can be longer)
  - Updates: hours to 3 days
  - Rejection reasons are provided — fix and resubmit

FIREFOX ADD-ONS (AMO) SUBMISSION:

Developer account:
  - Free registration
  - Extensions can be listed or self-hosted

Pre-submission checklist:
  [ ] manifest.json compatible with Firefox MV3
  [ ] All permissions justified
  [ ] Source code clean (AMO may request source for review)
  [ ] No obfuscated or minified-without-source code
  [ ] Privacy policy if collecting user data

Submission:
  1. Package as .zip or .xpi
  2. Upload to addons.mozilla.org
  3. Provide source code if using build tools (required for review)
  4. Fill listing details
  5. Submit for review

Review: AMO reviews are manual — expect 1-7 days.

SAFARI EXTENSION SUBMISSION:

Requirements:
  - Apple Developer account ($99/year)
  - Xcode for conversion and packaging
  - macOS for building

Process:
  1. Convert: xcrun safari-web-extension-converter /path/to/extension
  2. Open generated Xcode project
  3. Configure signing and capabilities
  4. Test in Safari (Develop → Allow Unsigned Extensions)
  5. Archive and submit via Xcode → App Store Connect
  6. Safari extensions are distributed via Mac App Store
```

### Step 8: Security Considerations

```
EXTENSION SECURITY CHECKLIST:

Permission minimization:
  [ ] Request only permissions actually used
  [ ] Use optional_permissions for features not needed at install
  [ ] Prefer activeTab over broad host_permissions
  [ ] Use declarativeNetRequest instead of webRequest where possible
  [ ] Remove unused permissions when features are deprecated

Content Security Policy:
  [ ] No 'unsafe-eval' (no eval, no Function constructor, no inline scripts)
  [ ] No 'unsafe-inline' for scripts
  [ ] No remote code loading (all scripts bundled locally)
  [ ] Restrict connection sources with connect-src

Input validation:
  [ ] Validate all messages (type, structure, source)
  [ ] Sanitize content from web pages before display
  [ ] Never use innerHTML with untrusted content (use textContent or DOMPurify)
  [ ] Validate URLs before navigation or fetch

Data security:
  [ ] Sensitive data in chrome.storage.session (not local — survives only session)
  [ ] API keys and tokens never in content scripts (use background relay)
  [ ] No secrets in manifest.json or source code
  [ ] Use HTTPS for all external requests

Communication security:
  [ ] Validate sender in onMessage handlers (sender.id, sender.url)
  [ ] Validate origin in onMessageExternal handlers
  [ ] Never execute arbitrary code received via messages
  [ ] Use structured message types (not string commands)

Update security:
  [ ] Do not auto-update from external servers (use store updates)
  [ ] No dynamic code injection from remote sources
  [ ] Version-lock all dependencies (supply chain attacks)
  [ ] Review dependency updates before publishing

COMMON VULNERABILITIES:
  XSS via innerHTML:
    BAD:  element.innerHTML = userInput
    GOOD: element.textContent = userInput
    GOOD: element.innerHTML = DOMPurify.sanitize(userInput)

  Privilege escalation via messaging:
    BAD:  chrome.runtime.onMessage.addListener((msg) => eval(msg.code))
    GOOD: chrome.runtime.onMessage.addListener((msg) => {
            if (msg.type === 'KNOWN_ACTION') { performKnownAction(); }
          })

  Data leakage via content scripts:
    BAD:  Content script reads page DOM and sends all data to background
    GOOD: Content script reads only specific elements needed for the feature
```

### Step 9: Extension Development Report

```
┌────────────────────────────────────────────────────────────────┐
│  EXTENSION PROJECT — <extension name>                           │
├────────────────────────────────────────────────────────────────┤
│  Manifest: V3                                                    │
│  Browsers: <Chrome | Firefox | Safari | all>                     │
│  Framework: <WXT | Plasmo | CRXJS | vanilla>                    │
│                                                                  │
│  Components:                                                     │
│    Background worker: <IMPLEMENTED | TESTED | N/A>              │
│    Content scripts: <IMPLEMENTED | TESTED | N/A>                │
│    Popup UI: <IMPLEMENTED | TESTED | N/A>                       │
│    Options page: <IMPLEMENTED | TESTED | N/A>                   │
│    Side panel: <IMPLEMENTED | TESTED | N/A>                     │
│                                                                  │
│  Permissions:                                                    │
│    Required: <list>                                              │
│    Optional: <list>                                              │
│    Host permissions: <specific domains | broad | none>           │
│                                                                  │
│  Security:                                                       │
│    CSP: <DEFAULT | CUSTOM | NEEDS REVIEW>                       │
│    Input validation: <YES | PARTIAL | NO>                        │
│    Message validation: <YES | PARTIAL | NO>                      │
│                                                                  │
│  Store readiness:                                                │
│    Chrome Web Store: <N>/<total> checklist items                 │
│    Firefox Add-ons: <N>/<total> checklist items                  │
│    Safari Extensions: <N>/<total> checklist items                │
├────────────────────────────────────────────────────────────────┤
│  Next: /godmode:test — Test extension across browsers            │
│        /godmode:secure — Security audit for extension            │
│        /godmode:ship — Submit to extension stores                │
└────────────────────────────────────────────────────────────────┘
```

### Step 10: Commit and Transition
1. Commit extension scaffold: `"extension: <browser> — MV3 extension scaffold"`
2. Commit content scripts: `"extension: content scripts — <page interaction description>"`
3. Commit store preparation: `"extension: store — <browser> submission preparation"`
4. If store-ready: "Extension is built and tested. Run `/godmode:ship` to submit."
5. If in progress: "Extension scaffold complete. Run `/godmode:build` to implement features."

## Key Behaviors

1. **Manifest V3 is mandatory.** Chrome requires MV3 for all new extensions. Design for MV3 from the start — do not build on MV2 and hope to migrate later.
2. **Permissions are trust.** Every permission you request is a reason for users to not install your extension. Request the minimum set and use optional permissions for non-essential features.
3. **Service workers are ephemeral.** Unlike MV2 background pages, MV3 service workers can be terminated at any time. Never rely on in-memory state — persist everything to storage.
4. **Content scripts are guests.** Your content script runs on someone else's page. Namespace everything, use Shadow DOM for UI, and clean up after yourself.
5. **Test across browsers.** Chrome, Firefox, and Safari have subtle API differences. What works in Chrome may fail silently in Firefox. Test on every target browser.
6. **Store reviews are gatekeepers.** Chrome Web Store and Firefox Add-ons have strict review policies. Read and follow the guidelines before submission — rejection delays are costly.

## Example Usage

### Building a productivity extension
```
User: /godmode:extension Build a tab manager extension for Chrome and Firefox

Extension: Assessing requirements...

EXTENSION PROJECT:
Manifest: V3
Browsers: Chrome + Firefox
Framework: WXT (cross-browser, Vite-based)

Architecture:
  /src
    /background
      index.ts         — Tab event listeners, session management
    /popup
      App.tsx           — Tab list with search, group, close actions
      TabItem.tsx       — Individual tab with favicon, title, actions
    /options
      App.tsx           — Settings (auto-group rules, shortcuts)
    /shared
      storage.ts        — Tab groups, user preferences
      messaging.ts      — Typed messages between components

Permissions:
  Required: tabs, storage
  Optional: tabGroups (Chrome-specific feature)

Features:
  - Search across all tabs (fuzzy matching)
  - Group tabs by domain
  - Suspend inactive tabs (save memory)
  - Keyboard shortcut to open popup (Ctrl+Shift+T)
  - Sync settings across devices (chrome.storage.sync)

Cross-browser:
  - Tab grouping: Chrome only (feature-detected)
  - Tab suspension: Chrome only (feature-detected)
  - Core features work on both Chrome and Firefox

Next: /godmode:build to implement tab management features
      /godmode:test to add Playwright E2E tests
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full extension project assessment and setup |
| `--content` | Content script development focus |
| `--popup` | Popup UI development focus |
| `--store` | Store submission preparation only |
| `--security` | Security audit for extension |
| `--browser <name>` | Target specific browser (chrome, firefox, safari) |
| `--framework <name>` | Use specific framework (wxt, plasmo, crxjs, vanilla) |
| `--migrate` | Migrate MV2 extension to MV3 |

## Anti-Patterns

- **Do NOT request all_urls permission unless absolutely necessary.** It triggers the highest-level permission warning and may cause rejection in store review. Use activeTab and specific host permissions instead.
- **Do NOT use eval or remote code execution.** Chrome Web Store rejects extensions that use eval(), new Function(), or load scripts from external servers. All code must be bundled in the extension.
- **Do NOT store state in service worker global variables.** The service worker can be terminated at any time. State in global variables will be lost. Use chrome.storage.session for ephemeral state.
- **Do NOT modify page DOM without namespacing.** Your CSS classes and element IDs will conflict with the page's styles. Prefix everything or use Shadow DOM for injected UI.
- **Do NOT send sensitive data through content scripts.** Content scripts share the DOM with the page. Page scripts can intercept postMessage and observe DOM changes. Route sensitive data through the background worker.
- **Do NOT bundle unnecessary code.** Extension size affects install willingness and store review time. Tree-shake, code-split, and remove dev dependencies from the production build.
- **Do NOT ignore the single-purpose policy.** Chrome enforces that extensions do one thing well. An extension that combines a tab manager, ad blocker, and password generator will be rejected.
- **Do NOT auto-open tabs or change the new tab page without clear user intent.** This is the fastest way to get your extension reported and removed from stores.

---
name: pwa
description: |
  Progressive Web App skill. Activates when user needs service worker implementation, offline-first architecture, app manifest configuration, push notification setup, background sync, or installability requirements. Covers the full PWA lifecycle from manifest creation to production deployment with offline support. Triggers on: /godmode:pwa, "progressive web app", "service worker", "offline", "app manifest", "push notifications", "background sync", "installable", "add to home screen", "PWA".
---

# PWA — Progressive Web App Development

## When to Activate
- User invokes `/godmode:pwa`
- User says "make this a PWA", "add offline support", "service worker"
- User mentions "app manifest", "install prompt", "add to home screen"
- User asks about "push notifications", "background sync", "offline first"
- When building a web app that needs native-like capabilities
- After implementing core features and wanting to add installability
- When users report poor experience on unreliable networks

## Workflow

### Step 1: PWA Readiness Assessment
Evaluate current state and determine what is needed:

```
PWA READINESS ASSESSMENT:
Target: <URL / application>
Framework: <Next.js | React | Vue | Svelte | Angular | vanilla>
Current state:
  HTTPS: <yes | no (BLOCKER — PWA requires HTTPS)>
  Service worker: <registered | not registered>
  Web app manifest: <present | missing>
  Responsive design: <yes | partially | no>
  Offline support: <full | partial | none>
  Installable: <yes | no>

Lighthouse PWA audit:
  Installable: <PASS | FAIL>
  PWA Optimized: <PASS | FAIL>
  Fast and reliable: <PASS | FAIL>

Missing requirements:
  [ ] Web app manifest with required fields
  [ ] Service worker with fetch handler
  [ ] Offline fallback page
  [ ] HTTPS (or localhost for development)
  [ ] Responsive viewport meta tag
  [ ] Apple touch icon
  [ ] Maskable icon
  [ ] Theme color
```

```bash
# Run Lighthouse PWA audit
npx lighthouse https://example.com --only-categories=pwa --output=json --output-path=./pwa-audit.json

# Check service worker registration
# In browser DevTools: Application → Service Workers

# Validate manifest
npx pwa-asset-generator --help  # Generate icons from source image
```

### Step 2: Web App Manifest
Create or validate the web app manifest:

```json
// manifest.json (or manifest.webmanifest)
{
  "name": "Application Full Name",
  "short_name": "AppName",
  "description": "A brief description of the application.",
  "start_url": "/",
  "scope": "/",
  "display": "standalone",
  "orientation": "any",
  "theme_color": "#1a73e8",
  "background_color": "#ffffff",
  "categories": ["productivity", "utilities"],
  "icons": [
    {
      "src": "/icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    },
    {
      "src": "/icons/icon-maskable-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable"
    }
  ],
  "screenshots": [
    {
      "src": "/screenshots/desktop.png",
      "sizes": "1280x720",
      "type": "image/png",
      "form_factor": "wide",
      "label": "Desktop view of the application"
    },
    {
      "src": "/screenshots/mobile.png",
      "sizes": "750x1334",
      "type": "image/png",
      "form_factor": "narrow",
      "label": "Mobile view of the application"
    }
  ],
  "shortcuts": [
    {
      "name": "New Item",
      "short_name": "New",
      "url": "/new",
      "icons": [{ "src": "/icons/shortcut-new.png", "sizes": "96x96" }]
    }
  ],
  "share_target": {
    "action": "/share",
    "method": "POST",
    "enctype": "multipart/form-data",
    "params": {
      "title": "title",
      "text": "text",
      "url": "url",
      "files": [{ "name": "media", "accept": ["image/*", "video/*"] }]
    }
  }
}
```

```
MANIFEST VALIDATION:
┌──────────────────────────────────────────────────────────────────┐
│ Field           │ Value            │ Status │ Notes              │
├──────────────────────────────────────────────────────────────────┤
│ name            │ "App Name"       │ OK     │ < 45 chars         │
│ short_name      │ "App"            │ OK     │ < 12 chars         │
│ start_url       │ "/"              │ OK     │ Within scope       │
│ display         │ "standalone"     │ OK     │ standalone/minimal │
│ theme_color     │ "#1a73e8"        │ OK     │ Matches <meta>     │
│ background_color│ "#ffffff"        │ OK     │ Splash screen bg   │
│ icons (192)     │ present          │ OK     │ Required minimum   │
│ icons (512)     │ present          │ OK     │ Required minimum   │
│ maskable icon   │ present          │ OK     │ Adaptive icon      │
│ screenshots     │ present          │ OK     │ Richer install UI  │
│ scope           │ "/"              │ OK     │ Navigation scope   │
│ description     │ present          │ OK     │ Install UI text    │
└──────────────────────────────────────────────────────────────────┘
```

```html
<!-- Link manifest and meta tags in HTML <head> -->
<link rel="manifest" href="/manifest.json">
<meta name="theme-color" content="#1a73e8">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="default">
<meta name="apple-mobile-web-app-title" content="AppName">
<link rel="apple-touch-icon" href="/icons/apple-touch-icon-180.png">
```

```bash
# Generate all icon sizes from a single source image
npx pwa-asset-generator logo.svg ./public/icons --manifest ./public/manifest.json --index ./public/index.html

# Validate manifest
npx web-app-manifest-validator manifest.json
```

### Step 3: Service Worker Implementation
Build the service worker with appropriate caching strategies:

#### Registration
```javascript
// src/register-sw.js — Register service worker
if ('serviceWorker' in navigator) {
  window.addEventListener('load', async () => {
    try {
      const registration = await navigator.serviceWorker.register('/sw.js', {
        scope: '/',
      });
      console.log('SW registered:', registration.scope);

      // Check for updates periodically
      setInterval(() => registration.update(), 60 * 60 * 1000); // Every hour
    } catch (error) {
      console.error('SW registration failed:', error);
    }
  });
}
```

#### Service Worker with Workbox
```javascript
// sw.js — Service worker using Workbox
import { precacheAndRoute, cleanupOutdatedCaches } from 'workbox-precaching';
import { registerRoute } from 'workbox-routing';
import { CacheFirst, NetworkFirst, StaleWhileRevalidate } from 'workbox-strategies';
import { ExpirationPlugin } from 'workbox-expiration';
import { CacheableResponsePlugin } from 'workbox-cacheable-response';
import { BackgroundSyncPlugin } from 'workbox-background-sync';

// Precache static assets (injected by build tool)
precacheAndRoute(self.__WB_MANIFEST);
cleanupOutdatedCaches();

// HTML pages — Network First (fresh content, offline fallback)
registerRoute(
  ({ request }) => request.mode === 'navigate',
  new NetworkFirst({
    cacheName: 'pages',
    plugins: [
      new CacheableResponsePlugin({ statuses: [200] }),
      new ExpirationPlugin({ maxEntries: 50 }),
    ],
  })
);

// CSS and JS — Cache First (hashed filenames are immutable)
registerRoute(
  ({ request }) => request.destination === 'style' || request.destination === 'script',
  new CacheFirst({
    cacheName: 'static-resources',
    plugins: [
      new CacheableResponsePlugin({ statuses: [200] }),
      new ExpirationPlugin({ maxEntries: 60, maxAgeSeconds: 365 * 24 * 60 * 60 }),
    ],
  })
);

// Images — Cache First with size limit
registerRoute(
  ({ request }) => request.destination === 'image',
  new CacheFirst({
    cacheName: 'images',
    plugins: [
      new CacheableResponsePlugin({ statuses: [200] }),
      new ExpirationPlugin({ maxEntries: 100, maxAgeSeconds: 30 * 24 * 60 * 60 }),
    ],
  })
);

// Fonts — Cache First (never change)
registerRoute(
  ({ request }) => request.destination === 'font',
  new CacheFirst({
    cacheName: 'fonts',
    plugins: [
      new CacheableResponsePlugin({ statuses: [200] }),
      new ExpirationPlugin({ maxEntries: 10, maxAgeSeconds: 365 * 24 * 60 * 60 }),
    ],
  })
);

// API calls — Network First with offline fallback
registerRoute(
  ({ url }) => url.pathname.startsWith('/api/'),
  new NetworkFirst({
    cacheName: 'api-responses',
    networkTimeoutSeconds: 3,
    plugins: [
      new CacheableResponsePlugin({ statuses: [200] }),
      new ExpirationPlugin({ maxEntries: 50, maxAgeSeconds: 5 * 60 }),
    ],
  })
);

// Offline fallback page
const OFFLINE_PAGE = '/offline.html';
self.addEventListener('install', (event) => {
  event.waitUntil(caches.open('offline').then((cache) => cache.add(OFFLINE_PAGE)));
});

self.addEventListener('fetch', (event) => {
  if (event.request.mode === 'navigate') {
    event.respondWith(
      fetch(event.request).catch(() => caches.match(OFFLINE_PAGE))
    );
  }
});
```

#### Vanilla Service Worker (No Workbox)
```javascript
// sw.js — Vanilla service worker
const CACHE_NAME = 'app-v1';
const PRECACHE_URLS = [
  '/',
  '/offline.html',
  '/styles/main.css',
  '/scripts/main.js',
  '/icons/icon-192.png',
];

// Install — precache essential resources
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(PRECACHE_URLS))
      .then(() => self.skipWaiting())
  );
});

// Activate — clean up old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(
        keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))
      ))
      .then(() => self.clients.claim())
  );
});

// Fetch — network first for navigation, cache first for assets
self.addEventListener('fetch', (event) => {
  const { request } = event;

  if (request.mode === 'navigate') {
    // Network first for HTML
    event.respondWith(
      fetch(request)
        .then((response) => {
          const clone = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(request, clone));
          return response;
        })
        .catch(() => caches.match(request).then((r) => r || caches.match('/offline.html')))
    );
  } else {
    // Cache first for assets
    event.respondWith(
      caches.match(request).then((cached) => cached || fetch(request))
    );
  }
});
```

### Step 4: Offline-First Architecture
Design the application to work offline by default:

```
OFFLINE CAPABILITY MATRIX:
┌──────────────────────────────────────────────────────────────────┐
│ Feature          │ Offline Behavior         │ Sync Strategy      │
├──────────────────────────────────────────────────────────────────┤
│ View content     │ Serve from cache         │ N/A (read-only)    │
│ Create items     │ Save to IndexedDB        │ Background sync    │
│ Edit items       │ Save to IndexedDB        │ Background sync    │
│ Delete items     │ Mark deleted in IndexedDB│ Background sync    │
│ Search           │ Search IndexedDB         │ Refresh on connect │
│ User profile     │ Cached in SW             │ Stale while rev.   │
│ Notifications    │ Queue in IndexedDB       │ Push when online   │
│ File upload      │ Queue in IndexedDB       │ Background sync    │
│ Authentication   │ Cached token             │ Refresh on connect │
└──────────────────────────────────────────────────────────────────┘
```

#### IndexedDB for Offline Data
```javascript
// Offline data store using IndexedDB (via idb library)
import { openDB } from 'idb';

const db = await openDB('app-store', 1, {
  upgrade(db) {
    // Create object stores
    const itemStore = db.createObjectStore('items', { keyPath: 'id' });
    itemStore.createIndex('updatedAt', 'updatedAt');

    // Sync queue for offline mutations
    db.createObjectStore('sync-queue', { keyPath: 'id', autoIncrement: true });
  },
});

// Save item (works offline)
async function saveItem(item) {
  item.updatedAt = Date.now();
  item.synced = false;
  await db.put('items', item);

  // Queue for background sync
  await db.add('sync-queue', {
    type: 'PUT',
    url: `/api/items/${item.id}`,
    body: JSON.stringify(item),
    timestamp: Date.now(),
  });

  // Request background sync if available
  if ('serviceWorker' in navigator && 'SyncManager' in window) {
    const registration = await navigator.serviceWorker.ready;
    await registration.sync.register('sync-items');
  }
}

// Load items (offline-first)
async function getItems() {
  try {
    // Try network first
    const response = await fetch('/api/items');
    const items = await response.json();
    // Update local store
    const tx = db.transaction('items', 'readwrite');
    await Promise.all(items.map((item) => tx.store.put({ ...item, synced: true })));
    await tx.done;
    return items;
  } catch {
    // Fall back to IndexedDB
    return db.getAll('items');
  }
}
```

#### Offline Fallback Page
```html
<!-- offline.html — Shown when network is unavailable and page is not cached -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Offline — AppName</title>
  <style>
    body { font-family: system-ui, sans-serif; text-align: center; padding: 4rem 2rem; }
    h1 { font-size: 1.5rem; margin-bottom: 1rem; }
    p { color: #666; margin-bottom: 2rem; }
    button { padding: 0.75rem 2rem; background: #1a73e8; color: #fff;
             border: none; border-radius: 4px; cursor: pointer; font-size: 1rem; }
  </style>
</head>
<body>
  <h1>You are offline</h1>
  <p>Check your internet connection and try again.</p>
  <button onclick="window.location.reload()">Retry</button>
</body>
</html>
```

### Step 5: Push Notifications
Set up web push notifications:

```
PUSH NOTIFICATION ARCHITECTURE:
┌─────────────┐     ┌──────────────┐     ┌────────────────┐
│   Browser    │────>│  Push Service │────>│  Service Worker│
│  (subscribe) │     │  (FCM/APNs)  │     │  (receive)     │
└─────────────┘     └──────────────┘     └────────────────┘
       │                                          │
       │         ┌──────────────┐                 │
       └────────>│  App Server   │<───────────────┘
                 │  (send push)  │
                 └──────────────┘
```

#### Client-Side Subscription
```javascript
// Subscribe to push notifications
async function subscribeToPush() {
  const registration = await navigator.serviceWorker.ready;

  // Check permission
  const permission = await Notification.requestPermission();
  if (permission !== 'granted') {
    console.log('Push permission denied');
    return null;
  }

  // Subscribe with VAPID key
  const subscription = await registration.pushManager.subscribe({
    userVisibleOnly: true,
    applicationServerKey: urlBase64ToUint8Array(VAPID_PUBLIC_KEY),
  });

  // Send subscription to server
  await fetch('/api/push/subscribe', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(subscription),
  });

  return subscription;
}

// Helper: Convert VAPID key
function urlBase64ToUint8Array(base64String) {
  const padding = '='.repeat((4 - base64String.length % 4) % 4);
  const base64 = (base64String + padding).replace(/-/g, '+').replace(/_/g, '/');
  const rawData = window.atob(base64);
  return Uint8Array.from([...rawData].map((char) => char.charCodeAt(0)));
}
```

#### Service Worker Push Handler
```javascript
// In sw.js — Handle push events
self.addEventListener('push', (event) => {
  const data = event.data?.json() ?? {};

  const options = {
    body: data.body || 'New notification',
    icon: '/icons/icon-192.png',
    badge: '/icons/badge-72.png',
    image: data.image,
    tag: data.tag || 'default',
    renotify: Boolean(data.tag),
    data: { url: data.url || '/' },
    actions: data.actions || [
      { action: 'open', title: 'Open' },
      { action: 'dismiss', title: 'Dismiss' },
    ],
    vibrate: [200, 100, 200],
  };

  event.waitUntil(
    self.registration.showNotification(data.title || 'App Notification', options)
  );
});

// Handle notification click
self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  if (event.action === 'dismiss') return;

  const url = event.notification.data?.url || '/';
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true })
      .then((windowClients) => {
        // Focus existing window or open new one
        const existingClient = windowClients.find((c) => c.url === url);
        if (existingClient) return existingClient.focus();
        return clients.openWindow(url);
      })
  );
});
```

#### Server-Side Push (Node.js)
```javascript
// server/push.js — Send push notifications
import webpush from 'web-push';

webpush.setVapidDetails(
  'mailto:admin@example.com',
  process.env.VAPID_PUBLIC_KEY,
  process.env.VAPID_PRIVATE_KEY
);

async function sendPushNotification(subscription, payload) {
  try {
    await webpush.sendNotification(
      subscription,
      JSON.stringify({
        title: payload.title,
        body: payload.body,
        url: payload.url,
        tag: payload.tag,
        image: payload.image,
      })
    );
  } catch (error) {
    if (error.statusCode === 410 || error.statusCode === 404) {
      // Subscription expired — remove from database
      await removeSubscription(subscription.endpoint);
    }
    throw error;
  }
}

// Generate VAPID keys (run once)
// npx web-push generate-vapid-keys
```

### Step 6: Background Sync
Implement background sync for offline mutations:

```javascript
// In sw.js — Background sync handler
import { BackgroundSyncPlugin } from 'workbox-background-sync';
import { registerRoute } from 'workbox-routing';
import { NetworkOnly } from 'workbox-strategies';

// Queue failed API mutations for retry
const bgSyncPlugin = new BackgroundSyncPlugin('mutation-queue', {
  maxRetentionTime: 24 * 60, // Retry for up to 24 hours (in minutes)
  onSync: async ({ queue }) => {
    let entry;
    while ((entry = await queue.shiftRequest())) {
      try {
        await fetch(entry.request.clone());
      } catch (error) {
        // Put the entry back in the queue and re-throw
        await queue.unshiftRequest(entry);
        throw error;
      }
    }
  },
});

// Apply to mutation routes (POST, PUT, DELETE)
registerRoute(
  ({ url, request }) =>
    url.pathname.startsWith('/api/') &&
    ['POST', 'PUT', 'DELETE'].includes(request.method),
  new NetworkOnly({ plugins: [bgSyncPlugin] }),
  'POST'
);

// Periodic background sync (check for updates)
self.addEventListener('periodicsync', (event) => {
  if (event.tag === 'content-sync') {
    event.waitUntil(syncContent());
  }
});

async function syncContent() {
  const response = await fetch('/api/sync/changes?since=' + getLastSyncTime());
  const changes = await response.json();
  // Update IndexedDB with server changes
  const db = await openDB('app-store', 1);
  const tx = db.transaction('items', 'readwrite');
  await Promise.all(changes.map((item) => tx.store.put({ ...item, synced: true })));
  await tx.done;
  setLastSyncTime(Date.now());
}
```

#### Register Periodic Sync
```javascript
// Register periodic background sync (client-side)
async function registerPeriodicSync() {
  const registration = await navigator.serviceWorker.ready;

  // Check if periodic sync is supported
  if ('periodicSync' in registration) {
    const status = await navigator.permissions.query({ name: 'periodic-background-sync' });
    if (status.state === 'granted') {
      await registration.periodicSync.register('content-sync', {
        minInterval: 12 * 60 * 60 * 1000, // Minimum 12 hours
      });
    }
  }
}
```

### Step 7: Installability & Install Prompt
Handle the PWA install experience:

```javascript
// Install prompt handling
let deferredPrompt = null;

window.addEventListener('beforeinstallprompt', (event) => {
  // Prevent automatic prompt
  event.preventDefault();
  deferredPrompt = event;

  // Show custom install UI
  showInstallButton();
});

async function handleInstallClick() {
  if (!deferredPrompt) return;

  // Show the browser install prompt
  deferredPrompt.prompt();
  const result = await deferredPrompt.userChoice;

  if (result.outcome === 'accepted') {
    console.log('PWA installed');
    trackEvent('pwa_installed');
  } else {
    console.log('PWA install dismissed');
    trackEvent('pwa_install_dismissed');
  }

  deferredPrompt = null;
  hideInstallButton();
}

// Detect if already installed
window.addEventListener('appinstalled', () => {
  deferredPrompt = null;
  hideInstallButton();
  trackEvent('pwa_installed');
});

// Detect standalone mode (already installed and running)
function isStandalone() {
  return window.matchMedia('(display-mode: standalone)').matches ||
         window.navigator.standalone === true;
}
```

```
INSTALLABILITY CHECKLIST:
┌──────────────────────────────────────────────────────────────────┐
│ Requirement                    │ Status │ Notes                  │
├──────────────────────────────────────────────────────────────────┤
│ HTTPS (or localhost)           │ OK     │ Required               │
│ Web app manifest               │ OK     │ Linked in <head>       │
│ manifest: name or short_name   │ OK     │ "AppName"              │
│ manifest: start_url            │ OK     │ "/"                    │
│ manifest: display              │ OK     │ "standalone"           │
│ manifest: icons (192px)        │ OK     │ PNG format             │
│ manifest: icons (512px)        │ OK     │ PNG format             │
│ Service worker with fetch      │ OK     │ Registered at /sw.js   │
│ No beforeinstallprompt block   │ OK     │ Custom UI shown        │
│ Engagement heuristic           │ OK     │ User visited 2+ times  │
└──────────────────────────────────────────────────────────────────┘

Install prompt strategy:
  - Do NOT show install prompt on first visit
  - Show after user demonstrates engagement (3+ page views, 2+ visits)
  - Show contextually (e.g., after completing a task, saving content)
  - Provide dismiss option and do not show again for 30 days
  - Track install rate: prompts shown / installs completed
```

### Step 8: PWA Testing & Validation

```bash
# Lighthouse PWA audit
npx lighthouse https://example.com --only-categories=pwa --output=json

# Test offline behavior
# Chrome DevTools → Application → Service Workers → Offline checkbox
# Then navigate the app and verify behavior

# Test install prompt
# Chrome DevTools → Application → Manifest → check for install warnings

# Validate manifest
# Chrome DevTools → Application → Manifest → verify all fields

# Test push notifications
# Chrome DevTools → Application → Service Workers → Push button

# Test background sync
# Chrome DevTools → Application → Service Workers → Sync button
```

```
PWA TESTING MATRIX:
┌──────────────────────────────────────────────────────────────────┐
│ Test                    │ Chrome │ Safari │ Firefox │ Edge        │
├──────────────────────────────────────────────────────────────────┤
│ Service worker          │ OK     │ OK     │ OK      │ OK          │
│ Manifest + install      │ OK     │ OK*    │ OK      │ OK          │
│ Offline navigation      │ OK     │ OK     │ OK      │ OK          │
│ Push notifications      │ OK     │ OK**   │ OK      │ OK          │
│ Background sync         │ OK     │ N/A    │ N/A     │ OK          │
│ Periodic sync           │ OK     │ N/A    │ N/A     │ OK          │
│ Cache storage           │ OK     │ OK     │ OK      │ OK          │
│ IndexedDB               │ OK     │ OK     │ OK      │ OK          │
│ Share Target             │ OK     │ N/A    │ N/A     │ OK          │
└──────────────────────────────────────────────────────────────────┘
* Safari has its own PWA install flow (Add to Home Screen)
** Safari push requires Web Push API (supported since Safari 16.4)
```

### Step 9: PWA Report

```
+------------------------------------------------------------+
|  PWA AUDIT — <target>                                       |
+------------------------------------------------------------+
|  Installability:                                            |
|  Manifest: <valid/invalid/missing>                          |
|  Service worker: <registered/not registered>                |
|  HTTPS: <yes/no>                                            |
|  Icons: <complete/incomplete>                               |
|  Installable: <YES/NO>                                      |
|                                                             |
|  Offline Support:                                           |
|  Offline fallback page: <yes/no>                            |
|  Cached pages: <N> pages available offline                  |
|  Cached assets: <N> static assets precached                 |
|  API offline: <IndexedDB fallback/queue/none>               |
|  Background sync: <configured/not configured>               |
|                                                             |
|  Caching:                                                   |
|  Precache: <N> assets (<size>)                              |
|  Runtime cache: <N> strategies configured                   |
|  Cache storage used: <size>                                 |
|                                                             |
|  Push Notifications:                                        |
|  VAPID keys: <configured/not configured>                    |
|  Subscription flow: <implemented/not implemented>           |
|  Push handler: <implemented/not implemented>                |
|  Notification click: <handled/not handled>                  |
|                                                             |
|  Lighthouse PWA Score:                                      |
|  Installable: <PASS/FAIL>                                   |
|  PWA Optimized: <PASS/FAIL>                                 |
|                                                             |
|  Browser Compatibility:                                     |
|  Chrome/Edge: <full support>                                |
|  Safari: <partial — no background sync/periodic sync>       |
|  Firefox: <partial — no background sync>                    |
|                                                             |
|  Verdict: <READY | PARTIAL | NOT READY>                    |
+------------------------------------------------------------+
|  Remaining work:                                            |
|  1. <missing feature or fix>                                |
|  2. <missing feature or fix>                                |
+------------------------------------------------------------+
```

Verdicts:
- **READY**: Lighthouse PWA passes all checks, offline fallback works, installable, push configured.
- **PARTIAL**: Installable and offline fallback work, but missing push/sync or browser-specific issues.
- **NOT READY**: Missing core requirements (no manifest, no service worker, no HTTPS, no offline support).

### Step 10: Commit and Transition
1. Save report as `docs/pwa/<target>-pwa-report.md`
2. Commit service worker and manifest: `"pwa: <target> — service worker, manifest, offline support"`
3. Commit push notifications: `"pwa: <target> — push notification setup"`
4. Commit report: `"pwa: <target> — <verdict> (<features implemented>)"`
5. If NOT READY: "Core PWA requirements missing. Fix the remaining items, then re-audit with `/godmode:pwa`."
6. If READY: "PWA implementation complete. Ready for `/godmode:webperf` or `/godmode:ship`."

## Key Behaviors

1. **Service worker is the foundation.** Without a service worker, there is no PWA. It enables offline support, push notifications, background sync, and installability. Build the service worker first.
2. **Offline is not optional.** A PWA that breaks without a network connection is not a PWA. At minimum, serve a branded offline page. Ideally, cache the full app shell and critical data.
3. **Cache with intention.** Every caching strategy is a trade-off between freshness and speed. Network First for HTML (fresh), Cache First for hashed assets (fast), Stale While Revalidate for API data (balanced).
4. **Test on real devices.** Service workers, install prompts, and push notifications behave differently across browsers and platforms. Test on Chrome, Safari (iOS and macOS), Firefox, and Edge.
5. **Push notifications need permission.** Never request notification permission on page load. Ask after the user has engaged with the app and understands the value of notifications. A premature prompt gets denied permanently.
6. **Background sync is not universally supported.** Safari and Firefox do not support the Background Sync API. Implement a fallback that syncs when the app is opened.
7. **Update service workers carefully.** A broken service worker update can take down the entire app. Use skipWaiting cautiously, version your caches, and always clean up old caches on activation.

## Example Usage

### Full PWA implementation
```
User: /godmode:pwa

PWA: Assessing readiness...

PWA READINESS:
Target: https://example.com (React SPA)
HTTPS: Yes
Service worker: Not registered
Manifest: Missing
Offline: None

Implementing PWA features:
  1. Generated manifest.json with icons (192, 512, maskable)
  2. Created service worker with Workbox caching strategies
  3. Added offline fallback page
  4. Configured precaching for app shell (12 assets, 180 KB)
  5. Set up runtime caching for API and images
  6. Added install prompt handling

Lighthouse PWA: All checks passing
Installable: Yes
Offline: App shell cached, fallback page for uncached routes

Verdict: READY
Next: /godmode:webperf for performance optimization
```

### Add push notifications to existing PWA
```
User: /godmode:pwa --push

PWA: Existing service worker detected. Adding push notifications...

  1. Generated VAPID keys (store in environment variables)
  2. Created subscription flow with permission handling
  3. Added push event handler to service worker
  4. Created notification click handler with deep linking
  5. Added server-side push endpoint (Node.js + web-push)

Push notifications ready. Test with:
  DevTools → Application → Service Workers → Push
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full PWA implementation (manifest, SW, offline, install) |
| `--manifest` | Generate or validate web app manifest only |
| `--sw` | Service worker implementation only |
| `--offline` | Offline-first architecture with IndexedDB |
| `--push` | Push notification setup only |
| `--sync` | Background sync implementation only |
| `--audit` | PWA audit only (no implementation) |
| `--workbox` | Use Workbox for service worker (default) |
| `--vanilla` | Use vanilla service worker (no Workbox) |
| `--icons <source>` | Generate icon set from source image |
| `--ci` | CI-friendly output (exit code 1 on failure) |

## Anti-Patterns

- **Do NOT register a service worker that does nothing.** An empty service worker provides no value and adds complexity. Every service worker should at minimum cache the app shell and provide an offline fallback.
- **Do NOT cache everything.** Unlimited caching fills device storage and causes eviction. Set maxEntries and maxAgeSeconds on every cache. Be strategic about what deserves cache space.
- **Do NOT request notification permission on page load.** Users who have not engaged with the app will deny the prompt. A denied permission is permanent. Ask contextually after demonstrating value.
- **Do NOT ignore service worker updates.** Users can get stuck on old versions if the update flow is broken. Implement proper update detection, notify users, and handle the skipWaiting/claim lifecycle.
- **Do NOT use the Cache API for user data.** The Cache API is for HTTP responses. Use IndexedDB for structured application data. Mixing them creates confusion and data loss risks.
- **Do NOT assume background sync is available.** Check for SyncManager support before registering. Implement a fallback that syncs when the app is reopened or network status changes.
- **Do NOT skip the offline fallback page.** When a user navigates to an uncached page without network, they see the browser's default offline error. A branded offline page with retry is vastly better.
- **Do NOT serve stale HTML indefinitely.** Use Network First for HTML pages so users get fresh content when online. Cache First for HTML means users might never see updates unless they clear their cache.

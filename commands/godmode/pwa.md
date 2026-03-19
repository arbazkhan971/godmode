# /godmode:pwa

Progressive Web App development covering service worker implementation, offline-first architecture, web app manifest configuration, push notification setup, background sync, and installability requirements. Builds production-grade PWAs with Workbox caching strategies and cross-browser compatibility.

## Usage

```
/godmode:pwa                              # Full PWA implementation (manifest, SW, offline, install)
/godmode:pwa --manifest                   # Generate or validate web app manifest
/godmode:pwa --sw                         # Service worker implementation only
/godmode:pwa --offline                    # Offline-first architecture with IndexedDB
/godmode:pwa --push                       # Push notification setup
/godmode:pwa --sync                       # Background sync implementation
/godmode:pwa --audit                      # PWA audit only (no implementation)
/godmode:pwa --workbox                    # Use Workbox for service worker (default)
/godmode:pwa --vanilla                    # Use vanilla service worker (no Workbox)
/godmode:pwa --icons logo.svg             # Generate icon set from source image
/godmode:pwa --ci                         # CI-friendly output (exit code 1 on failure)
```

## What It Does

1. Assesses PWA readiness (HTTPS, existing SW, manifest, responsive design)
2. Creates web app manifest with icons, screenshots, shortcuts, and share target
3. Implements service worker with caching strategies:
   - **Precaching** for app shell (HTML, CSS, JS, icons)
   - **Network First** for HTML pages (fresh content, offline fallback)
   - **Cache First** for hashed assets (immutable, fast)
   - **Stale While Revalidate** for API data (balanced)
4. Builds offline-first architecture:
   - IndexedDB for offline data storage
   - Offline fallback page for uncached routes
   - Sync queue for offline mutations
5. Sets up push notifications (VAPID keys, subscription, handler, click actions)
6. Implements background sync for offline mutations with retry
7. Handles install prompt with engagement-based timing
8. Tests across Chrome, Safari, Firefox, and Edge

## Output
- PWA report at `docs/pwa/<target>-pwa-report.md`
- SW + manifest commit: `"pwa: <target> — service worker, manifest, offline support"`
- Push commit: `"pwa: <target> — push notification setup"`
- Report commit: `"pwa: <target> — <verdict> (<features implemented>)"`
- Verdict: READY / PARTIAL / NOT READY

## Next Step
If NOT READY: Fix core requirements, then re-audit with `/godmode:pwa`.
If READY: `/godmode:webperf` for performance, or `/godmode:ship` to deploy.

## Examples

```
/godmode:pwa                              # Full PWA implementation
/godmode:pwa --push                       # Add push notifications to existing PWA
/godmode:pwa --offline                    # Build offline-first data layer
/godmode:pwa --audit                      # Check current PWA status
```

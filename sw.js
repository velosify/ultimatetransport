/* Minimal service worker.
 *
 * It exists for two reasons: some Chrome versions will not offer an install
 * prompt without one that handles fetch, and it lets the page open from the
 * home screen when the phone has no signal, which for this audience is the
 * difference between finding the number and not.
 *
 * Strategy is network-first: the network answer always wins, and the cache is
 * only a fallback. Nothing here ever serves a stale page while online. */

const CACHE = "ultimate-transport-v1";
const SHELL = [
  "/",
  "/assets/icon.svg?v=2",
  "/assets/icon-192.png?v=2"
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE).then((c) => c.addAll(SHELL)).then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (event) => {
  const req = event.request;

  // Only ever touch our own GET requests. tel: and sms: links, and anything
  // cross-origin such as the fonts, pass straight through untouched.
  if (req.method !== "GET") return;
  if (new URL(req.url).origin !== self.location.origin) return;

  event.respondWith(
    fetch(req)
      .then((res) => {
        const copy = res.clone();
        caches.open(CACHE).then((c) => c.put(req, copy)).catch(() => {});
        return res;
      })
      .catch(() =>
        caches.match(req).then((hit) => hit || caches.match("/"))
      )
  );
});

# Ultimate Transport — landing page

One-page site for **Ultimate Transport**, Billy O's wheelchair transportation
service in St. Paul, Minnesota.

Static HTML. No build step, no framework, no dependencies. `index.html` is the
whole site — open it in a browser and it works.

---

## What's in here

```
index.html          the site (self-contained: CSS and JS inline)
404.html            not-found page, keeps the phone number in front of people
robots.txt          crawler rules + sitemap pointer
sitemap.xml         one URL, for Google Search Console
site.webmanifest    icon set for "add to home screen"
_headers            Cloudflare Pages security + cache headers
set-domain.sh       swaps the placeholder domain everywhere at once
assets/
  icon.svg              favicon (scalable)
  favicon-32.png        favicon fallback
  apple-touch-icon.png  180×180, iOS home screen
  icon-512.png          512×512, Android / manifest
  og-image.png          1200×630 link preview card
  og-card.html          source for og-image.png — edit + re-screenshot to change it
```

The only external request the page makes is to **Google Fonts** for Archivo and
Source Sans 3. Everything else ships with the page.

---

## Deploy to Cloudflare Pages

### 1. Push to GitHub

The repo is **velosify/ultimatetransport**. From inside the unzipped folder:

```bash
cd ultimate-transport
git init
git add .
git commit -m "Ultimate Transport landing page"
git branch -M main
git remote add origin https://github.com/velosify/ultimatetransport.git
git push -u origin main
```

If you'd rather not use the command line: on the empty repo page, click
**uploading an existing file**, then drag the *contents* of the unzipped folder
onto the page — the files themselves, not the folder. Commit at the bottom.

### 2. Connect it in Cloudflare

1. Cloudflare dashboard → **Workers & Pages** → **Create** → **Pages** →
   **Connect to Git**
2. Authorize GitHub, pick the `ultimatetransport` repo
3. Build settings — **leave everything empty**:
   - Framework preset: **None**
   - Build command: *(blank)*
   - Build output directory: `/`
4. **Save and Deploy**

You get a live URL in about thirty seconds — `ultimatetransport.pages.dev`,
which is what the page's canonical URL is already set to. Every push to `main`
redeploys automatically.

### 3. Point it at a real domain

The page currently uses `https://ultimatetransport.pages.dev` as its canonical
URL — that's a placeholder. Once you have the real domain:

1. In Cloudflare Pages → your project → **Custom domains** → **Set up a domain**
2. Then rewrite the URLs in the repo:

```bash
./set-domain.sh ultimatetransportmn.com
git commit -am "Point at production domain"
git push
```

That updates `index.html` (canonical, Open Graph, Twitter card, and the
structured-data block), `robots.txt`, and `sitemap.xml` in one shot.

### 4. Tell Google it exists

- [Google Search Console](https://search.google.com/search-console) → add the
  property → submit `https://yourdomain.com/sitemap.xml`
- [Google Business Profile](https://business.google.com) — **this matters more
  than the website for a local service business.** A verified profile with the
  phone number, service area, and hours is what puts Ultimate Transport in the
  map results when someone searches "wheelchair transportation St. Paul."

---

## How the request form works

There's no server and no database. The form fields are assembled into a
plain-text ride request, and the **Text this request** button opens the
visitor's own messaging app with that text pre-filled, addressed to
651-274-1881. They still press send themselves.

For desktop visitors without texting set up, **Copy the details** puts the same
text on their clipboard to paste into an email or read over the phone.

This means:

- nothing to maintain, nothing to break, no monthly cost
- no inbox to check — requests land as text messages on the scheduling line
- no personal information passes through any third party

If you later want a form that emails Billy instead, that needs a Cloudflare
Pages Function plus an email service (Resend, Postmark, or similar). It's about
thirty lines of code and one API key.

---

## Editing the page

Everything is in `index.html`. The pieces you'll most likely touch:

| What | Where to look |
|---|---|
| Phone numbers | search for `651` — appears in `tel:` links, the visible text, the SMS link, the JSON-LD block, and `404.html` |
| Trip types | the `<ul class="trips">` list |
| Service area towns | the `<ul class="towns">` list, and `areaServed` in the JSON-LD block |
| Colors | the CSS custom properties in `:root` (light) and the two dark-theme blocks |
| Link preview card | edit `assets/og-card.html`, screenshot it at 1200×630, save over `assets/og-image.png` |

**When you change a phone number, change it everywhere** — there are several
copies on purpose (a visible one, a tappable `tel:` one, and one in the
structured data that Google reads).

The page is designed for light and dark themes. If you change a color, change
it in all three `:root` blocks or one theme will break.

---

## Still to confirm with Billy

The page deliberately makes **no claims** about hours, rates, insurance,
Medicaid or MA billing, licensing, vehicle count, or years in business —
because those weren't verified. Add them only when they're confirmed true.

Open items:

1. Hours and days of operation
2. Rates, and whether to publish them
3. Payment methods accepted
4. Insurance / Medicaid / waiver billing
5. Licensing and credentials
6. How much advance notice a booking really needs
7. Whether the town list matches where Billy actually drives
8. Whether the named St. Paul hospitals and clinics are places he actually serves
9. An email address, if he wants one on the page
10. **A real photo of the van** — the single highest-value addition to this page

---

## A note on the public repo

This repository is public, which is fine — everything in it is meant to be seen
by visitors anyway. Just don't add anything here that shouldn't be: no API keys,
no customer information, no ride records. If the form is ever wired up to send
email, the API key goes in Cloudflare's environment variables, never in a file.

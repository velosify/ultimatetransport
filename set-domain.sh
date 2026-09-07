#!/usr/bin/env bash
# Point the whole site at a new domain.
#
#   ./set-domain.sh ultimatetransportmn.com
#   ./set-domain.sh https://ultimatetransportmn.com
#
# Rewrites the absolute URLs in index.html, robots.txt and sitemap.xml.
# Run it once after you buy a domain and attach it in Cloudflare Pages,
# then commit the result.

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "usage: $0 <domain-or-url>" >&2
  echo "example: $0 ultimatetransportmn.com" >&2
  exit 1
fi

RAW="$1"
NEW="${RAW#http://}"
NEW="${NEW#https://}"
NEW="${NEW%/}"
NEW="https://${NEW}"

OLD_PATTERN='https://[a-zA-Z0-9.-]*\.pages\.dev'
CURRENT="$(grep -o "$OLD_PATTERN" index.html | head -1 || true)"

if [ -z "$CURRENT" ]; then
  echo "No *.pages.dev URL found in index.html." >&2
  echo "The domain may already be set. Current canonical:" >&2
  grep -o 'rel="canonical" href="[^"]*"' index.html >&2 || true
  exit 1
fi

echo "Rewriting $CURRENT  ->  $NEW"

for f in index.html privacy.html terms.html accessibility.html robots.txt sitemap.xml; do
  if [ -f "$f" ]; then
    # macOS and GNU sed both accept this form.
    sed -i.bak "s#${CURRENT}#${NEW}#g" "$f"
    rm -f "$f.bak"
    echo "  updated $f"
  fi
done

# Refresh the sitemap's lastmod to today.
TODAY="$(date +%Y-%m-%d)"
sed -i.bak "s#<lastmod>.*</lastmod>#<lastmod>${TODAY}</lastmod>#" sitemap.xml
rm -f sitemap.xml.bak
echo "  sitemap lastmod set to ${TODAY}"

echo
echo "Done. Review with:  git diff"

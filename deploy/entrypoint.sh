#!/bin/sh
set -eu
export BTV_SUPABASE_URL="${BTV_SUPABASE_URL:-}" BTV_SUPABASE_ANON_KEY="${BTV_SUPABASE_ANON_KEY:-}"
envsubst '${BTV_SUPABASE_URL} ${BTV_SUPABASE_ANON_KEY}' < /usr/share/nginx/html/deploy/config.template.js > /usr/share/nginx/html/config.js

# Public origin for server-rendered social metadata. Coolify normally provides COOLIFY_URL.
origin="${BTV_PUBLIC_URL:-${COOLIFY_URL:-}}"
origin="${origin%%,*}"
origin="${origin%/}"
case "$origin" in
  https://*|http://*) ;;
  *) origin="" ;;
esac
if [ -n "$origin" ] && printf '%s' "$origin" | grep -Eq '^https?://[A-Za-z0-9.-]+(:[0-9]+)?$'; then
  for page in /usr/share/nginx/html/index.html /usr/share/nginx/html/directo/index.html; do
    sed -i "s|__BTV_PUBLIC_ORIGIN__|$origin|g" "$page"
  done
else
  echo "BTV_PUBLIC_URL is not set to a valid public origin; social previews require configuration." >&2
  for page in /usr/share/nginx/html/index.html /usr/share/nginx/html/directo/index.html; do
    sed -i 's|__BTV_PUBLIC_ORIGIN__||g' "$page"
  done
fi

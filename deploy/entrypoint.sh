#!/bin/sh
set -eu
export BTV_SUPABASE_URL BTV_SUPABASE_ANON_KEY
envsubst '${BTV_SUPABASE_URL} ${BTV_SUPABASE_ANON_KEY}' < /usr/share/nginx/html/deploy/config.template.js > /usr/share/nginx/html/config.js

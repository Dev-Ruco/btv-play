FROM alpine:3.22 AS icons
RUN apk add --no-cache imagemagick
COPY assets/images/logo-btv.png /tmp/logo.png
RUN mkdir -p /icons && for n in 32 180 192 512; do magick /tmp/logo.png -trim +repage -resize "$((n*78/100))x$((n*78/100))" -background "#6b318f" -gravity center -extent "${n}x${n}" "/icons/icon-${n}.png"; done && cp /icons/icon-32.png /icons/favicon-32.png && cp /icons/icon-180.png /icons/apple-touch-icon.png && magick /tmp/logo.png -trim +repage -resize 280x280 -background "#6b318f" -gravity center -extent 512x512 /icons/maskable-512.png
COPY ["assets/images/Setion Hero desktop.jpg", "/tmp/hero.jpg"]
RUN magick /tmp/hero.jpg -resize "1200x630^" -gravity center -extent 1200x630 -strip -quality 88 /icons/btv-social.jpg
FROM nginx:1.27-alpine
RUN apk add --no-cache gettext
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY . /usr/share/nginx/html/
COPY --from=icons /icons/ /usr/share/nginx/html/assets/icons/
COPY --from=icons /icons/btv-social.jpg /usr/share/nginx/html/assets/images/btv-social.jpg
COPY deploy/entrypoint.sh /docker-entrypoint.d/50-config.sh
RUN chmod +x /docker-entrypoint.d/50-config.sh
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s CMD wget -q -O /dev/null http://127.0.0.1/health || exit 1

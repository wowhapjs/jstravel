FROM node:22-alpine AS unpack
WORKDIR /work
RUN apk add --no-cache patch
COPY payload2/ /payload2/
COPY payload3/ /payload3/
COPY payload4/ /payload4/
COPY payload6/part-000.b64 /payload6/part-000.b64
COPY payload6/part-001.b64 /payload6/part-001.b64
COPY tail-final/ /tail-final/
COPY mumbai-v12.patch.gz /mumbai-v12.patch.gz
COPY mumbai-v12-mapfix.patch.gz /mumbai-v12-mapfix.patch.gz
COPY apply-hampi-v13.js /apply-hampi-v13.js
RUN { \
      cat /payload2/part-000.b64; \
      cat /payload2/part-001.b64; \
      tail -c +8001 /payload3/part-000.b64; \
      cat /payload3/part-001.b64; \
      cat /payload4/part-000.b64; \
      cat /payload4/part-001.b64; \
      cat /payload4/part-002.b64; \
      cat /payload4/part-003.b64; \
      cat /payload6/part-000.b64; \
      cat /payload6/part-001.b64; \
      cat /tail-final/part-000.b64; \
      cat /tail-final/part-001.b64; \
      cat /tail-final/part-002.b64; \
      cat /tail-final/part-003.b64; \
      cat /tail-final/part-004.b64; \
      cat /tail-final/part-005.b64; \
      cat /tail-final/part-006.b64; \
    } | base64 -d > /tmp/site.zip \
 && echo 'b00aa4781c42537deb695a5200f581e2ecd6db60c9cf2f24c6cb8e62db358b39  /tmp/site.zip' | sha256sum -c - \
 && mkdir -p /tmp/site /out \
 && unzip -q /tmp/site.zip -d /tmp/site \
 && echo '0631eef222694276d5d4d96559b1da7e92ff8357ec332109f2fa82dca17f41af  /mumbai-v12.patch.gz' | sha256sum -c - \
 && gzip -dc /mumbai-v12.patch.gz | patch -d /tmp/site/india-night-transit-trip-planner-v7 -p0 --batch --forward \
 && echo '625c3e6a0f23a66f655ee0ae96b1f32d443570fb2ba8580513a5a1aa2634c1db  /mumbai-v12-mapfix.patch.gz' | sha256sum -c - \
 && gzip -dc /mumbai-v12-mapfix.patch.gz | patch -d /tmp/site/india-night-transit-trip-planner-v7 -p0 --batch --forward \
 && node /apply-hampi-v13.js /tmp/site/india-night-transit-trip-planner-v7/data.js \
 && node -e "global.window={};require('/tmp/site/india-night-transit-trip-planner-v7/data.js');const h=window.TRIP_DATA.cities.hampi;const ids=a=>a.map(x=>x.id);const names=a=>a.map(x=>String(x.name||'').trim().toLowerCase());const dup=a=>new Set(a).size!==a.length;if(window.TRIP_DATA.version!==13||h.attractions.length!==38||h.restaurants.length!==36||dup(ids(h.attractions))||dup(names(h.attractions))||dup(ids(h.restaurants))||dup(names(h.restaurants)))process.exit(1);" \
 && cp -a /tmp/site/india-night-transit-trip-planner-v7/. /out/ \
 && test -f /out/index.html

FROM nginx:alpine
COPY --from=unpack /out/ /usr/share/nginx/html/
EXPOSE 80

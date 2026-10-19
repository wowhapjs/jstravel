FROM alpine:3.22 AS unpack
WORKDIR /work
COPY payload/ /payload/
RUN cat /payload/part-*.b64 | base64 -d > /tmp/site.zip \
 && echo 'b00aa4781c42537deb695a5200f581e2ecd6db60c9cf2f24c6cb8e62db358b39  /tmp/site.zip' | sha256sum -c - \
 && mkdir -p /tmp/site /out \
 && unzip -q /tmp/site.zip -d /tmp/site \
 && cp -a /tmp/site/india-night-transit-trip-planner-v7/. /out/ \
 && test -f /out/index.html

FROM nginx:alpine
COPY --from=unpack /out/ /usr/share/nginx/html/
EXPOSE 80

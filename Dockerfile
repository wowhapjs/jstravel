FROM alpine:3.22 AS unpack
WORKDIR /work
COPY payload2/ /payload2/
COPY payload3/ /payload3/
COPY payload4/ /payload4/
COPY payload6/part-000.b64 /payload6/part-000.b64
COPY payload6/part-001.b64 /payload6/part-001.b64
COPY tail-final/ /tail-final/
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
 && cp -a /tmp/site/india-night-transit-trip-planner-v7/. /out/ \
 && test -f /out/index.html

FROM nginx:alpine
COPY --from=unpack /out/ /usr/share/nginx/html/
EXPOSE 80

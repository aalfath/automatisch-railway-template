# Automatisch on Railway: the official image, pinned by version and digest,
# plus a small start script. One image serves both services of the template:
# the web/API service, and the queue worker (WORKER=true).
FROM automatischio/automatisch:0.15.0@sha256:3bace7a12d5fb3f5b1305a6a52232270e0e0abd8465a8b78baacb07f6ea89594

# ioredis 5.4.1 defaults to IPv4 only (family: 4) and Automatisch has no
# setting for it. Railway's private network resolves to IPv6, so let ioredis
# use either family. The grep fails the build if upstream changes the file.
RUN sed -i 's/^  enableReadyCheck: true,$/  enableReadyCheck: true,\n  family: 0,/' \
      /automatisch/packages/backend/src/config/redis.js \
 && grep -q 'family: 0' /automatisch/packages/backend/src/config/redis.js

COPY railway-seed-admin.js /automatisch/packages/backend/railway-seed-admin.js
COPY railway-start.sh /railway-start.sh
RUN sh -n /railway-start.sh && node --check /automatisch/packages/backend/railway-seed-admin.js

ENV PORT=3000
EXPOSE 3000
WORKDIR /automatisch
ENTRYPOINT ["sh", "/railway-start.sh"]

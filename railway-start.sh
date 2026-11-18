#!/bin/sh
# Start script for both services of the Automatisch Railway template.
# WORKER=true runs the queue worker; otherwise it runs migrations, creates the
# first admin (only on an empty database) and starts the web/API server.
set -e
cd /automatisch/packages/backend

log() { echo "[railway] $*"; }

# Settings that never change on Railway. Each can still be overridden by a
# service variable of the same name.
export APP_ENV="${APP_ENV:-production}"
export PROTOCOL="${PROTOCOL:-https}"
export PORT="${PORT:-3000}"
export TELEMETRY_ENABLED="${TELEMETRY_ENABLED:-false}"
# Never seed upstream's fixed user@automatisch.io / sample admin.
export DISABLE_SEED_USER=true
if [ -z "$API_URL" ] && [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
  export API_URL="https://$RAILWAY_PUBLIC_DOMAIN"
fi

if [ "$WORKER" = "true" ]; then
  log "starting the queue worker"
  exec node --loader ./alias-loader.mjs src/worker.js
fi

# Railway starts services in any order, so wait for Postgres by retrying.
i=1
until node --loader ./alias-loader.mjs ./node_modules/.bin/knex migrate:latest; do
  if [ "$i" -ge 60 ]; then
    log "database migrations failed 60 times; giving up"
    exit 1
  fi
  log "migrations failed (attempt $i), retrying in 5 s"
  i=$((i + 1))
  sleep 5
done

# Create the first admin before the public port opens, so the
# installation form is never reachable by a stranger.
DISABLE_SEED_USER=false node --loader ./alias-loader.mjs ./railway-seed-admin.js

log "starting the web/API server on port $PORT"
exec node --loader ./alias-loader.mjs src/server.js

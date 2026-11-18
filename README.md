[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/automatisch-1?utm_medium=integration&utm_source=button&utm_campaign=automatisch)

# Automatisch on Railway

A one-click Railway template for [Automatisch](https://github.com/automatisch/automatisch), the open-source Zapier alternative. It deploys **Automatisch 0.15.0** from the official image `automatischio/automatisch:0.15.0`, pinned by digest (`sha256:3bace7a12d5fb3f5b1305a6a52232270e0e0abd8465a8b78baacb07f6ea89594`).

## What the template deploys

| Service | Source | Role |
|---|---|---|
| **Automatisch** | this repo (`Dockerfile`) | Web UI and API on a public Railway domain. Health check `/healthcheck` |
| **Automatisch Worker** | this repo, with `WORKER=true` | Runs flows, polling triggers and webhooks from the queue |
| **Postgres** | Railway Postgres, with a volume | Users, flows, connections (encrypted), execution history |
| **Redis** | Railway Redis, with a volume | BullMQ job queue |

Both app services run the same image, so they always stay on the same version.

## What this repo adds to the official image

- `railway-start.sh` runs the database migrations, with retries while Postgres starts. Then it creates the first admin from `ADMIN_EMAIL` and `ADMIN_PASSWORD`, and only after that starts the web server.
- Upstream's start script creates the published login `user@automatisch.io` / `sample` on every new database. This template never does. The admin is created only if the database has no users yet, so later deploys never touch your accounts.
- The installation form is closed before the public port opens, so nobody else can claim the instance.
- The ioredis client is switched from IPv4-only to "any family", because Railway's private network uses IPv6.
- Fixed settings are defaults in the start script: `APP_ENV=production`, `PROTOCOL=https`, `TELEMETRY_ENABLED=false`, and `API_URL` from the Railway domain. Each one can be overridden with a service variable of the same name.

## Variables

| Variable | Service | Default |
|---|---|---|
| `ADMIN_EMAIL` | Automatisch | **asked at deploy**: the email you sign in with |
| `ADMIN_PASSWORD` | Automatisch | generated, 24 characters. Read it in the service's Variables tab. Change it in the app after the first sign-in |
| `APP_SECRET_KEY`, `ENCRYPTION_KEY`, `WEBHOOK_SECRET_KEY` | Automatisch (the worker references them) | generated, 48 characters. **Never change `ENCRYPTION_KEY`** after you add connections: it encrypts their stored credentials |
| `API_URL` | both | `https://` plus the Railway domain. Set it to `https://YOUR-DOMAIN` after you add a custom domain |
| `POSTGRES_*`, `REDIS_*` | both | references to the Postgres and Redis services |
| `PORT` | Automatisch | `3000` |
| `WORKER` | Automatisch Worker | `true` |

Optional: to send emails (password resets, invitations), add `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASSWORD`, `SMTP_SECURE` and `FROM_EMAIL` to the **Automatisch Worker** service, because the worker sends them.

## Updates

This template builds from this repository. When we bump the pinned Automatisch version on `main`, Railway shows everyone who deployed the template an "update available" notice. You choose when to apply it. Read [CHANGELOG.md](CHANGELOG.md) first: breaking changes are listed at the top of each entry. Migrations run automatically when the web service starts.

## Local test

```sh
docker build -t automatisch-railway .
```

Run it with a Postgres and a Redis and the variables above. Run the image a second time with `WORKER=true` for the worker.

## License

The wrapper files in this repo are MIT. Automatisch itself is AGPL-3.0, with enterprise features under its own license. See the [upstream repository](https://github.com/automatisch/automatisch).

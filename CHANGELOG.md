# Changelog

Each entry lists breaking changes first. Read it before you apply an update from Railway.

## 0.15.0 (2026-11-18)

First release of the template.

- Automatisch 0.15.0, from `automatischio/automatisch:0.15.0@sha256:3bace7a12d5fb3f5b1305a6a52232270e0e0abd8465a8b78baacb07f6ea89594`.
- Web and worker services built from this repo, with Railway Postgres and Redis on volumes.
- The first admin comes from `ADMIN_EMAIL` / `ADMIN_PASSWORD`. Upstream's default `user@automatisch.io` / `sample` login is never created.
- ioredis may use IPv6, as Railway's private network needs.

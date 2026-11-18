# Changelog

Each entry lists breaking changes first. Railway shows deployers an update when `main` changes.

## 18.24.8 (2026-11-18)

- First release of this template: Atuin 18.24.8 (`ghcr.io/atuinsh/atuin:18.24.8@sha256:2bc3a558b236283cd64ce64cf9aa463c24e34f97fc36a4b1a5b2b1853a5dcb49`) with Railway's Postgres.
- Wrapper: listens on Railway's `PORT`, keeps registration closed, creates the first account from `ADMIN_USERNAME` and a generated `ADMIN_PASSWORD`, waits for Postgres.
- README: Deploy on Railway button (template `atuin-1`).

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/atuin-1?utm_medium=integration&utm_source=button&utm_campaign=atuin)

# Atuin sync server on Railway

A Railway template for the [Atuin](https://github.com/atuinsh/atuin) sync server (MIT). Atuin keeps your shell history (bash, zsh, fish, nushell) in a searchable local database and syncs it, end-to-end encrypted, between your machines. This template runs your own sync server, so the encrypted history lives in your own Railway project.

**Version:** Atuin **18.24.8**, from the official `ghcr.io/atuinsh/atuin` image, pinned by version and digest in the [`Dockerfile`](Dockerfile).

## What it deploys

| Service | Source | Public | Storage |
|---|---|---|---|
| Atuin | this repo (`Dockerfile`: `FROM ghcr.io/atuinsh/atuin:18.24.8@sha256:2bc3a558…`) | yes, health check `/healthz` | everything in Postgres |
| Postgres | Railway's Postgres | no (private network) | volume at `/var/lib/postgresql/data` |

What the small wrapper ([`start.sh`](start.sh)) adds to the official image:

- **Listens on Railway's `PORT`** on `::`, so Railway's health check, the public domain and the private network all reach it.
- **Registration is closed.** Nobody can sign up on your public URL. Instead, the wrapper creates one account on first boot with `atuin-server admin user create`, using `ADMIN_USERNAME` and the generated `ADMIN_PASSWORD`. Later boots leave that account alone.
- **Start order.** Railway starts services in any order, so it retries until Postgres accepts connections. The schema migrations run on start.

## Variables

| Variable | Default | Notes |
|---|---|---|
| `ADMIN_USERNAME` | `atuin` | The account created on first boot. Letters, digits and hyphens. |
| `ADMIN_PASSWORD` | `${{secret(32)}}` | Its password, generated per deployment. Read it in the Atuin service's **Variables** tab. |
| `ATUIN_DB_URI` | `${{Postgres.DATABASE_URL}}` | Private network. |
| `PORT` | `8888` | |

Optional, add them to the Atuin service:

- `ATUIN_OPEN_REGISTRATION=true` lets anyone who knows the URL create an account. Leave it off unless you want to share the server; you can also add accounts by hand (below).
- `ADMIN_EMAIL` sets the first account's email (default `ADMIN_USERNAME@` the Railway domain). Atuin doesn't send email.
- Other `ATUIN_*` server settings from upstream's [server setup](https://docs.atuin.sh/self-hosting/server-setup/), for example `ATUIN_PATH` or `ATUIN_MAX_RECORD_SIZE`.

## After deploying

1. Wait until both services are green. Opening the Atuin domain in a browser shows a short JSON greeting with the server version.
2. On each machine, install the client and point it at your server, in `~/.config/atuin/config.toml`:
   ```toml
   sync_address = "https://YOUR-DOMAIN"
   ```
3. Log in with the username and password from the Atuin service's Variables tab: `atuin login -u atuin`. On your first machine leave the key prompt empty and Atuin makes one; on the others, paste the output of `atuin key` from the first. Keep that key in a password manager: the server only stores encrypted history and can't recover it.
4. `atuin import auto` and `atuin sync`.

More accounts, password changes and deletions: open a shell on the Atuin service (`railway ssh`) and run `atuin-server admin user create NAME --email EMAIL`, `atuin-server admin user set-password NAME` or `atuin-server admin user delete NAME`. Changing `ADMIN_PASSWORD` after the first boot doesn't change the account's password.

## Updates

Railway tells everyone who deployed this template when `main` of this repo changes, and you choose when to apply the update. Each change is listed in [CHANGELOG.md](CHANGELOG.md), breaking changes first. Atuin runs its database migrations on start. Back up the Postgres volume before a major upgrade and read the [release notes](https://github.com/atuinsh/atuin/releases).

Maintainers: bump the `FROM` pin (version and digest together) and add a `CHANGELOG.md` entry.

## Licence

This wrapper is MIT-licensed. Atuin is MIT-licensed by its authors.

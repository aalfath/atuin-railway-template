#!/bin/sh
# Start wrapper for the Atuin sync server on Railway.
set -eu

log() { printf '[atuin-railway] %s\n' "$*"; }

SERVER=/usr/local/bin/atuin-server

# Listen on Railway's PORT. "::" is dual-stack, so it answers Railway's health
# check (IPv4) and the private network (IPv6).
export ATUIN_HOST="${ATUIN_HOST:-::}"
export ATUIN_PORT="${PORT:-${ATUIN_PORT:-8888}}"
# Closed unless the deployer adds ATUIN_OPEN_REGISTRATION=true.
export ATUIN_OPEN_REGISTRATION="${ATUIN_OPEN_REGISTRATION:-false}"
export RUST_LOG="${RUST_LOG:-info,atuin_server=info}"

if [ -z "${ATUIN_DB_URI:-}" ]; then
  log "ATUIN_DB_URI is not set; point it at your database (the template uses \${{Postgres.DATABASE_URL}})."
  exit 1
fi

# The first account. Consumed here and never passed to the server process.
user="${ADMIN_USERNAME:-}"
pass="${ADMIN_PASSWORD:-}"
email="${ADMIN_EMAIL:-}"
unset ADMIN_USERNAME ADMIN_PASSWORD ADMIN_EMAIL
[ -n "$email" ] || email="${user}@${RAILWAY_PUBLIC_DOMAIN:-localhost}"

if [ -n "$user" ] && [ -n "$pass" ]; then
  # Railway starts services in any order, so the database may still be booting
  # on the first deploy. The admin command also runs the schema migrations.
  i=0
  while :; do
    i=$((i + 1))
    if out=$(printf '%s\n' "$pass" | "$SERVER" admin user create "$user" --email "$email" 2>&1); then
      log "created account '$user'"
      break
    fi
    case "$out" in
      *duplicate*|*already*|*UNIQUE*|*unique*)
        log "account '$user' already exists; leaving its password unchanged"
        break ;;
      *"not a valid username"*)
        log "ADMIN_USERNAME '$user' is not valid: use only letters, digits and hyphens (-)"
        exit 1 ;;
    esac
    if [ "$i" -ge 60 ]; then
      log "could not create account '$user' after $i tries:"
      printf '%s\n' "$out" | tail -n 5
      exit 1
    fi
    [ "$i" -eq 1 ] && log "waiting for the database: $(printf '%s\n' "$out" | grep -m1 '^ *0:' | sed 's/^ *0: *//')"
    sleep 3
  done
else
  log "ADMIN_USERNAME or ADMIN_PASSWORD is empty; not creating an account"
fi
unset pass

exec "$SERVER" start

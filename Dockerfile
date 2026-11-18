# Atuin sync server for Railway.
# Official image, pinned by version and multi-arch digest. To update: bump both,
# add a CHANGELOG.md entry, and merge to main (deployers get an update notice).
FROM ghcr.io/atuinsh/atuin:18.24.8@sha256:2bc3a558b236283cd64ce64cf9aa463c24e34f97fc36a4b1a5b2b1853a5dcb49

# Small start wrapper: binds to Railway's PORT, keeps registration closed by
# default, and creates the first account with `atuin-server admin user create`.
COPY start.sh /usr/local/bin/atuin-railway-start

ENTRYPOINT ["/usr/local/bin/atuin-railway-start"]

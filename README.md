# dotsmith

Opinionated dotfiles bootstrap aligned to Ansible roles, with pluggable secrets (env → file → Vault → SOPS) and **no 1Password**.

## Quick start
```bash
# Plan
./scripts/dotsmith --check -i inventories/local/hosts.ini

# Apply
./scripts/dotsmith -i inventories/local/hosts.ini
```

## Secrets
Provide `GIT_USER_NAME` and `GIT_USER_EMAIL` via env, `~/.config/dotfiles/secrets.yml`, or `secrets/vault.yml` (Ansible Vault).

## GitHub Bootstrap
```bash
DF_REPO=github.com/GertGerber/dotsmith DF_REF=main bash -c '$(curl -fsSL https://raw.githubusercontent.com/GertGerber/dotsmith/main/scripts/dotsmith)' init
```

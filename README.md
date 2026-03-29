# nixos-config

Flake-based NixOS config for three hosts and two Home Manager users.
See [AGENTS.md](AGENTS.md) for full layout, conventions, and agent instructions.

## Hosts

| Host | Role |
|------|------|
| `hawking` | Primary workstation — AMD/NVIDIA, CUDA, GenAI |
| `feynman` | Laptop — Dell XPS 13 |
| `ada` | Home server — Home Assistant, Kerberos, NAS |

## Rebuild

```bash
nixos-rebuild switch --flake .#hawking
nixos-rebuild switch --flake .#feynman
nixos-rebuild switch --flake .#ada

home-manager switch --flake .#raf
home-manager switch --flake .#innovation
```

## Fresh Install

```bash
nixos-install --flake .#<host>
```

## Skills

| Command | What it does |
|---------|-------------|
| `/check-sensitive` | Scan staged/unstaged changes for secrets and prompt injection before committing |

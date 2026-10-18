# nixos-config

Flake-based NixOS config for three hosts and two Home Manager users.
See [AGENTS.md](AGENTS.md) for full layout, conventions, and agent instructions.

## Hosts

| Host | Role | Desktop capabilities enabled |
|------|------|------------------------------|
| `hawking` | Primary workstation — AMD/NVIDIA, CUDA, GenAI | desktop-base, audio, plasma-gnome, tiling, minecraft |
| `curie` | Apple Silicon laptop (Asahi, aarch64) | desktop-base, audio, plasma-gnome, tiling, minecraft |
| `feynman` | Laptop — Dell XPS 13 (also hosts ada's Home Assistant, Kerberos, NAS) | desktop-base, audio, tiling (SDDM logs in to niri) |
| `ada` | **Deprecated** home server — services moved to feynman | none (headless) |

NixOS hosts import and enable each `services.x-*` capability explicitly in their host file.

## Home Manager roles

The role (`full-desktop` | `tiling` | `server`) exists only in Home Manager, set per
config in `home-manager/default.nix`. It is not tied to a machine; any machine can
switch to any config.

| Config | Role |
|--------|------|
| `raf`, `raf@curie.linux`, `raf@curie.mac` | `full-desktop` |
| `raf@feynman` | `tiling` (no IntelliJ, GIMP, Slack) |
| `raf@ada` | `server` (CLI only) |

## Rebuild

```bash
nixos-rebuild switch --flake .#hawking
nixos-rebuild switch --flake .#feynman
nixos-rebuild switch --flake .#ada

home-manager switch --flake .#raf
home-manager switch --flake .#raf@feynman   # tiling
home-manager switch --flake .#raf@ada       # server
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

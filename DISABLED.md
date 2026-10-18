# DISABLED.md: things switched off because of unstable / broken upstream

Why this file exists: when `nixos-unstable` breaks something we switch it off, then forget.
This is the list, so we can re-test and turn things back on.

Rules
- Add a row the same day you disable something. Say WHY and HOW to re-test.
- Keep the commented-out line in the config (do not delete it). Put `# DISABLED: see DISABLED.md` next to it.
- Re-test after each `nix flake update`. When it works, move the row to "Re-enabled".

Scraped from `git log` on 2026-10-18. Status was checked against the current tree.

## Still disabled

| Since      | Thing                              | Where                                          | Why                                              | Commit    |
|------------|------------------------------------|------------------------------------------------|--------------------------------------------------|-----------|
| 2026-10-18 | sidequest                        | hardware-configuration/hawking.nix:193                     | CVE on unstable ("temporary")          | afc14e1   |
| 2026-10-04 | gqrx, sdrpp                        | capabilities/x-rtl-sdr.nix                     | issues on unstable ("temporary")                 | 169e009   |
| 2026-05-02 | gnuradio                           | capabilities/x-rtl-sdr.nix                     | broke on upgrade                                 | fb8408f   |
| 2026-02-10 | dump1090-fa                        | capabilities/x-rtl-sdr.nix                     | broken in unstable                               | b2c93b1   |
| 2026-03-22 | documentation.doc                  | configuration.nix:10                           | pydoc issues in unstable (FIXME: reenable)       | e091575   |
| 2025-08-31 | python virtualenv (3.10, 3.11)     | configuration.nix:215                          | asyncio issues in unstable                       | 2898aaa   |
| 2025-08-31 | programs.ssh.startAgent            | configuration.nix:65                           | disabled, reason not recorded                    | c72913c   |
| 2024-12-01 | x-android-dev on feynman           | hardware-configuration/feynman.nix:79          | Android Studio broke on 24.11 (hawking has it on)| 7e57ddc   |
| 2023-07-21 | gnome-keyring                      | capabilities/x-tiling-environments.nix:13           | conflicts with Hyprland launcher (hyprwm #1376)  | 14db231   |
| 2026-07-13 | fzf nushell integration            | home-manager/home.nix:162                      | disabled, reason not recorded                    | 563176b   |

## Pending (decided, not applied yet)

| Date       | Thing                                        | Where                                  | Why                                                                                   |
|------------|----------------------------------------------|----------------------------------------|---------------------------------------------------------------------------------------|
| (none) | | | |

## Workarounds in place (not disabled, but fragile)

| Since      | Thing                              | Why                                                   | Commit  |
|------------|------------------------------------|-------------------------------------------------------|---------|
| 2026-10-18 | displaylink src overlay (curie) | x-displaylink.nix pins the driver zip URL + hash. nixpkgs moved to 6.3.0-48 and the old 6.2 zip broke the build; overlay now fetches the 6.3 zip. Re-enabled on curie 2026-10-18. After each `nix flake update`, compare URL + hash with nixpkgs pkgs/os-specific/linux/displaylink/default.nix, then build curie. | uncommitted |
| 2026-04-25 | VS Code settings.json out-of-store symlink | home-manager workaround                        | 38f36a3 |
| 2026-03-22 | "Unstable Fixes" block, configuration.nix | collected March 2026 unstable workarounds       | e091575 |
| 2026-02-10 | android-tools via package (not programs.adb) | android tooling changed in unstable          | 8d1ee1c |
| 2026-08-01 | waybar declarative config under niri | waybar was dead with hyprland-only config          | ca0a15f |
| any        | `nixpkgs.config.allowBroken = true` | on ada.nix and feynman.nix: hides broken packages     | n/a     |

## Re-enabled since (history)

| Thing                    | Was disabled        | Now                                     |
|--------------------------|---------------------|-----------------------------------------|
| x-rtl-sdr on feynman     | 2025-10-26 (51fe595) | back on in feynman.nix (2026-10-18)    |
| intel-compute-runtime-legacy1 (feynman) | 2026-10-18, GCC 16 build failure | flake update 0c1b0ac. The current lock's output is on cache.nixos.org and in feynman's store, so it is fetched, not built. feynman builds without the stub (confirmed 2026-10-19), so the stub overlay was dropped before pushing. |
| gpredict                 | 2025-08-31 (ffc4352) | back on in x-rtl-sdr.nix               |
| carla                    | 2025-08-31 (c2b74d8) | back on in x-musician.nix              |
| fronius (home-assistant) | 2025-04-27 (972bf57) | back on in x-home-assistant.nix        |
| dotnet-sdk_7             | 2025-04-21 (a3ff9b4) | no longer in the tree                  |
| opengl driSupport        | 2024-12-01 (d58dd62) | no longer in the tree (deprecated option) |
| ollama source override   | 2024-08-03 (df88978) | no longer in the tree                  |

## Other history (not instability)

Removals and pins that were choices, not breakage: pet projects removed (9609664), GPU/audio sink pins
(b7a6f24), wivrn on ARM with x86 features off (ac7e3af), nvidia branch choice (5f18a54).

## GitHub issues checked (2026-10-18)

Searched NixOS/nixpkgs, intel/compute-runtime, hyprwm/Hyprland. A closed issue does NOT prove the fix is in
our pinned nixpkgs. Re-test by building. "No issue found" means the search found nothing, not that none exists.

| Thing                         | Finding                                                                                             |
|-------------------------------|-----------------------------------------------------------------------------------------------------|
| intel-compute-runtime-legacy1 | Same bug class as intel/compute-runtime #908 "FTBFS with gcc 16" (CLOSED 2026-04-13). Intel posted a patch to `opencl/source/mem_obj/image.h` and fixed it in the CURRENT release line (26.x). legacy1 24.35 is a frozen branch, so an upstream fix there is unlikely. No nixpkgs issue found. Options: carry a small nixpkgs patch, or drop the package on feynman. |
| dump1090-fa                   | nixpkgs #488592 "Build failure" CLOSED 2026-02-09. We disabled it 2026-02-10. Worth a re-test now.   |
| gqrx                          | nixpkgs #425469 "Build failure" CLOSED 2025-07-15 (older than our 2026-10-04 disable, so probably a different problem). No open issue found. Re-test. |
| sdrpp                         | nixpkgs #340299 OPEN "does not start under Wayland". #450446 (cmake) and #467610 (core dump) CLOSED. Our disable may be the Wayland issue. |
| gnuradio                      | No open build-failure issue found. Re-test.                                                          |
| virtualenv asyncio            | No issue found. Re-test.                                                                             |
| documentation.doc (pydoc)     | No issue found. Re-test.                                                                             |
| carla / pyliblo3              | No issue found (carla is already back on).                                                           |
| gnome-keyring + Hyprland      | hyprwm/Hyprland #1376 CLOSED 2023-01-15. The conflict note is 3 years old. Worth re-testing.        |
| XPS 13 9370 (nixos-hardware)  | Open issues exist (#96 i915 flags, #133 throttling) but none about the compute-runtime build.        |

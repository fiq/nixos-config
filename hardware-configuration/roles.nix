{ lib, config, ... }:
with lib;
let
  role = config.host.role;
  full = role == "full-desktop";
  tiling = role == "tiling";
in {
  # A host picks its desktop weight here, in one line: host.role = "...".
  # The heavy desktop capabilities are imported once, here, so host files
  # do not import them. Each enable is a mkDefault, so a host can still
  # override one (e.g. services.x-minecraft.enable = false).
  # Desktop-only bits of the shared base (X, SDDM, audio, GUI apps) are
  # gated on the role in configuration.nix.
  imports = [
    ./capabilities/x-minecraft.nix
    ./capabilities/x-plasma-gnome.nix
    ./capabilities/x-tiling-desktop.nix
  ];

  options.host.role = mkOption {
    type = types.enum [ "full-desktop" "tiling" "server" ];
    default = "full-desktop";
    description = ''
      How much desktop this host gets.
      full-desktop: GNOME + Plasma + tiling (niri/sway/hyprland) + Minecraft launchers.
      tiling: tiling only (niri/sway/hyprland), SDDM logs in to niri.
      server: headless; no X, no display manager, no desktop GUI apps.
    '';
  };

  config = {
    services.x-plasma-gnome.enable = mkDefault full;
    services.x-minecraft.enable = mkDefault full;
    services.x-tiling-desktop.enable = mkDefault (full || tiling);

    # No Plasma/GNOME here; log in straight to niri
    services.displayManager.defaultSession = mkIf tiling (mkDefault "niri");
  };
}

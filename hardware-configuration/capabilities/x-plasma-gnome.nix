{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-plasma-gnome;
in {
  options.services.x-plasma-gnome = {
    enable = mkEnableOption "full GNOME and KDE Plasma desktops (heavy; leave off headless/tiling-only hosts)";
  };

  config = mkIf cfg.enable {
    # SDDM itself lives in x-desktop-base (it is the login screen for niri/sway too).
    services.desktopManager.gnome.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.displayManager.defaultSession = "plasma";
    programs.ssh.askPassword = lib.mkForce "${pkgs.kdePackages.ksshaskpass.out}/bin/ksshaskpass";
  };
}

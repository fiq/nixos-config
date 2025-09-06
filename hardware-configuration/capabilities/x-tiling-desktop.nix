{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-tiling-desktop;
in {
  # TODO: note to self - refactored in sept - remember to consolidate other configs
  options.services.x-tiling-desktop = {
    enable = mkEnableOption "custom tiling desktops setup";
  };
  
  config = mkIf cfg.enable {
    # Gnome-Keyring is interfering with hyprland process launcher
    # See https://github.com/hyprwm/Hyprland/issues/1376
    services.gnome.gnome-keyring.enable = lib.mkForce false;
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };


    # Tiling managers
    # Sway
    programs.sway.enable = true;
    # Niri
    programs.niri.enable = true;


    programs.waybar = {
      enable = true;
    };

    # only start waybar on hyprland
    systemd.user.services = {
      waybar = {
        unitConfig.PartOf = lib.mkForce "hyprland-session.target";
        wantedBy = lib.mkForce [ "hyprland-session.target" ];
      };

      swww-daemon = {
        description = "SWWW Daemon for Niri and Hyprland";
        enable = true;
        wantedBy = [ "graphical-session.target" "niri-session.target" "hyprland-session.target" "sway-session.target" ];
        after = [ "graphical-session.target" "niri-session.target" "hyprland-session.target" "sway-session.target" ];

        # only start for wayland
        unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.swww}/bin/swww-daemon";
          Restart = "on-failure";
        };
      };
    };


    environment.systemPackages = with pkgs; [
      rofi-bluetooth
      swaybg
      swww
      wofi
      xdg-desktop-portal-hyprland
    ];
  };
}

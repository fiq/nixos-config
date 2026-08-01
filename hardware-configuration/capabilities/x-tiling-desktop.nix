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

    # Declarative bar config. /etc/xdg is ahead of /run/current-system/sw/etc/xdg
    # in XDG_CONFIG_DIRS, so this overrides the sway-oriented config.jsonc shipped
    # by the waybar package. A stale ~/.config/waybar/ still shadows both.
    environment.etc = {
      "xdg/waybar/config.jsonc".source = ./waybar/config.jsonc;
      "xdg/waybar/style.css".source = "${pkgs.waybar}/etc/xdg/waybar/style.css";
    };

    systemd.user.services = {
      # waybar.service upstream is already PartOf/WantedBy graphical-session.target,
      # which niri, sway and hyprland all bind to — it does not need a target
      # override, and pinning it to hyprland-session.target left it dead under niri.
      waybar = {
        wantedBy = [ "graphical-session.target" ];
      };

      awww-daemon = {
        description = "AWWW Daemon for Niri and Hyprland";
        enable = true;
        wantedBy = [ "graphical-session.target" "niri-session.target" "hyprland-session.target" "sway-session.target" ];
        after = [ "graphical-session.target" "niri-session.target" "hyprland-session.target" "sway-session.target" ];

        # only start for wayland
        unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.awww}/bin/awww-daemon";
          Restart = "on-failure";
        };
      };
    };

    environment.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "0";
    };


    environment.systemPackages = with pkgs; [
      libdisplay-info
      rofi-bluetooth
      swaybg
      awww
      wofi
      xdg-desktop-portal-hyprland
    ];
  };
}

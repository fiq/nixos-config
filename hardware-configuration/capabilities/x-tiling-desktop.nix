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


    # ironbar reads a single config file pointed at by IRONBAR_CONFIG and looks
    # for style.css alongside it, so both live in /etc/xdg/ironbar.
    environment.etc = {
      "xdg/ironbar/config.json".source = ./ironbar/config.json;
      "xdg/ironbar/style.css".source = ./ironbar/style.css;
    };

    systemd.user.services = {
      # ironbar ships no unit of its own. graphical-session.target is what niri,
      # sway and hyprland all bind to, so it is the correct anchor for all three.
      #
      # MemoryMax is a backstop, not a fix: on 2026-08-01 the previous bar
      # (waybar) leaked 18.7G of wl_shm buffers over 32h because an nvidia
      # userspace/module mismatch broke EGL and pushed GTK onto the software
      # renderer. ironbar is GTK too and would leak the same way. Capped, the
      # cgroup OOM killer takes the bar alone instead of the whole session.
      ironbar = {
        description = "ironbar status bar";
        documentation = [ "https://github.com/JakeStanger/ironbar" ];
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];

        # Don't try to start under a non-wayland session (plasma/x11).
        unitConfig = {
          ConditionEnvironment = "WAYLAND_DISPLAY";
          StartLimitIntervalSec = 300;
          StartLimitBurst = 5;
        };

        environment = {
          IRONBAR_CONFIG = "/etc/xdg/ironbar/config.json";
          IRONBAR_CSS = "/etc/xdg/ironbar/style.css";
        };

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.ironbar}/bin/ironbar";
          Restart = "on-failure";
          RestartSec = 5;
          MemoryHigh = "512M";
          MemoryMax = "1G";
        };
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

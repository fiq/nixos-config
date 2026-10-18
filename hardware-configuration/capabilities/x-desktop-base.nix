{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-desktop-base;
in {
  # The shared desktop layer: X, graphics, SDDM login screen, GUI apps,
  # scanner, OpenRGB, dictionary. Sessions come from x-tiling-environments
  # (niri/sway/hyprland) and x-desktop-environments (GNOME, Plasma).
  # Headless hosts (ada) leave this off.
  options.services.x-desktop-base = {
    enable = mkEnableOption "shared desktop base (X, SDDM, GUI apps, scanner, OpenRGB, dictd)";
  };

  config = mkIf cfg.enable {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    hardware.graphics.enable = true;

    # Login screen, started in Wayland
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    programs.dconf.enable = true;

    # SANE - Scanner
    hardware.sane = {
      enable = true;
      brscan4.netDevices.home = {
        model = "MFC-7350N";
        ip = "192.168.50.251";
      };
    };
    users.users.raf.extraGroups = [ "scanner" ];

    # OpenRGB (motherboard type is set in configuration.nix)
    services.hardware.openrgb.enable = true;

    # dictionary
    services.dictd.enable = true;

    # Required for vscode (home manager managed) wayland issues
    # See: https://github.com/NixOS/nixpkgs/issues/241337
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    environment.systemPackages = with pkgs; [
      appimage-run
      audacity
      firefox
      fuzzel
      google-chrome
      grim
      kitty
      keepassxc
      pavucontrol
      portaudio
      slurp
      vlc
      wireshark
      wl-clipboard
      xdg-desktop-portal
      xdg-desktop-portal-wlr
    ];

    # Enable AppImage exec via appimage-run
    boot.binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };
  };
}

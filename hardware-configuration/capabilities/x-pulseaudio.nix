{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-pulseaudio;
in {
  options.services.x-pulseaudio = {
    enable = mkEnableOption "custom pulseaudio bundle";
  };

  config = mkIf cfg.enable {
    # I use android on both hawking and feynman but may not do on other boxes
    services.udev.packages = [
      pkgs.android-udev-rules
    ];
    environment.systemPackages = with pkgs; [
      pavucontrol
    ];

    hardware.enableAllFirmware = true;
    nixpkgs.config.pulseaudio = true;
    services.pulseaudio.enable = true;
  };
}

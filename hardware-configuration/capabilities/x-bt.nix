{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-bt;
in {
  options.services.x-bt = {
    enable = mkEnableOption "custom bluetooth setup";
  };
  
  config = mkIf cfg.enable {
    services.blueman.enable = true;
    services.pipewire.pulse.enable = true;
    hardware.bluetooth.enable = true;

    environment.systemPackages = with pkgs; [
      bluez
      bluez-tools
      rofi-bluetooth
      wireshark
    ];
  };
}

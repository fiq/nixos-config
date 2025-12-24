{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-android-dev;
in {
  options.services.x-android-dev = {
    enable = mkEnableOption "custom android dev setup";
  };
  
  config = mkIf cfg.enable {
    # I use android on both hawking and feynman but may not do on other boxes
    programs.adb.enable = true;
    services.udev.packages = [
    ];

    # TODO - Rescope
    services.udev.extraRules = ''
      SUBSYSTEM=="usb", TAG+="uaccess"
    '';
    environment.systemPackages = with pkgs; [
      godot_4
      android-studio
    ];
  };
}

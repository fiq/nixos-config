{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-yubi;
in {
  options.services.x-yubi = {
    enable = mkEnableOption "custom yubi setup";
  };
  
  config = mkIf cfg.enable {
    hardware.gpgSmartcards.enable = true;
    services.udev.packages = [ pkgs.yubikey-personalization ];
    services.pcscd.enable = true;

    environment.systemPackages = with pkgs; [
      yubikey-manager
      yubico-piv-tool
      yubikey-personalization 
    ];
  };
}

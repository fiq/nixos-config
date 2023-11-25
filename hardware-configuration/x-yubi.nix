{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-yubi;
in {
  options.services.x-yubi = {
    enable = mkEnableOption "custom yubi setup";
  };
  
  config = mkIf cfg.enable {
    hardware.gpgSmartcards.enable = true;
    services.udev.packages = [ pkgts.yubikey-personalization ];
    services.pcscd.enable = false;

    environment.systemPackages = with pkgs; [
      yubikey-manager
      yubico-piv-tool
      yubikey-personalization 
    ];
  };
}

{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-mt7921-rz608;
in {
  options.services.x-mt7921-rz608 = {
    enable = mkEnableOption "custom";
  };
  
  config = mkIf cfg.enable {
    # setup udev rules
    services.udev.extraValues = ''
      SUBSYSTEM=="drivers", DEVPATH=="/bus/pci/drivers/mt7921e", ATTR{new_id}="14c3 0608"
    '';
    

    hardware.rtl-sdr.enable = true;
    environment.systemPackages = with pkgs; [
      rtl-sdr
      gqrx
    ];
  };
}

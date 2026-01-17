{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-rtl-sdr;
in {
  options.services.x-rtl-sdr = {
    enable = mkEnableOption "custom rtl sdr setup";
  };
  
  config = mkIf cfg.enable {
    # I use RTL-SDR on both hawking and feynman but may not do on other boxes
    hardware.rtl-sdr.enable = true;
    environment.systemPackages = with pkgs; [
      dump1090-fa 
      gqrx
      gpredict
      gnuradio
      kstars
      noaa-apt
      readsb
      rtl-sdr
      satdump
      sdrpp
    ];
  };
}

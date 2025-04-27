{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-printing;
in {
  options.services.x-printing = {
    enable = mkEnableOption "custom printing setup";
  };

  config = mkIf cfg.enable {
    services.printing = {
       enable = true;
       drivers = [ pkgs.brlaser ];
    };
  };
}

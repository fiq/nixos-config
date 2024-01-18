{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-midi;
in {
  options.services.x-midi = {
    enable = mkEnableOption "custom midi setup";
  };
  
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      rosegarden
    ];
  };
}

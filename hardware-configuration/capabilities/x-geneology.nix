{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-geneology;
in {
  options.services.x-geneology = {
    enable = mkEnableOption "custom home-assistant setup";
  };
  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      gramps
    ];
  };
}

{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-authoring;
in {
  options.services.x-authoring = {
    enable = mkEnableOption "custom authoring and writing setup";
  };
  
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ispell
      libreoffice-qt
      mdp
      texmacs 
      texinfo
      texliveSmall  # was texliveFull (6.3G); add packages via texliveSmall.withPackages if needed
    ];
  };
}

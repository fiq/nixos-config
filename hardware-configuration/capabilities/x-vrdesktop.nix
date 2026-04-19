{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-vrdesktop;
in {
  options.services.x-vrdesktop = {
    enable = mkEnableOption "custom vr desktop setup";
  };
 
  config = mkIf cfg.enable {
    services.wivrn = {
      enable = true;
      openFirewall = true;
      autoStart = true;
      package = (pkgs.wivrn.override { cudaSupport = true; });
    };
    environment.systemPackages = with pkgs; [
      wayvr
    ];
  };
}

{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-network-storage;
in {
  options.services.x-network-storage = {
    enable = mkEnableOption "custom network storage setup";
    media_dir = mkOption {
      type = types.str;
      default = "/home/minidlna";
    };
  };
 
  config = mkIf cfg.enable {
    services.minidlna = {
       enable = true;
       settings.media_dir = [ cfg.media_dir ];
    };
    services.samba = {
       enable = true;
       settings = {
         global = {
           security = "user";           
         };
 
         public = {
           public = "yes";
           path = cfg.media_dir;
           "read only" = "yes";
           browseable = "yes";  
         };
         homes = {
           browseable = "no";
         };
       };
     };
  };
}

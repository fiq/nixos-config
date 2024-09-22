{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-btrfs;
in {
  options.services.x-btrfs = {
    enable = mkEnableOption "custom btrfs setup";
  };
  
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      btrfs-progs
      btrfs-heatmap
      btrfs-assistant
    ];
  };
}

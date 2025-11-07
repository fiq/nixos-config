{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services;
in {
  options.services.x-video = {
    enable = mkEnableOption "custom video setup";
  };

  config = mkIf cfg.x-video.enable {
    programs.droidcam.enable = true;
    programs.obs-studio.enableVirtualCamera = true;
    boot = {
      kernelModules = [ "v4l2loopback" ];
      extraModulePackages = with config.boot.kernelPackages; [
        v4l2loopback
      ];
      extraModprobeConfig = ''
        options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
      '';
    };
    environment.systemPackages = with pkgs; [
       
      davinci-resolve
      ffmpeg
      obs-studio
      scrcpy
      v4l-utils
    ];
  };

}

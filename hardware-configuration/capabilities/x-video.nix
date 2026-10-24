{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services;
in {
  options.services.x-video = {
    enable = mkEnableOption "custom video setup";
  };

  config = mkIf cfg.x-video.enable {
    # kbuild's modules_install runs depmod and leaves modules.* index files in
    # v4l2loopback's $out, which collide with the kernel's own in the modules
    # buildEnv. Patched in the package set so obs-studio/droidcam pick it up too.
    # Fixed upstream in NixOS/nixpkgs#575861; drop once it reaches nixos-unstable.
    nixpkgs.overlays = [
      (final: prev: {
        linuxPackages = prev.linuxPackages.extend (lpFinal: lpPrev: {
          v4l2loopback = lpPrev.v4l2loopback.overrideAttrs (old: {
            postInstall = (old.postInstall or "") + ''
              rm -f $out/lib/modules/*/modules.*
            '';
          });
        });
      })
    ];
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
      cameractrls
      davinci-resolve
      ffmpeg
      guvcview
      obs-studio
      scrcpy
      v4l-utils
    ];
  };

}

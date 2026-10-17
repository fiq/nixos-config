{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-displaylink;
in {
  options.services.x-displaylink = {
    enable = mkEnableOption "DisplayLink dock support (evdi + DisplayLinkManager)";
  };

  # The nixpkgs displaylink module keys off videoDrivers: it loads evdi, installs
  # the udev rules and runs DisplayLinkManager (dlm.service) which starts when a
  # dock is plugged in. Wayland compositors see the dock as an extra DRM card.
  #
  # nixpkgs gates the driver zip behind requireFile (manual download). The URL is
  # public and the hash is the one nixpkgs expects, so fetch it directly instead.
  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: prev: {
        displaylink = prev.displaylink.overrideAttrs (_: {
          src = final.fetchurl {
            name = "displaylink-620.zip";
            url = "https://www.synaptics.com/sites/default/files/exe_files/2025-09/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.2-EXE.zip";
            hash = "sha256-JQO7eEz4pdoPkhcn9tIuy5R4KyfsCniuw6eXw/rLaYE=";
          };
        });
      })
    ];
    services.xserver.videoDrivers = [ "displaylink" "modesetting" ];
  };
}

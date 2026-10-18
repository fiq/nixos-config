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
  # When nixpkgs bumps displaylink, update url + hash to match its requireFile
  # (the old 6.2 zip broke the build after nixpkgs moved to 6.3.0-48, 2026-10-18).
  # Old 6.2 values, kept for reference:
  #   name = "displaylink-620.zip";
  #   url = ".../exe_files/2025-09/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.2-EXE.zip";
  #   hash = "sha256-JQO7eEz4pdoPkhcn9tIuy5R4KyfsCniuw6eXw/rLaYE=";
  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: prev: {
        displaylink = prev.displaylink.overrideAttrs (_: {
          src = final.fetchurl {
            name = "displaylink-630.zip";
            url = "https://www.synaptics.com/sites/default/files/exe_files/2026-06/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.3-EXE.zip";
            hash = "sha256-cmmFbHUnBgxRMhXOG1o2/vB02Oicq4m8qxPfNCrM4Jg=";
          };
        });
      })
    ];
    services.xserver.videoDrivers = [ "displaylink" "modesetting" ];

    # Closed root binary that sees the whole screen; it only needs USB and local
    # sockets, so cut off all IP traffic (unix sockets and netlink still work).
    systemd.services.dlm.serviceConfig.IPAddressDeny = "any";
  };
}

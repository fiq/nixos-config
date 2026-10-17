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
  # The driver zip is license-gated and must be added to the store once:
  #   nix-prefetch-url --name displaylink-620.zip file://$PWD/displaylink-620.zip
  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [ "displaylink" "modesetting" ];
  };
}

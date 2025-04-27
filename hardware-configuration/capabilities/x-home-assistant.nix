{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-home-assistant;
in {
  options.services.x-home-assistant = {
    enable = mkEnableOption "custom home-assistant setup";
  };
  
  config = mkIf cfg.enable {
    services.home-assistant = {
      enable = true;
      extraComponents = [
        # Components required to complete the onboarding
        "esphome"
        "fronius"
        "geonetnz_quakes"
        "geonetnz_volcano"
        "google"
        "google_assistant"
        "google_assistant_sdk"
        "gree"
        "met"
        "radio_browser"
      ];
      config = {
        # https://www.home-assistant.io/integrations/default_config/
        default_config = {
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 8123 ]; 

# if the nix way fails, I'll containerise:
#  virtualisation.oci-containers = {
#    backend = "podman";
#    containers.homeassistant = {
#      volumes = [ "home-assistant:/config" ];
#      environment.TZ = "Europe/Berlin";
#      image = "ghcr.io/home-assistant/home-assistant:stable"; # Warning: if the tag does not change, the image will not be updated
#      extraOptions = [ 
#        "--network=host" 
#      ];
#    };
    environment.systemPackages = with pkgs; [
      home-assistant-cli
    ];
  };
}

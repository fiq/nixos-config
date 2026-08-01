{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-bt;
in {
  options.services.x-bt = {
    enable = mkEnableOption "custom bluetooth setup";

    avahiInterfaces = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "enp7s0" "wlp6s0" ];
      description = ''
        Interfaces avahi is allowed to publish on. Empty means every interface,
        which includes docker0 and the br-* container bridges; those reflect
        mDNS back at the daemon, so it decides its own name is taken and renames
        itself in a loop (hawking.local -> hawking-46.local, ad infinitum).
        Set this to the real NICs on hosts that run containers.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.blueman.enable = true;
    services.pipewire.pulse.enable = true;
    services.pipewire.wireplumber.extraConfig."10-bluez" = {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = [
          "hsp_hs"
          "hsp_ag"
          "hfp_hf"
          "hfp_ag"
        ];
      };
    };
    # avahi required for service discovery (pipewire RAOP/AirPlay)
    services.avahi.enable = true;
    services.avahi.allowInterfaces =
      if cfg.avahiInterfaces == [ ] then null else cfg.avahiInterfaces;
    services.pipewire = {
        # opens UDP ports 6001-6002
        raopOpenFirewall = true;
        extraConfig.pipewire = {
          "10-airplay" = {
          "context.modules" = [
            {
              name = "libpipewire-module-raop-discover";
      # increase the buffer size if you get dropouts/glitches
      # args = {
      #   "raop.latency.ms" = 500;
      # };
            }
          ];
        };
      };
    };
    hardware.bluetooth.enable = true;
    hardware.bluetooth.settings = {
      General = {
        Experimental = true;
      };
    };

    environment.systemPackages = with pkgs; [
      bluez
      bluez-tools
      rofi-bluetooth
      wireshark
    ];
  };
}

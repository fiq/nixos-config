{ lib, config, ... }:
with lib;
let
  cfg = config.services.x-audio;

  # Rocksmith cable: wanted for Steam and guitarix, never as a default device.
  # Matched by node name so it behaves the same on every host it is plugged into.
  rocksmith = {
    match = { "node.name" = "~alsa_(input|output)\\.usb-Hercules_Rocksmith.*"; };
    priority = 1;
  };

  nodeRule = r: {
    matches = [ r.match ];
    actions."update-props"."priority.session" = r.priority;
  };

  profileRule = name: profile: {
    matches = [ { "device.name" = name; } ];
    actions."update-props"."device.profile" = profile;
  };
in {
  options.services.x-audio = {
    enable = mkEnableOption "predictable audio defaults";

    deviceProfiles = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = { "alsa_card.pci-0000_01_00.1" = "pro-audio"; };
      description = ''
        Card profile to force, keyed by WirePlumber device.name (a leading ~
        makes it a regex). Declared here so it does not depend on whatever
        was last clicked in pavucontrol and saved to ~/.local/state.
      '';
    };

    nodePriorities = mkOption {
      type = types.listOf (types.submodule {
        options = {
          match = mkOption {
            type = types.attrsOf types.str;
            description = "WirePlumber match properties (all must match).";
          };
          priority = mkOption {
            type = types.int;
            description = "priority.session; the highest available node becomes the default.";
          };
        };
      });
      default = [ ];
      description = "Per-host default device ranking. Rocksmith is always ranked last.";
    };
  };

  config = mkIf cfg.enable {
    services.pipewire.wireplumber.extraConfig = {
      # Why each setting is here:
      #  - restore-default-targets: a saved default beats priority.session
      #    (state-default-nodes.lua), so one stale click would pin a dead port.
      #  - stream.restore-*: pavucontrol moves one app and the choice, and its
      #    volume, followed that app around. Every app follows the default.
      #  - autoswitch: a Bluetooth headset flipping to headset mode swaps mic
      #    and output mid-call.
      "10-x-audio-settings" = {
        "wireplumber.settings" = {
          "node.restore-default-targets" = false;
          "node.stream.restore-target" = false;
          "node.stream.restore-props" = false;
          "bluetooth.autoswitch-to-headset-profile" = false;
        };
      };

      "10-x-audio-rules" = {
        "monitor.alsa.rules" =
          (mapAttrsToList profileRule cfg.deviceProfiles)
          ++ map nodeRule (cfg.nodePriorities ++ [ rocksmith ]);
      };
    };
  };
}

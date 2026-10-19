{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-dlna-client;
in {
  options.services.x-dlna-client = {
    enable = mkEnableOption "DLNA/UPnP client discovery (VLC and friends)";
    servers = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Addresses of DLNA servers whose SSDP replies are accepted";
    };
  };

  config = mkIf cfg.enable {
    # A server answers an SSDP search with unicast UDP to a random client port.
    # The firewall sees that as an unsolicited packet from another host and drops
    # it, so VLC never lists the server. Accept UDP from the known servers.
    # The firewall backend differs per host: nftables hosts take extraInputRules,
    # iptables hosts ignore it and need extraCommands.
    networking.firewall = mkMerge [
      (mkIf config.networking.nftables.enable {
        extraInputRules = mkAfter (concatMapStrings (srv: ''
          ip saddr ${srv} udp accept
        '') cfg.servers);
      })
      (mkIf (!config.networking.nftables.enable) {
        extraCommands = concatMapStrings (srv: ''
          iptables -A nixos-fw -s ${srv} -p udp -j nixos-fw-accept
        '') cfg.servers;
      })
    ];
  };
}

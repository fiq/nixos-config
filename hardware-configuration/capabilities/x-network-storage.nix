{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-network-storage;
in {
  options.services.x-network-storage = {
    enable = mkEnableOption "custom network storage setup";
    media_dir = mkOption {
      type = types.str;
      default = "/home/minidlna";
    };
    lanSubnets = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Source subnets (CIDR) allowed to reach the SMB and DLNA ports";
    };
  };
 
  config = mkIf cfg.enable {
    services.minidlna = {
       enable = true;
       settings.media_dir = [ cfg.media_dir "/mnt/backups" ];
       # Watch the media folders so new files show up without a restart.
       settings.inotify = "yes";
    };
    # minidlna reuses files.db on restart and never rescans, and its inotify is
    # blind in the sandbox (/proc/sys hidden), so media copied in later is missed.
    # Drop the index on every start (it rebuilds) and restart nightly.
    systemd.services.minidlna.serviceConfig.ExecStartPre = "+${pkgs.coreutils}/bin/rm -f /var/cache/minidlna/files.db";
    systemd.services.minidlna-rescan = {
      description = "Restart minidlna so it rebuilds its media index";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${config.systemd.package}/bin/systemctl restart minidlna.service";
      };
    };
    systemd.timers.minidlna-rescan = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 04:00:00";
        Persistent = true;
      };
    };
    # SMB 445, DLNA 8200 + SSDP 1900, only from the LAN subnets. The firewall
    # backend differs per host: nftables hosts take extraInputRules, iptables
    # hosts (feynman) ignore it and need extraCommands.
    networking.firewall = mkMerge [
      (mkIf config.networking.nftables.enable {
        # mkAfter keeps these behind the host's own drop rules (e.g. the VPN interface)
        extraInputRules = mkAfter (concatMapStrings (net: ''
          ip saddr ${net} tcp dport { 445, 8200 } accept
          ip saddr ${net} udp dport 1900 accept
        '') cfg.lanSubnets);
      })
      (mkIf (!config.networking.nftables.enable) {
        extraCommands = concatMapStrings (net: ''
          iptables -A nixos-fw -s ${net} -p tcp -m multiport --dports 445,8200 -j nixos-fw-accept
          iptables -A nixos-fw -s ${net} -p udp --dport 1900 -j nixos-fw-accept
        '') cfg.lanSubnets;
      })
    ];
    services.samba = {
       enable = true;
       settings = {
         global = {
           security = "user";           
         };
 
         public = {
           public = "yes";
           path = cfg.media_dir;
           "read only" = "yes";
           browseable = "yes";
           "wide links" = "yes";
         };
         homes = {
           browseable = "no";
         };
       };
     };
  };
}

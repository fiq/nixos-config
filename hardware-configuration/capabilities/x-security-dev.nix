{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-security-dev;
in {
  options.services.x-security-dev = {
    enable = mkEnableOption "custom security dev setup";
  };
  
  config = mkIf cfg.enable {
    # I use security on both hawking and feynman but may not do on other boxes
    environment.systemPackages = with pkgs; [
      armitage
      burpsuite 
      ghidra
      iaito   
      metasploit
      nmap
      radare2 
      tcpdump
      wireshark
    ];
  };
}
